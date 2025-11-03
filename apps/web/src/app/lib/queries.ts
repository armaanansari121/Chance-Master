import { ToriiQueryBuilder, MemberClause, OrComposeClause } from '@dojoengine/sdk';
import type { SchemaType } from '@/bindings/typescript/models.gen';

const TBL_GAME = 'chance_master-Game' as const;

/** Game(status == Active AND (white == me OR black == me)) */
export function myActiveGameQuery(address: string) {
  const me = address.toLowerCase();
  return new ToriiQueryBuilder<SchemaType>()
    .withEntityModels([TBL_GAME])
    // NOTE: if your index stores enums numerically, swap 'Active' for the numeric value.
    .withClause(
      MemberClause<SchemaType, typeof TBL_GAME, 'status'>(TBL_GAME, 'status', 'Eq', 'Active').build()
    )
    .withClause(
      OrComposeClause<SchemaType>([
        MemberClause<SchemaType, typeof TBL_GAME, 'white'>(TBL_GAME, 'white', 'Eq', me),
        MemberClause<SchemaType, typeof TBL_GAME, 'black'>(TBL_GAME, 'black', 'Eq', me),
      ]).build()
    )
    .withLimit(1);
}

