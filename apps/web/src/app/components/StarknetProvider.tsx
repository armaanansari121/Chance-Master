// apps/web/src/app/components/StarknetProvider.tsx
'use client';

import { StarknetConfig, jsonRpcProvider, cartridge } from '@starknet-react/core';
import { sepolia, mainnet } from '@starknet-react/chains';
import { ControllerConnector } from '@cartridge/connector';
import Controller, { toSessionPolicies } from '@cartridge/controller';

const ACTIONS_ADDRESS =
  '0x00eaec51fd4735de22d26feb034b1f3c8076ba6045940ec21ac1157b48e771b2'; // your chance_master-actions

// Define simple policies and normalize them for the controller
const rawPolicies = {
  contracts: {
    [ACTIONS_ADDRESS]: {
      name: 'Chance Master – actions',
      description: 'Gameplay calls',
      methods: [
        { name: 'enqueue', entrypoint: 'enqueue' },
        { name: 'dequeue', entrypoint: 'dequeue' },
        { name: 'roll', entrypoint: 'roll' },
        { name: 'submit_move', entrypoint: 'submit_move' },
        { name: 'resign', entrypoint: 'resign' },
        { name: 'offer_draw', entrypoint: 'offer_draw' },
        { name: 'claim', entrypoint: 'claim' },
        { name: 'accept_claim', entrypoint: 'accept_claim' },
        { name: 'adjudicate_claim', entrypoint: 'adjudicate_claim' },
      ],
    },
  },
} as const;

const policies = toSessionPolicies(rawPolicies);

// Create the connector once (module scope)
export const controllerConnector = new ControllerConnector({
  policies,
  // you can also pass a custom theme/preset here if you want
});

// JSON-RPC provider with Cartridge endpoints, Sepolia + Mainnet
const provider = jsonRpcProvider({
  rpc: (chain) => {
    switch (chain) {
      case sepolia:
        return { nodeUrl: 'https://api.cartridge.gg/x/starknet/sepolia' };
      default:
        return { nodeUrl: 'https://api.cartridge.gg/x/starknet/mainnet' };
    }
  },
});

export default function StarknetProvider({ children }: { children: React.ReactNode }) {
  return (
    <StarknetConfig
      autoConnect
      defaultChainId={sepolia.id}
      chains={[sepolia, mainnet]}
      provider={provider}
      connectors={[controllerConnector]}
      explorer={cartridge}
    >
      {children}
    </StarknetConfig>
  );
}

