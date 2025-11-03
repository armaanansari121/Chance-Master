'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAccount } from '@starknet-react/core';
import { toast } from 'sonner';
import { useActions } from '../lib/actions';
import { useMatchmaking } from '../hooks/useMatchmaking';

export default function MatchPage() {
  const r = useRouter();
  const { address } = useAccount();
  const { enqueue, dequeue, ready } = useActions();

  const {
    queue,
    is_enqueued,
    is_in_game,
    last_game_id,
    loading,   // true until both globals + player seed are fetched
    error,
    ensureEnqueued,
  } = useMatchmaking();

  // ----- wallet guard (same pattern as chess page) -----
  const addressRef = useRef<string | null>(null);
  useEffect(() => { addressRef.current = address ?? null; }, [address]);

  const [guardLoading, setGuardLoading] = useState<boolean>(true);
  const pendingNoWalletTimerRef = useRef<number | null>(null);

  useEffect(() => {
    if (!address) {
      setGuardLoading(true);
      if (pendingNoWalletTimerRef.current) {
        clearTimeout(pendingNoWalletTimerRef.current);
        pendingNoWalletTimerRef.current = null;
      }
      pendingNoWalletTimerRef.current = window.setTimeout(() => {
        if (!addressRef.current) {
          r.replace('/'); // back to home to connect wallet
        }
      }, 2500);
      return () => {
        if (pendingNoWalletTimerRef.current) {
          clearTimeout(pendingNoWalletTimerRef.current);
          pendingNoWalletTimerRef.current = null;
        }
      };
    }

    setGuardLoading(false);
    if (pendingNoWalletTimerRef.current) {
      clearTimeout(pendingNoWalletTimerRef.current);
      pendingNoWalletTimerRef.current = null;
    }
    return () => {
      if (pendingNoWalletTimerRef.current) {
        clearTimeout(pendingNoWalletTimerRef.current);
        pendingNoWalletTimerRef.current = null;
      }
    };
  }, [address, r]);
  // ----- end guard -----

  const queueLen = useMemo(
    () => (Array.isArray(queue) ? queue.length : 0),
    [queue]
  );

  const inQueue = useMemo(
    () =>
      !!address &&
      Array.isArray(queue) &&
      queue.some((a) => (a || '').toLowerCase() === address.toLowerCase()),
    [queue, address]
  );

  // Treat 0 as "no game". Only proceed once we HAVE a value from GraphQL.
  const gameId = useMemo(() => {
    if (last_game_id == null) return null;        // not received yet (wait)
    const n = Number(last_game_id);
    return n > 0 ? n : null;                      // 0 => null
  }, [last_game_id]);

  // redirect when we are in a game AND have a valid game id
  useEffect(() => {
    if (loading) return;                          // wait for seed
    if (is_in_game && gameId != null) {
      r.replace(`/chess?game=${gameId}`);
    }
  }, [is_in_game, gameId, loading, r]);

  // enqueue exactly once when eligible
  const inFlight = useRef(false);
  const triedOnce = useRef(false);
  useEffect(() => {
    if (loading) return;                          // wait for seed
    if (!ready || !address) return;
    if (is_in_game || is_enqueued) return;
    if (inFlight.current || triedOnce.current) return;

    inFlight.current = true;
    (async () => {
      try {
        await ensureEnqueued();
        triedOnce.current = true;
      } finally {
        inFlight.current = false;
      }
    })();
  }, [ready, address, is_in_game, is_enqueued, loading, gameId, ensureEnqueued]);

  const onCancel = async () => {
    if (!ready) { r.replace('/'); return; }
    try {
      r.replace('/'); // optimistic nav
      await dequeue();
      triedOnce.current = false;
      inFlight.current = false;
    } catch (e: any) {
      toast.error(e?.message ?? 'Could not cancel matchmaking');
    }
  };

  return (
    <main className="relative min-h-[calc(100vh-56px)] pt-16">
      {/* Themed overlay while deciding wallet state on first load */}
      {guardLoading && (
        <div className="
          absolute inset-0 z-20 grid place-items-center
          bg-black/40 backdrop-blur-md
          before:pointer-events-none before:absolute before:inset-0 before:opacity-60
          before:bg-[radial-gradient(60%_50%_at_50%_50%,rgba(16,185,129,0.18)_0%,transparent_60%)]
        ">
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
              {/* spinner (inherits currentColor via text-emerald-300) */}
              <svg
                className="h-4 w-4 animate-spin text-emerald-300"
                viewBox="0 0 24 24"
                fill="none"
                aria-hidden="true"
              >
                <circle className="opacity-20" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="3" />
                <path d="M22 12a10 10 0 0 1-10 10" stroke="currentColor" strokeWidth="3" strokeLinecap="round" />
              </svg>
              <span className="font-medium">Loading player…</span>
            </div>
            <div className="mt-1 text-[11px] text-white/60">Connecting wallet / fetching player state</div>
          </div>
        </div>
      )}

      <div className="mx-auto max-w-3xl p-6">
        <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-6">
          <div className="mb-4 flex items-center justify-between">
            <h1 className="text-xl font-semibold">Matchmaking</h1>
          </div>

          <div className="rounded-lg bg-gradient-to-b from-white/5 to-transparent p-6 text-center">
            <div className="mb-2 text-white/80">
              {error
                ? `Error: ${error}`
                : loading
                  ? 'Looking for a match…'
                  : `Queue: ${queueLen} player${queueLen === 1 ? '' : 's'}${inQueue ? ' • you’re in!' : ''}`}
            </div>

            <div className="mx-auto h-1.5 w-40 overflow-hidden rounded bg-white/10">
              <div className="h-full w-1/3 animate-[pulse_1.6s_ease-in-out_infinite] bg-emerald-400/60" />
            </div>

            <div className="mt-6">
              <button
                onClick={onCancel}
                className="rounded-md border border-white/15 bg-white/[0.04] px-4 py-2 text-sm text-white/90 hover:bg-white/[0.08]"
              >
                Cancel
              </button>
            </div>

            <p className="mt-6 text-xs text-white/50">
              We’ll move you to the game as soon as an opponent is found.
            </p>
          </div>
        </div>
      </div>
    </main>
  );
}

