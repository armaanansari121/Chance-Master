export const ACTIONS_ADDRESS =
  ('0x00eaec51fd4735de22d26feb034b1f3c8076ba6045940ec21ac1157b48e771b2' as const);

// Only write methods a player needs during gameplay.
// Reads (get_game*, get_globals, etc.) don't need policies.
export function buildPolicies(): unknown {
  return {
    contracts: {
      [ACTIONS_ADDRESS]: {
        name: 'Chance Master — Actions',
        description: 'Match queue, rolls, moves and claims',
        methods: [
          { name: 'Queue: Enqueue', entrypoint: 'enqueue' },
          { name: 'Queue: Dequeue', entrypoint: 'dequeue' },
          { name: 'Roll Dice', entrypoint: 'roll' },
          { name: 'Submit Move', entrypoint: 'submit_move' },
          { name: 'Resign', entrypoint: 'resign' },
          { name: 'Offer Draw', entrypoint: 'offer_draw' },
          { name: 'Claim (mate/stalemate)', entrypoint: 'claim' },
          { name: 'Accept Claim', entrypoint: 'accept_claim' },
          { name: 'Adjudicate Claim', entrypoint: 'adjudicate_claim' },
          { name: 'Flag Win', entrypoint: 'flag_win' },
        ],
      },
    },
    // messages: [] // not used here
  };
}

