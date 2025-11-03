use crate::models::GameBoard;

pub const GameTime: u64 = 3600;

pub const InitialBoard: GameBoard = GameBoard {
    id: 0,
    white_pawns: 65280,
    white_knights: 66,
    white_rooks: 129,
    white_bishops: 36,
    white_queens: 8,
    white_king: 16,
    black_pawns: 71776119061217280,
    black_knights: 4755801206503243776,
    black_rooks: 9295429630892703744,
    black_bishops: 2594073385365405696,
    black_queens: 576460752303423488,
    black_king: 1152921504606846976,
    castling_rights: 15,
    ep_square: 255,
    is_white_in_check: false,
    is_black_in_check: false,
};
