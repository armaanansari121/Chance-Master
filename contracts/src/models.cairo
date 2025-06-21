use starknet::{ContractAddress, contract_address_const};
pub fn ZERO_ADDRESS() -> ContractAddress {
    contract_address_const::<0x0>()
}
// Constants
pub const MAX_REROLL_ATTEMPTS: u32 = 100; // Safety limit to prevent infinite loops

// Enums for Chess pieces and game states
#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
pub enum PieceType {
    None,
    Pawn,
    Bishop,
    Knight,
    Rook,
    Queen,
    King,
}

#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
pub enum Color {
    White,
    Black,
}

// Game status enum - represents all possible game end states
#[derive(Serde, Copy, Drop, Introspect, PartialEq)]
pub enum GameStatus {
    Active,
    Checkmate,
    Stalemate,
    Draw,
    WhiteResigned,
    BlackResigned,
    Abandoned,
}

// Board position struct - represents a square on the chess board
#[derive(Copy, Drop, Serde, Introspect, PartialEq)]
pub struct BoardPos {
    pub file: u8,
    pub rank: u8,
}

// Implement Into<felt252> for PieceType to enable felt252 conversion
impl PieceTypeIntoFelt252 of Into<PieceType, felt252> {
    fn into(self: PieceType) -> felt252 {
        match self {
            PieceType::None => 0,
            PieceType::Pawn => 1,
            PieceType::Bishop => 2,
            PieceType::Knight => 3,
            PieceType::Rook => 4,
            PieceType::Queen => 5,
            PieceType::King => 6,
        }
    }
}

// Implement Into<felt252> for Color
impl ColorIntoFelt252 of Into<Color, felt252> {
    fn into(self: Color) -> felt252 {
        match self {
            Color::White => 0,
            Color::Black => 1,
        }
    }
}

// Implement Into<felt252> for GameStatus
impl GameStatusIntoFelt252 of Into<GameStatus, felt252> {
    fn into(self: GameStatus) -> felt252 {
        match self {
            GameStatus::Active => 0,
            GameStatus::Checkmate => 1,
            GameStatus::Stalemate => 2,
            GameStatus::Draw => 3,
            GameStatus::WhiteResigned => 4,
            GameStatus::BlackResigned => 5,
            GameStatus::Abandoned => 6,
        }
    }
}

// Simplified Game model - removed time control complexity
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Game {
    #[key]
    pub game_id: u32,
    pub white_player: ContractAddress,
    pub black_player: ContractAddress,
    pub current_player: ContractAddress,
    pub turn_number: u32,
    pub game_status: GameStatus,
    pub created_timestamp: u64,
}

// Simple matchmaking queue entry - only tracks who's waiting
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct MatchmakingEntry {
    #[key]
    pub player: ContractAddress,
    pub joined_timestamp: u64,
    pub is_active: bool,
}

// Global queue state to track the first person in queue
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct MatchmakingQueue {
    #[key]
    pub queue_id: u32, // Will always be 1, but needed for model key
    pub first_player: ContractAddress,
    pub last_updated: u64,
}

// Player profile model - tracks player statistics
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct PlayerProfile {
    #[key]
    pub player: ContractAddress,
    pub rating: u32,
    pub games_played: u32,
    pub games_won: u32,
    pub games_drawn: u32,
    pub games_lost: u32,
    pub total_play_time: u64,
}

// Dice state model - tracks the current dice roll for a turn
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct DiceState {
    #[key]
    pub game_id: u32,
    #[key]
    pub turn_number: u32,
    pub dice1: PieceType,
    pub dice2: PieceType,
    pub dice3: PieceType,
    pub rolled_by: ContractAddress,
    pub rolled_timestamp: u64,
    pub roll_count: u32,
}

