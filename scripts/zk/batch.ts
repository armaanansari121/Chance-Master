import fs from "fs";
import path from "path";
import { spawnSync } from "child_process";

/* ---------------- Types ---------------- */
type Ok = { ok: true; ms: number; stdout?: string; stderr?: string };
type Err = { ok: false; ms: number; raw: string };
type RunResult = Ok | Err;

type Expect = "pass" | "fail";
type Actual = "pass" | "fail" | "error";
type Verdict = "PASS" | "FAIL";

type ManifestCase = {
  name: string;
  fen: string;
  move: string;
  expect: Expect;
};

type Row = {
  name: string;
  expect: Expect;
  actual: Actual;
  result: Verdict;
  make_ms: number;
  run_ms: number;
  total_ms: number;
  note?: string;
};

/* ---------------- Paths ---------------- */
const ROOT = process.cwd();
const CIRCUITS = path.join(ROOT, "circuits");
const BUILD = path.join(CIRCUITS, "build");
const BATCH = path.join(BUILD, "batch");
const INLINE_INPUTS = path.join(BATCH, "_inline_inputs");
const WITNESSES = path.join(BATCH, "_witness");
const PROOFS = path.join(BATCH, "_proofs");
const LOGS = path.join(BATCH, "_logs");

const GW_JS = path.join(BUILD, "Orchestrator_js", "generate_witness.js");
const WASM = path.join(BUILD, "Orchestrator_js", "Orchestrator.wasm");
const ZKEY = path.join(BUILD, "Orchestrator_final.zkey");
const VK = path.join(BUILD, "verification_key.json");

/* ---------------- Utils ---------------- */
function ensureDir(p: string) {
  try { fs.mkdirSync(p, { recursive: true }); } catch { }
}

function run(cmd: string, args: string[], opts?: { cwd?: string; env?: NodeJS.ProcessEnv }): RunResult {
  const t0 = Date.now();
  const r = spawnSync(cmd, args, { stdio: "pipe", encoding: "utf8", ...opts });
  const ms = Date.now() - t0;
  if (r.status === 0) return { ok: true, ms, stdout: r.stdout, stderr: r.stderr };
  const raw = (r.stderr || "") + (r.stdout || "");
  return { ok: false, ms, raw };
}

function writeCaseLog(dir: string, name: string, content: string): string {
  ensureDir(dir);
  const p = path.join(dir, `${name}.log`);
  fs.writeFileSync(p, content);
  return p;
}

function padRight(s: string, w: number) {
  return s.length >= w ? s.slice(0, w) : s + " ".repeat(w - s.length);
}
function num(n: number) { return String(n).padStart(7, " "); }

function parseCircomError(raw: string): { summary: string; chain: string[] } {
  const lines = raw.split(/\r?\n/);
  const chain: string[] = [];
  for (const ln of lines) {
    const m1 = ln.match(/Error in template\s+([A-Za-z0-9_]+).*?line:\s*([0-9]+)/);
    if (m1) chain.push(`${m1[1]}.circom:${m1[2]}`);
    const m2 = ln.match(/\b([A-Za-z0-9_]+\.circom):(\d+)/);
    if (m2) chain.push(`${m2[1]}:${m2[2]}`);
  }
  const summary =
    chain.length > 0
      ? chain[chain.length - 1]
      : (lines.find((l) => /Error|Assert/i.test(l)) || lines.slice(0, 3).join(" | "));
  const seen = new Set<string>();
  const uniq = chain.filter((c) => (seen.has(c) ? false : (seen.add(c), true)));
  return { summary: String(summary), chain: uniq };
}

function expectedActual(expect: Expect): Actual {
  return expect === "pass" ? "pass" : "fail";
}
function isErr(r: RunResult): r is Err { return r.ok === false; }

/* ---------------- External steps ---------------- */
function makeInputViaScript(fen: string, move: string, outPath: string): RunResult {
  return run("ts-node", [
    "--compiler-options",
    '{"module":"commonjs","esModuleInterop":true}',
    path.join("scripts", "make-input.ts"),
    "--fen", fen,
    "--move", move,
    "--out", outPath,
  ]);
}
function genWitness(inputPath: string, wtnsPath: string): RunResult {
  return run("node", [GW_JS, WASM, inputPath, wtnsPath]);
}
function prove(wtnsPath: string, proofPath: string, publicPath: string): RunResult {
  return run("npx", ["snarkjs", "groth16", "prove", ZKEY, wtnsPath, proofPath, publicPath]);
}
function verify(proofPath: string, publicPath: string): RunResult {
  return run("npx", ["snarkjs", "groth16", "verify", VK, publicPath, proofPath]);
}

/* ---------------- Manifest mode ---------------- */
function readManifest(file: string): ManifestCase[] {
  const txt = fs.readFileSync(file, "utf8");
  const arr = JSON.parse(txt);
  if (!Array.isArray(arr)) throw new Error("manifest must be an array");
  return arr.map((o: any, i: number) => {
    if (!o || typeof o !== "object") throw new Error(`manifest[${i}] not an object`);
    const { name, fen, move, expect } = o;
    if (!name || !fen || !move || (expect !== "pass" && expect !== "fail")) {
      throw new Error(`manifest[${i}] missing fields (name, fen, move, expect)`);
    }
    return { name, fen, move, expect };
  });
}

