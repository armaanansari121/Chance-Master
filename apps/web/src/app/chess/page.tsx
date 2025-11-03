'use client';

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { Chess, Move } from 'chess.js';
import { Chessboard } from 'react-chessboard';
import { toast } from 'sonner';
import Timer from '../components/Timer';
import { DiceTray } from '../components/Dice';
import { useRouter, useSearchParams } from 'next/navigation';
import { useAccount } from '@starknet-react/core';
import { gqlFetch, getWsClient } from '../lib/torii-graphql';
import { toFEN, type OnchainGame, type OnchainGameBoard } from '../lib/fen-from-bitboards';
import { useActions } from '../lib/actions';
import { HUDBar } from '../components/HUDBar';
import { EndGameDialog } from '../components/EndGameDialog';

// ---------- GraphQL ----------

const GQL_PLAYER_GUARD = /* GraphQL */ `
  query PlayerGuard($addr: ContractAddress) {
    chanceMasterPlayerModels(where: { contract_address: $addr }, limit: 1) {
      edges {
        node {
          entity { id }
          contract_address
          is_in_game
          last_game_id
        }
      }
    }
  }
`;

const GQL_ENTITY_UPDATED = /* GraphQL */ `
  subscription EntityUpdated($id: ID!) {
    entityUpdated(id: $id) {
      models {
        __typename
        ... on chance_master_Player {
          contract_address
          is_enqueued
          is_in_game
          last_game_id
        }
        ... on chance_master_Game {
          id white black status result turn
          prev_roll { _0 _1 _2 } white_draw_offered black_draw_offered
        }
        ... on chance_master_GameBoard {
          id
          white_pawns white_knights white_bishops white_rooks white_queens white_king
          black_pawns black_knights black_bishops black_rooks black_queens black_king
          castling_rights ep_square
          is_white_in_check is_black_in_check
        }
        ... on chance_master_GameClock {
          id white_rem black_rem last_updated
        }
        ... on chance_master_GameClaim {
          id claim
        }
      }
    }
  }
`;

const GQL_GAME_SEED = /* GraphQL */ `
  query GameSeed($id: ID!) {
    chanceMasterGameModels(where: { id: $id }, limit: 1) {
      edges {
        node {
          entity { id }
          id white black status result turn
          prev_roll { _0 _1 _2 } white_draw_offered black_draw_offered
        }
      }
    }
  }
`;

const GQL_BOARD_SEED = /* GraphQL */ `
  query BoardSeed($id: ID!) {
    chanceMasterGameBoardModels(where: { id: $id }, limit: 1) {
      edges {
        node {
          entity { id }
          id
          white_pawns white_knights white_bishops white_rooks white_queens white_king
          black_pawns black_knights black_bishops black_rooks black_queens black_king
          castling_rights ep_square
          is_white_in_check is_black_in_check
        }
      }
    }
  }
`;

const GQL_CLOCK_SEED = /* GraphQL */ `
  query ClockSeed($id: ID!) {
    chanceMasterGameClockModels(where: { id: $id }, limit: 1) {
      edges {
        node {
          entity { id }
          id white_rem black_rem last_updated
        }
      }
    }
  }
`;

const GQL_CLAIM_SEED = /* GraphQL */ `
  query ClaimSeed($id: ID!) {
    chanceMasterGameClaimModels(where: { id: $id }, limit: 1) {
      edges {
        node {
          entity { id }
          id claim
        }
      }
    }
  }
`;

// ---------- Local helpers / types ----------

type ProveRequest = { fen: string; move: string; dice?: number[] };
type ProveResponse = { calldata: string[]; public_signals: string[]; felt_count: number };

function formatMs(ms: number) {
  const s = Math.max(0, Math.floor(ms / 1000));
  const m = Math.floor(s / 60);
  const sec = s % 60;
  return `${String(m).padStart(2, '0')}:${String(sec).padStart(2, '0')}`;
}

const frameStyle: React.CSSProperties = {
  borderRadius: 16,
  padding: 10,
  background: 'linear-gradient(180deg, rgba(23,36,44,.9), rgba(10,18,22,.9))',
  boxShadow: '0 20px 40px var(--board-shadow), inset 0 0 0 1px rgba(255,255,255,.04)',
};
const lightSq = { backgroundColor: 'var(--sq-light)' };
const darkSq = { backgroundColor: 'var(--sq-dark)' };
const highlight = { background: 'var(--move)' };
const lastMove = { background: 'var(--last)' };

const DIE_TO_PIECE: Record<number, 'p' | 'n' | 'b' | 'r' | 'q' | 'k'> = {
  1: 'p', 2: 'n', 3: 'b', 4: 'r', 5: 'q', 6: 'k',
};

const canonAddr32 = (addr: string) =>
  `0x${addr.trim().replace(/^0x/i, '').toLowerCase().padStart(64, '0')}`;

const sameAddress = (a?: string | null, b?: string | null): boolean => {
  if (!a || !b) return false;
  try { return BigInt(a) === BigInt(b); } catch { return canonAddr32(a) === canonAddr32(b); }
};

