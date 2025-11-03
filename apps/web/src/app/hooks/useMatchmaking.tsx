// src/app/hooks/useMatchmaking.tsx
'use client';

import { useCallback, useEffect, useRef, useState } from 'react';
import { useAccount } from '@starknet-react/core';
import { gqlFetch, getWsClient } from '../lib/torii-graphql';
import { useActions } from '../lib/actions';

export type MatchmakingState = {
  queue: Array<String>;
  is_enqueued: boolean;
  is_in_game: boolean;
  last_game_id: number | null;

  loadingQ: boolean; // queue loading
  loadingP: boolean; // player loading
  error?: string | null;
};

// --- GraphQL (exact names) ---
const GQL_GLOBALS_SEED = /* GraphQL */ `
  query GlobalsSeed {
    chanceMasterGlobalVarsModels(where: { id: 1 }, limit: 1) {
      edges {
        node {
          entity { id }
          id
          queue
        }
      }
    }
  }
`;

const GQL_PLAYER_SEED = /* GraphQL */ `
  query PlayerSeed($addr: ContractAddress) {
    chanceMasterPlayerModels(where: { contract_address: $addr }, limit: 1) {
      edges {
        node {
          entity { id }
          contract_address
          is_enqueued
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
        ... on chance_master_GlobalVars { queue }
        ... on chance_master_Player {
          contract_address
          is_enqueued
          is_in_game
          last_game_id
        }
      }
    }
  }
`;

export function useMatchmaking() {
  const { address } = useAccount();
  const { enqueue } = useActions();

  const [st, setSt] = useState<MatchmakingState>({
    queue: [],
    is_enqueued: false,
    is_in_game: false,
    last_game_id: null,
    loadingQ: true,
    loadingP: true,
    error: null,
  });

  console.log(st)
  // ---------- GlobalVars: seed + subscribe ----------
  useEffect(() => {
    let cancel = false;
    let stop: (() => void) | null = null;

    (async () => {
      try {
        const seed = await gqlFetch<any>(GQL_GLOBALS_SEED);
        const node = seed?.chanceMasterGlobalVarsModels?.edges?.[0]?.node;
        const eid: string | undefined = node?.entity?.id;

        const queue: string[] = Array.isArray(node?.queue) ? node.queue : [];
        if (!cancel) {
          setSt((s) => ({
            ...s,
            queue,
            loadingQ: false,
            error: null,
          }));
        }

        if (!eid) return;

        const client = getWsClient();
        let closed = false;
        const unsub = client.subscribe(
          { query: GQL_ENTITY_UPDATED, variables: { id: eid } },
          {
            next: (msg) => {
              if (cancel || closed) return;
              const models = msg?.data?.entityUpdated?.models ?? [];
              const gv = models.find(
                (m: any) => m.__typename === 'chance_master_GlobalVars'
              );
              if (!gv) return;

              const q: string[] = Array.isArray(gv.queue) ? gv.queue : [];

              setSt((s) => ({ ...s, queue: q }));
            },
            error: () => { },
            complete: () => { },
          }
        );
        stop = () => {
          try {
            closed = true;
            unsub();
          } catch { }
        };
      } catch (e: any) {
        if (!cancel) {
          setSt((s) => ({
            ...s,
            loadingQ: false,
            error: e?.message ?? 'Globals subscribe failed',
          }));
        }
      }
    })();

    return () => {
      cancel = true;
      try {
        stop?.();
      } catch { }
    };
  }, [address]);

  // ---------- Player: seed + subscribe ----------
  useEffect(() => {
    let cancel = false;
    let stop: (() => void) | null = null;

    if (!address) {
      // clear on sign-out
      setSt((s) => ({
        ...s,
        is_enqueued: false,
        is_in_game: false,
        last_game_id: null,
        loadingP: false,
      }));
      return;
    }

    (async () => {
      try {
        const seed = await gqlFetch<any>(GQL_PLAYER_SEED, { addr: address });
        const node = seed?.chanceMasterPlayerModels?.edges?.[0]?.node;
        const eid: string | undefined = node?.entity?.id;

        if (node) {
          if (!cancel) {
            setSt((s) => ({
              ...s,
              is_enqueued: node.is_enqueued,
              is_in_game: node.is_in_game,
              last_game_id: node.last_game_id,
              loadingP: false,
              error: null,
            }));
          }
        } else if (!cancel) {
          setSt((s) => ({ ...s, loadingP: false }));
        }

        if (!eid) return;

        const client = getWsClient();
        let closed = false;
        const unsub = client.subscribe(
          { query: GQL_ENTITY_UPDATED, variables: { id: eid } },
          {
            next: (msg) => {
              if (cancel || closed) return;
              const models = msg?.data?.entityUpdated?.models ?? [];
              const pl = models.find(
                (m: any) => m.__typename === 'chance_master_Player'
              );
              if (!pl) return;

              console.log(pl)
              setSt((s) => ({
                ...s,
                is_enqueued: pl.is_enqueued,
                is_in_game: pl.is_in_game,
                last_game_id: pl.last_game_id,
              }));
            },
            error: () => { },
            complete: () => { },
          }
        );
        stop = () => {
          try {
            closed = true;
            unsub();
          } catch { }
        };
      } catch (e: any) {
        if (!cancel) {
          setSt((s) => ({
            ...s,
            loadingP: false,
            error: e?.message ?? 'Player subscribe failed',
          }));
        }
      }
    })();

    return () => {
      cancel = true;
      try {
        stop?.();
      } catch { }
    };
  }, [address]);

  // enqueue-once helper (simple guards)
  const enqOnceRef = useRef(false);
  const ensureEnqueued = useCallback(async () => {
    if (!address) return;
    if (enqOnceRef.current) return;

    if (st.loadingQ || st.loadingP) return;

    if (st.is_in_game || st.is_enqueued) return;

    try {
      const fresh = await gqlFetch<any>(GQL_PLAYER_SEED, { addr: address });
      const node = fresh?.chanceMasterPlayerModels?.edges?.[0]?.node;
      const stillInGame =
        !!node?.is_in_game && Number(node?.last_game_id ?? 0) > 0;
      const stillEnqueued = !!node?.is_enqueued;
      if (stillInGame || stillEnqueued) return; // bail if state changed
    } catch {
      return;
    }

    enqOnceRef.current = true;
    try {
      await enqueue({
        onRevert: () => { enqOnceRef.current = false; },
      });
    } catch {
      enqOnceRef.current = false;
    }
  }, [address, enqueue, st.loadingQ, st.loadingP, st.is_in_game, st.is_enqueued]);
  const loading = st.loadingQ || st.loadingP;
  return { ...st, loading, ensureEnqueued };
}