/* ---------------- Dir mode ---------------- */
type DirCase = { name: string; inputPath: string; expect: Expect };

function readDirCases(dir: string): DirCase[] {
  const files = fs.readdirSync(dir).filter(f => f.endsWith(".json"));
  files.sort();
  const cases: DirCase[] = [];
  for (const f of files) {
    const name = path.basename(f, ".json");
    const inputPath = path.join(dir, f);
    let expect: Expect = "pass";
    const expFile = path.join(dir, `${name}.expect`);
    if (fs.existsSync(expFile)) {
      const t = fs.readFileSync(expFile, "utf8").trim();
      if (t === "pass" || t === "fail") expect = t;
    }
    cases.push({ name, inputPath, expect });
  }
  return cases;
}

/* ---------------- Printing ---------------- */
function printHeader() {
  const h =
    padRight("case", 21) + "  " +
    padRight("expect", 6) + "  " +
    padRight("actual", 6) + "  " +
    padRight("result", 6) + "  " +
    padRight("make_ms", 7) + "  " +
    padRight("run_ms", 7) + "  " +
    padRight("total_ms", 8) + "  " +
    "note";
  console.log(h);
  console.log(
    padRight("-".repeat(21), 21) + "  " +
    padRight("-".repeat(6), 6) + "  " +
    padRight("-".repeat(6), 6) + "  " +
    padRight("-".repeat(6), 6) + "  " +
    padRight("-".repeat(7), 7) + "  " +
    padRight("-".repeat(7), 7) + "  " +
    padRight("-".repeat(8), 8) + "  " +
    "-".repeat(80)
  );
}

function printRow(r: Row) {
  const note = r.note ?? "";
  const line =
    padRight(r.name, 21) + "  " +
    padRight(r.expect, 6) + "  " +
    padRight(r.actual, 6) + "  " +
    padRight(r.result, 6) + "  " +
    num(r.make_ms) + "  " +
    num(r.run_ms) + "  " +
    num(r.total_ms) + "  " +
    note;
  console.log(line);
}

/* ---------------- Main ---------------- */
function parseArgs() {
  const a = process.argv.slice(2);
  const get = (flag: string) => {
    const i = a.indexOf(flag);
    return i >= 0 && i + 1 < a.length ? a[i + 1] : undefined;
  };
  const manifest = get("--manifest");
  const dir = get("--dir");
  return { manifest, dir };
}