interface CM_Player {
  __typename: 'chance_master_Player';
  contract_address: string;
  is_enqueued: boolean;
  is_in_game: boolean;
  last_game_id: string | number | null;
}
type Triple = { _0: string | number; _1: string | number; _2: string | number };
interface CM_Game extends OnchainGame {
  __typename: 'chance_master_Game';
  white_draw_offered?: boolean;
  black_draw_offered?: boolean;
  prev_roll?: Triple;
}
interface CM_Board extends OnchainGameBoard {
  __typename: 'chance_master_GameBoard';
}
interface CM_Clock {
  __typename: 'chance_master_GameClock';
  id: string | number;
  white_rem: string | number;
  black_rem: string | number;
  last_updated: string | number;
}
type ClaimKind = 'None' | 'Checkmate' | 'Stalemate';
interface CM_Claim {
  __typename: 'chance_master_GameClaim';
  id: string | number;
  claim: ClaimKind;
}
type UpdatedModel = CM_Player | CM_Game | CM_Board | CM_Clock | CM_Claim;
type EntityUpdatedMsg = {
  data?: { entityUpdated?: { models?: UpdatedModel[] } };
};

// contract 0..5 piece, 6 none  ->  UI 1..6 piece, 0 none
const toNum = (x: unknown) => {
  const n = Number(x);
  return Number.isFinite(n) ? n : 6;
};
const isSentinel = (t: Triple | null | undefined) =>
  toNum(t?._0) === 6 && toNum(t?._1) === 6 && toNum(t?._2) === 6;
const rollOnchainToUI = (t: Triple | null | undefined): [number, number, number] => {
  const conv = (v: number) => (v === 6 ? 0 : v + 1);
  return [conv(toNum(t?._0)), conv(toNum(t?._1)), conv(toNum(t?._2))];
};

// ---------- Component ----------

