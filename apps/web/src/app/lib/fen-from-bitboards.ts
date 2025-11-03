// fen-from-onchain.ts
type U64ish = bigint | number | string;

export type OnchainGame = {
  id: U64ish;
  white: string; black: string;
  status: number; result: number;
  turn: U64ish;              // 0 -> white, 1 -> black
  prev_roll: [number, number, number];
  white_draw_offered: boolean;
  black_draw_offered: boolean;
};

export type OnchainGameBoard = {
  id: U64ish;
  white_pawns: U64ish; white_knights: U64ish; white_bishops: U64ish; white_rooks: U64ish; white_queens: U64ish; white_king: U64ish;
  black_pawns: U64ish; black_knights: U64ish; black_bishops: U64ish; black_rooks: U64ish; black_queens: U64ish; black_king: U64ish;
  castling_rights: U64ish;   // u8 mask: wk=8,wq=4,bk=2,bq=1
  ep_square: U64ish;         // 0..63, 255 => none
  is_white_in_check: boolean;
  is_black_in_check: boolean;
};

const toBI = (x: U64ish) => (typeof x === 'bigint' ? x : BigInt(x ?? 0));

// bit i set? (uses BigInt literals)
const bitAt = (bb: U64ish, i: number) =>
  ((toBI(bb) >> BigInt(i)) & 1n) === 1n;

// 0=a1 … 63=h8
const idxToSquare = (i: number) =>
  String.fromCharCode(97 + (i % 8)) + (Math.floor(i / 8) + 1);

// wk=8, wq=4, bk=2, bq=1
const castleMaskToFEN = (m: U64ish) => {
  const n = Number(m ?? 0);
  let s = '';
  if (n & 8) s += 'K';
  if (n & 4) s += 'Q';
  if (n & 2) s += 'k';
  if (n & 1) s += 'q';
  return s || '-';
};

const placementFromBoards = (b: OnchainGameBoard) => {
  const pieceAt = (i: number): string => {
    if (bitAt(b.white_pawns, i)) return 'P';
    if (bitAt(b.white_knights, i)) return 'N';
    if (bitAt(b.white_bishops, i)) return 'B';
    if (bitAt(b.white_rooks, i)) return 'R';
    if (bitAt(b.white_queens, i)) return 'Q';
    if (bitAt(b.white_king, i)) return 'K';
    if (bitAt(b.black_pawns, i)) return 'p';
    if (bitAt(b.black_knights, i)) return 'n';
    if (bitAt(b.black_bishops, i)) return 'b';
    if (bitAt(b.black_rooks, i)) return 'r';
    if (bitAt(b.black_queens, i)) return 'q';
    if (bitAt(b.black_king, i)) return 'k';
    return '';
  };

  const ranks: string[] = [];
  for (let r = 7; r >= 0; r--) {
    let row = '';
    let empty = 0;
    for (let f = 0; f < 8; f++) {
      const i = r * 8 + f;
      const p = pieceAt(i);
      if (p) { if (empty) { row += empty; empty = 0; } row += p; }
      else empty++;
    }
    if (empty) row += empty;
    ranks.push(row);
  }
  return ranks.join('/');
};

/** Build FEN from on-chain GameBoard + Game.turn; clocks default to "0 1". */
export function toFEN(board: OnchainGameBoard, game: OnchainGame): string {
  const placement = placementFromBoards(board);
  const side = Number(game.turn ?? 0) === 0 ? 'w' : 'b';
  const castle = castleMaskToFEN(board.castling_rights);
  const epNum = Number(board.ep_square ?? 255);
  const ep = epNum === 255 ? '-' : idxToSquare(epNum);

  // you don't store these; use safe defaults
  const halfmove_clock = 0;
  const fullmove_number = 1;

  return `${placement} ${side} ${castle} ${ep} ${halfmove_clock} ${fullmove_number}`;
}

