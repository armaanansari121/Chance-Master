// src/app/lib/actions.ts
'use client';

import { useAccount, useSendTransaction } from '@starknet-react/core';
import { invokeOptimistic, OptimisticOpts } from './optimistic-tx';

// ===== Contract (ACTIONS) =====
const ACTIONS_ADDRESS =
  ('0x00eaec51fd4735de22d26feb034b1f3c8076ba6045940ec21ac1157b48e771b2' as const);

// ---------- helpers ----------
type BigNumberish = string | number | bigint;

// Mirror your Cairo enum: None=0, Checkmate=1, Stalemate=2
export type ClaimType = 'Checkmate' | 'Stalemate';
const encodeClaimType = (c: ClaimType): number => (c === 'Checkmate' ? 1 : 2);

// Pre-built call shapes for no-arg entrypoints
const callEnqueue = { contractAddress: ACTIONS_ADDRESS, entrypoint: 'enqueue', calldata: [] as any[] } as const;
const callDequeue = { contractAddress: ACTIONS_ADDRESS, entrypoint: 'dequeue', calldata: [] as any[] } as const;

export function useActions() {
  const { account, status } = useAccount();
  const ready = status === 'connected' && !!account;
  const { sendAsync: sendTx } = useSendTransaction({});

  // -------- existing --------
  async function enqueue(ui?: OptimisticOpts<any>) {
    if (!ready) throw new Error('Wallet not connected');
    return invokeOptimistic(
      async () => {
        const res = await sendTx([callEnqueue]);
        await account!.waitForTransaction(res.transaction_hash);
        return res.transaction_hash;
      },
      ui
    );
  }

  async function dequeue(ui?: OptimisticOpts<any>) {
    if (!ready) throw new Error('Wallet not connected');
    return invokeOptimistic(
      async () => {
        const res = await sendTx([callDequeue]);
        await account!.waitForTransaction(res.transaction_hash);
        return res.transaction_hash;
      },
      ui
    );
  }

  // -------- new actions --------

  /** roll(game_id) -> (u8,u8,u8). UI should read updates via Torii/GraphQL. */
  async function roll(gameId: BigNumberish, ui?: OptimisticOpts<any>) {
    if (!ready) throw new Error('Wallet not connected');
    const call = {
      contractAddress: ACTIONS_ADDRESS,
      entrypoint: 'roll',
      calldata: [String(gameId)],
    };
    return invokeOptimistic(
      async () => {
        const res = await sendTx([call]);
        await account!.waitForTransaction(res.transaction_hash);
        return res.transaction_hash;
      },
      ui
    );
  }

  /**
   * submit_move(game_id, full_proof_with_hints: Span<felt252>)
   * `proofCalldata` must be the flat array returned by your prover (hex strings ok).
   */
  async function submitMove(
    gameId: BigNumberish,
    proofCalldata: (string | number | bigint)[],
    ui?: OptimisticOpts<any>
  ) {
    if (!ready) throw new Error('Wallet not connected');
    if (!Array.isArray(proofCalldata) || proofCalldata.length === 0) {
      throw new Error('Missing/empty proof calldata');
    }
    const toHexFelt = (v: string | number | bigint) =>
      typeof v === 'bigint'
        ? `0x${v.toString(16)}`
        : typeof v === 'number'
          ? `0x${BigInt(v).toString(16)}`
          : v.startsWith('0x')
            ? v
            : `0x${BigInt(v).toString(16)}`;
    console.log(toHexFelt(proofCalldata.length))
    const lenHexa = toHexFelt(proofCalldata.length)
    const call = {
      contractAddress: ACTIONS_ADDRESS,
      entrypoint: 'submit_move',
      calldata: [String(gameId), lenHexa, ...proofCalldata],
    };
    return invokeOptimistic(
      async () => {
        const res = await sendTx([call]);
        await account!.waitForTransaction(res.transaction_hash);
        return res.transaction_hash;
      },
      ui
    );
  }

  async function resign(gameId: BigNumberish, ui?: OptimisticOpts<any>) {
    if (!ready) throw new Error('Wallet not connected');
    const call = {
      contractAddress: ACTIONS_ADDRESS,
      entrypoint: 'resign',
      calldata: [String(gameId)],
    };
    return invokeOptimistic(
      async () => {
        const res = await sendTx([call]);
        await account!.waitForTransaction(res.transaction_hash);
        return res.transaction_hash;
      },
      ui
    );
  }

  async function offerDraw(gameId: BigNumberish, ui?: OptimisticOpts<any>) {
    if (!ready) throw new Error('Wallet not connected');
    const call = {
      contractAddress: ACTIONS_ADDRESS,
      entrypoint: 'offer_draw',
      calldata: [String(gameId)],
    };
    return invokeOptimistic(
      async () => {
        const res = await sendTx([call]);
        await account!.waitForTransaction(res.transaction_hash);
        return res.transaction_hash;
      },
      ui
    );
  }

  async function claim(gameId: BigNumberish, claimType: ClaimType, ui?: OptimisticOpts<any>) {
    if (!ready) throw new Error('Wallet not connected');
    const call = {
      contractAddress: ACTIONS_ADDRESS,
      entrypoint: 'claim',
      // ClaimType discriminant (1=Checkmate, 2=Stalemate)
      calldata: [String(gameId), encodeClaimType(claimType)],
    };
    return invokeOptimistic(
      async () => {
        const res = await sendTx([call]);
        await account!.waitForTransaction(res.transaction_hash);
        return res.transaction_hash;
      },
      ui
    );
  }

  async function acceptClaim(gameId: BigNumberish, ui?: OptimisticOpts<any>) {
    if (!ready) throw new Error('Wallet not connected');
    const call = {
      contractAddress: ACTIONS_ADDRESS,
      entrypoint: 'accept_claim',
      calldata: [String(gameId)],
    };
    return invokeOptimistic(
      async () => {
        const res = await sendTx([call]);
        await account!.waitForTransaction(res.transaction_hash);
        return res.transaction_hash;
      },
      ui
    );
  }

  async function adjudicateClaim(gameId: BigNumberish, ui?: OptimisticOpts<any>) {
    if (!ready) throw new Error('Wallet not connected');
    const call = {
      contractAddress: ACTIONS_ADDRESS,
      entrypoint: 'adjudicate_claim',
      calldata: [String(gameId)],
    };
    return invokeOptimistic(
      async () => {
        const res = await sendTx([call]);
        await account!.waitForTransaction(res.transaction_hash);
        return res.transaction_hash;
      },
      ui
    );
  }

  async function flagWin(gameId: BigNumberish, ui?: OptimisticOpts<any>) {
    if (!ready) throw new Error('Wallet not connected');
    const call = {
      contractAddress: ACTIONS_ADDRESS,
      entrypoint: 'flag_win',
      calldata: [String(gameId)],
    };
    return invokeOptimistic(
      async () => {
        const res = await sendTx([call]);
        await account!.waitForTransaction(res.transaction_hash);
        return res.transaction_hash;
      },
      ui
    );
  }

  return {
    enqueue,
    dequeue,
    ready,
    roll,
    submitMove,
    resign,
    offerDraw,
    claim,
    acceptClaim,
    adjudicateClaim,
    flagWin,
  };
}