export default function ChessPage() {
  const [game, setGame] = useState(() => new Chess());
  const [proving, setProving] = useState(false);
  const [last, setLast] = useState<{ from: string; to: string } | null>(null);

  const [claimType, setClaimType] = useState<'Checkmate' | 'Stalemate'>('Checkmate');
  const [claimKind, setClaimKind] = useState<ClaimKind>('None');

  const [dice, setDice] = useState<number[]>([0, 0, 0]);
  const [rolling, setRolling] = useState(false);

  const [clockBase, setClockBase] = useState<{ whiteSec: number; blackSec: number; lastUpdatedSec: number }>({
    whiteSec: 180, blackSec: 180, lastUpdatedSec: 0,
  });
  const [displayMs, setDisplayMs] = useState<{ white: number; black: number }>({
    white: 180000, black: 180000,
  });

  const [flagged, setFlagged] = useState<{ white: boolean; black: boolean }>({ white: false, black: false });
  const toastFiredRef = useRef<{ white: boolean; black: boolean }>({ white: false, black: false });

  const [whiteAddr, setWhiteAddr] = useState<string | null>(null);
  const [blackAddr, setBlackAddr] = useState<string | null>(null);

  const r = useRouter();
  const sp = useSearchParams();
  const gidStr = useMemo(() => {
    const gameId = sp.get('game');
    return gameId ? String(gameId) : null;
  }, [sp]);
  const { address } = useAccount();

  // Track current address for delayed checks
  const addressRef = useRef<string | null>(null);
  useEffect(() => { addressRef.current = address ?? null; }, [address]);

  const {
    resign, offerDraw, claim, acceptClaim, adjudicateClaim, flagWin, roll, submitMove, ready,
  } = useActions();

  const onchainTurnRef = useRef<0 | 1>(0);

  const [guardLoading, setGuardLoading] = useState(true);
  const didNormalizeRef = useRef(false);

  // NEW: seed/redirect debouncers
  const seededOkRef = useRef(false); // becomes true once we successfully seed subs for the current gid
  const pendingRedirectTimerRef = useRef<number | null>(null);
  const pendingNoWalletTimerRef = useRef<number | null>(null);
  const clearTimer = (ref: React.MutableRefObject<number | null>) => {
    if (ref.current) {
      clearTimeout(ref.current);
      ref.current = null;
    }
  };

  const shouldRun = useMemo(() => {
    if (flagged.white || flagged.black) return false;
    return !proving && displayMs.white > 0 && displayMs.black > 0 && !!clockBase.lastUpdatedSec;
  }, [proving, displayMs.white, displayMs.black, clockBase.lastUpdatedSec, flagged.white, flagged.black]);

  // ---------- Entry guard (improved) ----------
  useEffect(() => {
    let cancel = false;
    let stop: (() => void) | null = null;

    // If wallet isn't available immediately after a hard refresh,
    // wait a short grace period before deciding to bounce to "/".
    if (!address) {
      setGuardLoading(true);
      clearTimer(pendingNoWalletTimerRef);
      pendingNoWalletTimerRef.current = window.setTimeout(() => {
        if (!addressRef.current && !cancel) {
          r.replace('/');
        }
      }, 2500); // 2.5s grace to let wallet reconnect on refresh
      return () => {
        clearTimer(pendingNoWalletTimerRef);
      };
    }

    (async () => {
      try {
        const seed = await gqlFetch<{
          chanceMasterPlayerModels: { edges: { node: { entity?: { id: string } | null; contract_address: string; is_in_game: boolean; last_game_id: number | string | null; } }[] }
        }>(GQL_PLAYER_GUARD, { addr: address });

        if (cancel) return;
        const node = seed?.chanceMasterPlayerModels?.edges?.[0]?.node;
        const eid = node?.entity?.id ?? null;
        const lastId = node?.last_game_id != null ? String(node?.last_game_id) : null;
        const isInGame = !!node?.is_in_game;

        setGuardLoading(false);

        // If URL has a gid:
        if (gidStr) {
          // Normalize to canonical game id if needed
          if (lastId && gidStr !== lastId) {
            didNormalizeRef.current = true;
            r.replace(`/chess?game=${lastId}`);
          } else {
            // Debounce redirect to /match only if not seeded and user is not in game
            clearTimer(pendingRedirectTimerRef);
            if (!isInGame) {
              pendingRedirectTimerRef.current = window.setTimeout(() => {
                if (!seededOkRef.current && !cancel) {
                  r.replace('/match');
                }
              }, 2000);
            }
          }
        } else {
          // No gid in URL; choose destination
          if (isInGame && lastId) {
            r.replace(`/chess?game=${lastId}`);
          } else {
            r.replace('/match');
          }
        }

        if (!eid) return;

        // Subscribe for live normalization without flicker
        const client = getWsClient();
        let closed = false;
        const unsub = client.subscribe(
          { query: GQL_ENTITY_UPDATED, variables: { id: eid } },
          {
            next: (msg: unknown) => {
              if (cancel || closed) return;
              const models = (msg as EntityUpdatedMsg).data?.entityUpdated?.models ?? [];
              const pl = models.find((m): m is CM_Player => m.__typename === 'chance_master_Player');
              if (!pl) return;

              const liveInGame = !!pl.is_in_game;
              const liveLastId = pl.last_game_id != null ? String(pl.last_game_id) : null;

              if (liveInGame && liveLastId) {
                clearTimer(pendingRedirectTimerRef);
                if (sp.get('game') !== liveLastId) {
                  r.replace(`/chess?game=${liveLastId}`);
                }
                return;
              }

              // If not in game, only go to /match if we haven't seeded a board yet
              clearTimer(pendingRedirectTimerRef);
              pendingRedirectTimerRef.current = window.setTimeout(() => {
                if (!seededOkRef.current && !liveInGame && !liveLastId && !cancel) {
                  r.replace('/match');
                }
              }, 1200);
            },
            error: () => { },
            complete: () => { },
          }
        );
        stop = () => { try { closed = true; unsub(); } catch { } };
      } catch {
        setGuardLoading(false);
        if (!cancel) r.replace('/match');
      }
    })();

    return () => {
      clearTimer(pendingRedirectTimerRef);
      clearTimer(pendingNoWalletTimerRef);
      try { stop?.(); } catch { }
    };
  }, [address, gidStr, r, sp]);

  // ---------- Seed + subs (game/board/clock/claim) ----------
  const latestGameRef = useRef<CM_Game | null>(null);
  const latestBoardRef = useRef<CM_Board | null>(null);
  const latestClaimRef = useRef<CM_Claim | null>(null);

  useEffect(() => {
    if (gidStr == null) return;

    // reset seed ok status whenever gid changes
    seededOkRef.current = false;

    let stopBoard: (() => void) | null = null;
    let stopGame: (() => void) | null = null;
    let stopClock: (() => void) | null = null;
    let stopClaim: (() => void) | null = null;

    (async () => {
      try {
        const [boardSeed, gameSeed, clockSeed, claimSeed] = await Promise.all([
          gqlFetch<{ chanceMasterGameBoardModels: { edges: { node: (OnchainGameBoard & { entity?: { id: string } | null }) }[] } }>(GQL_BOARD_SEED, { id: gidStr }),
          gqlFetch<{ chanceMasterGameModels: { edges: { node: (OnchainGame & { entity?: { id: string } | null }) }[] } }>(GQL_GAME_SEED, { id: gidStr }),
          gqlFetch<{ chanceMasterGameClockModels: { edges: { node: { entity?: { id: string } | null; id: string | number; white_rem: string | number; black_rem: string | number; last_updated: string | number; } }[] } }>(GQL_CLOCK_SEED, { id: gidStr }),
          gqlFetch<{ chanceMasterGameClaimModels: { edges: { node: { entity?: { id: string } | null; id: string | number; claim: ClaimKind } }[] } }>(GQL_CLAIM_SEED, { id: gidStr }),
        ]);

        const boardNode = boardSeed?.chanceMasterGameBoardModels?.edges?.[0]?.node;
        const gameNode = gameSeed?.chanceMasterGameModels?.edges?.[0]?.node as CM_Game | undefined;
        const clockNode = clockSeed?.chanceMasterGameClockModels?.edges?.[0]?.node;
        const claimNode = claimSeed?.chanceMasterGameClaimModels?.edges?.[0]?.node as CM_Claim | undefined;

        const boardEid = boardNode?.entity?.id;
        const gameEid = gameNode?.entity?.id;
        const clockEid = clockNode?.entity?.id;
        const claimEid = claimNode?.entity?.id;

        if (!boardNode || !gameNode || !clockNode || !claimNode) {
          toast.error('Game not found');
          return;
        }

        latestBoardRef.current = { __typename: 'chance_master_GameBoard', ...(boardNode as any) };
        latestGameRef.current = { __typename: 'chance_master_Game', ...(gameNode as any) };
        latestClaimRef.current = claimNode;

        // Mark seed success early to suppress guard bouncing
        seededOkRef.current = true;

        // Seed dice from onchain prev_roll
        if (isSentinel(gameNode.prev_roll as any)) setDice([0, 0, 0]);
        else setDice(rollOnchainToUI(gameNode.prev_roll as any));

        setWhiteAddr(String(gameNode.white));
        setBlackAddr(String(gameNode.black));
        onchainTurnRef.current = Number(gameNode.turn ?? 0) === 0 ? 0 : 1;

        setClockBase({
          whiteSec: Number(clockNode.white_rem ?? 0),
          blackSec: Number(clockNode.black_rem ?? 0),
          lastUpdatedSec: Number(clockNode.last_updated ?? 0),
        });

        setFlagged({ white: false, black: false });
        toastFiredRef.current = { white: false, black: false };

        try {
          const fen = toFEN(boardNode, gameNode);
          setGame(new Chess(fen));
        } catch {
          toast.error('Could not build FEN from chain state');
        }

        setClaimKind((claimNode.claim as ClaimKind) ?? 'None');

        const client = getWsClient();

        if (boardEid) {
          let closed = false;
          const unsub = client.subscribe(
            { query: GQL_ENTITY_UPDATED, variables: { id: boardEid } },
            {
              next: (msg: unknown) => {
                if (closed) return;
                const models = (msg as EntityUpdatedMsg).data?.entityUpdated?.models ?? [];
                const b = models.find((m): m is CM_Board => m.__typename === 'chance_master_GameBoard');
                if (!b) return;
                latestBoardRef.current = b;
                const g = latestGameRef.current;
                if (!g) return;
                try {
                  const fen = toFEN(latestBoardRef.current!, g);
                  setGame(new Chess(fen));
                } catch { }
              },
              error: () => { },
              complete: () => { },
            }
          );
          stopBoard = () => { try { closed = true; unsub(); } catch { } };
        }

        if (gameEid) {
          let closed = false;
          const unsub = client.subscribe(
            { query: GQL_ENTITY_UPDATED, variables: { id: gameEid } },
            {
              next: (msg: unknown) => {
                if (closed) return;
                const models = (msg as EntityUpdatedMsg).data?.entityUpdated?.models ?? [];
                const g = models.find((m): m is CM_Game => m.__typename === 'chance_master_Game');
                if (!g) return;

                const prev = latestGameRef.current;
                latestGameRef.current = g;
                onchainTurnRef.current = Number(g.turn ?? 0) === 0 ? 0 : 1;

                // Dice from onchain
                if (isSentinel(g.prev_roll as any)) {
                  setDice([0, 0, 0]);
                  setRolling(false);
                } else {
                  setDice(rollOnchainToUI(g.prev_roll as any));
                  setRolling(false);
                }

                if (prev) {
                  if (!prev.white_draw_offered && g.white_draw_offered) toast.info('White offered a draw', { duration: 1600 });
                  if (!prev.black_draw_offered && g.black_draw_offered) toast.info('Black offered a draw', { duration: 1600 });
                  if ((prev.white_draw_offered || prev.black_draw_offered) && !g.white_draw_offered && !g.black_draw_offered) {
                    toast.message('Draw offer cleared', { duration: 1200 });
                  }
                  if (prev.result !== g.result && g.result && g.result !== 'None') {
                    const res = String(g.result);
                    toast.success(`Game ended · ${res === 'Draw' ? 'Draw' : `${res} wins`}`, { duration: 2200 });
                  }
                }

                const b = latestBoardRef.current;
                if (!b) return;
                try {
                  const fen = toFEN(b, g);
                  setGame(new Chess(fen));
                } catch { }
              },
              error: () => { },
              complete: () => { },
            }
          );
          stopGame = () => { try { closed = true; unsub(); } catch { } };
        }

        if (clockEid) {
          let closed = false;
          const unsub = client.subscribe(
            { query: GQL_ENTITY_UPDATED, variables: { id: clockEid } },
            {
              next: (msg: unknown) => {
                if (closed) return;
                const models = (msg as EntityUpdatedMsg).data?.entityUpdated?.models ?? [];
                const c = models.find((m): m is CM_Clock => m.__typename === 'chance_master_GameClock');
                if (!c) return;
                setClockBase({
                  whiteSec: Number(c.white_rem ?? 0),
                  blackSec: Number(c.black_rem ?? 0),
                  lastUpdatedSec: Number(c.last_updated ?? 0),
                });
              },
              error: () => { },
              complete: () => { },
            }
          );
          stopClock = () => { try { closed = true; unsub(); } catch { } };
        }

        if (claimEid) {
          let closed = false;
          const unsub = client.subscribe(
            { query: GQL_ENTITY_UPDATED, variables: { id: claimEid } },
            {
              next: (msg: unknown) => {
                if (closed) return;
                const models = (msg as EntityUpdatedMsg).data?.entityUpdated?.models ?? [];
                const c = models.find((m): m is CM_Claim => m.__typename === 'chance_master_GameClaim');
                if (!c) return;

                const prev = latestClaimRef.current;
                latestClaimRef.current = c;
                setClaimKind(c.claim);

                if (prev?.claim !== c.claim) {
                  if (c.claim !== 'None') toast.warning(`${c.claim} claim made`, { duration: 1600 });
                  else toast.message('Claim cleared/resolved', { duration: 1200 });
                }
              },
              error: () => { },
              complete: () => { },
            }
          );
          stopClaim = () => { try { closed = true; unsub(); } catch { } };
        }
      } catch {
        toast.error('GraphQL read failed');
      }
    })();

    return () => {
      try { stopBoard?.(); } catch { }
      try { stopGame?.(); } catch { }
      try { stopClock?.(); } catch { }
      try { stopClaim?.(); } catch { }
    };
  }, [gidStr, address]);

  // ---------- live display clocks ----------
  useEffect(() => {
    if (!shouldRun) {
      if (proving) return;
      setDisplayMs({ white: clockBase.whiteSec * 1000, black: clockBase.blackSec * 1000 });
      return;
    }

    let mounted = true;
    let raf: number | null = null;

    const tick = () => {
      if (!mounted) return;
      const nowSec = Date.now() / 1000;
      const elapsed = Math.max(0, nowSec - clockBase.lastUpdatedSec);

      const w = onchainTurnRef.current === 0
        ? Math.max(0, (clockBase.whiteSec - elapsed) * 1000)
        : clockBase.whiteSec * 1000;

      const b = onchainTurnRef.current === 1
        ? Math.max(0, (clockBase.blackSec - elapsed) * 1000)
        : clockBase.blackSec * 1000;

      setDisplayMs({ white: w, black: b });
      raf = requestAnimationFrame(tick);
    };

    raf = requestAnimationFrame(tick);
    return () => { mounted = false; if (raf) cancelAnimationFrame(raf); };
  }, [clockBase, shouldRun, proving]);

  // ---------- timeout guard ----------
  const fireTimeoutOnce = useCallback((side: 'white' | 'black') => {
    if (toastFiredRef.current[side]) return;
    toastFiredRef.current[side] = true;
    setFlagged((prev) => ({ ...prev, [side]: true }));
    toast.error(`${side[0].toUpperCase() + side.slice(1)} flagged`, { duration: 1800 });
  }, []);

  useEffect(() => {
    if (displayMs.white <= 0 && !flagged.white) fireTimeoutOnce('white');
    if (displayMs.black <= 0 && !flagged.black) fireTimeoutOnce('black');
  }, [displayMs.white, displayMs.black, flagged.white, flagged.black, fireTimeoutOnce]);

  // ---------- board actions ----------
  const allowedPieceSet = useMemo(() => {
    const s = new Set<'p' | 'n' | 'b' | 'r' | 'q' | 'k'>();
    for (const v of dice) if (v >= 1 && v <= 6) s.add(DIE_TO_PIECE[v]);
    return s;
  }, [dice]);

  const onPieceDrop = useCallback(
    async ({ sourceSquare, targetSquare }: { sourceSquare: string; targetSquare: string }) => {
      if (proving) return false;
      const piece = game.get(sourceSquare as any); if (!piece) return false;
      if (dice.every(d => d === 0)) { toast.error('Roll the dice first', { duration: 1400 }); return false; }
      if (piece.color !== (game.turn() as 'w' | 'b')) return false;
      if (!allowedPieceSet.has(piece.type)) { toast.error(`"${pieceName(piece.type)}" not allowed by dice`, { duration: 1600 }); return false; }

      const next = new Chess(game.fen({ forceEnpassantSquare: true }));
      const m: Move | null = next.move({ from: sourceSquare, to: targetSquare as string, promotion: 'q' });
      if (!m) return false;

      const prevFen = game.fen({ forceEnpassantSquare: true });
      const nextFen = next.fen({ forceEnpassantSquare: true });

      setProving(true);
      try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 20000);
        const payload: ProveRequest = { fen: prevFen, move: `${sourceSquare}${targetSquare ?? ''}`, dice };
        const res = await fetch('/api/prove', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(payload), signal: controller.signal });
        clearTimeout(timeoutId);
        if (!res.ok) { toast.error('Prover error', { duration: 1600 }); return false; }
        const data: ProveResponse = await res.json();
        if (data?.calldata?.length) {
          // local UX: show the move right away (subs will confirm/reconcile)
          setGame(new Chess(nextFen));
          setLast({ from: sourceSquare, to: targetSquare });
          setDice([0, 0, 0]);
          toast.success('Move proven', { duration: 900 });

          // flip clocks optimistically
          const nowSec = Date.now() / 1000;
          setClockBase({
            whiteSec: Math.ceil(displayMs.white / 1000),
            blackSec: Math.ceil(displayMs.black / 1000),
            lastUpdatedSec: nowSec,
          });
          onchainTurnRef.current = onchainTurnRef.current === 0 ? 1 : 0;

          // fire-and-forget onchain submit
          if (gidStr) {
            toast.message('Submitting move…', { duration: 700 });
            void submitMove(gidStr, data.calldata).catch((e) => {
              toast.error(e?.message ?? 'Move submit failed', { duration: 1800 });
            });
          }
        } else {
          toast.error('Proof invalid', { duration: 1600 });
          return false;
        }
      } catch {
        toast.error('Prover error', { duration: 1600 });
        return false;
      } finally {
        setProving(false);
      }
      return false;
    },
    [game, proving, dice, allowedPieceSet, displayMs, gidStr, submitMove]
  );

  // ---------- orientation ----------
  const whiteCanon = whiteAddr ? canonAddr32(whiteAddr) : null;
  const blackCanon = blackAddr ? canonAddr32(blackAddr) : null;

  const boardOrientation = useMemo<'white' | 'black'>(() => {
    if (!address || !whiteAddr || !blackAddr) return 'white';
    if (sameAddress(address, whiteAddr)) return 'white';
    if (sameAddress(address, blackAddr)) return 'black';
    return 'white';
  }, [address, whiteAddr, blackAddr]);

  const isMeWhite = boardOrientation === 'white';
  const oppCanon = isMeWhite ? blackCanon : whiteCanon;
  const meCanon = isMeWhite ? whiteCanon : blackCanon;

  const topTimeMs = isMeWhite ? displayMs.black : displayMs.white;
  const bottomTimeMs = isMeWhite ? displayMs.white : displayMs.black;

  const boardKey = `board-${boardOrientation}`;

  const options = useMemo(() => ({
    position: game.fen({ forceEnpassantSquare: true }),
    onPieceDrop,
    allowDragging: !proving,
    animationDurationInMs: 180,
    showNotation: true,
    boardOrientation,
    boardStyle: frameStyle,
    lightSquareStyle: lightSq,
    darkSquareStyle: darkSq,
    squareStyles: {
      legalMove: highlight,
      lastMove,
      ...(last ? { [last.from]: lastMove, [last.to]: lastMove } : {})
    },
  }), [game, onPieceDrop, proving, last, boardOrientation]);

  // ---------- TX handlers ----------
  const disableActions = guardLoading || !ready || !gidStr;

  const fireTx = (fn: () => Promise<unknown>, label: string) => {
    try {
      toast.message(`${label} sent`, { duration: 900 });
      void fn().catch((e) => {
        toast.error(e?.message ?? `${label} failed`, { duration: 1800 });
      });
    } catch (e: unknown) {
      toast.error((e as Error)?.message ?? `${label} failed`, { duration: 1800 });
    }
  };

  const meToMove =
    latestGameRef.current
      ? (latestGameRef.current.turn === 0 && sameAddress(address, whiteAddr)) ||
      (latestGameRef.current.turn === 1 && sameAddress(address, blackAddr))
      : false;

  const onResign = () => gidStr && fireTx(() => resign(gidStr), 'Resign');
  const onOfferDraw = () => gidStr && fireTx(() => offerDraw(gidStr), 'Offer draw');
  const onClaim = () => gidStr && fireTx(() => claim(gidStr, claimType), `Claim: ${claimType}`);
  const onAcceptClaim = () => gidStr && fireTx(() => acceptClaim(gidStr), 'Accept claim');
  const onAdjudicate = () => gidStr && fireTx(() => adjudicateClaim(gidStr), 'Adjudicate claim');
  const onFlag = () => gidStr && fireTx(() => flagWin(gidStr), 'Flag win');

  const prevRollSentinel = isSentinel(latestGameRef.current?.prev_roll as any);
  const canRoll = !!gidStr && ready && meToMove && prevRollSentinel && !proving && !rolling;

  const drawPending =
    latestGameRef.current?.white_draw_offered || latestGameRef.current?.black_draw_offered;

  const turnDot = (game.turn() as 'w' | 'b') === 'w' ? 'bg-emerald-400' : 'bg-purple-400';

  const whiteRunning = onchainTurnRef.current === 0 && shouldRun;
  const blackRunning = onchainTurnRef.current === 1 && shouldRun;

  const resultText = latestGameRef.current?.result && latestGameRef.current?.result !== 'None'
    ? String(latestGameRef.current.result)
    : null;

  const ended = !!resultText;

  useEffect(() => {
    if (ended) {
      const prev = document.body.style.overflow;
      document.body.style.overflow = 'hidden';
      return () => {
        document.body.style.overflow = prev;
      };
    }
  }, [ended]);
  return (
    <main className="min-h-screen">
      <div className="container mx-auto grid max-w-6xl grid-cols-1 gap-6 p-6 lg:grid-cols-[minmax(320px,640px)_1fr]">
        <div className="rounded-2xl p-4" style={{ background: 'linear-gradient(180deg,rgba(17,27,34,.92),rgba(11,19,24,.92))' }}>

          {/* Top bar (opponent) */}
          <HUDBar
            label="Opponent"
            address={oppCanon}
            timeMs={topTimeMs}
            accent={boardOrientation === 'white' ? 'purple' : 'emerald'}
          />

          <div
            className="board-wrap themed-board glass-board relative"
            style={{ width: '100%', aspectRatio: '1 / 1' }}
          >
            <Chessboard key={boardKey} options={options as any} />
            <div className="board-sheen" aria-hidden />
            <div className="board-reflections" aria-hidden />


            {(proving || guardLoading) && (
              <div
                className="
      absolute inset-0 z-30 grid place-items-center rounded-2xl
      bg-black/40 backdrop-blur-md
      before:pointer-events-none before:absolute before:inset-0 before:rounded-2xl before:opacity-60
      before:bg-[radial-gradient(60%_50%_at_50%_50%,rgba(16,185,129,0.18)_0%,transparent_60%)]
    "
              >
                <div
                  className="
        relative rounded-xl border border-emerald-400/20
        bg-[linear-gradient(180deg,rgba(17,27,34,0.95),rgba(11,19,24,0.92))]
        px-4 py-3 text-sm text-white/90 shadow-[0_10px_40px_rgba(16,185,129,0.15)]
        ring-1 ring-white/5
      "
                  role="status"
                  aria-live="polite"
                >
                  <div className="flex items-center gap-2">
                    <svg
                      className="h-4 w-4 animate-spin text-emerald-300"
                      viewBox="0 0 24 24"
                      fill="none"
                      aria-hidden="true"
                    >
                      <circle className="opacity-20" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="3" />
                      <path d="M22 12a10 10 0 0 1-10 10" stroke="currentColor" strokeWidth="3" strokeLinecap="round" />
                    </svg>
                    <span className="font-medium">
                      {guardLoading ? 'Loading player…' : 'Proving…'}
                    </span>
                  </div>
                  <div className="mt-1 text-[11px] text-white/60">
                    {guardLoading ? 'Connecting wallet / fetching game state' : 'Generating zk proof for your move'}
                  </div>
                </div>
              </div>
            )}
            {drawPending && (
              <div className="pointer-events-none absolute inset-x-2 bottom-2 z-30 grid place-items-center">
                <div className="rounded-md bg-white/10 px-3 py-2 text-xs text-white/90">
                  Draw offered — you may accept by offering a draw back.
                </div>
              </div>
            )}
          </div>

          {/* Bottom bar (you) */}
          <HUDBar
            label="You"
            address={meCanon}
            timeMs={bottomTimeMs}
            accent={boardOrientation === 'white' ? 'emerald' : 'purple'}
          />
        </div>

        {/* ---------------- RIGHT PANEL ---------------- */}
        <aside className="space-y-4 rounded-2xl p-4" style={{ background: 'linear-gradient(180deg,rgba(17,27,34,.92),rgba(11,19,24,.92))' }}>
          {/* Header: Turn & status */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className={`h-2.5 w-2.5 rounded-full ${turnDot}`} />
              <h2 className="text-base font-medium text.white/90">
                {(game.turn() as 'w' | 'b') === 'w' ? 'White to move' : 'Black to move'}
              </h2>
            </div>
            {resultText ? (
              <span className="rounded-md bg-white/10 px-2 py-1 text-xs text-white/80">
                Result: {resultText}
              </span>
            ) : null}
          </div>

          {/* Clocks */}
          <div className="grid grid-cols-2 gap-3">
            <Timer
              key={`w-${Math.floor(displayMs.white / 1000)}-${onchainTurnRef.current}`}
              label="White"
              initial={displayMs.white}
              running={whiteRunning}
              accent="white"
              invert
              onTimeout={() => fireTimeoutOnce('white')}
            />
            <Timer
              key={`b-${Math.floor(displayMs.black / 1000)}-${onchainTurnRef.current}`}
              label="Black"
              initial={displayMs.black}
              running={blackRunning}
              accent="black"
              invert
              onTimeout={() => fireTimeoutOnce('black')}
            />
          </div>

          {(flagged.white || flagged.black) && (
            <div className="rounded-lg bg-white/10 p-3 text-sm text-white/90">
              {flagged.white ? 'White flagged — Black wins on time.' : 'Black flagged — White wins on time.'}
            </div>
          )}

          {/* Quick status row */}
          <div className="grid grid-cols-3 gap-3 text-sm">
            <div className="rounded-lg bg-white/5 p-3">
              <div className="text-xs text-white/60">last move</div>
              <div className="mt-1 font-mono text-xs">
                {last ? `${last.from}→${last.to}` : <span className="text-white/40">—</span>}
              </div>
            </div>
            <div className="rounded-lg bg-white/5 p-3">
              <div className="text-xs text-white/60">claim</div>
              <div className="mt-1">{claimKind !== 'None' ? claimKind : '—'}</div>
            </div>
            <div className="rounded-lg bg-white/5 p-3">
              <div className="text-xs text-white/60">draw</div>
              <div className={`mt-1 inline-flex items-center gap-1 ${drawPending ? 'text-amber-300' : 'text-white/70'}`}>
                <span className={`h-1.5 w-1.5 rounded-full ${drawPending ? 'bg-amber-300' : 'bg-white/30'}`} />
                {drawPending ? 'Offered' : '—'}
              </div>
            </div>
          </div>

          {/* Dice */}
          <DiceTray
            values={dice}
            rolling={rolling}
            onRoll={
              canRoll
                ? () => {
                  setRolling(true);
                  toast.message('Roll sent', { duration: 900 });
                  void roll(gidStr!).catch((e) => {
                    setRolling(false);
                    toast.error(e?.message ?? 'Roll failed', { duration: 1800 });
                  });
                }
                : undefined
            }
            active={game.turn() as 'w' | 'b'}
            title="dice"
          />

          {/* Draw controls */}
          <section className="glass-card p-3">
            <div className="mb-2 flex items-center justify-between">
              <div className="text-sm font-medium text-white/80">Draw</div>
              {drawPending && (
                <span className="rounded-md bg-amber-500/15 px-2 py-0.5 text-[11px] text-amber-300">
                  offered
                </span>
              )}
            </div>
            <div className="grid grid-cols-2 gap-2">
              <button
                onClick={onOfferDraw}
                disabled={disableActions}
                className="btn btn-ghost disabled:opacity-50"
              >
                Offer Draw
              </button>
              <button
                onClick={onOfferDraw}
                disabled={disableActions || !drawPending || !meToMove}
                className="btn btn-primary disabled:opacity-50"
                title="Protocol: accept by offering back while it's your move"
              >
                Accept Draw
              </button>
            </div>
            {drawPending && (
              <p className="mt-2 text-xs text-white/60">
                To accept a draw, the side-to-move must also offer a draw.
              </p>
            )}
          </section>

          {/* Claims (radio bar) */}
          <section className="glass-card p-3">
            <div className="mb-2 text-sm font-medium text-white/80">Claims</div>

            <div className="mb-3">
              <div className="inline-grid grid-cols-2 overflow-hidden rounded-md border border-white/15">
                {(['Checkmate', 'Stalemate'] as const).map((opt, idx) => {
                  const active = claimType === opt;
                  return (
                    <button
                      key={opt}
                      type="button"
                      onClick={() => setClaimType(opt)}
                      className={[
                        'px-3 py-1.5 text-sm transition',
                        active ? 'bg-white/15 text-white' : 'bg-black/20 text-white/70 hover:text-white/90',
                        idx === 0 ? 'border-r border-white/10' : '',
                      ].join(' ')}
                    >
                      {opt}
                    </button>
                  );
                })}
              </div>
            </div>

            <div className="grid grid-cols-3 gap-2">
              <button onClick={onClaim} disabled={disableActions} className="btn btn-primary disabled:opacity-50">Claim</button>
              <button onClick={onAcceptClaim} disabled={disableActions || !(claimKind !== 'None' && meToMove)} className="btn btn-ghost disabled:opacity-50">Accept</button>
              <button onClick={onAdjudicate} disabled={disableActions || claimKind === 'None'} className="btn btn-ghost disabled:opacity-50">Adjudicate</button>
            </div>
            {claimKind !== 'None' && (
              <p className="mt-2 text-xs text-white/60">
                Only side-to-move may accept. Adjudication succeeds if opponent’s clock has expired.
              </p>
            )}
            <p className="mt-2 text-xs text-white/60">
              You can refute a claim by playing a valid move
            </p>
          </section>

          {/* Gameplay actions */}
          <section className="glass-card p-3">
            <div className="mb-2 text-sm font-medium text-white/80">Gameplay</div>
            <div className="grid grid-cols-2 gap-2">
              <button onClick={onFlag} disabled={disableActions} className="btn btn-ghost disabled:opacity-50">Flag Win</button>
              <button onClick={onResign} disabled={disableActions} className="btn btn-ghost disabled:opacity-50">Resign</button>
            </div>
          </section>
        </aside>
      </div>
      {ended && (
        <EndGameDialog
          result={resultText!}
          onPlayAgain={() => r.replace('/match')}
          onHome={() => r.replace('/')}
        />
      )}
    </main>
  );
}

function pieceName(t: 'p' | 'n' | 'b' | 'r' | 'q' | 'k') {
  switch (t) {
    case 'p': return 'pawn';
    case 'n': return 'knight';
    case 'b': return 'bishop';
    case 'r': return 'rook';
    case 'q': return 'queen';
    case 'k': return 'king';
  }
}

