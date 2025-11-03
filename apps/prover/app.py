# apps/prover/app.py
import json
import os
import subprocess
from uuid import uuid4
from dataclasses import dataclass
from typing import Dict, Any, List, Literal, Optional, Tuple

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from pydantic import BaseModel, field_validator
import chess as pychess

# ----- Required tool paths from env -----
CIRCUIT_WASM = os.getenv("CIRCUIT_WASM")   # e.g. /circuits/Main_js/Main.wasm
WITNESS_JS   = os.getenv("WITNESS_JS")     # e.g. /circuits/Main_js/generate_witness.js
ZKEY         = os.getenv("ZKEY")           # e.g. /circuits/Main_final.zkey
VK_JSON      = os.getenv("VK_JSON")        # e.g. /circuits/verification_key.json

# Binaries (overrideable)
SNARKJS = os.getenv("SNARKJS", "snarkjs")
NODE    = os.getenv("NODE", "node")
GARAGA  = os.getenv("GARAGA_BIN", "garaga")

# tmpfs mount for per-request working dirs
WORK_ROOT = os.getenv("WORK_ROOT", "/srv/work")

app = FastAPI(title="StarkNet Prover (Garaga CLI)", version="1.0.0")


# --------- Pydantic models ---------
class ProveBody(BaseModel):
    fen: str
    move: str                                     # UCI, e.g. "e2e4", "e7e8q"
    color: Optional[Literal[0, 1]] = None         # 0 white, 1 black (optional override)
    turn:  Optional[Literal[0, 1]] = None         # 0 white, 1 black (optional override)
    # exact 3 dice; each must be in 1..6 (1 pawn … 6 king)
    dice: Tuple[int, int, int]

    @field_validator("dice")
    @classmethod
    def _v_dice(cls, v: Tuple[int, int, int]):
        a, b, c = v
        for i, d in enumerate((a, b, c)):
            if not isinstance(d, int):
                raise ValueError(f"dice[{i}] must be int")
            if d < 1 or d > 6:
                raise ValueError("each die must be in 1..6 (1=pawn … 6=king)")
        return v


class ProveEnvelope(BaseModel):
    success: bool
    error: Optional[str] = None
    calldata: Optional[List[str]] = None


# --------- Error handling (make 422s readable) ---------
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    # Also print details to container logs for quick debugging
    print("⚠️ Request validation error:", exc.errors())
    return JSONResponse(
        status_code=422,
        content={"detail": exc.errors(), "message": "Invalid request body"},
    )


