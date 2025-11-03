// src/app/match/page.tsx
'use client';

import { useEffect, useMemo, useRef } from 'react';
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
  // If GraphQL hasn’t returned yet, loading=true, so nothing runs.
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

    // block enqueue if: already in game, already enqueued, or a valid game id exists
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
    <main className="min-h-[calc(100vh-56px)] pt-16">
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
              <div className="h-full w-1/3 animate-[pulse_1.6s_ease-in-out_infinite]" />
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

