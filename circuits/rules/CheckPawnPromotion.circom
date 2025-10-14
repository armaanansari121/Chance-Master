pragma circom 2.0.0;

include "circomlib/circuits/bitify.circom";      // Num2Bits
include "circomlib/circuits/comparators.circom"; // IsEqual, IsZero

// promo_choice: 0=no promo, otherwise {2=knight,3=bishop,4=rook,5=queen}
template CheckPawnPromotion() {
    signal input piece_type;     // 1..6
    signal input mover_color;    // 0=white, 1=black
    signal input to_square;      // 0..63
    signal input promo_choice;   // 0 or {2,3,4,5}

    signal output promo_flag;        // 1 iff promotion happens on this move
    signal output isN;               // chosen knight
    signal output isB;               // chosen bishop
    signal output isR;               // chosen rook
    signal output isQ;               // chosen queen

    // --- decode to_rank ---
    component T = Num2Bits(6); T.in <== to_square;
    signal to_rank; to_rank <== T.out[3] + 2*T.out[4] + 4*T.out[5];

    // --- color tests ---
    component is_white = IsZero(); is_white.in <== mover_color;  // 1 if white
    signal iw;  iw  <== is_white.out;               iw  * (1 - iw)  === 0;
    signal ib;  ib  <== 1 - iw;                     ib  * (1 - ib)  === 0;

    // last rank per color
    component eq_r7 = IsEqual(); eq_r7.in[0] <== to_rank; eq_r7.in[1] <== 7;
    component eq_r0 = IsEqual(); eq_r0.in[0] <== to_rank; eq_r0.in[1] <== 0;

    signal last_w; last_w <== iw * eq_r7.out; last_w * (1 - last_w) === 0;
    signal last_b; last_b <== ib * eq_r0.out; last_b * (1 - last_b) === 0;
    signal is_last; is_last <== last_w + last_b; is_last * (1 - is_last) === 0;

    // piece_type == pawn ?
    component eq_pawn = IsEqual(); eq_pawn.in[0] <== piece_type; eq_pawn.in[1] <== 1;
    signal is_pawn; is_pawn <== eq_pawn.out; is_pawn * (1 - is_pawn) === 0;

    // promotion required iff (pawn && last rank) — pairwise gated chain
    signal pawn_at_last; pawn_at_last <== is_pawn * is_last;
    signal need_promo;   need_promo   <== pawn_at_last;   // alias with explicit name
    need_promo * (1 - need_promo) === 0;

    // promo_choice decoding
    component e2 = IsEqual(); e2.in[0] <== promo_choice; e2.in[1] <== 2;  // knight
    component e3 = IsEqual(); e3.in[0] <== promo_choice; e3.in[1] <== 3;  // bishop
    component e4 = IsEqual(); e4.in[0] <== promo_choice; e4.in[1] <== 4;  // rook
    component e5 = IsEqual(); e5.in[0] <== promo_choice; e5.in[1] <== 5;  // queen
    component e0 = IsEqual(); e0.in[0] <== promo_choice; e0.in[1] <== 0;  // none

    signal c2; c2 <== e2.out; c2 * (1 - c2) === 0;
    signal c3; c3 <== e3.out; c3 * (1 - c3) === 0;
    signal c4; c4 <== e4.out; c4 * (1 - c4) === 0;
    signal c5; c5 <== e5.out; c5 * (1 - c5) === 0;
    signal c0; c0 <== e0.out; c0 * (1 - c0) === 0;

    // outputs (one-hots for piece boards)
    isN <== c2;  isB <== c3;  isR <== c4;  isQ <== c5;

    // any_piece = OR(c2,c3,c4,c5) using pairwise OR expansions only
    signal c2c3; c2c3 <== c2 + c3 - c2*c3;
    signal c4c5; c4c5 <== c4 + c5 - c4*c5;
    signal any_piece; any_piece <== c2c3 + c4c5 - c2c3*c4c5;

    // promo_flag == need_promo AND any_piece
    signal need_and_any; need_and_any <== need_promo * any_piece;
    promo_flag <== need_and_any;
    promo_flag * (1 - promo_flag) === 0;

    // ----- CASE CONSTRAINTS -----
    // If need_promo==1 → c0==0 and exactly one of {c2,c3,c4,c5}==1
    signal bad_need; bad_need <== need_promo * c0;     // cannot pick 0 when needed
    bad_need === 0;

    signal sPieces; sPieces <== c2 + c3 + c4 + c5;
    signal sPiecesMinus1; sPiecesMinus1 <== sPieces - 1;
    signal must_eq1; must_eq1 <== need_promo * sPiecesMinus1;
    must_eq1 === 0;

    // If need_promo==0, c0 must be 1 (no promotion allowed)
    signal not_need; not_need <== 1 - need_promo;
    signal bad_not_need; bad_not_need <== not_need * (1 - c0);
    bad_not_need === 0;
}