# --------- Helpers ---------
def run(cmd: List[str], cwd: Optional[str] = None) -> str:
    p = subprocess.run(cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if p.returncode != 0:
        raise RuntimeError(
            f"Command failed: {' '.join(cmd)}\n--- STDOUT ---\n{p.stdout}\n--- STDERR ---\n{p.stderr}"
        )
    return p.stdout


@dataclass
class BB:
    wP: int = 0; wN: int = 0; wB: int = 0; wR: int = 0; wQ: int = 0; wK: int = 0
    bP: int = 0; bN: int = 0; bB: int = 0; bR: int = 0; bQ: int = 0; bK: int = 0


def to_json(bb: BB) -> Dict[str, int]:
    return {k: int(v) for k, v in bb.__dict__.items()}


def build_bb(board: pychess.Board) -> BB:
    bb = BB()
    for sq in pychess.SQUARES:
        p = board.piece_at(sq)
        if not p:
            continue
        key = ("w" if p.color == pychess.WHITE else "b") + {
            pychess.PAWN: "P",
            pychess.KNIGHT: "N",
            pychess.BISHOP: "B",
            pychess.ROOK: "R",
            pychess.QUEEN: "Q",
            pychess.KING: "K",
        }[p.piece_type]
        setattr(bb, key, getattr(bb, key) | (1 << sq))
    return bb


def sq_to_index(sq: str) -> int:
    # a1=0, …, h1=7, a2=8, …, h8=63
    file = ord(sq[0]) - ord('a')
    rank = int(sq[1]) - 1
    return file + rank * 8


def castle_mask(s: str) -> int:
    if s == "-" or not s:
        return 0
    return (8 if "K" in s else 0) | (4 if "Q" in s else 0) | (2 if "k" in s else 0) | (1 if "q" in s else 0)


def promo_choice(ch: Optional[str]) -> int:
    # Circuit piece_type mapping: 1 pawn,2 knight,3 bishop,4 rook,5 queen,6 king
    return {"n": 2, "b": 3, "r": 4, "q": 5}.get((ch or "").lower(), 0)  # 0 = no promotion


def ensure_paths():
    missing = []
    for name, path in [
        ("CIRCUIT_WASM", CIRCUIT_WASM),
        ("WITNESS_JS", WITNESS_JS),
        ("ZKEY", ZKEY),
        ("VK_JSON", VK_JSON),
    ]:
        if not path or not os.path.exists(path):
            missing.append(f"{name}={path}")
    if missing:
        raise RuntimeError(f"Missing or invalid config: {', '.join(missing)}")
    os.makedirs(WORK_ROOT, exist_ok=True)


# --------- Routes ---------
@app.get("/health")
def health():
    try:
        ensure_paths()
        return {"ok": True}
    except Exception as e:
        return {"ok": False, "error": str(e)}


@app.post("/prove", response_model=ProveEnvelope)
def prove(b: ProveBody):
    try:
        ensure_paths()

        # Parse FEN & move
        try:
            board = pychess.Board(b.fen)
        except Exception as e:
            return {"success": False, "error": f"Invalid FEN: {e}", "calldata": None}

        if len(b.move) < 4:
            return {"success": False, "error": "Move must be UCI like e2e4 or e7e8q", "calldata": None}

        frm, to = b.move[:2], b.move[2:4]
        promo = b.move[4].lower() if len(b.move) >= 5 else None

        # Infer color/turn from FEN unless explicitly provided (python-chess: True=white)
        color = b.color if b.color is not None else (0 if board.turn else 1)
        turn = b.turn if b.turn is not None else (0 if board.turn else 1)

        mover_is_white = (color == 0)
        py_mover_color = pychess.WHITE if mover_is_white else pychess.BLACK
        py_opp_color = pychess.BLACK if mover_is_white else pychess.WHITE

        # Pre-move state: castling rights from FEN
        parts = b.fen.split()
        rights = parts[2] if len(parts) > 2 else "-"

        # Pre-move bitboards
        prev_bb = build_bb(board)
        prev_bbj = to_json(prev_bb)

        # Apply the move (to compute expected next state)
        try:
            b2 = pychess.Board(b.fen)
            m = pychess.Move.from_uci(b.move)
            b2.push(m)
        except Exception as e:
            return {"success": False, "error": f"Invalid move: {e}", "calldata": None}

        next_bb = build_bb(b2)
        next_bbj = to_json(next_bb)

        fen_after = b2.fen()
        parts2 = fen_after.split()
        rights2 = parts2[2] if len(parts2) > 2 else "-"

        # ✅ EP fields (pre): use python-chess' computed ep_square (0..63) or 0 if none
        prev_ep_sq_py = board.ep_square  # None or 0..63
        prev_ep_flag = 1 if prev_ep_sq_py is not None else 0
        prev_ep_sq = int(prev_ep_sq_py if prev_ep_sq_py is not None else 0)

        # ✅ EP fields (post): rely on b2.ep_square (handles legality & special cases)
        next_ep_sq_py = b2.ep_square
        next_ep_flag = 1 if next_ep_sq_py is not None else 0
        next_ep_sq = int(next_ep_sq_py if next_ep_sq_py is not None else 0)

        # dice are required & already validated as (1..6, 1..6, 1..6)
        d0, d1, d2 = b.dice

        # Opponent check status after the move (opponent is side-to-move in b2)
        pre_my_king_sq = board.king(py_mover_color) or 0
        pre_opp_king_sq = board.king(py_opp_color) or 0
        opp_in_check = 1 if b2.is_check() else 0

        # Build circuit input object
        input_obj: Dict[str, Any] = {
            # Pre bitboards
            **prev_bbj,

            # Core meta
            "_mover_color": int(color),
            "_turn": int(turn),
            "_from_square": sq_to_index(frm),
            "_to_square": sq_to_index(to),
            "_promo_choice": promo_choice(promo),

            "_dice0": int(d0),
            "_dice1": int(d1),
            "_dice2": int(d2),

            "_castle_rights": castle_mask(rights),
            "_my_king_sq": int(pre_my_king_sq),

            # ✅ EP (pre)
            "_prev_ep_flag": int(prev_ep_flag),
            "_prev_ep_square": int(prev_ep_sq),

            "_opp_king_sq": int(pre_opp_king_sq),

            "expected_opp_in_check": int(opp_in_check),

            # Expected admin flags after the move
            "expected_next_castle_rights": castle_mask(rights2),

            # ✅ EP (post)
            "expected_next_ep_flag": int(next_ep_flag),
            "expected_next_ep_square": int(next_ep_sq),

            # Expected next bitboards
            "expected_next_wP": next_bbj["wP"],
            "expected_next_wN": next_bbj["wN"],
            "expected_next_wB": next_bbj["wB"],
            "expected_next_wR": next_bbj["wR"],
            "expected_next_wQ": next_bbj["wQ"],
            "expected_next_wK": next_bbj["wK"],
            "expected_next_bP": next_bbj["bP"],
            "expected_next_bN": next_bbj["bN"],
            "expected_next_bB": next_bbj["bB"],
            "expected_next_bR": next_bbj["bR"],
            "expected_next_bQ": next_bbj["bQ"],
            "expected_next_bK": next_bbj["bK"],
        }

        # Per-request work dir
        workdir = os.path.join(WORK_ROOT, str(uuid4()))
        os.makedirs(workdir, exist_ok=True)

        inp = os.path.join(workdir, "input.json")
        wtns = os.path.join(workdir, "witness.wtns")
        proof = os.path.join(workdir, "proof.json")
        pub = os.path.join(workdir, "public.json")
        calldata_txt = os.path.join(workdir, "proof_calldata.txt")

        # Ensure all fields in input_obj are serialized as strings
        with open(inp, "w") as f:
            json.dump({k: str(v) for k, v in input_obj.items()}, f, separators=(",", ":"))

        # 1) witness
        run([NODE, WITNESS_JS, CIRCUIT_WASM, inp, wtns])

        # 2) groth16 prove
        run([SNARKJS, "groth16", "prove", ZKEY, wtns, proof, pub])

        # 3) garaga calldata (writes proof_calldata.txt in cwd)
        garaga_stdout = run(
            [
                GARAGA,
                "calldata",
                "--system",
                "groth16",
                "--vk",
                VK_JSON,
                "--proof",
                proof,
                "--public-inputs",
                pub,
            ],
            cwd=workdir,
        ).strip()

        if not os.path.exists(calldata_txt):
            for line in garaga_stdout.splitlines():
                if "Calldata written to:" in line:
                    cand = line.split("Calldata written to:")[-1].strip()
                    if cand:
                        calldata_txt = cand if os.path.isabs(cand) else os.path.join(workdir, cand)
                    break

        if not os.path.exists(calldata_txt):
            raise RuntimeError(f"garaga didn't produce proof_calldata.txt.\n--- STDOUT ---\n{garaga_stdout}")

        calldata_text = open(calldata_txt, "r").read().strip()
        calldata_tokens = [tok for tok in calldata_text.split() if tok]

        return {"success": True, "error": None, "calldata": calldata_tokens}

    except Exception as e:
        return {"success": False, "error": str(e), "calldata": None}

