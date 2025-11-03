// circuits/rules/CheckEnPassant.circom
pragma circom 2.0.0;

include "circomlib/circuits/bitify.circom";      // Num2Bits
include "circomlib/circuits/comparators.circom"; // IsEqual, LessThan, IsZero
include "_helpers.circom";                       // SelectBit64

/* En Passant legality for the current move.

Inputs:
  piece_type     : 1..6
  mover_color    : 0=white, 1=black
  from_square    : 0..63
  to_square      : 0..63
  ep_prev_0_64   : 0..64 (64 means no EP available this turn)
  selfP, oppP    : pawns (u64) of mover & opponent
  occ_pre        : selfALL | oppALL   (u64)

Outputs:
  is_ep          : 1 if the move is an en passant capture
  cap_sq         : 0..63 (valid only when is_ep==1)
  ok             : constrained to 1
*/
template CheckEnPassant() {
    // ---- inputs ----
    signal input piece_type;
    signal input mover_color;    // 0/1
    signal input from_square;    // 0..63
    signal input to_square;      // 0..63
    signal input ep_prev_0_64;   // 0..64 (64 = none)
    signal input selfP;          // u64
    signal input oppP;           // u64
    signal input occ_pre;        // u64

    // ---- outputs ----
    signal output is_ep;
    signal output cap_sq;
    signal output ok;

    // ---- piece is pawn? ----
    component eqPawn = IsEqual(); eqPawn.in[0] <== piece_type; eqPawn.in[1] <== 1;
    signal isPawn; isPawn <== eqPawn.out; isPawn * (1 - isPawn) === 0;

    // ---- color booleans ----
    component isW = IsZero(); isW.in <== mover_color; // 1 if white
    signal iw; iw <== isW.out; signal ib; ib <== 1 - iw;

    // ---- decode from/to (files+ranks) ----
    component F = Num2Bits(6); F.in <== from_square;
    component T = Num2Bits(6); T.in <== to_square;

    signal ff; ff <== F.out[0] + 2*F.out[1] + 4*F.out[2];
    signal fr; fr <== F.out[3] + 2*F.out[4] + 4*F.out[5];
    signal tf; tf <== T.out[0] + 2*T.out[1] + 4*T.out[2];
    signal tr; tr <== T.out[3] + 2*T.out[4] + 4*T.out[5];

    // |df|==1 and dr==+1 (white) or dr==-1 (black)
    signal df; df <== tf - ff; signal dr; dr <== tr - fr;
    signal df2; df2 <== df * df;

    component eq_df2_1 = IsEqual(); eq_df2_1.in[0] <== df2; eq_df2_1.in[1] <== 1;
    signal abs_df_is1; abs_df_is1 <== eq_df2_1.out;

    component eq_dr_plus1  = IsEqual(); eq_dr_plus1.in[0]  <== tr;      eq_dr_plus1.in[1]  <== fr + 1;
    component eq_dr_minus1 = IsEqual(); eq_dr_minus1.in[0] <== fr;      eq_dr_minus1.in[1] <== tr + 1;
    signal step_w; step_w <== iw * eq_dr_plus1.out;
    signal step_b; step_b <== ib * eq_dr_minus1.out;
    signal dir_ok; dir_ok <== step_w + step_b; dir_ok * (1 - dir_ok) === 0;

    // ---- prev EP target usable? (0..63) ----
    component ep_lt64 = LessThan(7); ep_lt64.in[0] <== ep_prev_0_64; ep_lt64.in[1] <== 64; // 1 if <64
    // bring ep_prev into 0..63 only when valid; else alias to `to_square` so eq doesn't matter
    signal ep_idx6_sel; ep_idx6_sel <== ep_lt64.out * ep_prev_0_64 + (1 - ep_lt64.out) * to_square;

    component eq_to_ep = IsEqual(); eq_to_ep.in[0] <== to_square; eq_to_ep.in[1] <== ep_idx6_sel;

    // ---- destination must be empty pre-move (by definition of EP) ----
    component occAtTo = SelectBit64(); occAtTo.packed <== occ_pre; occAtTo.idx <== to_square;

    // ---- captured square depending on color: cap = to - 8 (white) or to + 8 (black) ----
    signal to_minus_8; to_minus_8 <== to_square - 8;
    signal to_plus_8;  to_plus_8  <== to_square + 8;

    component tm8_ge0  = LessThan(7); tm8_ge0.in[0]  <== 0;            tm8_ge0.in[1]  <== to_minus_8;
    component tp8_lt64 = LessThan(7); tp8_lt64.in[0] <== to_plus_8;    tp8_lt64.in[1] <== 64;

    // choose by color, gate ranges
    signal cap_w_ok; cap_w_ok <== iw * tm8_ge0.out;
    signal cap_b_ok; cap_b_ok <== ib * tp8_lt64.out;

    signal cap_w; cap_w <== cap_w_ok * to_minus_8;
    signal cap_b; cap_b <== cap_b_ok * to_plus_8;
    cap_sq <== cap_w + cap_b; // valid only under is_ep

    // prove cap_sq < 64 (for the chosen color path)
    component cap_lt64 = LessThan(7); cap_lt64.in[0] <== cap_sq; cap_lt64.in[1] <== 64; cap_lt64.out === 1;

    // a pawn must exist on oppP at cap_sq
    component oppPawnAtCap = SelectBit64(); oppPawnAtCap.packed <== oppP; oppPawnAtCap.idx <== cap_sq;

    // ---- side-conditions: from/to ranks must be the EP ranks ----
    // white EP: from rank==4, to rank==5 ; black EP: from==3, to==2   (0-based)
    component eq_fr_4 = IsEqual(); eq_fr_4.in[0] <== fr; eq_fr_4.in[1] <== 4;
    component eq_tr_5 = IsEqual(); eq_tr_5.in[0] <== tr; eq_tr_5.in[1] <== 5;

    component eq_fr_3 = IsEqual(); eq_fr_3.in[0] <== fr; eq_fr_3.in[1] <== 3;
    component eq_tr_2 = IsEqual(); eq_tr_2.in[0] <== tr; eq_tr_2.in[1] <== 2;

    signal rank_w; rank_w <== iw * eq_fr_4.out * eq_tr_5.out; // pairwise chained by compiler
    signal rank_b; rank_b <== ib * eq_fr_3.out * eq_tr_2.out;
    signal ranks_ok; ranks_ok <== rank_w + rank_b;

    // ---- assemble EP condition (pairwise only) ----
    // must be pawn, dest==ep_prev, abs_df_is1, dir_ok, ranks_ok, dest empty, opp pawn at cap
    signal t0; t0 <== isPawn * ep_lt64.out;
    signal t1; t1 <== t0 * eq_to_ep.out;
    signal t2; t2 <== abs_df_is1 * dir_ok;
    signal t3; t3 <== t2 * ranks_ok;
    signal t4; t4 <== t3 * (1 - occAtTo.bit);
    signal t5; t5 <== t4 * oppPawnAtCap.bit;

    is_ep <== t1 * t5;  // still quadratic, as we multiply pairwise

    // ---- ok asserted ----
    ok <== 1;
    ok * (1 - ok) === 0;
    ok === 1;
}
