'use client';

import { useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { useAccount } from '@starknet-react/core';
import { toast } from 'sonner';
import { useActions } from '../lib/actions';
import { gqlFetch } from '../lib/torii-graphql';

/** EXACT playground-style query name + fields */
const GQL_PLAYER_BY_ADDR = /* GraphQL */ `
  query PlayerByAddr($addr: String!) {
    chanceMasterPlayerModels(where: { contract_address: $addr }, limit: 1) {
      edges {
        node {
          contract_address
          is_enqueued
          is_in_game
          last_game_id
        }
      }
    }
  }
`;

export default function QueueButton() {
  const r = useRouter();
  const { address } = useAccount();
  const { ready } = useActions();

  const onPlay = useCallback(async () => {
    if (!ready) { toast.error('Connect wallet first'); return; }
    if (!address) { toast.error('No wallet address'); return; }

    try {
      const addr = address.toLowerCase();
      const data = await gqlFetch<{
        chanceMasterPlayerModels: {
          edges: {
            node: {
              contract_address: string;
              is_enqueued: boolean;
              is_in_game: boolean;
              last_game_id: number | string | null;
            }
          }[]
        }
      }>(GQL_PLAYER_BY_ADDR, { addr });

      const node = data?.chanceMasterPlayerModels?.edges?.[0]?.node;
      const isInGame = node?.is_in_game;
      const gameId = node?.last_game_id;

      if (isInGame && gameId != null) {
        r.push(`/chess?game=${gameId}`);
      } else {
        r.push('/match');
      }
    } catch (e) {
      console.warn('[PLAY] GQL error:', e);
      // fallback to match page if query fails
      r.push('/match');
    }
  }, [ready, address, r]);

  return (
    <button
      onClick={onPlay}
      disabled={!ready}
      className="rounded-lg bg-emerald-400 px-5 py-3 text-sm font-medium text-black disabled:opacity-50"
    >
      Play
    </button>
  );
}

