use starknet::ContractAddress;
use crate::models::{ClaimType, Game, GameBoard, GameClaim, GameClock, GlobalVars};

#[starknet::interface]
pub trait IGroth16VerifierBN254<TContractState> {
    fn verify_groth16_proof_bn254(
        self: @TContractState, full_proof_with_hints: Span<felt252>,
    ) -> Option<Span<u256>>;
}

#[starknet::interface]
pub trait IChanceMaster<T> {
    fn enqueue(ref self: T);
    fn dequeue(ref self: T);
    fn roll(ref self: T, game_id: u64) -> (u8, u8, u8);
    fn submit_move(ref self: T, game_id: u64, full_proof_with_hints: Span<felt252>);
    fn resign(ref self: T, game_id: u64);
    fn offer_draw(ref self: T, game_id: u64);
    fn claim(ref self: T, game_id: u64, claim: ClaimType);
    fn accept_claim(ref self: T, game_id: u64);
    fn adjudicate_claim(ref self: T, game_id: u64);
    fn flag_win(ref self: T, game_id: u64);
    fn get_game(self: @T, game_id: u64) -> Game;
    fn get_game_board(self: @T, game_id: u64) -> GameBoard;
    fn get_game_clock(self: @T, game_id: u64) -> GameClock;
    fn get_game_claim(self: @T, game_id: u64) -> GameClaim;
}

#[starknet::interface]
pub trait IAdminControls<T> {
    fn setup(ref self: T, initial_verifier: ContractAddress);
    fn transfer_admin(ref self: T, new_admin: ContractAddress);
    fn set_verifier_contract(ref self: T, new_verifier: ContractAddress);
    fn get_admin(self: @T) -> ContractAddress;
    fn get_globals(self: @T) -> GlobalVars;
}

