pragma circom 2.0.0;
include "circomlib/circuits/bitify.circom";       // Num2Bits
include "circomlib/circuits/comparators.circom";  // IsEqual, IsZero

// piece_type: 1=pawn, 2=knight, 3=bishop, 4=rook, 5=queen, 6=king
// mover_color: 0=white (+1 rank), 1=black (-1 rank)
// opp_at_to: 0/1 (destination has opponent) — assumed boolean
// Outputs: ok (asserted ==1), needs_lineclear (B/R/Q or pawn double-step)
template CheckPieceGeometry() {
    signal input piece_type;
    signal input mover_color;    // 0 or 1
    signal input from_square;    // 0..63
    signal input to_square;      // 0..63
    signal input opp_at_to;      // 0/1

    signal output ok;
    signal output needs_lineclear;

    // Enforce boolean on opp_at_to
    opp_at_to * (1 - opp_at_to) === 0;

    // --- file/rank extraction ---
    component s_from = Num2Bits(6); s_from.in <== from_square;
    component s_to   = Num2Bits(6); s_to.in   <== to_square;

    signal from_file; from_file <== s_from.out[0] + 2*s_from.out[1] + 4*s_from.out[2];
    signal to_file;   to_file   <== s_to.out[0]   + 2*s_to.out[1]   + 4*s_to.out[2];

    signal from_rank; from_rank <== s_from.out[3] + 2*s_from.out[4] + 4*s_from.out[5];
    signal to_rank;   to_rank   <== s_to.out[3]   + 2*s_to.out[4]   + 4*s_to.out[5];

    // --- deltas & squares ---
    signal df; df <== to_file - from_file;
    signal dr; dr <== to_rank - from_rank;

    signal df2; df2 <== df * df;
    signal dr2; dr2 <== dr * dr;

    // --- common booleans ---
    component is_df0 = IsZero(); is_df0.in <== df;
    component is_dr0 = IsZero(); is_dr0.in <== dr;
    signal same_file; same_file <== is_df0.out; same_file * (1 - same_file) === 0;
    signal same_rank; same_rank <== is_dr0.out; same_rank * (1 - same_rank) === 0;

    component eq_df2_dr2 = IsEqual(); eq_df2_dr2.in[0] <== df2; eq_df2_dr2.in[1] <== dr2;
    component eq_df2_1   = IsEqual(); eq_df2_1.in[0]   <== df2; eq_df2_1.in[1]   <== 1;
    component eq_dr2_1   = IsEqual(); eq_dr2_1.in[0]   <== dr2; eq_dr2_1.in[1]   <== 1;
    component eq_dr2_0   = IsEqual(); eq_dr2_0.in[0]   <== dr2; eq_dr2_0.in[1]   <== 0;

    // Bishop diagonal non-zero: |df|==|dr| && |dr|>0
    signal diag_nonzero; diag_nonzero <== eq_df2_dr2.out * (1 - eq_dr2_0.out);
    diag_nonzero * (1 - diag_nonzero) === 0;

    // Rook: same file XOR same rank, not both
    signal both_zero; both_zero <== same_file * same_rank;
    signal either;    either    <== same_file + same_rank - both_zero;
    signal rook_ok;   rook_ok   <== either * (1 - both_zero);
    rook_ok * (1 - rook_ok) === 0;

    // Knight: df2 + dr2 == 5
    signal sum_kn; sum_kn <== df2 + dr2;
    component eq_sum5 = IsEqual(); eq_sum5.in[0] <== sum_kn; eq_sum5.in[1] <== 5;
    signal knight_ok; knight_ok <== eq_sum5.out;
    knight_ok * (1 - knight_ok) === 0;

    // King: (|df| in {0,1}) AND (|dr| in {0,1}) AND not both zero
    component eq_df2_0 = IsEqual();  eq_df2_0.in[0]  <== df2; eq_df2_0.in[1]  <== 0;
    component eq_dr2_0b = IsEqual(); eq_dr2_0b.in[0] <== dr2; eq_dr2_0b.in[1] <== 0;

    signal df_in01; df_in01 <== eq_df2_0.out + eq_df2_1.out - eq_df2_0.out * eq_df2_1.out;
    signal dr_in01; dr_in01 <== eq_dr2_0b.out + eq_dr2_1.out - eq_dr2_0b.out * eq_dr2_1.out;

    signal king_nonzero; king_nonzero <== 1 - (eq_df2_0.out * eq_dr2_0b.out);

    signal king_step;  king_step  <== df_in01 * dr_in01;        // pairwise
    signal king_ok;    king_ok    <== king_step * king_nonzero; // pairwise
    king_ok * (1 - king_ok) === 0;

    // Bishop / Queen
    signal bishop_ok; bishop_ok <== diag_nonzero;
    bishop_ok * (1 - bishop_ok) === 0;

    signal queen_ok; queen_ok <== bishop_ok + rook_ok - bishop_ok * rook_ok;
    queen_ok * (1 - queen_ok) === 0;

    // --- Pawn (single-step + capture + double-step) ---
    // color: 0 = white (forward +1/+2 rank), 1 = black (forward -1/-2 rank)
    component eq_dr_plus1  = IsEqual(); eq_dr_plus1.in[0]  <== to_rank;    eq_dr_plus1.in[1]  <== from_rank + 1;
    component eq_dr_minus1 = IsEqual(); eq_dr_minus1.in[0] <== from_rank;  eq_dr_minus1.in[1] <== to_rank + 1;

    signal dr_plus1;  dr_plus1  <== eq_dr_plus1.out;  dr_plus1  * (1 - dr_plus1) === 0;
    signal dr_minus1; dr_minus1 <== eq_dr_minus1.out; dr_minus1 * (1 - dr_minus1) === 0;

    component is_white = IsZero(); is_white.in <== mover_color; // 1 if white, 0 if black
    signal oneMinusW; oneMinusW <== 1 - is_white.out;

    // dir_match for single-step
    signal d_white;   d_white   <== is_white.out * dr_plus1;   // pairwise
    signal d_black;   d_black   <== oneMinusW    * dr_minus1;  // pairwise
    signal dir_match; dir_match <== d_white + d_black;         // linear
    dir_match * (1 - dir_match) === 0;

    // |df| == 1 ?
    signal abs_df_is1; abs_df_is1 <== eq_df2_1.out; abs_df_is1 * (1 - abs_df_is1) === 0;

    // forward_ok = same_file & dir_match & !opp_at_to
    signal f_step;     f_step     <== same_file * dir_match;
    signal forward_ok; forward_ok <== f_step * (1 - opp_at_to);
    forward_ok * (1 - forward_ok) === 0;

    // capture_ok = |df|==1 & dir_match & opp_at_to
    signal c_step;     c_step     <== abs_df_is1 * dir_match;
    signal capture_ok; capture_ok <== c_step * opp_at_to;
    capture_ok * (1 - capture_ok) === 0;

    // ----- Pawn initial two-square push (FIXED: use ±2 checks, not dir_match) -----
    component eq_dr_plus2  = IsEqual(); eq_dr_plus2.in[0]  <== to_rank;    eq_dr_plus2.in[1]  <== from_rank + 2;
    component eq_dr_minus2 = IsEqual(); eq_dr_minus2.in[0] <== from_rank;  eq_dr_minus2.in[1] <== to_rank + 2;

    // start ranks
    component eq_fr_1 = IsEqual(); eq_fr_1.in[0] <== from_rank; eq_fr_1.in[1] <== 1; // white start
    component eq_fr_6 = IsEqual(); eq_fr_6.in[0] <== from_rank; eq_fr_6.in[1] <== 6; // black start

    // color-gated start & direction for double
    signal start_w; start_w <== is_white.out * eq_fr_1.out;
    signal start_b; start_b <== oneMinusW    * eq_fr_6.out;

    signal dir2_w; dir2_w <== is_white.out * eq_dr_plus2.out;
    signal dir2_b; dir2_b <== oneMinusW    * eq_dr_minus2.out;
    signal dir2_ok; dir2_ok <== dir2_w + dir2_b;

    // combine: same file AND correct ±2 direction
    signal df0_dir2; df0_dir2 <== same_file * dir2_ok;

    // must be destination empty for the double
    signal dest_empty_required; dest_empty_required <== 1 - opp_at_to;

    // start_ok OR and final double_ok
    signal start_ok;  start_ok  <== start_w + start_b;
    signal pre_double; pre_double <== df0_dir2 * start_ok;           // pairwise
    signal double_ok;  double_ok  <== pre_double * dest_empty_required; // pairwise
    double_ok * (1 - double_ok) === 0;

    // Combine pawn branches: forward OR capture OR double
    signal f_or_c;  f_or_c  <== forward_ok + capture_ok - forward_ok * capture_ok;
    signal pawn_ok; pawn_ok <== f_or_c + double_ok - f_or_c * double_ok;
    pawn_ok * (1 - pawn_ok) === 0;

    // --- piece-type gating (1..6) ---
    component eq_t1 = IsEqual(); eq_t1.in[0] <== piece_type; eq_t1.in[1] <== 1;
    component eq_t2 = IsEqual(); eq_t2.in[0] <== piece_type; eq_t2.in[1] <== 2;
    component eq_t3 = IsEqual(); eq_t3.in[0] <== piece_type; eq_t3.in[1] <== 3;
    component eq_t4 = IsEqual(); eq_t4.in[0] <== piece_type; eq_t4.in[1] <== 4;
    component eq_t5 = IsEqual(); eq_t5.in[0] <== piece_type; eq_t5.in[1] <== 5;
    component eq_t6 = IsEqual(); eq_t6.in[0] <== piece_type; eq_t6.in[1] <== 6;

    signal t1; t1 <== eq_t1.out; t1 * (1 - t1) === 0;
    signal t2; t2 <== eq_t2.out; t2 * (1 - t2) === 0;
    signal t3; t3 <== eq_t3.out; t3 * (1 - t3) === 0;
    signal t4; t4 <== eq_t4.out; t4 * (1 - t4) === 0;
    signal t5; t5 <== eq_t5.out; t5 * (1 - t5) === 0;
    signal t6; t6 <== eq_t6.out; t6 * (1 - t6) === 0;

    // needs_lineclear = OR(bishop, rook, queen, pawn_double)
    signal br;    br    <== t3 + t4 - t3*t4;          // bishop or rook
    signal brq;   brq   <== br + t5 - br*t5;          // add queen
    needs_lineclear <== brq + double_ok - brq * double_ok;
    needs_lineclear * (1 - needs_lineclear) === 0;

    // Gate each branch, OR them together (pairwise), assert ok
    signal v1; v1 <== t1 * pawn_ok;
    signal v2; v2 <== t2 * knight_ok;
    signal v3; v3 <== t3 * bishop_ok;
    signal v4; v4 <== t4 * rook_ok;
    signal v5; v5 <== t5 * queen_ok;
    signal v6; v6 <== t6 * king_ok;

    signal o12;   o12   <== v1 + v2 - v1*v2;
    signal o34;   o34   <== v3 + v4 - v3*v4;
    signal o56;   o56   <== v5 + v6 - v5*v6;
    signal o1234; o1234 <== o12 + o34 - o12*o34;
    ok <== o1234 + o56 - o1234*o56;

    ok * (1 - ok) === 0;
    ok === 1;
}
