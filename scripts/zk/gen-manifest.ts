import fs from "fs";
import path from "path";
import { Chess, type Square as ChessSquare, type Move } from "chess.js";

type Item = {
  name: string;
  fen: string;
  move: string;
  expect: "pass" | "fail";
  // dice omitted on purpose → dice will always match mover in make-input
};

function randInt(n: number, rng: () => number) { return Math.floor(rng() * n); }
function mulberry32(a: number) {
  return function() {
    let t = (a += 0x6D2B79F5);
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function randomGameState(ply: number, rng: () => number): Chess {
  const ch = new Chess();
  for (let i = 0; i < ply; i++) {
    const legal = ch.moves({ verbose: true });
    if (!legal.length) break;
    const m = legal[randInt(legal.length, rng)];
    ch.move({ from: (m as any).from as ChessSquare, to: (m as any).to as ChessSquare, promotion: (m as any).promotion as any });
  }
  return ch;
}

function pickLegalMove(ch: Chess, rng: () => number): Move {
  const legal = ch.moves({ verbose: true }) as Move[];
  return legal[randInt(legal.length, rng)];
}

function anyFriendlySquares(ch: Chess): string[] {
  const color = ch.turn(); // 'w' | 'b'
  const res: string[] = [];
  for (let r = 0; r < 8; r++) {
    for (let f = 0; f < 8; f++) {
      const file = String.fromCharCode("a".charCodeAt(0) + f);
      const rank = String(8 - r);
      const sq = (file + rank);
      const p = ch.get(sq as ChessSquare);
      if (p && p.color === color) res.push(sq);
    }
  }
  return res;
}

function anyEnemySquares(ch: Chess): string[] {
  const color = ch.turn();
  const res: string[] = [];
  for (let r = 0; r < 8; r++) {
    for (let f = 0; f < 8; f++) {
      const file = String.fromCharCode("a".charCodeAt(0) + f);
      const rank = String(8 - r);
      const sq = (file + rank);
      const p = ch.get(sq as ChessSquare);
      if (p && p.color !== color) res.push(sq);
    }
  }
  return res;
}

function illegal_same_square(ch: Chess, rng: () => number) {
  const legal = ch.moves({ verbose: true }) as Move[];
  if (!legal.length) return null;
  const m = legal[randInt(legal.length, rng)] as any;
  // e2e2 style "no move"
  return `${m.from}${m.from}`;
}

function illegal_friendly_capture(ch: Chess, rng: () => number) {
  const friends = anyFriendlySquares(ch);
  const legal = ch.moves({ verbose: true }) as Move[];
  if (!legal.length || friends.length < 2) return null;
  const m = legal[randInt(legal.length, rng)] as any;
  // choose a *different* friendly-occupied square for destination
  const choices = friends.filter(sq => sq !== m.from);
  if (!choices.length) return null;
  const dest = choices[randInt(choices.length, rng)];
  return `${m.from}${dest}`;
}

function illegal_geometry(ch: Chess, rng: () => number) {
  const legal = ch.moves({ verbose: true }) as Move[];
  if (!legal.length) return null;
  const m = legal[randInt(legal.length, rng)] as any;
  const p = ch.get(m.from as ChessSquare);
  if (!p) return null;

  const file = m.from.charCodeAt(0) - "a".charCodeAt(0);
  const rank = parseInt(m.from[1], 10) - 1;

  const clamp = (x: number) => Math.max(0, Math.min(7, x));
  let candidates: string[] = [];

  if (p.type === "b") { // bishop illegal: try orthogonal
    const targets = [[file + 1, rank], [file - 1, rank], [file, rank + 1], [file, rank - 1]];
    candidates = targets.map(([f, r]) => String.fromCharCode("a".charCodeAt(0) + clamp(f)) + (clamp(r) + 1));
  } else if (p.type === "r") { // rook illegal: try diagonal
    const targets = [[file + 1, rank + 1], [file - 1, rank - 1], [file + 1, rank - 1], [file - 1, rank + 1]];
    candidates = targets.map(([f, r]) => String.fromCharCode("a".charCodeAt(0) + clamp(f)) + (clamp(r) + 1));
  } else if (p.type === "q") { // queen illegal: try knight
    const jumps = [[1, 2], [2, 1], [-1, 2], [-2, 1], [1, -2], [2, -1], [-1, -2], [-2, -1]];
    candidates = jumps.map(([df, dr]) => String.fromCharCode("a".charCodeAt(0) + clamp(file + df)) + (clamp(rank + dr) + 1));
  } else if (p.type === "n") { // knight illegal: try bishop-like one step
    const targets = [[file + 1, rank + 1], [file - 1, rank - 1], [file + 1, rank - 1], [file - 1, rank + 1]];
    candidates = targets.map(([f, r]) => String.fromCharCode("a".charCodeAt(0) + clamp(f)) + (clamp(r) + 1));
  } else if (p.type === "k") { // king illegal: two squares forward (non-castle)
    candidates = [String.fromCharCode("a".charCodeAt(0) + file) + (clamp(rank + (ch.turn() === "w" ? 2 : -2)) + 1)];
  } else if (p.type === "p") { // pawn illegal: move backward 1
    const dir = ch.turn() === "w" ? -1 : +1;
    candidates = [String.fromCharCode("a".charCodeAt(0) + file) + (clamp(rank + dir) + 1)];
  }

  const to = candidates[randInt(candidates.length, rng)];
  if (!to || to === m.from) return null;
  return `${m.from}${to}`;
}

function genCases(passCount: number, failCount: number, ply: number, seed: number): Item[] {
  const rng = mulberry32(seed);
  const items: Item[] = [];

  // PASS cases: pick legal moves
  for (let i = 0; i < passCount; i++) {
    const ch = randomGameState(ply, rng);
    const legal = ch.moves({ verbose: true }) as Move[];
    if (!legal.length) { i--; continue; }
    const m = legal[randInt(legal.length, rng)] as any;
    const move = `${m.from}${m.to}${m.promotion ? m.promotion : ""}`;
    items.push({ name: `pass_${i}_${m.from}${m.to}`, fen: ch.fen(), move, expect: "pass" });
  }

  // FAIL cases (non-dice): craft illegal moves that exercise other rules
  const failMakers = [illegal_same_square, illegal_friendly_capture, illegal_geometry];
  for (let i = 0; i < failCount; i++) {
    let tries = 0;
    while (tries++ < 50) {
      const ch = randomGameState(ply, rng);
      const maker = failMakers[randInt(failMakers.length, rng)];
      const move = maker(ch, rng);
      if (!move) continue; // try another
      items.push({ name: `fail_${i}_${move}`, fen: ch.fen(), move, expect: "fail" });
      break;
    }
  }

  return items;
}

function parseCli() {
  const args = process.argv.slice(2);
  const get = (flag: string, dflt?: string) => {
    const i = args.indexOf(flag);
    return i >= 0 && i + 1 < args.length ? args[i + 1] : dflt;
  };
  const out = get("--out", "circuits/inputs/manifest.gen.json")!;
  const seed = Number(get("--seed", "1337"));
  const passCount = Number(get("--pass", "50"));
  const failCount = Number(get("--fail", "50"));
  const ply = Number(get("--ply", "8"));
  return { out, seed, passCount, failCount, ply };
}

function main() {
  const { out, seed, passCount, failCount, ply } = parseCli();
  const items = genCases(passCount, failCount, ply, seed);
  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, JSON.stringify(items, null, 2));
  console.log(`wrote ${out}  // pass=${passCount} fail=${failCount} seed=${seed} ply=${ply}`);
}

main();