#[dojo::contract]
pub mod actions {
    use core::array::{ArrayTrait, SpanTrait};
    use core::hash::{HashStateExTrait, HashStateTrait};
    use core::poseidon::PoseidonTrait;
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use dojo::world::WorldStorage;
    use starknet::{
        ContractAddress, contract_address_const, get_block_number, get_block_timestamp,
        get_caller_address,
    };
    use crate::constants::{GameTime, InitialBoard};
    use crate::models::{
        AdminSettings, ClaimType, Entropy, Game, GameBoard, GameClaim, GameClock, GameResult,
        GameStatus, GlobalVars, Player, PublicInputs,
    };
    use super::{
        IAdminControls, IChanceMaster, IGroth16VerifierBN254, IGroth16VerifierBN254Dispatcher,
        IGroth16VerifierBN254DispatcherTrait,
    };

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct Enqueued {
        #[key]
        pub player: ContractAddress,
        pub queue_len: u64,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct Dequeued {
        #[key]
        pub player: ContractAddress,
        pub queue_len: u64,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct GameStarted {
        #[key]
        pub id: u64,
        pub white: ContractAddress,
        pub black: ContractAddress,
        pub queue_len: u64,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct DiceRolled {
        #[key]
        pub game_id: u64,
        pub color: u8,
        pub dice1: u8,
        pub dice2: u8,
        pub dice3: u8,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct ClaimMade {
        #[key]
        pub game_id: u64,
        pub color: u8,
        pub claim: ClaimType,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct ClaimCleared {
        #[key]
        pub game_id: u64,
        pub color: u8,
    }
    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct DrawOffered {
        #[key]
        pub game_id: u64,
        pub color: u8,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct DrawAgreed {
        #[key]
        pub game_id: u64,
        pub GameResult: GameResult,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct DrawCleared {
        #[key]
        pub game_id: u64,
        pub color: u8,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct Resigned {
        #[key]
        pub game_id: u64,
        pub color: u8,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct GameEnded {
        #[key]
        pub id: u64,
        pub result: GameResult,
    }

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct ClaimResolved {
        #[key]
        pub game_id: u64,
        pub color: u8, // claimant color
        pub claim: ClaimType,
        pub result: GameResult // White | Black | Draw
    }


    #[abi(embed_v0)]
    impl ChanceMaster of IChanceMaster<ContractState> {
        fn enqueue(ref self: ContractState) {
            let mut world = self.world_default();
            let caller: ContractAddress = get_caller_address();
            let player: Player = world.read_model(caller);
            assert!(!player.is_enqueued, "Player is already in queue");
            assert!(!player.is_in_game, "Player is in an active game");

            let globals: GlobalVars = world.read_model(1);
            let queue = globals.queue;

            if (queue.is_empty()) {
                let mut arr: Array<ContractAddress> = ArrayTrait::new();
                arr.append(player.contract_address);
                let globals = GlobalVars { queue: arr.span(), ..globals };
                world.write_model(@globals);
                world
                    .emit_event(
                        @Enqueued { player: player.contract_address, queue_len: arr.len().into() },
                    );
                world.write_model(@Player { is_enqueued: true, ..player });
            } else {
                let opponent_address = *queue.at(0);
                let player1: Player = world.read_model(opponent_address);
                let player2 = player;
                let game_id = globals.game_id;
                world
                    .write_model(
                        @Player {
                            is_enqueued: false,
                            is_in_game: true,
                            last_game_id: game_id,
                            ..player1,
                        },
                    );
                world
                    .write_model(
                        @Player {
                            is_enqueued: false,
                            is_in_game: true,
                            last_game_id: game_id,
                            ..player2,
                        },
                    );
                let mut arr: Array<ContractAddress> = ArrayTrait::new();
                for i in 1..queue.len() {
                    arr.append(*queue.at(i));
                }
                let globals = GlobalVars { queue: arr.span(), game_id: game_id + 1, ..globals };
                world.write_model(@globals);
                let entropy = Entropy {
                    timestamp: get_block_timestamp(),
                    block_number: get_block_number(),
                    caller_address: player2.contract_address,
                    seed: 1,
                };
                let random: u256 = self.generate_randomness(entropy);
                let random_u8: u8 = (random % 2).try_into().unwrap();
                let game = Game {
                    id: game_id,
                    status: GameStatus::Active,
                    result: GameResult::None,
                    turn: 0,
                    white: match random_u8 {
                        1 => player1.contract_address,
                        0 => player2.contract_address,
                        _ => contract_address_const::<0>(),
                    },
                    black: match random_u8 {
                        1 => player2.contract_address,
                        0 => player1.contract_address,
                        _ => contract_address_const::<0>(),
                    },
                    prev_roll: (6, 6, 6),
                    white_draw_offered: false,
                    black_draw_offered: false,
                };
                world.write_model(@game);
                self.setup_initial_position(world, game_id);
                world
                    .emit_event(
                        @GameStarted {
                            id: game_id,
                            white: game.white,
                            black: game.black,
                            queue_len: queue.len().into() - 1,
                        },
                    );
            }
        }

        fn dequeue(ref self: ContractState) {
            let mut world = self.world_default();
            let caller: ContractAddress = get_caller_address();
            let player: Player = world.read_model(caller);
            assert!(player.is_enqueued, "Player not enqueued");

            let globals: GlobalVars = world.read_model(1);
            let queue = globals.queue;
            let mut arr: Array<ContractAddress> = ArrayTrait::new();
            for i in 0..queue.len() {
                let queued_player = *queue.at(i);
                if (queued_player == player.contract_address) {
                    continue;
                } else {
                    arr.append(queued_player);
                }
            }
            world.write_model(@GlobalVars { queue: arr.span(), ..globals });
            world.write_model(@Player { is_enqueued: false, ..player });
            world
                .emit_event(
                    @Dequeued { player: player.contract_address, queue_len: arr.len().into() },
                );
        }

        fn roll(ref self: ContractState, game_id: u64) -> (u8, u8, u8) {
            let mut world = self.world_default();
            let game: Game = world.read_model(game_id);
            let caller: ContractAddress = get_caller_address();
            assert(caller == game.white || caller == game.black, 'Not a Player');
            assert(game.status == GameStatus::Active, 'Game Ended');
            assert(game.result == GameResult::None, 'Game Ended');
            let mut player_color = 0;
            if (caller == game.white) {
                player_color = 0;
            } else {
                player_color = 1;
            }

            assert!(game.turn == player_color, "Not your turn");
            assert!(game.prev_roll == (6, 6, 6), "Already Rolled");

            if game.white_draw_offered || game.black_draw_offered {
                world.emit_event(@DrawCleared { game_id, color: player_color });
            }

            let mut rolls: Array<u8> = ArrayTrait::new();
            for i in 0..3_u64 {
                let entropy = Entropy {
                    timestamp: get_block_timestamp(),
                    block_number: get_block_number(),
                    caller_address: get_caller_address(),
                    seed: i,
                };
                let roll: u8 = (self.generate_randomness(entropy) % 6).try_into().unwrap();
                rolls.append(roll);
            }

            let roll_result: (u8, u8, u8) = (*rolls.at(0), *rolls.at(1), *rolls.at(2));
            world
                .write_model(
                    @Game {
                        prev_roll: roll_result,
                        white_draw_offered: false,
                        black_draw_offered: false,
                        ..game,
                    },
                );
            world
                .emit_event(
                    @DiceRolled {
                        game_id,
                        color: player_color,
                        dice1: *rolls.at(0),
                        dice2: *rolls.at(1),
                        dice3: *rolls.at(2),
                    },
                );
            roll_result
        }

        fn submit_move(
            ref self: ContractState, game_id: u64, full_proof_with_hints: Span<felt252>,
        ) {
            let mut world = self.world_default();
            let game: Game = world.read_model(game_id);
            let game_clock: GameClock = world.read_model(game_id);
            let caller: ContractAddress = get_caller_address();
            assert(caller == game.black || caller == game.white, 'Not a Player');
            assert(game.status == GameStatus::Active, 'Game Ended');
            assert(game.result == GameResult::None, 'Game Ended');

            let mut player_color = 0;
            let mut player_time_rem = 0;
            if (caller == game.white) {
                player_color = 0;
                player_time_rem = game_clock.white_rem;
            } else {
                player_color = 1;
                player_time_rem = game_clock.black_rem;
            }

            let globals: GlobalVars = world.read_model(1);

            assert!(game.turn == player_color, "Not your turn");
            assert!(game.prev_roll != (6, 6, 6), "Roll the Dice First");

            let timestamp = get_block_timestamp();
            let time_consumed = timestamp - game_clock.last_updated;
            assert(player_time_rem > time_consumed, 'Timed out');
            let dispatcher = IGroth16VerifierBN254Dispatcher {
                contract_address: globals.verifier_contract,
            };

            let res = dispatcher.verify_groth16_proof_bn254(full_proof_with_hints);

            let public_inputs: PublicInputs = self.parse_verifier_response(res);

            assert!(public_inputs._mover_color == player_color, "Fraudulent Proof Mover Colour Mismatch");
            assert!(public_inputs._turn == game.turn, "Fraudulent Proof Turn Mismatch");

            let game_board: GameBoard = world.read_model(game_id);

            assert!(game_board.white_pawns == public_inputs.white_pawns, "Fraudulent Proof White Pawns Mismatch");
            assert!(game_board.white_knights == public_inputs.white_knights, "Fraudulent Proof White Knights Mismatch");
            assert!(game_board.white_bishops == public_inputs.white_bishops, "Fraudulent Proof White Bishops Mismatch");
            assert!(game_board.white_rooks == public_inputs.white_rooks, "Fraudulent Proof White Rooks Mismatch");
            assert!(game_board.white_queens == public_inputs.white_queens, "Fraudulent Proof White Queens Mismatch");
            assert!(game_board.white_king == public_inputs.white_king, "Fraudulent Proof White King Mismatch");
            assert!(game_board.black_pawns == public_inputs.black_pawns, "Fraudulent Proof Black Pawns Mismatch");
            assert!(game_board.black_knights == public_inputs.black_knights, "Fraudulent Proof Black Knights Mismatch");
            assert!(game_board.black_bishops == public_inputs.black_bishops, "Fraudulent Proof Black Bishops Mismatch");
            assert!(game_board.black_rooks == public_inputs.black_rooks, "Fraudulent Proof Black Rooks Mismatch");
            assert!(game_board.black_queens == public_inputs.black_queens, "Fraudulent Proof Black Queens Mismatch");
            assert!(game_board.black_king == public_inputs.black_king, "Fraudulent Proof Black King Mismatch");
            assert!(game_board.castling_rights == public_inputs.castling_rights, "Fraudulent Proof Castling Rights Mismatch");
            if game_board.ep_square == 255 {
                assert!(public_inputs.ep_flag == 0, "Fraudulent Proof EP Square Mismatch");
            } else {
                assert!(public_inputs.ep_flag == 1, "Fraudulent Proof EP Square Mismatch");
                assert!(game_board.ep_square == public_inputs.ep_square, "Fraudulent Proof EP Square Mismatch");
            }
            assert!(
                game.prev_roll == (public_inputs.dice0 - 1, public_inputs.dice1 - 1, public_inputs.dice2 - 1),
                "Fraudulent Proof Dice Mismatch",
            );

            if game.white_draw_offered || game.black_draw_offered {
                world.emit_event(@DrawCleared { game_id, color: player_color });
            }

            let gc: GameClaim = world.read_model(game_id);
            if gc.claim != ClaimType::None {
                // If there's an active claim, the mover is necessarily the opponent.
                // (Claimant_color = 1 - game.turn; mover_color == game.turn.)
                let claimant_color: u8 = 1 - game.turn;
                world.write_model(@GameClaim { id: game_id, claim: ClaimType::None });
                world.emit_event(@ClaimCleared { game_id, color: claimant_color });
            }

            // 0/1 -> bool (reject anything else)
            let opp_in_check = match public_inputs.expected_opp_king_in_check {
                0 => false,
                1 => true,
                _ => panic!("Fraudulent Proof check not Bool"),
            };

            // Compute flags without tuple matching
            let is_white_in_check = if opp_in_check {
                match player_color {
                    0 => false, // white moved, only black can be in check
                    1 => true, // black moved, so white can be in check
                    _ => panic!("Invalid Color"),
                }
            } else {
                false
            };

            let is_black_in_check = if opp_in_check {
                match player_color {
                    0 => true, // white moved and gave check
                    1 => false, // black moved and gave check
                    _ => panic!("Invalid Color"),
                }
            } else {
                false
            };

            // use the computed flags
            let updated_board = GameBoard {
                id: game_id,
                white_pawns: public_inputs.expected_next_white_pawns,
                white_knights: public_inputs.expected_next_white_knights,
                white_bishops: public_inputs.expected_next_white_bishops,
                white_rooks: public_inputs.expected_next_white_rooks,
                white_queens: public_inputs.expected_next_white_queens,
                white_king: public_inputs.expected_next_white_king,
                black_pawns: public_inputs.expected_next_black_pawns,
                black_knights: public_inputs.expected_next_black_knights,
                black_bishops: public_inputs.expected_next_black_bishops,
                black_rooks: public_inputs.expected_next_black_rooks,
                black_queens: public_inputs.expected_next_black_queens,
                black_king: public_inputs.expected_next_black_king,
                castling_rights: public_inputs.expected_next_castling_rights,
                ep_square: match public_inputs.expected_next_ep_flag {
                    0 => 255,
                    1 => public_inputs.expected_next_ep_square,
                    _ => panic!("Fraudulent Proof Invalid EP Flag"),
                },
                is_white_in_check,
                is_black_in_check,
            };

            world.write_model(@updated_board);
            let updated_clock = GameClock {
                white_rem: match player_color {
                    0 => game_clock.white_rem - time_consumed,
                    1 => game_clock.white_rem,
                    _ => panic!("Invalid Color"),
                },
                black_rem: match player_color {
                    0 => game_clock.black_rem,
                    1 => game_clock.black_rem - time_consumed,
                    _ => panic!("Invalid Color"),
                },
                last_updated: timestamp,
                ..game_clock,
            };
            world.write_model(@updated_clock);

            let updated_game = Game {
                turn: 1 - game.turn,
                prev_roll: (6, 6, 6),
                white_draw_offered: false,
                black_draw_offered: false,
                ..game,
            };
            world.write_model(@updated_game);
        }

        fn resign(ref self: ContractState, game_id: u64) {
            let mut world = self.world_default();

            let game: Game = world.read_model(game_id);
            let caller: ContractAddress = get_caller_address();

            assert(caller == game.white || caller == game.black, 'Not a Player');
            assert(game.status == GameStatus::Active, 'Game Ended');
            assert(game.result == GameResult::None, 'Game Ended');

            let color = match caller == game.white {
                true => 0,
                false => 1,
            };

            world.emit_event(@Resigned { game_id, color: color });

            let result = if caller == game.white {
                GameResult::Black
            } else {
                GameResult::White
            };

            self.finalize_game(world, game, result);
        }

        fn offer_draw(ref self: ContractState, game_id: u64) {
            let mut world = self.world_default();

            let game: Game = world.read_model(game_id);
            let caller: ContractAddress = get_caller_address();

            assert(caller == game.white || caller == game.black, 'Not a Player');
            assert(game.status == GameStatus::Active, 'Game Ended');
            assert(game.result == GameResult::None, 'Game Ended');

            let color = match caller == game.white {
                true => 0,
                false => 1,
            };

            if color == 0 {
                if game.black_draw_offered {
                    world.emit_event(@DrawAgreed { game_id, GameResult: GameResult::Draw });
                    self.finalize_game(world, game, GameResult::Draw);
                    return;
                }
                world.write_model(@Game { white_draw_offered: true, ..game });
            } else {
                if game.white_draw_offered {
                    world.emit_event(@DrawAgreed { game_id, GameResult: GameResult::Draw });
                    self.finalize_game(world, game, GameResult::Draw);
                    return;
                }
                world.write_model(@Game { black_draw_offered: true, ..game });
            }
            world.emit_event(@DrawOffered { game_id, color: color });
        }

        fn claim(ref self: ContractState, game_id: u64, claim: ClaimType) {
            let mut world = self.world_default();

            let game: Game = world.read_model(game_id);
            let caller: ContractAddress = get_caller_address();

            assert(caller == game.white || caller == game.black, 'Not a Player');
            assert(
                game.status == GameStatus::Active && game.result == GameResult::None, 'Game Ended',
            );

            // determine colors
            let caller_color: u8 = if caller == game.white {
                0
            } else {
                1
            };
            let claimant_color: u8 = 1 - game.turn; // the side that just moved

            assert!(
                caller_color == claimant_color,
                "Only the claimant (side that just moved) can claim",
            );

            // validate supported claims
            match claim {
                ClaimType::Checkmate | ClaimType::Stalemate => {},
                _ => { panic!("Unsupported claim type"); },
            }

            // read current claim
            let gc: GameClaim = world.read_model(game_id);

            // If there is an active claim, ensure only the same side is updating it
            if gc.claim != ClaimType::None {
                assert!(caller_color == claimant_color, "Claim already active by opponent");
            }

            world.write_model(@GameClaim { id: game_id, claim });
            world.emit_event(@ClaimMade { game_id, color: claimant_color, claim });
        }

        fn accept_claim(ref self: ContractState, game_id: u64) {
            let mut world = self.world_default();

            let game: Game = world.read_model(game_id);
            let gc: GameClaim = world.read_model(game_id);
            let caller: ContractAddress = get_caller_address();

            assert(gc.claim != ClaimType::None, 'No active claim');
            assert(
                game.status == GameStatus::Active && game.result == GameResult::None, 'Game Ended',
            );
            assert(caller == game.white || caller == game.black, 'Not a Player');

            // Opponent (side to move) must accept
            let side_to_move_addr = if game.turn == 0 {
                game.white
            } else {
                game.black
            };
            assert!(
                caller == side_to_move_addr, "Only the opponent (side to move) can accept a claim",
            );

            // Claimant is the side that just moved.
            let claimant_color: u8 = 1 - game.turn;

            // Decide the result from the claim kind
            let result = match gc.claim {
                ClaimType::Checkmate => {
                    if claimant_color == 0 {
                        GameResult::White
                    } else {
                        GameResult::Black
                    }
                },
                ClaimType::Stalemate => GameResult::Draw,
                _ => { panic!("Unsupported claim type"); },
            };

            // Clear the claim and emit resolution before ending the game
            world.write_model(@GameClaim { id: game_id, claim: ClaimType::None });
            world
                .emit_event(
                    @ClaimResolved { game_id, color: claimant_color, claim: gc.claim, result },
                );

            self.finalize_game(world, game, result);
        }

        fn adjudicate_claim(ref self: ContractState, game_id: u64) {
            let mut world = self.world_default();

            let game: Game = world.read_model(game_id);
            let clock: GameClock = world.read_model(game_id);
            let gc: GameClaim = world.read_model(game_id);

            assert(gc.claim != ClaimType::None, 'No active claim');
            assert(
                game.status == GameStatus::Active && game.result == GameResult::None, 'Game Ended',
            );

            // Check flag-fall for side to move
            let now = get_block_timestamp();
            let elapsed = now - clock.last_updated;
            let opp_time = if game.turn == 0 {
                clock.white_rem
            } else {
                clock.black_rem
            };
            assert!(elapsed >= opp_time, "Side to move still has time");

            // Claimant is the side that just moved (the *opponent* of side-to-move).
            let claimant_color: u8 = 1 - game.turn;

            let result = match gc.claim {
                ClaimType::Checkmate => {
                    if claimant_color == 0 {
                        GameResult::White
                    } else {
                        GameResult::Black
                    }
                },
                ClaimType::Stalemate => GameResult::Draw,
                _ => { panic!("Unsupported claim type"); },
            };

            // Clear and emit resolution, then finalize
            world.write_model(@GameClaim { id: game_id, claim: ClaimType::None });
            world
                .emit_event(
                    @ClaimResolved { game_id, color: claimant_color, claim: gc.claim, result },
                );

            self.finalize_game(world, game, result);
        }

        fn flag_win(ref self: ContractState, game_id: u64) {
            let mut world = self.world_default();

            let game: Game = world.read_model(game_id);
            let clock: GameClock = world.read_model(game_id);
            let caller: ContractAddress = get_caller_address();

            assert(caller == game.white || caller == game.black, 'Not a Player');
            assert(
                game.status == GameStatus::Active && game.result == GameResult::None, 'Game Ended',
            );

            let now = get_block_timestamp();
            let elapsed = now - clock.last_updated;
            let side_to_move_time = if game.turn == 0 {
                clock.white_rem
            } else {
                clock.black_rem
            };
            assert!(elapsed >= side_to_move_time, "Side to move still has time");

            let gc: GameClaim = world.read_model(game_id);
            if gc.claim != ClaimType::None {
                // claimant is the side that just moved = opponent of side-to-move
                let claimant_color: u8 = 1 - game.turn;
                world.write_model(@GameClaim { id: game_id, claim: ClaimType::None });
                world.emit_event(@ClaimCleared { game_id, color: claimant_color });
            }

            // side-to-move flagged -> opponent wins
            let loser_color: u8 = game.turn;
            let result = if loser_color == 0 {
                GameResult::Black
            } else {
                GameResult::White
            };

            self.finalize_game(world, game, result);
        }
        fn get_game(self: @ContractState, game_id: u64) -> Game {
            let mut world = self.world_default();
            let game: Game = world.read_model(game_id);
            game
        }

        fn get_game_board(self: @ContractState, game_id: u64) -> GameBoard {
            let mut world = self.world_default();
            let gameboard: GameBoard = world.read_model(game_id);
            gameboard
        }


        fn get_game_clock(self: @ContractState, game_id: u64) -> GameClock {
            let mut world = self.world_default();
            let gameclock: GameClock = world.read_model(game_id);
            gameclock
        }

        fn get_game_claim(self: @ContractState, game_id: u64) -> GameClaim {
            let mut world = self.world_default();
            let gameclaim: GameClaim = world.read_model(game_id);
            gameclaim
        }
    }

    #[abi(embed_v0)]
    impl AdminControls of IAdminControls<ContractState> {
        fn setup(ref self: ContractState, initial_verifier: ContractAddress) {
            let mut world = self.world_default();

            let admin_state: AdminSettings = world.read_model(1);
            assert!(!admin_state.initialized, "Already initialized");

            let caller = get_caller_address();

            let new_admin = AdminSettings { id: 1, admin: caller, initialized: true };
            world.write_model(@new_admin);

            let mut empty: Array<ContractAddress> = ArrayTrait::new();
            let globals = GlobalVars {
                id: 1,
                game_id: 1, // first game will get id=1
                queue: empty.span(),
                verifier_contract: initial_verifier,
            };
            world.write_model(@globals);
        }

        fn transfer_admin(ref self: ContractState, new_admin: ContractAddress) {
            let mut world = self.world_default();
            let mut admin_state: AdminSettings = world.read_model(1);
            self.assert_admin(world, admin_state);
            assert!(new_admin != contract_address_const::<0>(), "Zero address");
            admin_state = AdminSettings { admin: new_admin, ..admin_state };
            world.write_model(@admin_state);
        }

        fn set_verifier_contract(ref self: ContractState, new_verifier: ContractAddress) {
            let mut world = self.world_default();
            let admin_state: AdminSettings = world.read_model(1);
            self.assert_admin(world, admin_state);

            let mut globals: GlobalVars = world.read_model(1);
            globals = GlobalVars { verifier_contract: new_verifier, ..globals };
            world.write_model(@globals);
        }

        fn get_admin(self: @ContractState) -> ContractAddress {
            let mut world = self.world_default();
            let admin_state: AdminSettings = world.read_model(1);
            admin_state.admin
        }

        fn get_globals(self: @ContractState) -> GlobalVars {
            let mut world = self.world_default();
            world.read_model(1)
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"chance_master")
        }

        fn u256_to_u8(self: @ContractState, x: u256) -> u8 {
            x.try_into().unwrap() // assumes value fits in u8
        }

        fn u256_to_u64(self: @ContractState, x: u256) -> u64 {
            x.try_into().unwrap() // assumes value fits in u64
        }

        fn assert_admin(self: @ContractState, mut world: WorldStorage, admin_state: AdminSettings) {
            let caller = get_caller_address();
            assert!(admin_state.initialized, "Not initialized");
            assert!(caller == admin_state.admin, "Admin only");
        }

        fn setup_initial_position(ref self: ContractState, mut world: WorldStorage, game_id: u64) {
            let timestamp = get_block_timestamp();
            let game_clock = GameClock {
                id: game_id, white_rem: GameTime, black_rem: GameTime, last_updated: timestamp,
            };
            world.write_model(@game_clock);
            world.write_model(@GameBoard { id: game_id, ..InitialBoard });
            world.write_model(@GameClaim { id: game_id, claim: ClaimType::None });
        }

        fn generate_randomness(self: @ContractState, entropy: Entropy) -> u256 {
            let rand_felt: felt252 = PoseidonTrait::new().update_with(entropy).finalize();
            let rand_u256: u256 = rand_felt.into();
            return rand_u256;
        }

        fn parse_verifier_response(self: @ContractState, res: Option<Span<u256>>) -> PublicInputs {
            let public_inputs = match res {
                Option::Some(pi) => pi,
                Option::None => { panic!("Groth16 verification failed") },
            };

            assert!(public_inputs.len() == 41, "Invalid public input length");

            // 0..11 — bitboards (u64)
            let white_pawns = self.u256_to_u64(*public_inputs.at(0));
            let white_knights = self.u256_to_u64(*public_inputs.at(1));
            let white_bishops = self.u256_to_u64(*public_inputs.at(2));
            let white_rooks = self.u256_to_u64(*public_inputs.at(3));
            let white_queens = self.u256_to_u64(*public_inputs.at(4));
            let white_king = self.u256_to_u64(*public_inputs.at(5));
            let black_pawns = self.u256_to_u64(*public_inputs.at(6));
            let black_knights = self.u256_to_u64(*public_inputs.at(7));
            let black_bishops = self.u256_to_u64(*public_inputs.at(8));
            let black_rooks = self.u256_to_u64(*public_inputs.at(9));
            let black_queens = self.u256_to_u64(*public_inputs.at(10));
            let black_king = self.u256_to_u64(*public_inputs.at(11));

            // 12..23 — small ints (u8)
            let _mover_color = self.u256_to_u8(*public_inputs.at(12));
            let _turn = self.u256_to_u8(*public_inputs.at(13));
            let _from_square = self.u256_to_u8(*public_inputs.at(14));
            let _to_square = self.u256_to_u8(*public_inputs.at(15));
            let _promo_choice = self.u256_to_u8(*public_inputs.at(16));
            let dice0 = self.u256_to_u8(*public_inputs.at(17));
            let dice1 = self.u256_to_u8(*public_inputs.at(18));
            let dice2 = self.u256_to_u8(*public_inputs.at(19));
            let castling_rights = self.u256_to_u8(*public_inputs.at(20));
            let _my_king_sq = self.u256_to_u8(*public_inputs.at(21));
            let ep_flag = self.u256_to_u8(*public_inputs.at(22));
            let ep_square = self.u256_to_u8(*public_inputs.at(23));

            // 24..26 — expected meta (u8)
            let expected_next_castling_rights = self.u256_to_u8(*public_inputs.at(24));
            let expected_next_ep_flag = self.u256_to_u8(*public_inputs.at(25));
            let expected_next_ep_square = self.u256_to_u8(*public_inputs.at(26));

            // 27..38 — expected next bitboards (u64)
            let expected_next_white_pawns = self.u256_to_u64(*public_inputs.at(27));
            let expected_next_white_knights = self.u256_to_u64(*public_inputs.at(28));
            let expected_next_white_bishops = self.u256_to_u64(*public_inputs.at(29));
            let expected_next_white_rooks = self.u256_to_u64(*public_inputs.at(30));
            let expected_next_white_queens = self.u256_to_u64(*public_inputs.at(31));
            let expected_next_white_king = self.u256_to_u64(*public_inputs.at(32));
            let expected_next_black_pawns = self.u256_to_u64(*public_inputs.at(33));
            let expected_next_black_knights = self.u256_to_u64(*public_inputs.at(34));
            let expected_next_black_bishops = self.u256_to_u64(*public_inputs.at(35));
            let expected_next_black_rooks = self.u256_to_u64(*public_inputs.at(36));
            let expected_next_black_queens = self.u256_to_u64(*public_inputs.at(37));
            let expected_next_black_king = self.u256_to_u64(*public_inputs.at(38));

            // 39, 40
            let _opp_king_sq = self.u256_to_u8(*public_inputs.at(39));
            let expected_opp_king_in_check = self.u256_to_u8(*public_inputs.at(40));

            PublicInputs {
                white_pawns,
                white_knights,
                white_bishops,
                white_rooks,
                white_queens,
                white_king,
                black_pawns,
                black_knights,
                black_bishops,
                black_rooks,
                black_queens,
                black_king,
                _mover_color,
                _turn,
                _from_square,
                _to_square,
                _promo_choice,
                dice0,
                dice1,
                dice2,
                castling_rights,
                _my_king_sq,
                ep_flag,
                ep_square,
                expected_next_castling_rights,
                expected_next_ep_flag,
                expected_next_ep_square,
                expected_next_white_pawns,
                expected_next_white_knights,
                expected_next_white_bishops,
                expected_next_white_rooks,
                expected_next_white_queens,
                expected_next_white_king,
                expected_next_black_pawns,
                expected_next_black_knights,
                expected_next_black_bishops,
                expected_next_black_rooks,
                expected_next_black_queens,
                expected_next_black_king,
                _opp_king_sq,
                expected_opp_king_in_check,
            }
        }

        fn finalize_game(
            self: @ContractState, mut world: WorldStorage, game: Game, result: GameResult,
        ) {
            let updated_game = Game {
                status: GameStatus::Ended,
                result, // reset the roll to sentinel so no further moves are attempted by mistake
                prev_roll: (6, 6, 6),
                white_draw_offered: false,
                black_draw_offered: false,
                ..game,
            };
            world.write_model(@updated_game);

            let mut white_player: Player = world.read_model(game.white);
            let mut black_player: Player = world.read_model(game.black);

            let wp_games = white_player.games + 1;
            let bp_games = black_player.games + 1;

            let (wp_wins, wp_losses, wp_draws) = match result {
                GameResult::White => (
                    white_player.wins + 1, white_player.losses, white_player.draws,
                ),
                GameResult::Black => (
                    white_player.wins, white_player.losses + 1, white_player.draws,
                ),
                GameResult::Draw => (
                    white_player.wins, white_player.losses, white_player.draws + 1,
                ),
                _ => (white_player.wins, white_player.losses, white_player.draws),
            };

            let (bp_wins, bp_losses, bp_draws) = match result {
                GameResult::White => (
                    black_player.wins, black_player.losses + 1, black_player.draws,
                ),
                GameResult::Black => (
                    black_player.wins + 1, black_player.losses, black_player.draws,
                ),
                GameResult::Draw => (
                    black_player.wins, black_player.losses, black_player.draws + 1,
                ),
                _ => (black_player.wins, black_player.losses, black_player.draws),
            };

            world
                .write_model(
                    @Player {
                        is_in_game: false,
                        games: wp_games,
                        wins: wp_wins,
                        losses: wp_losses,
                        draws: wp_draws,
                        last_game_id: game.id,
                        ..white_player,
                    },
                );

            world
                .write_model(
                    @Player {
                        is_in_game: false,
                        games: bp_games,
                        wins: bp_wins,
                        losses: bp_losses,
                        draws: bp_draws,
                        last_game_id: game.id,
                        ..black_player,
                    },
                );

            world.emit_event(@GameEnded { id: game.id, result });
        }
    }
}

