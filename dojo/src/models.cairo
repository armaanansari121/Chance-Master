use starknet::ContractAddress;

#[derive(Serde, Copy, Drop, Introspect, Default, DojoStore)]
pub enum GameStatus {
    #[default]
    Matchmaking,
    Active,
    Ended,
}

#[derive(Serde, Copy, Drop, Introspect, Default, DojoStore)]
pub enum GameResult {
    #[default]
    None,
    White,
    Black,
    Draw,
}

#[derive(Serde, Copy, Drop, Introspect, Default, DojoStore)]
pub enum ClaimType {
    #[default]
    None,
    Checkmate,
    Stalemate,
    Resign,
    Draw,
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
    pub prev_roll: (u8, u8, u8),
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
    pub castling_rights: u8, // bitmask (1=WK, 2=WQ, 4=BK, 8=BQ)
    pub ep_square: u8 // 0..63, 255 for none
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