async function main() {
  const { manifest, dir } = parseArgs();

  ensureDir(BATCH);
  ensureDir(INLINE_INPUTS);
  ensureDir(WITNESSES);
  ensureDir(PROOFS);
  ensureDir(LOGS);

  printHeader();

  const rows: Row[] = [];

  if (manifest && dir) {
    console.error("ERROR: provide only one of --manifest or --dir");
    process.exit(2);
  }

  if (!manifest && !dir) {
    console.error("Usage: ts-node scripts/batch.ts --manifest circuits/inputs/manifest.json");
    console.error("   or: ts-node scripts/batch.ts --dir circuits/inputs");
    process.exit(2);
  }

  if (manifest) {
    // MANIFEST MODE
    const cases = readManifest(manifest);
    for (const c of cases) {
      const { name, fen, move, expect } = c;
      const inputPath = path.join(INLINE_INPUTS, `${name}.json`);
      const wtnsPath = path.join(WITNESSES, `${name}.wtns`);
      const proofPath = path.join(PROOFS, `${name}.proof.json`);
      const publicPath = path.join(PROOFS, `${name}.public.json`);

      // MAKE
      const mk = makeInputViaScript(fen, move, inputPath);
      if (isErr(mk)) {
        const logPath = writeCaseLog(LOGS, name, mk.raw);
        const row: Row = {
          name, expect, actual: "error", result: "FAIL",
          make_ms: mk.ms, run_ms: 0, total_ms: mk.ms,
          note: `make failed FEN="${fen}" move=${move} [log: ${logPath}]`,
        };
        printRow(row); rows.push(row); continue;
      }

      // WITNESS
      const wit = genWitness(inputPath, wtnsPath);
      if (isErr(wit)) {
        const { summary, chain } = parseCircomError(wit.raw);
        const logPath = writeCaseLog(LOGS, name, wit.raw);
        const actual: Actual = "fail";
        const verdict: Verdict = actual === expectedActual(expect) ? "PASS" : "FAIL";
        const note = `${chain.length ? chain[chain.length - 1] : summary} FEN="${fen}" move=${move} [log: ${logPath}]`;
        const row: Row = {
          name, expect, actual, result: verdict,
          make_ms: mk.ms, run_ms: wit.ms, total_ms: mk.ms + wit.ms, note,
        };
        printRow(row); rows.push(row); continue;
      }

      // PROVE
      const pr = prove(wtnsPath, proofPath, publicPath);
      if (isErr(pr)) {
        const logPath = writeCaseLog(LOGS, name, pr.raw);
        const row: Row = {
          name, expect, actual: "error", result: "FAIL",
          make_ms: mk.ms, run_ms: wit.ms + pr.ms, total_ms: mk.ms + wit.ms + pr.ms,
          note: `prove failed FEN="${fen}" move=${move} [log: ${logPath}]`,
        };
        printRow(row); rows.push(row); continue;
      }

      // VERIFY
      const vr = verify(proofPath, publicPath);
      if (isErr(vr)) {
        const logPath = writeCaseLog(LOGS, name, vr.raw);
        const row: Row = {
          name, expect, actual: "error", result: "FAIL",
          make_ms: mk.ms, run_ms: wit.ms + pr.ms + vr.ms, total_ms: mk.ms + wit.ms + pr.ms + vr.ms,
          note: `verify failed FEN="${fen}" move=${move} [log: ${logPath}]`,
        };
        printRow(row); rows.push(row); continue;
      }

      const actual: Actual = "pass";
      const verdict: Verdict = actual === expectedActual(expect) ? "PASS" : "FAIL";
      let note = "";
      if (expect === "fail" && actual === "pass") {
        const payload = `UNEXPECTED-PASS\nFEN="${fen}"\nmove=${move}\ninput_json=${inputPath}\n`;
        const logPath = writeCaseLog(LOGS, name, payload);
        note = `[unexpected-pass log: ${logPath}]`;
      }
      const row: Row = {
        name, expect, actual, result: verdict,
        make_ms: mk.ms, run_ms: wit.ms + pr.ms + vr.ms, total_ms: mk.ms + wit.ms + pr.ms + vr.ms, note,
      };
      printRow(row); rows.push(row);
    }
  } else if (dir) {
    // DIR MODE
    const cases = readDirCases(dir);
    for (const c of cases) {
      const { name, inputPath, expect } = c;
      const wtnsPath = path.join(WITNESSES, `${name}.wtns`);
      const proofPath = path.join(PROOFS, `${name}.proof.json`);
      const publicPath = path.join(PROOFS, `${name}.public.json`);

      // No "make" step in dir mode
      const mk_ms = 0;

      // WITNESS
      const wit = genWitness(inputPath, wtnsPath);
      if (isErr(wit)) {
        const { summary, chain } = parseCircomError(wit.raw);
        const logPath = writeCaseLog(LOGS, name, wit.raw);
        const actual: Actual = "fail";
        const verdict: Verdict = actual === expectedActual(expect) ? "PASS" : "FAIL";
        const note = `${chain.length ? chain[chain.length - 1] : summary} input=${inputPath} [log: ${logPath}]`;
        const row: Row = {
          name, expect, actual, result: verdict,
          make_ms: mk_ms, run_ms: wit.ms, total_ms: mk_ms + wit.ms, note,
        };
        printRow(row); rows.push(row); continue;
      }

      // PROVE
      const pr = prove(wtnsPath, proofPath, publicPath);
      if (isErr(pr)) {
        const logPath = writeCaseLog(LOGS, name, pr.raw);
        const row: Row = {
          name, expect, actual: "error", result: "FAIL",
          make_ms: mk_ms, run_ms: wit.ms + pr.ms, total_ms: mk_ms + wit.ms + pr.ms,
          note: `prove failed input=${inputPath} [log: ${logPath}]`,
        };
        printRow(row); rows.push(row); continue;
      }

      // VERIFY
      const vr = verify(proofPath, publicPath);
      if (isErr(vr)) {
        const logPath = writeCaseLog(LOGS, name, vr.raw);
        const row: Row = {
          name, expect, actual: "error", result: "FAIL",
          make_ms: mk_ms, run_ms: wit.ms + pr.ms + vr.ms, total_ms: mk_ms + wit.ms + pr.ms + vr.ms,
          note: `verify failed input=${inputPath} [log: ${logPath}]`,
        };
        printRow(row); rows.push(row); continue;
      }

      const actual: Actual = "pass";
      const verdict: Verdict = actual === expectedActual(expect) ? "PASS" : "FAIL";
      let note = "";
      if (expect === "fail" && actual === "pass") {
        const payload = `UNEXPECTED-PASS\ninput=${inputPath}\n`;
        const logPath = writeCaseLog(LOGS, name, payload);
        note = `[unexpected-pass log: ${logPath}]`;
      }
      const row: Row = {
        name, expect, actual, result: verdict,
        make_ms: mk_ms, run_ms: wit.ms + pr.ms + vr.ms, total_ms: mk_ms + wit.ms + pr.ms + vr.ms, note,
      };
      printRow(row); rows.push(row);
    }
  }

  try {
    fs.writeFileSync(path.join(BATCH, "summary.json"), JSON.stringify(rows, null, 2));
  } catch { }
}

main().catch((e) => {
  console.error(e?.stack || e?.message || String(e));
  process.exit(1);
});

