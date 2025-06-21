use starknet::{ContractAddress, contract_address_const};

// Define the interface
#[starknet::interface]
pub trait IDiceChessActions<T> {
    fn join_queue(ref self: T) -> u32; // Returns game_id if matched, 0 if added to queue
    fn leave_queue(ref self: T) -> bool; // Returns true if successfully left queue
    fn roll_dice(ref self: T, game_id: u32); // Roll dice for current turn
}

// Dojo contract decorator
#[dojo::contract]
pub mod dice_chess_actions {
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::{WorldStorage, WorldStorageTrait};
    use starknet::{ContractAddress, get_block_timestamp, get_block_number, get_caller_address};
    use crate::models::{
        Game, GameStatus, MatchmakingEntry, MatchmakingQueue, PlayerProfile, ZERO_ADDRESS,
        DiceState, PieceType, Piece, BoardPos, Color,
    };
    use super::IDiceChessActions;

    // Constants for matchmaking
    const QUEUE_ID: u32 = 1; // Single global queue

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct GameCreated {
        #[key]
        pub game_id: u32,
        pub white_player: ContractAddress,
        pub black_player: ContractAddress,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct PlayerJoinedQueue {
        #[key]
        pub player: ContractAddress,
        pub timestamp: u64,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct PlayerLeftQueue {
        #[key]
        pub player: ContractAddress,
        pub timestamp: u64,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct DiceRolled {
        #[key]
        pub game_id: u32,
        #[key]
        pub player: ContractAddress,
        pub turn_number: u32,
        pub dice1: PieceType,
        pub dice2: PieceType,
        pub dice3: PieceType,
        pub timestamp: u64,
    }
    #[abi(embed_v0)]
    impl DiceChessActionsImpl of IDiceChessActions<ContractState> {
        fn join_queue(ref self: ContractState) -> u32 {
            let mut world = self.world(@"dice_chess");
            let player = get_caller_address();
            let current_timestamp = get_block_timestamp();

            // Check if player is already in queue
            let existing_entry: MatchmakingEntry = world.read_model(player);
            assert!(!existing_entry.is_active, "Player already in queue");

            // Get current queue state
            let mut queue: MatchmakingQueue = world.read_model(QUEUE_ID);

            // If queue is empty, add player to queue
            if queue.first_player == ZERO_ADDRESS() {
                // Add player to queue
                let queue_entry = MatchmakingEntry {
                    player, joined_timestamp: current_timestamp, is_active: true,
                };

                // Update queue state
                let updated_queue: MatchmakingQueue = MatchmakingQueue {
                    queue_id: QUEUE_ID, first_player: player, last_updated: current_timestamp,
                };

                // Write to world
                world.write_model(@queue_entry);
                world.write_model(@updated_queue);

                // Emit event
                world.emit_event(@PlayerJoinedQueue { player, timestamp: current_timestamp });

                0 // Return 0 to indicate added to queue
            } else {
                // There's someone in queue, create a match!
                let opponent = queue.first_player;

                // Generate unique game ID
                let game_id = self.generate_game_id(player, opponent, current_timestamp);

                // Create the game - first player in queue becomes white
                let game = Game {
                    game_id,
                    white_player: opponent, // First in queue gets white
                    black_player: player, // New player gets black
                    current_player: opponent, // White starts
                    turn_number: 0,
                    game_status: GameStatus::Active,
                    created_timestamp: current_timestamp,
                };

                // Remove opponent from queue
                let mut opponent_entry: MatchmakingEntry = world.read_model(opponent);
                opponent_entry.is_active = false;
                world.write_model(@opponent_entry);

                // Clear the queue
                queue.first_player = ZERO_ADDRESS();
                queue.last_updated = current_timestamp;

                // Write models to world
                world.write_model(@game);
                world.write_model(@queue);

                // Setup initial chess board for the new game
                self.setup_initial_board(world, game_id);

                // Emit game created event
                world
                    .emit_event(
                        @GameCreated { game_id, white_player: opponent, black_player: player },
                    );

                game_id // Return game_id to indicate match found
            }
        }

        fn leave_queue(ref self: ContractState) -> bool {
            let mut world = self.world(@"dice_chess");
            let player = get_caller_address();
            let current_timestamp = get_block_timestamp();

            // Check if player is in queue
            let mut player_entry: MatchmakingEntry = world.read_model(player);

            if !player_entry.is_active {
                return false; // Player not in queue
            }

            // Get current queue state
            let mut queue: MatchmakingQueue = world.read_model(QUEUE_ID);

            // Remove player from queue
            player_entry.is_active = false;
            world.write_model(@player_entry);

            // Clear the queue
            queue.first_player = ZERO_ADDRESS();
            queue.last_updated = current_timestamp;
            world.write_model(@queue);

            // Emit event
            world.emit_event(@PlayerLeftQueue { player, timestamp: current_timestamp });

            true
        }

        fn roll_dice(ref self: ContractState, game_id: u32) {
            let mut world = self.world(@"dice_chess");
            let player = get_caller_address();
            let current_timestamp = get_block_timestamp();

            // Validate game exists and get game state
            let game: Game = world.read_model(game_id);
            assert!(game.white_player != ZERO_ADDRESS(), "Game does not exist");
            assert!(game.game_status == GameStatus::Active, "Game is not active");

            // Validate it's the current player's turn
            assert!(game.current_player == player, "Not your turn");

            // Check if dice have already been rolled for this turn
            let existing_dice: DiceState = world.read_model((game_id, game.turn_number));
            assert!(existing_dice.roll_count == 0, "Dice already rolled for this turn");

            // TODO: IMPLEMENT RE-ROLL LOGIC FOR CHESS CONSTRAINTS
            // =====================================================
            // When chess logic is ready, implement unlimited re-rolls based on legal moves:
            //
            // 1. Roll dice to get 3 piece types
            // 2. Check if player has ANY legal moves with those piece types
            // 3. If NO legal moves with current dice result:
            //    - Re-roll automatically (unlimited attempts)
            //    - Continue until player gets at least one legal move
            //
            // SPECIAL CASES:
            // - If player is in CHECK: can only move pieces that resolve check
            //   Example: King in check, only King moves are legal
            //   → Keep re-rolling until dice shows King (or piece that can block/capture)
            //
            // - If player has NO legal moves at all (regardless of dice):
            //   → CHECKMATE (if in check) or STALEMATE (if not in check)
            //   → End game immediately, no dice rolling needed
            //
            // This ensures every turn has at least one legal move available,
            // maintaining game flow while preserving chess rules.
            // =====================================================

            // Generate entropy for randomness
            let entropy = self.generate_entropy(game_id, game.turn_number, player);

            // Generate three dice rolls (0-5 for PieceType enum)
            let (dice1, dice2, dice3) = self.roll_three_dice(entropy);

            // Create dice state
            let dice_state = DiceState {
                game_id,
                turn_number: game.turn_number,
                dice1,
                dice2,
                dice3,
                rolled_by: player,
                rolled_timestamp: current_timestamp,
                roll_count: 1,
            };

            // Write dice state to world
            world.write_model(@dice_state);

            // Emit dice rolled event
            world
                .emit_event(
                    @DiceRolled {
                        game_id,
                        player,
                        turn_number: game.turn_number,
                        dice1,
                        dice2,
                        dice3,
                        timestamp: current_timestamp,
                    },
                );
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        /// Generate a unique game ID using both players and timestamp
        fn generate_game_id(
            self: @ContractState,
            player1: ContractAddress,
            player2: ContractAddress,
            timestamp: u64,
        ) -> u32 {
            let player1_felt: felt252 = player1.into();
            let player2_felt: felt252 = player2.into();
            let timestamp_felt: felt252 = timestamp.into();

            // Hash combination to create unique ID
            let hash = core::poseidon::poseidon_hash_span(
                [player1_felt, player2_felt, timestamp_felt].span(),
            );

            // Convert to u32, ensuring it's not zero
            let id: u32 = (hash.into() % 0xFFFFFFFF_u256).try_into().unwrap();
            if id == 0 {
                1
            } else {
                id
            }
        }
        /// Generate entropy for dice rolling using multiple blockchain sources
        fn generate_entropy(
            self: @ContractState, game_id: u32, turn_number: u32, player: ContractAddress,
        ) -> felt252 {
            let block_timestamp = get_block_timestamp();
            let block_number = get_block_number();
            let player_felt: felt252 = player.into();
            let game_id_felt: felt252 = game_id.into();
            let turn_felt: felt252 = turn_number.into();
            let block_timestamp_felt: felt252 = block_timestamp.into();
            let block_number_felt: felt252 = block_number.into();

            // Combine multiple entropy sources using Pedersen hash
            core::poseidon::poseidon_hash_span(
                [block_timestamp_felt, block_number_felt, player_felt, game_id_felt, turn_felt]
                    .span(),
            )
        }

        /// Convert entropy into three piece types
        fn roll_three_dice(
            self: @ContractState, entropy: felt252,
        ) -> (PieceType, PieceType, PieceType) {
            // Split entropy into three parts for three dice
            let entropy_u256: u256 = entropy.into();

            // Use different parts of the entropy for each die
            let die1_val = (entropy_u256 % 6).try_into().unwrap();
            let die2_val = ((entropy_u256 / 6) % 6).try_into().unwrap();
            let die3_val = ((entropy_u256 / 36) % 6).try_into().unwrap();

            let dice1 = self.u8_to_piece_type(die1_val);
            let dice2 = self.u8_to_piece_type(die2_val);
            let dice3 = self.u8_to_piece_type(die3_val);

            (dice1, dice2, dice3)
        }

        /// Convert u8 (0-5) to PieceType enum
        fn u8_to_piece_type(self: @ContractState, value: u8) -> PieceType {
            match value {
                0 => PieceType::Pawn,
                1 => PieceType::Bishop,
                2 => PieceType::Knight,
                3 => PieceType::Rook,
                4 => PieceType::Queen,
                5 => PieceType::King,
                _ => PieceType::Pawn // Fallback (should never happen)
            }
        }

        /// Setup the initial chess board with all pieces in starting positions
        fn setup_initial_board(self: @ContractState, mut world: WorldStorage, game_id: u32) {
            // Setup white pieces (rank 0 and 1)
            self
                .place_piece(
                    world, game_id, BoardPos { file: 0, rank: 0 }, PieceType::Rook, Color::White,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 1, rank: 0 }, PieceType::Knight, Color::White,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 2, rank: 0 }, PieceType::Bishop, Color::White,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 3, rank: 0 }, PieceType::Queen, Color::White,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 4, rank: 0 }, PieceType::King, Color::White,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 5, rank: 0 }, PieceType::Bishop, Color::White,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 6, rank: 0 }, PieceType::Knight, Color::White,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 7, rank: 0 }, PieceType::Rook, Color::White,
                );

            // White pawns (rank 1)
            let mut file = 0;
            while file < 8 {
                self
                    .place_piece(
                        world, game_id, BoardPos { file, rank: 1 }, PieceType::Pawn, Color::White,
                    );
                file += 1;
            };

            // Setup black pieces (rank 7 and 6)
            self
                .place_piece(
                    world, game_id, BoardPos { file: 0, rank: 7 }, PieceType::Rook, Color::Black,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 1, rank: 7 }, PieceType::Knight, Color::Black,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 2, rank: 7 }, PieceType::Bishop, Color::Black,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 3, rank: 7 }, PieceType::Queen, Color::Black,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 4, rank: 7 }, PieceType::King, Color::Black,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 5, rank: 7 }, PieceType::Bishop, Color::Black,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 6, rank: 7 }, PieceType::Knight, Color::Black,
                );
            self
                .place_piece(
                    world, game_id, BoardPos { file: 7, rank: 7 }, PieceType::Rook, Color::Black,
                );

            // Black pawns (rank 6)
            file = 0;
            while file < 8 {
                self
                    .place_piece(
                        world, game_id, BoardPos { file, rank: 6 }, PieceType::Pawn, Color::Black,
                    );
                file += 1;
            };
        }

        /// Helper function to place a single piece on the board
        fn place_piece(
            self: @ContractState,
            mut world: WorldStorage,
            game_id: u32,
            position: BoardPos,
            piece_type: PieceType,
            color: Color,
        ) {
            let piece = Piece { game_id, position, piece_type, color, has_moved: false };

            world.write_model(@piece);
        }
    }
}

