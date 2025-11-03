use starknet::ContractAddress;

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Default, DojoStore)]
pub enum GameStatus {
    #[default]
    Matchmaking,
    Active,
    Ended,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Default, DojoStore)]
pub enum GameResult {
    #[default]
    None,
    White,
    Black,
    Draw,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq, Default, DojoStore)]
pub enum ClaimType {
    #[default]
    None,
    Checkmate,
    Stalemate,
}

#[derive(Serde, Copy, Drop)]
#[dojo::model]
pub struct AdminSettings {
    #[key]
    pub id: u8,
    pub admin: ContractAddress,
    pub initialized: bool,
}

#[derive(Serde, Copy, Drop)]
#[dojo::model]
pub struct Player {
    #[key]
    pub contract_address: ContractAddress,
    pub is_enqueued: bool,
    pub is_in_game: bool,
    pub games: u64,
    pub wins: u64,
    pub losses: u64,
    pub draws: u64,
    pub last_game_id: u64,
}

#[derive(Serde, Copy, Drop)]
#[dojo::model]
pub struct Game {
    #[key]
    pub id: u64,
    pub white: ContractAddress,
    pub black: ContractAddress,
    pub status: GameStatus,
    pub result: GameResult,
    pub turn: u8, // 0 -> white, 1 -> black
    pub prev_roll: (u8, u8, u8), // 0-5 --> pieces, 6 --> none
    pub white_draw_offered: bool,
    pub black_draw_offered: bool,
}

#[derive(Serde, Copy, Drop)]
#[dojo::model]
pub struct GlobalVars {
    #[key]
    pub id: u8,
    pub game_id: u64,
    pub queue: Span<ContractAddress>,
    pub verifier_contract: ContractAddress,
}

#[derive(Serde, Copy, Drop)]
#[dojo::model]
pub struct GameClock {
    #[key]
    pub id: u64,
    pub white_rem: u64,
    pub black_rem: u64,
    pub last_updated: u64,
}

#[derive(Serde, Copy, Drop)]
#[dojo::model]
pub struct GameBoard {
    #[key]
    pub id: u64,
    pub white_pawns: u64,
    pub white_knights: u64,
    pub white_bishops: u64,
    pub white_rooks: u64,
    pub white_queens: u64,
    pub white_king: u64,
    pub black_pawns: u64,
    pub black_knights: u64,
    pub black_bishops: u64,
    pub black_rooks: u64,
    pub black_queens: u64,
    pub black_king: u64,
    pub castling_rights: u8,
    pub ep_square: u8, // 0..63, 255 for none
    pub is_white_in_check: bool,
    pub is_black_in_check: bool,
}

#[derive(Serde, Copy, Drop)]
#[dojo::model]
pub struct GameClaim {
    #[key]
    pub id: u64,
    pub claim: ClaimType,
}

#[derive(Serde, Copy, Drop, Hash)]
pub struct Entropy {
    pub timestamp: u64,
    pub block_number: u64,
    pub caller_address: ContractAddress,
    pub seed: u64,
}

#[derive(Copy, Drop, Serde)]
pub struct PublicInputs {
    // 0..11 — bitboards
    pub white_pawns: u64,
    pub white_knights: u64,
    pub white_bishops: u64,
    pub white_rooks: u64,
    pub white_queens: u64,
    pub white_king: u64,
    pub black_pawns: u64,
    pub black_knights: u64,
    pub black_bishops: u64,
    pub black_rooks: u64,
    pub black_queens: u64,
    pub black_king: u64,
    // 12..23 — scalars / small ints
    pub _mover_color: u8, // 12
    pub _turn: u8, // 13
    pub _from_square: u8, // 14
    pub _to_square: u8, // 15
    pub _promo_choice: u8, // 16
    pub dice0: u8, // 17
    pub dice1: u8, // 18
    pub dice2: u8, // 19
    pub castling_rights: u8, // 20
    pub _my_king_sq: u8, // 21
    pub ep_flag: u8, // 22
    pub ep_square: u8, // 23
    // 24..26 — expected metadata
    pub expected_next_castling_rights: u8, // 24
    pub expected_next_ep_flag: u8, // 25
    pub expected_next_ep_square: u8, // 26
    // 27..38 — expected next bitboards
    pub expected_next_white_pawns: u64, // 27
    pub expected_next_white_knights: u64, // 28
    pub expected_next_white_bishops: u64, // 29
    pub expected_next_white_rooks: u64, // 30
    pub expected_next_white_queens: u64, // 31
    pub expected_next_white_king: u64, // 32
    pub expected_next_black_pawns: u64, // 33
    pub expected_next_black_knights: u64, // 34
    pub expected_next_black_bishops: u64, // 35
    pub expected_next_black_rooks: u64, // 36
    pub expected_next_black_queens: u64, // 37
    pub expected_next_black_king: u64, // 38
    pub _opp_king_sq: u8, //39
    pub expected_opp_king_in_check: u8 //40
}