// Player move capability model - tracks if player has any possible moves
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct PlayerMoveCapability {
    #[key]
    pub game_id: u32,
    #[key]
    pub player: ContractAddress,
    pub can_move_pawn: bool,
    pub can_move_bishop: bool,
    pub can_move_knight: bool,
    pub can_move_rook: bool,
    pub can_move_queen: bool,
    pub can_move_king: bool,
    pub has_any_legal_moves: bool,
    pub last_checked_turn: u32,
}

// Chess piece model - represents individual pieces on the board
#[derive(Copy, Drop, Serde)]
#[dojo::model]
pub struct Piece {
    #[key]
    pub game_id: u32,
    #[key]
    pub position: BoardPos,
    pub piece_type: PieceType,
    pub color: Color,
    pub has_moved: bool,
}

// Trait for DiceState helper functions
pub trait DiceStateTrait {
    fn contains_piece_type(self: @DiceState, piece_type: PieceType) -> bool;
    fn get_available_piece_types(self: @DiceState) -> Array<PieceType>;
}

pub impl DiceStateImpl of DiceStateTrait {
    fn contains_piece_type(self: @DiceState, piece_type: PieceType) -> bool {
        *self.dice1 == piece_type || *self.dice2 == piece_type || *self.dice3 == piece_type
    }

    fn get_available_piece_types(self: @DiceState) -> Array<PieceType> {
        let mut piece_types = array![];

        // Add dice1 if not already in array
        piece_types.append(*self.dice1);

        // Add dice2 if different from dice1
        piece_types.append(*self.dice2);

        // Add dice3 if different from both dice1 and dice2
        piece_types.append(*self.dice3);

        piece_types
    }
}

// Trait for PlayerMoveCapability helper functions
pub trait PlayerMoveCapabilityTrait {
    fn can_move_piece_type(self: @PlayerMoveCapability, piece_type: PieceType) -> bool;
    fn get_movable_piece_types(self: @PlayerMoveCapability) -> Array<PieceType>;
}

pub impl PlayerMoveCapabilityImpl of PlayerMoveCapabilityTrait {
    fn can_move_piece_type(self: @PlayerMoveCapability, piece_type: PieceType) -> bool {
        match piece_type {
            PieceType::None => false,
            PieceType::Pawn => *self.can_move_pawn,
            PieceType::Bishop => *self.can_move_bishop,
            PieceType::Knight => *self.can_move_knight,
            PieceType::Rook => *self.can_move_rook,
            PieceType::Queen => *self.can_move_queen,
            PieceType::King => *self.can_move_king,
        }
    }

    fn get_movable_piece_types(self: @PlayerMoveCapability) -> Array<PieceType> {
        let mut movable_types = array![];

        if *self.can_move_pawn {
            movable_types.append(PieceType::Pawn);
        }
        if *self.can_move_bishop {
            movable_types.append(PieceType::Bishop);
        }
        if *self.can_move_knight {
            movable_types.append(PieceType::Knight);
        }
        if *self.can_move_rook {
            movable_types.append(PieceType::Rook);
        }
        if *self.can_move_queen {
            movable_types.append(PieceType::Queen);
        }
        if *self.can_move_king {
            movable_types.append(PieceType::King);
        }

        movable_types
    }
}

// Trait for Piece helper functions
pub trait PieceTrait {
    fn is_empty(self: @Piece) -> bool;
    fn is_enemy(self: @Piece, other_color: Color) -> bool;
    fn is_friendly(self: @Piece, other_color: Color) -> bool;
    fn empty() -> Piece; // Factory method for creating empty squares
}

pub impl PieceImpl of PieceTrait {
    fn is_empty(self: @Piece) -> bool {
        *self.piece_type == PieceType::None
    }

    fn is_enemy(self: @Piece, other_color: Color) -> bool {
        !self.is_empty() && *self.color != other_color
    }

    fn is_friendly(self: @Piece, other_color: Color) -> bool {
        !self.is_empty() && *self.color == other_color
    }

    fn empty() -> Piece {
        Piece {
            game_id: 0,
            position: BoardPos { file: 0, rank: 0 },
            piece_type: PieceType::None,
            color: Color::White,
            has_moved: false,
        }
    }
}
