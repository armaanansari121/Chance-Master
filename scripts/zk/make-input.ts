import fs from "fs";
import path from "path";
import { Chess, type Square as ChessSquare, type PieceSymbol, type Color } from "chess.js";

type Bitboards = {
  wP: bigint; wN: bigint; wB: bigint; wR: bigint; wQ: bigint; wK: bigint;
  bP: bigint; bN: bigint; bB: bigint; bR: bigint; bQ: bigint; bK: bigint;
};

function sqToIndex(sq: ChessSquare): number {
  const file = sq.charCodeAt(0) - "a".charCodeAt(0);
  const rank = parseInt(sq[1], 10) - 1;
  return rank * 8 + file;
}
function indexOfSingleBit(bb: bigint): number {
  for (let i = 0; i < 64; i++) if (((bb >> BigInt(i)) & 1n) === 1n) return i;
  return 0;
}
function setBit(bb: bigint, idx: number) { return bb | (1n << BigInt(idx)); }
function emptyBB(): Bitboards {
  return { wP: 0n, wN: 0n, wB: 0n, wR: 0n, wQ: 0n, wK: 0n, bP: 0n, bN: 0n, bB: 0n, bR: 0n, bQ: 0n, bK: 0n };
}
function pieceKey(color: Color, type: PieceSymbol) {
  return (color === "w" ? "w" : "b") + type.toUpperCase() as keyof Bitboards;
}
function toJSONU64(bb: Bitboards) {
  return Object.fromEntries(Object.entries(bb).map(([k, v]) => [k, v.toString()]));
}
function castleMaskFromFenRights(rights: string): number {
  let m = 0;
  if (rights.includes("K")) m |= 8;
  if (rights.includes("Q")) m |= 4;
  if (rights.includes("k")) m |= 2;
  if (rights.includes("q")) m |= 1;
  return m;
}
function pieceTypeNumber(p: PieceSymbol): number {
  switch (p) {
    case "p": return 1;
    case "n": return 2;
    case "b": return 3;
    case "r": return 4;
    case "q": return 5;
    case "k": return 6;
  }
}

function buildBitboards(chess: Chess): Bitboards {
  const bb = emptyBB();
  const board = chess.board();
  for (let r = 0; r < 8; r++) {
    for (let f = 0; f < 8; f++) {
      const cell = board[r][f];
      if (!cell) continue;
      const rank = 8 - r;
      const fileChar = String.fromCharCode("a".charCodeAt(0) + f);
      const sq = (fileChar + rank.toString()) as ChessSquare;

      const idx = sqToIndex(sq);
      const key = pieceKey(cell.color, cell.type);
      // @ts-ignore
      bb[key] = setBit(bb[key] as bigint, idx);
    }
  }
  return bb;
}

function kingIndex(bb: Bitboards, moverColor: 0 | 1): number {
  const k = moverColor === 0 ? bb.wK : bb.bK;
  return indexOfSingleBit(k);
}

/** Robust arg parsing: reconstruct FEN spanning multiple tokens until next --flag */
function parseArgs(): { fen: string; move: string; out: string } | null {
  try {
    const args = process.argv.slice(2);

    const get = (flag: string, dflt?: string): string => {
      const i = args.indexOf(flag);
      if (i >= 0 && i + 1 < args.length && !args[i + 1].startsWith("--")) {
        return args[i + 1];
      }
      return dflt ?? "";
    };

    const idxFen = args.indexOf("--fen");
    let fen = "";
    if (idxFen >= 0) {
      const tail = args.slice(idxFen + 1);
      const end = tail.findIndex(t => t.startsWith("--"));
      const parts = end >= 0 ? tail.slice(0, end) : tail;
      fen = parts.join(" ");
    }

    const move = get("--move");
    const out = get("--out", "circuits/inputs/input.json");

    if (!fen || !move) {
      console.error("ERROR: usage => --fen '<FEN>' --move '<uci|uci+promo>' [--out path]");
      return null;
    }
    return { fen, move, out };
  } catch (e: any) {
    console.error(`ERROR: arg parsing failed: ${e?.message || e}`);
    return null;
  }
}

function main() {
  try {
    const parsed = parseArgs();
    if (!parsed) return; // soft fail
    const { fen, move, out } = parsed;

    let chess: Chess;
    try {
      chess = new Chess(fen);
    } catch (e: any) {
      console.error(`ERROR: invalid FEN: ${e?.message || e}`);
      return;
    }

    const fenParts = fen.split(" ");
    const sideToMove = fenParts[1] as "w" | "b";
    const rights = fenParts[2] ?? "-";
    const epField = fenParts[3] ?? "-";

    const bitboardsPre = buildBitboards(chess);

    const from = move.slice(0, 2) as ChessSquare;
    const to = move.slice(2, 4) as ChessSquare;
    const promoChar = move.length >= 5 ? move[4] : undefined;

    const p = chess.get(from) || null;

    // Try to make the move only to estimate post-king-square; do NOT abort if illegal.
    let postKingSq: number | null = null;
    const mover_color: 0 | 1 = sideToMove === "w" ? 0 : 1;
    try {
      const chessPost = new Chess(fen);
      const made = chessPost.move({ from, to, promotion: promoChar as any });
      if (made) {
        const postBB = buildBitboards(chessPost);
        postKingSq = kingIndex(postBB, mover_color);
      } else {
        // illegal: fall back to pre-move king location
        postKingSq = kingIndex(bitboardsPre, mover_color);
        console.warn(`WARN: illegal move per chess.js; continuing to emit input. move=${move}`);
      }
    } catch {
      postKingSq = kingIndex(bitboardsPre, mover_color);
      console.warn(`WARN: chess.js rejected move; continuing. move=${move}`);
    }

    const d = p ? pieceTypeNumber(p.type) : 6; // fallback to king if from-square empty
    const promo_choice = promoChar
      ? ({ n: 2, b: 3, r: 4, q: 5 } as const)[promoChar as "n" | "b" | "r" | "q"]
      : 0;

    const prev_ep_flag: 0 | 1 = epField !== "-" ? 1 : 0;
    const prev_ep_square = prev_ep_flag ? sqToIndex(epField as ChessSquare) : 0;

    const bbJSON = toJSONU64(bitboardsPre);

    const input = {
      ...bbJSON,
      _contract_addr_felt: 1,
      _game_id_low: 1,
      _game_id_high: 0,
      _rng_nonce_low: 42,
      _rng_nonce_high: 0,
      _mover_addr_felt: 2,
      _mover_color: mover_color,
      _turn: mover_color,
      _from_square: sqToIndex(from),
      _to_square: sqToIndex(to),
      _promo_choice: promo_choice,
      _dice0: d, _dice1: d, _dice2: d,
      _castle_rights: castleMaskFromFenRights(rights),
      _my_king_sq: postKingSq ?? kingIndex(bitboardsPre, mover_color),
      _prev_ep_flag: prev_ep_flag,
      _prev_ep_square: prev_ep_square
    };

    ensureDir(path.dirname(out));
    fs.writeFileSync(out, JSON.stringify(input));
    console.log(`Wrote ${out}`);
  } catch (e: any) {
    console.error(`ERROR: unexpected: ${e?.message || e}`);
  }
}

function ensureDir(p: string) {
  try { fs.mkdirSync(p, { recursive: true }); } catch { }
}

main();

