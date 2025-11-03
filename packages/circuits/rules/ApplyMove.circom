pragma circom 2.0.0;
include "_helpers.circom"; // SelectBit64, Pow2_64
include "circomlib/circuits/comparators.circom"; // IsEqual

// ApplyMove with promotion + optional castling rook-hop + optional en-passant.
// Pairwise-only multiplies, no signal declarations inside loops.
template ApplyMove() {
    // mover per-type
    signal input self_pawn;
    signal input self_knight;
    signal input self_bishop;
    signal input self_rook;
    signal input self_queen;
    signal input self_king;

    // opponent per-type
    signal input opp_pawn;
    signal input opp_knight;
    signal input opp_bishop;
    signal input opp_rook;
    signal input opp_queen;
    signal input opp_king;

    // move
    signal input piece_type;   // 1..6
    signal input from_square;  // 0..63
    signal input to_square;    // 0..63

    // PROMOTION (booleans)
    signal input promo_flag;
    signal input promo_is_knight;
    signal input promo_is_bishop;
    signal input promo_is_rook;
    signal input promo_is_queen;

    // CASTLING (booleans + rook coordinates)
    signal input castle_flag;          // 1 when doing castling
    signal input rook_from_square;     // valid only when castle_flag=1
    signal input rook_to_square;       // valid only when castle_flag=1

    // EN PASSANT (booleans + captured pawn square)
    // If ep_flag == 1, remove opponent pawn at ep_captured_square (to±8).
    signal input ep_flag;              // 0/1
    signal input ep_captured_square;   // 0..63 (gated/proved by Orchestrator)

    // outputs
    signal output next_self_pawn;
    signal output next_self_knight;
    signal output next_self_bishop;
    signal output next_self_rook;
    signal output next_self_queen;
    signal output next_self_king;

    signal output next_opp_pawn;
    signal output next_opp_knight;
    signal output next_opp_bishop;
    signal output next_opp_rook;
    signal output next_opp_queen;
    signal output next_opp_king;

    signal output ok;

    // masks
    component mFrom = Pow2_64(); mFrom.idx <== from_square; // 1<<from
    component mTo   = Pow2_64(); mTo.idx   <== to_square;   // 1<<to

    // Enforce booleans
    promo_flag * (1 - promo_flag) === 0;
    promo_is_knight * (1 - promo_is_knight) === 0;
    promo_is_bishop * (1 - promo_is_bishop) === 0;
    promo_is_rook   * (1 - promo_is_rook)   === 0;
    promo_is_queen  * (1 - promo_is_queen)  === 0;

    castle_flag * (1 - castle_flag) === 0;

    ep_flag * (1 - ep_flag) === 0;

    // self candidate updates (linear)
    signal one_minus_pf; one_minus_pf <== 1 - promo_flag;
    signal pawn_to_add;  pawn_to_add  <== one_minus_pf * mTo.out;

    signal move_pawn;   move_pawn   <== self_pawn   - mFrom.out + pawn_to_add;
    signal move_knight; move_knight <== self_knight - mFrom.out + mTo.out;
    signal move_bishop; move_bishop <== self_bishop - mFrom.out + mTo.out;
    signal move_rook0;  move_rook0  <== self_rook   - mFrom.out + mTo.out; // base (no castle)
    signal move_queen;  move_queen  <== self_queen  - mFrom.out + mTo.out;
    signal move_king0;  move_king0  <== self_king   - mFrom.out + mTo.out; // base (no castle)

    // One-hot by piece_type
    component e1 = IsEqual(); e1.in[0] <== piece_type; e1.in[1] <== 1;
    component e2 = IsEqual(); e2.in[0] <== piece_type; e2.in[1] <== 2;
    component e3 = IsEqual(); e3.in[0] <== piece_type; e3.in[1] <== 3;
    component e4 = IsEqual(); e4.in[0] <== piece_type; e4.in[1] <== 4;
    component e5 = IsEqual(); e5.in[0] <== piece_type; e5.in[1] <== 5;
    component e6 = IsEqual(); e6.in[0] <== piece_type; e6.in[1] <== 6;

    signal t1; t1 <== e1.out; t1 * (1 - t1) === 0;
    signal t2; t2 <== e2.out; t2 * (1 - t2) === 0;
    signal t3; t3 <== e3.out; t3 * (1 - t3) === 0;
    signal t4; t4 <== e4.out; t4 * (1 - t4) === 0;
    signal t5; t5 <== e5.out; t5 * (1 - t5) === 0;
    signal t6; t6 <== e6.out; t6 * (1 - t6) === 0;

    // Promotion injection to minor/major pieces when t1 & promo_flag
    signal t1pf;     t1pf     <== t1 * promo_flag;

    signal t1pfN;    t1pfN    <== t1pf * promo_is_knight;
    signal addN;     addN     <== t1pfN * mTo.out;

    signal t1pfB;    t1pfB    <== t1pf * promo_is_bishop;
    signal addB;     addB     <== t1pfB * mTo.out;

    signal t1pfR;    t1pfR    <== t1pf * promo_is_rook;
    signal addR;     addR     <== t1pfR * mTo.out;

    signal t1pfQ;    t1pfQ    <== t1pf * promo_is_queen;
    signal addQ;     addQ     <== t1pfQ * mTo.out;

    // Castling rook hop deltas (only when king moves and castle_flag=1)
    component mRF = Pow2_64(); mRF.idx <== rook_from_square;
    component mRT = Pow2_64(); mRT.idx <== rook_to_square;

    signal castle_for_king; castle_for_king <== t6 * castle_flag;

    signal rook_castle_sub; rook_castle_sub <== castle_for_king * mRF.out;
    signal rook_castle_add; rook_castle_add <== castle_for_king * mRT.out;

    signal move_rook; move_rook <== move_rook0 - rook_castle_sub + rook_castle_add;

    // For king, castling is already represented by from->to; rook moves separately
    signal move_king; move_king <== move_king0;

    // next self boards = tX*move + (1 - tX)*orig (pairwise)
    signal s1a; s1a <== t1 * move_pawn;   signal s1b; s1b <== (1 - t1) * self_pawn;   next_self_pawn   <== s1a + s1b;
    signal s2a; s2a <== t2 * move_knight; signal s2b; s2b <== (1 - t2) * self_knight; next_self_knight <== s2a + s2b + addN;
    signal s3a; s3a <== t3 * move_bishop; signal s3b; s3b <== (1 - t3) * self_bishop; next_self_bishop <== s3a + s3b + addB;
    signal s4a; s4a <== t4 * move_rook0;  signal s4b; s4b <== (1 - t4) * self_rook;
    next_self_rook   <== s4a + s4b - rook_castle_sub + rook_castle_add + addR;
    signal s5a; s5a <== t5 * move_queen;  signal s5b; s5b <== (1 - t5) * self_queen;  next_self_queen  <== s5a + s5b + addQ;
    signal s6a; s6a <== t6 * move_king;   signal s6b; s6b <== (1 - t6) * self_king;   next_self_king   <== s6a + s6b;

    // capture clear at 'to' on opponent boards
    component oP = SelectBit64(); oP.packed <== opp_pawn;   oP.idx <== to_square;
    component oN = SelectBit64(); oN.packed <== opp_knight; oN.idx <== to_square;
    component oB = SelectBit64(); oB.packed <== opp_bishop; oB.idx <== to_square;
    component oR = SelectBit64(); oR.packed <== opp_rook;   oR.idx <== to_square;
    component oQ = SelectBit64(); oQ.packed <== opp_queen;  oQ.idx <== to_square;
    component oK = SelectBit64(); oK.packed <== opp_king;   oK.idx <== to_square;

    signal cP; cP <== oP.bit * mTo.out;
    signal cN; cN <== oN.bit * mTo.out;
    signal cB; cB <== oB.bit * mTo.out;
    signal cR; cR <== oR.bit * mTo.out;
    signal cQ; cQ <== oQ.bit * mTo.out;
    signal cK; cK <== oK.bit * mTo.out;

    // EN PASSANT: subtract captured pawn at ep_captured_square when ep_flag=1
    component mEPC = Pow2_64(); mEPC.idx <== ep_captured_square;
    signal ep_sub; ep_sub <== ep_flag * mEPC.out;

    next_opp_pawn   <== opp_pawn   - cP - ep_sub;
    next_opp_knight <== opp_knight - cN;
    next_opp_bishop <== opp_bishop - cB;
    next_opp_rook   <== opp_rook   - cR;
    next_opp_queen  <== opp_queen  - cQ;
    next_opp_king   <== opp_king   - cK;

    ok <== 1;
    ok * (1 - ok) === 0;
    ok === 1;
}
