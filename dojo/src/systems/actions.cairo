use crate::models::{ClaimType, Game, GameBoard, GameClaim, GameClock};

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
    fn roll(ref self: T) -> (u8, u8, u8);
    //    fn submit_move(ref self: T, game_id: u64, full_proof_with_hints: Span<felt252>);
// fn claim(ref self: T, game_id: u64, claim: ClaimType);
// fn getGame(self: @T, game_id: u64) -> Game;
// fn getBitBoards(self: @T, game_id: u64) -> GameBoard;
// fn getGameClock(self: @T, game_id: u64) -> GameClock;
// fn getGameClaim(self: @T, game_id: u64) -> GameClaim;
}

#[dojo::contract]
pub mod actions {
    use core::hash::{HashStateExTrait, HashStateTrait};
    use core::poseidon::PoseidonTrait;
    use dojo::event::EventStorage;
    use dojo::model::ModelStorage;
    use starknet::{
        ContractAddress, contract_address_const, get_block_number, get_block_timestamp,
        get_caller_address,
    };
    use crate::models::{
        ClaimType, Entropy, Game, GameBoard, GameClaim, GameClock, GameResult, GameStatus,
        GlobalVars, Player,
    };
    use super::{IChanceMaster, IGroth16VerifierBN254, IGroth16VerifierBN254DispatcherTrait};

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
        pub colour: u8,
        pub dice1: u8,
        pub dice2: u8,
        pub dice3: u8,
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
                world.write_model(@Player { is_enqueued: false, is_in_game: true, ..player1 });
                world.write_model(@Player { is_enqueued: false, is_in_game: true, ..player2 });
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
                };
                world.write_model(@game);
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

        fn roll(ref self: ContractState) -> (u8, u8, u8) {
            let mut world = self.world_default();
            let caller: ContractAddress = get_caller_address();
            let player: Player = world.read_model(caller);
            let game_id = player.last_game_id;
            let game: Game = world.read_model(game_id);
            let mut player_color = 0;
            if (caller == game.white) {
                player_color = 0;
            } else {
                player_color = 1;
            }

            assert!(game.turn == player_color, "Not your turn");
            assert!(game.prev_roll == (6, 6, 6), "Already Rolled");
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
            world.write_model(@Game { prev_roll: roll_result, ..game });
            world
                .emit_event(
                    @DiceRolled {
                        game_id,
                        colour: player_color,
                        dice1: *rolls.at(0),
                        dice2: *rolls.at(1),
                        dice3: *rolls.at(2),
                    },
                );
            roll_result
        }

        fn submit_move(
            ref self: ContractState, game_id: u64, full_proof_with_hints: Span<felt252>,
        ) {}
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"chance_master")
        }

        fn generate_randomness(self: @ContractState, entropy: Entropy) -> u256 {
            let rand_felt: felt252 = PoseidonTrait::new().update_with(entropy).finalize();
            let rand_u256: u256 = rand_felt.into();
            return rand_u256;
        }
    }
}

