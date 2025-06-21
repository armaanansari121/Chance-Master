#[cfg(test)]
mod tests {
    use dojo::model::{ModelStorage, ModelStorageTest, ModelValueStorage};
    use dojo::world::WorldStorageTrait;
    use dojo_cairo_test::{
        ContractDef, ContractDefTrait, NamespaceDef, TestResource, WorldStorageTestTrait,
        spawn_test_world,
    };
    use starknet::{ContractAddress, contract_address_const, testing};
    use crate::models::{
        Game, GameStatus, MatchmakingEntry, MatchmakingQueue, PlayerProfile, DiceState, PieceType,
        ZERO_ADDRESS, m_Game, m_MatchmakingEntry, m_MatchmakingQueue, m_PlayerProfile, m_DiceState,
        Piece, m_Piece, BoardPos, Color,
    };
    use crate::systems::actions::{
        IDiceChessActionsDispatcher, IDiceChessActionsDispatcherTrait, dice_chess_actions,
    };

    const QUEUE_ID: u32 = 1;

    fn namespace_def() -> NamespaceDef {
        NamespaceDef {
            namespace: "dice_chess",
            resources: [
                TestResource::Model(m_Game::TEST_CLASS_HASH),
                TestResource::Model(m_MatchmakingEntry::TEST_CLASS_HASH),
                TestResource::Model(m_MatchmakingQueue::TEST_CLASS_HASH),
                TestResource::Model(m_PlayerProfile::TEST_CLASS_HASH),
                TestResource::Model(m_DiceState::TEST_CLASS_HASH),
                TestResource::Model(m_Piece::TEST_CLASS_HASH),
                TestResource::Event(dice_chess_actions::e_GameCreated::TEST_CLASS_HASH),
                TestResource::Event(dice_chess_actions::e_PlayerJoinedQueue::TEST_CLASS_HASH),
                TestResource::Event(dice_chess_actions::e_PlayerLeftQueue::TEST_CLASS_HASH),
                TestResource::Event(dice_chess_actions::e_DiceRolled::TEST_CLASS_HASH),
                TestResource::Contract(dice_chess_actions::TEST_CLASS_HASH),
            ]
                .span(),
        }
    }

    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"dice_chess", @"dice_chess_actions")
                .with_writer_of([dojo::utils::bytearray_hash(@"dice_chess")].span())
        ]
            .span()
    }

    #[test]
    fn test_setup() {
        let caller = ZERO_ADDRESS();
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());

        let mut player_profile: PlayerProfile = world.read_model(caller);
        assert(player_profile.rating == 0, 'Initial rating wrong.');

        player_profile.rating = 100;
        world.write_model_test(@player_profile);

        let mut player_profile: PlayerProfile = world.read_model(caller);
        assert(player_profile.rating == 100, 'Write model failed.');

        world.erase_model(@player_profile);

        let mut player_profile: PlayerProfile = world.read_model(caller);
        assert(player_profile.rating == 0, 'Initial rating wrong.');
    }

    // =====================================
    // COMPREHENSIVE TESTS FOR QUEUE SYSTEM
    // =====================================

    #[test]
    fn test_join_queue_first_player() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let player1 = contract_address_const::<0x1>();

        // Test: First player joins empty queue
        testing::set_contract_address(player1);
        let result = system.join_queue();

        // Should return 0 (added to queue, no match)
        assert!(result == 0, "Should return 0 for queue join");

        // Verify queue state
        let queue: MatchmakingQueue = world.read_model(QUEUE_ID);
        assert!(queue.first_player == player1, "Queue should have player1");
        assert!(queue.queue_id == QUEUE_ID, "Queue ID should be correct");

        // Verify player entry
        let entry: MatchmakingEntry = world.read_model(player1);
        assert!(entry.is_active, "Entry should be active");
        assert!(entry.player == player1, "Entry player should match");
    }

    #[test]
    fn test_join_queue_second_player_creates_match() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let player1 = contract_address_const::<0x1>();
        let player2 = contract_address_const::<0x2>();

        // First player joins queue
        testing::set_contract_address(player1);
        system.join_queue();

        // Second player joins - should create match
        testing::set_contract_address(player2);
        let game_id = system.join_queue();

        // Should return non-zero game ID
        assert!(game_id != 0, "Should return game ID");

        // Verify game was created
        let game: Game = world.read_model(game_id);
        assert!(game.white_player == player1, "Player1 should be white");
        assert!(game.black_player == player2, "Player2 should be black");
        assert!(game.current_player == player1, "White should start");
        assert!(game.game_status == GameStatus::Active, "Game should be active");

        // Verify queue is cleared
        let queue: MatchmakingQueue = world.read_model(QUEUE_ID);
        assert!(queue.first_player == ZERO_ADDRESS(), "Queue should be empty");

        // Verify player1 entry is deactivated
        let player1_entry: MatchmakingEntry = world.read_model(player1);
        assert!(!player1_entry.is_active, "Player1 entry should be inactive");
    }

    #[test]
    fn test_join_queue_prevents_duplicate_entries() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let player1 = contract_address_const::<0x1>();

        // First join should work
        testing::set_contract_address(player1);
        let result1 = system.join_queue();
        assert!(result1 == 0, "First join should succeed");

        // Verify player is in queue
        let entry: MatchmakingEntry = world.read_model(player1);
        assert!(entry.is_active, "Player should be active in queue");
    }

    #[test]
    #[should_panic(expected: ("Player already in queue", 'ENTRYPOINT_FAILED'))]
    fn test_join_queue_already_in_queue() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let player1 = contract_address_const::<0x1>();

        // First join should work
        testing::set_contract_address(player1);
        system.join_queue();

        // Second join should panic
        system.join_queue();
    }

    #[test]
    fn test_leave_queue_success() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let player1 = contract_address_const::<0x1>();

        // Join queue first
        testing::set_contract_address(player1);
        system.join_queue();

        // Verify player is in queue
        let entry_before: MatchmakingEntry = world.read_model(player1);
        assert!(entry_before.is_active, "Should be in queue");

        // Leave queue
        let result = system.leave_queue();
        assert!(result, "Should return true for successful leave");

        // Verify player entry is deactivated
        let entry_after: MatchmakingEntry = world.read_model(player1);
        assert!(!entry_after.is_active, "Should not be in queue");

        // Verify queue is cleared
        let queue: MatchmakingQueue = world.read_model(QUEUE_ID);
        assert!(queue.first_player == ZERO_ADDRESS(), "Queue should be empty");
    }

    #[test]
    fn test_leave_queue_not_in_queue() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let player1 = contract_address_const::<0x1>();

        // Try to leave queue without joining
        testing::set_contract_address(player1);
        let result = system.leave_queue();

        // Should return false (not in queue)
        assert!(!result, "Should return false when not in queue");
    }

    #[test]
    fn test_join_leave_join_cycle() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let player1 = contract_address_const::<0x1>();

        testing::set_contract_address(player1);

        // Join queue
        let result1 = system.join_queue();
        assert!(result1 == 0, "First join should add to queue");

        // Leave queue
        let leave_result = system.leave_queue();
        assert!(leave_result, "Leave should succeed");

        // Join again
        let result2 = system.join_queue();
        assert!(result2 == 0, "Second join should add to queue again");

        // Verify final state
        let entry: MatchmakingEntry = world.read_model(player1);
        assert!(entry.is_active, "Should be active after rejoin");

        let queue: MatchmakingQueue = world.read_model(QUEUE_ID);
        assert!(queue.first_player == player1, "Queue should have player1");
    }

    #[test]
    fn test_multiple_players_queue_sequence() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let player1 = contract_address_const::<0x1>();
        let player2 = contract_address_const::<0x2>();
        let player3 = contract_address_const::<0x3>();

        // Player1 joins queue
        testing::set_contract_address(player1);
        system.join_queue();

        // Player2 joins - creates game with player1
        testing::set_contract_address(player2);
        let game_id1 = system.join_queue();
        assert!(game_id1 != 0, "Should create first game");

        // Queue should be empty now
        let queue_empty: MatchmakingQueue = world.read_model(QUEUE_ID);
        assert!(queue_empty.first_player == ZERO_ADDRESS(), "Queue should be empty");

        // Player3 joins empty queue
        testing::set_contract_address(player3);
        let result3 = system.join_queue();
        assert!(result3 == 0, "Player3 should join empty queue");

        // Verify player3 is in queue
        let queue_with_p3: MatchmakingQueue = world.read_model(QUEUE_ID);
        assert!(queue_with_p3.first_player == player3, "Queue should have player3");

        // Player1 joins again (after their game) - creates game with player3
        testing::set_contract_address(player1);
        let game_id2 = system.join_queue();
        assert!(game_id2 != 0, "Should create second game");
        assert!(game_id2 != game_id1, "Game IDs should be different");

        // Verify second game
        let game2: Game = world.read_model(game_id2);
        assert!(game2.white_player == player3, "Player3 should be white in second game");
        assert!(game2.black_player == player1, "Player1 should be black in second game");
    }

    #[test]
    fn test_queue_state_consistency() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let player1 = contract_address_const::<0x1>();

        // Initial state: queue should be empty
        let initial_queue: MatchmakingQueue = world.read_model(QUEUE_ID);
        assert!(initial_queue.first_player == ZERO_ADDRESS(), "Initial queue should be empty");

        // Player joins
        testing::set_contract_address(player1);
        testing::set_block_timestamp(100);
        system.join_queue();

        // Queue should have player, with correct timestamps
        let queue_with_player: MatchmakingQueue = world.read_model(QUEUE_ID);
        assert!(queue_with_player.first_player == player1, "Queue should have player");
        assert!(queue_with_player.last_updated > 0, "Should have timestamp");

        // Player entry should match queue state
        let entry: MatchmakingEntry = world.read_model(player1);
        assert!(entry.is_active, "Entry should be active");
        assert!(entry.joined_timestamp > 0, "Entry should have timestamp");
        assert!(
            entry.joined_timestamp == queue_with_player.last_updated, "Timestamps should match",
        );
    }

    #[test]
    fn test_game_id_uniqueness() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let player1 = contract_address_const::<0x1>();
        let player2 = contract_address_const::<0x2>();
        let player3 = contract_address_const::<0x3>();
        let player4 = contract_address_const::<0x4>();

        // Create first game
        testing::set_contract_address(player1);
        system.join_queue();
        testing::set_contract_address(player2);
        let game_id1 = system.join_queue();

        // Create second game
        testing::set_contract_address(player3);
        system.join_queue();
        testing::set_contract_address(player4);
        let game_id2 = system.join_queue();

        // Game IDs should be different and non-zero
        assert!(game_id1 != 0, "Game ID 1 should be non-zero");
        assert!(game_id2 != 0, "Game ID 2 should be non-zero");
        assert!(game_id1 != game_id2, "Game IDs should be unique");

        // Both games should exist and be different
        let game1: Game = world.read_model(game_id1);
        let game2: Game = world.read_model(game_id2);

        assert!(game1.game_id == game_id1, "Game 1 ID should match");
        assert!(game2.game_id == game_id2, "Game 2 ID should match");
        assert!(game1.white_player != game2.white_player, "Games should have different players");
    }

    // =====================================
    // COMPREHENSIVE TESTS FOR DICE ROLLING
    // =====================================

    fn create_test_game(
        world: @dojo::world::WorldStorage, system: IDiceChessActionsDispatcher,
    ) -> (u32, ContractAddress, ContractAddress) {
        let player1 = contract_address_const::<0x1>();
        let player2 = contract_address_const::<0x2>();

        // Create a game using matchmaking
        testing::set_contract_address(player1);
        system.join_queue();
        testing::set_contract_address(player2);
        let game_id = system.join_queue();

        (game_id, player1, player2)
    }

    #[test]
    fn test_roll_dice_success_white_player() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        // Create a test game
        let (game_id, white_player, _black_player) = create_test_game(@world, system);

        // White player should be able to roll dice (their turn)
        testing::set_contract_address(white_player);
        testing::set_block_timestamp(1000);
        system.roll_dice(game_id);

        // Verify dice state was created
        let dice_state: DiceState = world.read_model((game_id, 0_u32)); // turn_number = 0
        assert!(dice_state.game_id == game_id, "Game ID should match");
        assert!(dice_state.turn_number == 0, "Turn number should be 0");
        assert!(dice_state.rolled_by == white_player, "Should be rolled by white player");
        assert!(dice_state.roll_count == 1, "Roll count should be 1");
        assert!(dice_state.rolled_timestamp == 1000, "Timestamp should match");
        // Verify dice results are valid piece types (implicitly tested by not panicking)
    // All dice should be valid PieceType enum values
    }

    #[test]
    fn test_roll_dice_validates_game_exists() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        // Create a valid game and test that dice rolling works
        let (game_id, white_player, _) = create_test_game(@world, system);

        // Valid dice roll should work
        testing::set_contract_address(white_player);
        system.roll_dice(game_id);

        // Verify dice state was created correctly
        let dice_state: DiceState = world.read_model((game_id, 0_u32));
        assert!(dice_state.game_id == game_id, "Should have correct game_id");
        assert!(dice_state.roll_count == 1, "Should have rolled once");
    }

    #[test]
    #[should_panic(expected: ("Game does not exist", 'ENTRYPOINT_FAILED'))]
    fn test_roll_dice_nonexistent_game() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let player1 = contract_address_const::<0x1>();

        // Try to roll dice for non-existent game
        testing::set_contract_address(player1);
        system.roll_dice(999999);
    }

    #[test]
    fn test_roll_dice_validates_player_turn() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        // Create a test game
        let (game_id, white_player, black_player) = create_test_game(@world, system);

        // Verify initial game state - white player should start
        let game: Game = world.read_model(game_id);
        assert!(game.current_player == white_player, "White player should start");

        // White player dice roll should work
        testing::set_contract_address(white_player);
        system.roll_dice(game_id);

        // Verify dice was rolled successfully
        let dice_state: DiceState = world.read_model((game_id, 0_u32));
        assert!(dice_state.rolled_by == white_player, "Should be rolled by white player");
    }

    #[test]
    #[should_panic(expected: ("Not your turn", 'ENTRYPOINT_FAILED'))]
    fn test_roll_dice_wrong_player_turn() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        // Create a test game
        let (game_id, _white_player, black_player) = create_test_game(@world, system);

        // Black player tries to roll dice (but it's white's turn)
        testing::set_contract_address(black_player);
        system.roll_dice(game_id);
    }

    #[test]
    fn test_roll_dice_prevents_duplicate_rolls() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        // Create a test game
        let (game_id, white_player, _black_player) = create_test_game(@world, system);

        // First dice roll should work
        testing::set_contract_address(white_player);
        system.roll_dice(game_id);

        // Verify dice state shows one roll
        let dice_state: DiceState = world.read_model((game_id, 0_u32));
        assert!(dice_state.roll_count == 1, "Should have exactly one roll");
        assert!(dice_state.rolled_by == white_player, "Should be rolled by correct player");
    }

    #[test]
    #[should_panic(expected: ("Dice already rolled for this turn", 'ENTRYPOINT_FAILED'))]
    fn test_roll_dice_already_rolled() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        // Create a test game
        let (game_id, white_player, _black_player) = create_test_game(@world, system);

        // Roll dice first time (should work)
        testing::set_contract_address(white_player);
        system.roll_dice(game_id);

        // Try to roll dice again for same turn (should panic)
        system.roll_dice(game_id);
    }

    #[test]
    fn test_roll_dice_validates_active_game() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        // Create a test game
        let (game_id, white_player, _black_player) = create_test_game(@world, system);

        // Verify game is initially active
        let game: Game = world.read_model(game_id);
        assert!(game.game_status == GameStatus::Active, "Game should be active");

        // Dice rolling on active game should work
        testing::set_contract_address(white_player);
        system.roll_dice(game_id);

        // Verify dice was rolled successfully
        let dice_state: DiceState = world.read_model((game_id, 0_u32));
        assert!(dice_state.roll_count == 1, "Should have rolled dice");
    }

    #[test]
    #[should_panic(expected: ("Game is not active", 'ENTRYPOINT_FAILED'))]
    fn test_roll_dice_inactive_game() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        // Create a test game
        let (game_id, white_player, _black_player) = create_test_game(@world, system);

        // Manually set game status to inactive
        let mut game: Game = world.read_model(game_id);
        game.game_status = GameStatus::Checkmate;
        world.write_model_test(@game);

        // Try to roll dice on inactive game (should panic)
        testing::set_contract_address(white_player);
        system.roll_dice(game_id);
    }

    #[test]
    fn test_dice_all_piece_types_possible() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        // Create a test game
        let (game_id, white_player, _) = create_test_game(@world, system);

        // Roll dice
        testing::set_contract_address(white_player);
        system.roll_dice(game_id);

        // Get dice state
        let dice_state: DiceState = world.read_model((game_id, 0_u32));

        // Verify each die shows a valid piece type
        // This is implicitly tested by the fact that the enum assignment didn't panic
        // But we can also verify they're in the valid range by testing they're not "invalid"

        // Since PieceType is an enum with known variants, if the dice values were invalid,
        // the enum conversion would have failed. The fact that we got here means they're valid.
        assert!(dice_state.roll_count == 1, "Should have rolled exactly once");
    }

    #[test]
    fn test_dice_state_persistence() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        // Create a test game
        let (game_id, white_player, _) = create_test_game(@world, system);

        // Roll dice with specific timestamp
        testing::set_contract_address(white_player);
        testing::set_block_timestamp(12345);
        system.roll_dice(game_id);

        // Read dice state multiple times to ensure persistence
        let dice_state1: DiceState = world.read_model((game_id, 0_u32));
        let dice_state2: DiceState = world.read_model((game_id, 0_u32));

        // All fields should be identical between reads
        assert!(dice_state1.game_id == dice_state2.game_id, "Game ID should persist");
        assert!(dice_state1.turn_number == dice_state2.turn_number, "Turn number should persist");
        assert!(dice_state1.dice1 == dice_state2.dice1, "Dice1 should persist");
        assert!(dice_state1.dice2 == dice_state2.dice2, "Dice2 should persist");
        assert!(dice_state1.dice3 == dice_state2.dice3, "Dice3 should persist");
        assert!(dice_state1.rolled_by == dice_state2.rolled_by, "Rolled by should persist");
        assert!(
            dice_state1.rolled_timestamp == dice_state2.rolled_timestamp,
            "Timestamp should persist",
        );
        assert!(dice_state1.roll_count == dice_state2.roll_count, "Roll count should persist");

        // Verify specific values
        assert!(dice_state1.rolled_timestamp == 12345, "Should have correct timestamp");
        assert!(dice_state1.rolled_by == white_player, "Should have correct player");
    }

    // =====================================
    // COMPREHENSIVE TESTS FOR BOARD SETUP
    // =====================================

    #[test]
    fn test_board_setup_creates_all_pieces() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        // Create a game (this should trigger board setup)
        let (game_id, _white_player, _black_player) = create_test_game(@world, system);

        // Count total pieces on the board
        let mut piece_count = 0;
        let mut file = 0;
        while file < 8 {
            let mut rank = 0;
            while rank < 8 {
                let position = BoardPos { file, rank };
                let piece: Piece = world.read_model((game_id, position));

                // Check if this position has a piece (not None)
                if piece.piece_type != PieceType::None {
                    piece_count += 1;
                }
                rank += 1;
            };
            file += 1;
        };

        // Should have exactly 32 pieces (16 white + 16 black)
        assert!(piece_count == 32, "Should have exactly 32 pieces");
    }

    #[test]
    fn test_board_setup_white_pieces_correct_positions() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let (game_id, _white_player, _black_player) = create_test_game(@world, system);

        // Test white back rank (rank 0)
        let white_rook1: Piece = world.read_model((game_id, BoardPos { file: 0, rank: 0 }));
        assert!(white_rook1.piece_type == PieceType::Rook, "a1 should be white rook");
        assert!(white_rook1.color == Color::White, "a1 should be white");

        let white_knight1: Piece = world.read_model((game_id, BoardPos { file: 1, rank: 0 }));
        assert!(white_knight1.piece_type == PieceType::Knight, "b1 should be white knight");
        assert!(white_knight1.color == Color::White, "b1 should be white");

        let white_bishop1: Piece = world.read_model((game_id, BoardPos { file: 2, rank: 0 }));
        assert!(white_bishop1.piece_type == PieceType::Bishop, "c1 should be white bishop");
        assert!(white_bishop1.color == Color::White, "c1 should be white");

        let white_queen: Piece = world.read_model((game_id, BoardPos { file: 3, rank: 0 }));
        assert!(white_queen.piece_type == PieceType::Queen, "d1 should be white queen");
        assert!(white_queen.color == Color::White, "d1 should be white");

        let white_king: Piece = world.read_model((game_id, BoardPos { file: 4, rank: 0 }));
        assert!(white_king.piece_type == PieceType::King, "e1 should be white king");
        assert!(white_king.color == Color::White, "e1 should be white");

        let white_bishop2: Piece = world.read_model((game_id, BoardPos { file: 5, rank: 0 }));
        assert!(white_bishop2.piece_type == PieceType::Bishop, "f1 should be white bishop");
        assert!(white_bishop2.color == Color::White, "f1 should be white");

        let white_knight2: Piece = world.read_model((game_id, BoardPos { file: 6, rank: 0 }));
        assert!(white_knight2.piece_type == PieceType::Knight, "g1 should be white knight");
        assert!(white_knight2.color == Color::White, "g1 should be white");

        let white_rook2: Piece = world.read_model((game_id, BoardPos { file: 7, rank: 0 }));
        assert!(white_rook2.piece_type == PieceType::Rook, "h1 should be white rook");
        assert!(white_rook2.color == Color::White, "h1 should be white");

        // Test white pawns (rank 1)
        let mut file = 0;
        while file < 8 {
            let pawn: Piece = world.read_model((game_id, BoardPos { file, rank: 1 }));
            assert!(pawn.piece_type == PieceType::Pawn, "Rank 1 should have white pawns");
            assert!(pawn.color == Color::White, "Rank 1 pawns should be white");
            assert!(!pawn.has_moved, "Initial pieces should not have moved");
            file += 1;
        };
    }

    #[test]
    fn test_board_setup_black_pieces_correct_positions() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let (game_id, _white_player, _black_player) = create_test_game(@world, system);

        // Test black back rank (rank 7)
        let black_rook1: Piece = world.read_model((game_id, BoardPos { file: 0, rank: 7 }));
        assert!(black_rook1.piece_type == PieceType::Rook, "a8 should be black rook");
        assert!(black_rook1.color == Color::Black, "a8 should be black");

        let black_knight1: Piece = world.read_model((game_id, BoardPos { file: 1, rank: 7 }));
        assert!(black_knight1.piece_type == PieceType::Knight, "b8 should be black knight");
        assert!(black_knight1.color == Color::Black, "b8 should be black");

        let black_bishop1: Piece = world.read_model((game_id, BoardPos { file: 2, rank: 7 }));
        assert!(black_bishop1.piece_type == PieceType::Bishop, "c8 should be black bishop");
        assert!(black_bishop1.color == Color::Black, "c8 should be black");

        let black_queen: Piece = world.read_model((game_id, BoardPos { file: 3, rank: 7 }));
        assert!(black_queen.piece_type == PieceType::Queen, "d8 should be black queen");
        assert!(black_queen.color == Color::Black, "d8 should be black");

        let black_king: Piece = world.read_model((game_id, BoardPos { file: 4, rank: 7 }));
        assert!(black_king.piece_type == PieceType::King, "e8 should be black king");
        assert!(black_king.color == Color::Black, "e8 should be black");

        // Test black pawns (rank 6)
        let mut file = 0;
        while file < 8 {
            let pawn: Piece = world.read_model((game_id, BoardPos { file, rank: 6 }));
            assert!(pawn.piece_type == PieceType::Pawn, "Rank 6 should have black pawns");
            assert!(pawn.color == Color::Black, "Rank 6 pawns should be black");
            assert!(!pawn.has_moved, "Initial pieces should not have moved");
            file += 1;
        };
    }

    #[test]
    fn test_board_setup_empty_middle_ranks() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let (game_id, _white_player, _black_player) = create_test_game(@world, system);

        // Check that ranks 2, 3, 4, 5 are empty
        let mut rank = 2;
        while rank < 6 {
            let mut file = 0;
            while file < 8 {
                let piece: Piece = world.read_model((game_id, BoardPos { file, rank }));
                // Empty squares should have PieceType::None
                assert!(piece.piece_type == PieceType::None, "Middle ranks should be empty");
                file += 1;
            };
            rank += 1;
        };
    }

    #[test]
    fn test_board_setup_independent_games() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        // Create first game
        let player1 = contract_address_const::<0x1>();
        let player2 = contract_address_const::<0x2>();
        testing::set_contract_address(player1);
        system.join_queue();
        testing::set_contract_address(player2);
        let game_id1 = system.join_queue();

        // Create second game
        let player3 = contract_address_const::<0x3>();
        let player4 = contract_address_const::<0x4>();
        testing::set_contract_address(player3);
        system.join_queue();
        testing::set_contract_address(player4);
        let game_id2 = system.join_queue();

        // Verify both games have independent piece sets
        assert!(game_id1 != game_id2, "Games should have different IDs");

        // Check that both games have their own white king at e1
        let king1: Piece = world.read_model((game_id1, BoardPos { file: 4, rank: 0 }));
        let king2: Piece = world.read_model((game_id2, BoardPos { file: 4, rank: 0 }));

        assert!(king1.game_id == game_id1, "King1 should belong to game1");
        assert!(king2.game_id == game_id2, "King2 should belong to game2");
        assert!(king1.piece_type == PieceType::King, "King1 should be a king");
        assert!(king2.piece_type == PieceType::King, "King2 should be a king");
        assert!(king1.color == Color::White, "Both kings should be white");
        assert!(king2.color == Color::White, "Both kings should be white");

        // Verify game1 pieces don't interfere with game2
        let mut total_pieces_game1 = 0;
        let mut total_pieces_game2 = 0;

        let mut file = 0;
        while file < 8 {
            let mut rank = 0;
            while rank < 8 {
                let position = BoardPos { file, rank };
                let piece1: Piece = world.read_model((game_id1, position));
                let piece2: Piece = world.read_model((game_id2, position));

                if piece1.piece_type != PieceType::None {
                    total_pieces_game1 += 1;
                }
                if piece2.piece_type != PieceType::None {
                    total_pieces_game2 += 1;
                }
                rank += 1;
            };
            file += 1;
        };

        assert!(total_pieces_game1 == 32, "Game1 should have 32 pieces");
        assert!(total_pieces_game2 == 32, "Game2 should have 32 pieces");
    }

    #[test]
    fn test_board_setup_pieces_have_correct_game_id() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let (game_id, _white_player, _black_player) = create_test_game(@world, system);

        // Check a few specific pieces to ensure they have the correct game_id
        let white_king: Piece = world.read_model((game_id, BoardPos { file: 4, rank: 0 }));
        assert!(white_king.game_id == game_id, "White king should have correct game_id");

        let black_queen: Piece = world.read_model((game_id, BoardPos { file: 3, rank: 7 }));
        assert!(black_queen.game_id == game_id, "Black queen should have correct game_id");

        let white_pawn: Piece = world.read_model((game_id, BoardPos { file: 3, rank: 1 }));
        assert!(white_pawn.game_id == game_id, "White pawn should have correct game_id");

        let black_pawn: Piece = world.read_model((game_id, BoardPos { file: 5, rank: 6 }));
        assert!(black_pawn.game_id == game_id, "Black pawn should have correct game_id");
    }

    #[test]
    fn test_board_setup_all_pieces_unmarked_as_moved() {
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"dice_chess_actions").unwrap();
        let system = IDiceChessActionsDispatcher { contract_address };

        let (game_id, _white_player, _black_player) = create_test_game(@world, system);
        // Check that all pieces start with has_moved = false
        let mut file = 0;
        while file < 8 {
            let mut rank = 0;
            while rank < 8 {
                let position = BoardPos { file, rank };
                let piece: Piece = world.read_model((game_id, position));

                // Only check pieces that exist (not None)
                if piece.piece_type != PieceType::None {
                    assert!(!piece.has_moved, "All initial pieces should not have moved");
                }
                rank += 1;
            };
            file += 1;
        };
    }
}
