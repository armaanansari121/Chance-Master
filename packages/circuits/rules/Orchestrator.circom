pragma circom 2.0.0;

/* External libs */
include "circomlib/circuits/bitify.circom";       // Num2Bits
include "circomlib/circuits/comparators.circom";  // IsEqual, IsZero, LessThan
include "circomlib/circuits/poseidon.circom";     // Poseidon

/* Your modules */
include "_helpers.circom";                          // SelectBit64, SelectFromBits64, Pow2_64
include "MoveInsideBoard.circom";                   // template MoveInsideBoard
include "CheckPlayerTurn.circom";                   // template CheckPlayerTurn
include "PieceExistsAtSquare.circom";               // template PieceExistsAtSquare_assert_ok
include "CheckDiceInclusion.circom";                // template CheckDiceInclusion
include "CheckDestinationEmptyOrOpponent.circom";   // template CheckDestinationEmptyOrOpponent_assert_ok
include "CheckPieceGeometry.circom";                // template CheckPieceGeometry
include "LineClear.circom";                         // template LineClearRuntime
include "ApplyMove.circom";                         // template ApplyMove
include "BoardHash.circom";                         // (still included, but we won't use it for outputs)
include "KingSafeCheck.circom";                     // template KingSafeRuntime_NoWitness
include "CheckCastling.circom";                     // template CheckCastling
include "NoBitCollisions.circom";                   // template NoBitCollisions12

/* ============== MAIN (promotion + castling + en passant + no-collision) ==============
Public outputs (contract decodes in this order):
0  mover_color      1  turn
2  from_square      3  to_square
4  promo_choice
5  dice0            6  dice1          7  dice2
8  castle_rights
9  next_castle_rights
10  prev_ep_flag    11 prev_ep_square
12 next_ep_flag     13 next_ep_square
-- previous board (12 bitboards) --
14 prev_wP          15 prev_wN        16 prev_wB
17 prev_wR          18 prev_wQ        19 prev_wK
20 prev_bP          21 prev_bN        22 prev_bB
23 prev_bR          24 prev_bQ        25 prev_bK
-- next board (12 bitboards) --
26 next_wP          27 next_wN        28 next_wB
29 next_wR          30 next_wQ        31 next_wK
32 next_bP          33 next_bN        34 next_bB
35 next_bR          36 next_bQ        37 next_bK
38 next_castle_rights
*/
template Orchestrator() {
    // ---- PUBLIC CONTEXT (emitted) ----
    signal output mover_color;   // 0/1
    signal output turn;          // 0/1
    signal output from_square;   // 0..63
    signal output to_square;     // 0..63

    // Promotion: public choice to bind post-move board
    signal output promo_choice;  // 0=no promo, 2=N,3=B,4=R,5=Q

    signal output dice0;         // 1..6
    signal output dice1;         // 1..6
    signal output dice2;         // 1..6

    // Castling rights (wk=8, wq=4, bk=2, bq=1)
    signal output castle_rights;
    signal output next_castle_rights;


    // EP public state (previous and next half-move)
    signal output prev_ep_flag;     // 0/1
    signal output prev_ep_square;   // 0..63 (meaningful only if flag=1)
    signal output next_ep_flag;     // 0/1
    signal output next_ep_square;   // 0..63 (meaningful only if flag=1)

    // ---- PRIVATE PRE-STATE (12 bitboards) ----
    signal input wP; signal input wN; signal input wB; signal input wR; signal input wQ; signal input wK;
    signal input bP; signal input bN; signal input bB; signal input bR; signal input bQ; signal input bK;

    // ---- ALSO EMIT PRE-STATE AS PUBLICS (mirror inputs) ----
    signal output prev_wP; signal output prev_wN; signal output prev_wB; signal output prev_wR; signal output prev_wQ; signal output prev_wK;
    signal output prev_bP; signal output prev_bN; signal output prev_bB; signal output prev_bR; signal output prev_bQ; signal output prev_bK;

    // ---- PRIVATE CONTEXT (fed by prover, re-emitted) ----
    signal input _mover_color;   // 0/1
    signal input _turn;          // 0/1
    signal input _from_square;   // 0..63
    signal input _to_square;     // 0..63

    // Promotion choice
    signal input _promo_choice;  // 0 / 2 / 3 / 4 / 5

    signal input _dice0;         // 1..6
    signal input _dice1;         // 1..6
    signal input _dice2;         // 1..6

    // Castling rights private copy (bound to public)
    signal input _castle_rights; // 0..15

    // Post-move king square of the mover (avoid heavy “find index” gadget)
    signal input _my_king_sq;    // 0..63
    signal input _opp_king_sq;   // 0..63

    // Previous en passant state (from last half-move)
    signal input _prev_ep_flag;   // 0/1
    signal input _prev_ep_square; // 0..63 (only meaningful if flag=1)

    // Re-emit as publics
    mover_color        <== _mover_color;    turn           <== _turn;
    from_square        <== _from_square;    to_square      <== _to_square;

    promo_choice       <== _promo_choice;

    dice0              <== _dice0;          dice1          <== _dice1;          dice2 <== _dice2;

    castle_rights      <== _castle_rights;

    prev_ep_flag       <== _prev_ep_flag;
    prev_ep_square     <== _prev_ep_square;

    // Mirror previous bitboards to public outputs
    prev_wP <== wP; prev_wN <== wN; prev_wB <== wB; prev_wR <== wR; prev_wQ <== wQ; prev_wK <== wK;
    prev_bP <== bP; prev_bN <== bN; prev_bB <== bB; prev_bR <== bR; prev_bQ <== bQ; prev_bK <== bK;

    /* ---- NEW: No bit collisions across the 12 input bitboards ---- */
    component noCol = NoBitCollisions12();
    noCol.wP <== wP; noCol.wN <== wN; noCol.wB <== wB; noCol.wR <== wR; noCol.wQ <== wQ; noCol.wK <== wK;
    noCol.bP <== bP; noCol.bN <== bN; noCol.bB <== bB; noCol.bR <== bR; noCol.bQ <== bQ; noCol.bK <== bK;

    /* ---- Basic checks ---- */
    component cTurn = CheckPlayerTurn();      cTurn.turn <== _turn; cTurn.player_color <== _mover_color; // asserts ok
    component cIn   = MoveInsideBoard();      cIn.from_square <== _from_square; cIn.to_square <== _to_square; // asserts ok

    /* ---- Split self vs opp by color (pairwise only) ---- */
    component is_white = IsZero(); is_white.in <== _mover_color; // 1 if mover = white
    signal iw;  iw  <== is_white.out;
    signal niw; niw <== 1 - iw;

    // self = iw ? white : black
    signal t_wP; t_wP <== iw * wP;   signal t_bP; t_bP <== niw * bP;   signal selfP; selfP <== t_wP + t_bP;
    signal t_wN; t_wN <== iw * wN;   signal t_bN; t_bN <== niw * bN;   signal selfN; selfN <== t_wN + t_bN;
    signal t_wB; t_wB <== iw * wB;   signal t_bB; t_bB <== niw * bB;   signal selfB; selfB <== t_wB + t_bB;
    signal t_wR; t_wR <== iw * wR;   signal t_bR; t_bR <== niw * bR;   signal selfR; selfR <== t_wR + t_bR;
    signal t_wQ; t_wQ <== iw * wQ;   signal t_bQ; t_bQ <== niw * bQ;   signal selfQ; selfQ <== t_wQ + t_bQ;
    signal t_wK; t_wK <== iw * wK;   signal t_bK; t_bK <== niw * bK;   signal selfK; selfK <== t_wK + t_bK;

    // opp = iw ? black : white
    signal u_wP; u_wP <== niw * wP;  signal u_bP; u_bP <== iw * bP;    signal oppP;  oppP  <== u_wP + u_bP;
    signal u_wN; u_wN <== niw * wN;  signal u_bN; u_bN <== iw * bN;    signal oppN;  oppN  <== u_wN + u_bN;
    signal u_wB; u_wB <== niw * wB;  signal u_bB; u_bB <== iw * bB;    signal oppB;  oppB  <== u_wB + u_bB;
    signal u_wR; u_wR <== niw * wR;  signal u_bR; u_bR <== iw * bR;    signal oppR;  oppR  <== u_wR + u_bR;
    signal u_wQ; u_wQ <== niw * wQ;  signal u_bQ; u_bQ <== iw * bQ;    signal oppQ;  oppQ  <== u_wQ + u_bQ;
    signal u_wK; u_wK <== niw * wK;  signal u_bK; u_bK <== iw * bK;    signal oppK;  oppK  <== u_wK + u_bK;

    signal selfALL; selfALL <== selfP + selfN + selfB + selfR + selfQ + selfK;
    signal oppALL;  oppALL  <== oppP  + oppN  + oppB  + oppR  + oppQ  + oppK;

    /* ---- From-square must contain some self piece ---- */
    component cExist = PieceExistsAtSquare_assert_ok();
    cExist.bitboard    <== selfALL;
    cExist.from_square <== _from_square;

    /* ---- Determine piece_type at `from` inline (one-hot) ---- */
    component sP = SelectBit64(); sP.packed <== selfP; sP.idx <== _from_square;
    component sN = SelectBit64(); sN.packed <== selfN; sN.idx <== _from_square;
    component sB2= SelectBit64(); sB2.packed<== selfB; sB2.idx<== _from_square;
    component sR2= SelectBit64(); sR2.packed<== selfR; sR2.idx<== _from_square;
    component sQ2= SelectBit64(); sQ2.packed<== selfQ; sQ2.idx<== _from_square;
    component sK2= SelectBit64(); sK2.packed<== selfK; sK2.idx<== _from_square;

    signal sumTypes; sumTypes <== sP.bit + sN.bit + sB2.bit + sR2.bit + sQ2.bit + sK2.bit;
    component eq_one = IsEqual(); eq_one.in[0] <== sumTypes; eq_one.in[1] <== 1;

    signal piece_type;
    piece_type <== 1*sP.bit + 2*sN.bit + 3*sB2.bit + 4*sR2.bit + 5*sQ2.bit + 6*sK2.bit;

    /* ---- Dice inclusion ---- */
    component cDice = CheckDiceInclusion();
    cDice.piece_type <== piece_type;
    cDice.dice[0]    <== _dice0;  cDice.dice[1] <== _dice1;  cDice.dice[2] <== _dice2;

    /* ---- Destination must not be occupied by self ---- */
    component cDest = CheckDestinationEmptyOrOpponent_assert_ok();
    cDest.self_board     <== selfALL;
    cDest.opponent_board <== oppALL;
    cDest.dest_square    <== _to_square;

    /* ---- Castling (must precede geometry) ---- */
    component cCastle = CheckCastling();
    cCastle.piece_type    <== piece_type;
    cCastle.mover_color   <== _mover_color;
    cCastle.from_square   <== _from_square;
    cCastle.to_square     <== _to_square;
    cCastle.castle_rights <== _castle_rights;
    cCastle.selfALL       <== selfALL;
    cCastle.oppALL        <== oppALL;
    cCastle.wR <== wR;  cCastle.bR <== bR;
    cCastle.wB <== wB;  cCastle.bB <== bB;
    cCastle.wQ <== wQ;  cCastle.bQ <== bQ;
    cCastle.wN <== wN;  cCastle.bN <== bN;
    cCastle.wP <== wP;  cCastle.bP <== bP;
    cCastle.wK <== wK;  cCastle.bK <== bK;
    cCastle.occ_pre       <== selfALL + oppALL;

    signal isCastle; isCastle <== cCastle.is_castle;  isCastle * (1 - isCastle) === 0;

    /* ---- EN PASSANT: compute capture possibility (no loops) ---- */
    component FB = Num2Bits(6); FB.in <== _from_square;
    component TB = Num2Bits(6); TB.in <== _to_square;
    signal from_file; from_file <== FB.out[0] + 2*FB.out[1] + 4*FB.out[2];
    signal to_file;   to_file   <== TB.out[0] + 2*TB.out[1] + 4*TB.out[2];
    signal from_rank; from_rank <== FB.out[3] + 2*FB.out[4] + 4*FB.out[5];
    signal to_rank;   to_rank   <== TB.out[3] + 2*TB.out[4] + 4*TB.out[5];

    signal df; df <== to_file - from_file;
    signal df2; df2 <== df * df;
    component eq_df2_1 = IsEqual(); eq_df2_1.in[0] <== df2; eq_df2_1.in[1] <== 1;
    signal abs_df_is1; abs_df_is1 <== eq_df2_1.out; abs_df_is1 * (1 - abs_df_is1) === 0;

    component eq_dr_plus1  = IsEqual(); eq_dr_plus1.in[0]  <== to_rank;   eq_dr_plus1.in[1]  <== from_rank + 1;
    component eq_dr_minus1 = IsEqual(); eq_dr_minus1.in[0] <== from_rank; eq_dr_minus1.in[1] <== to_rank + 1;
    signal dr_plus1;  dr_plus1  <== eq_dr_plus1.out;
    signal dr_minus1; dr_minus1 <== eq_dr_minus1.out;

    signal dir_match_w; dir_match_w <== iw  * dr_plus1;
    signal dir_match_b; dir_match_b <== niw * dr_minus1;
    signal dir_match;   dir_match   <== dir_match_w + dir_match_b;

    component isPawn = IsEqual(); isPawn.in[0] <== piece_type; isPawn.in[1] <== 1;
    signal tPawn; tPawn <== isPawn.out; tPawn * (1 - tPawn) === 0;

    component eq_to_prevEP = IsEqual(); eq_to_prevEP.in[0] <== _to_square; eq_to_prevEP.in[1] <== _prev_ep_square;

    component oppAtTo_raw = SelectBit64(); oppAtTo_raw.packed <== oppALL; oppAtTo_raw.idx <== _to_square;

    signal ep_candidate_t1; ep_candidate_t1 <== tPawn * _prev_ep_flag;
    signal ep_candidate_t2; ep_candidate_t2 <== ep_candidate_t1 * eq_to_prevEP.out;
    signal ep_candidate_t3; ep_candidate_t3 <== ep_candidate_t2 * abs_df_is1;
    signal ep_candidate;    ep_candidate    <== ep_candidate_t3 * dir_match;

    signal ep_to_empty_ok; ep_to_empty_ok <== 1 - (ep_candidate * oppAtTo_raw.bit);
    ep_to_empty_ok === 1;

    signal to_minus8; to_minus8 <== _to_square - 8;
    signal to_plus8;  to_plus8  <== _to_square + 8;

    signal cap_raw_w; cap_raw_w <== iw  * to_minus8;
    signal cap_raw_b; cap_raw_b <== niw * to_plus8;
    signal cap_raw;   cap_raw   <== cap_raw_w + cap_raw_b;

    signal cap_sel_a; cap_sel_a <== ep_candidate * cap_raw;
    signal cap_sel_b; cap_sel_b <== (1 - ep_candidate) * _to_square;
    signal ep_captured_square; ep_captured_square <== cap_sel_a + cap_sel_b;

    component ep_idx_ok = LessThan(7);
    ep_idx_ok.in[0] <== ep_captured_square;
    ep_idx_ok.in[1] <== 64;
    ep_idx_ok.out === 1;

    component oppPawnAtCap = SelectBit64();
    oppPawnAtCap.packed <== oppP;
    oppPawnAtCap.idx    <== ep_captured_square;

    signal ep_has_pawn; ep_has_pawn <== ep_candidate * oppPawnAtCap.bit;
    signal ep_need_ok; ep_need_ok <== ep_candidate - ep_has_pawn;
    ep_need_ok === 0;

    signal ep_flag; ep_flag <== ep_candidate;
    ep_flag * (1 - ep_flag) === 0;

    signal from_p1; from_p1 <== _from_square + 1;
    signal t_castle_to; t_castle_to <== isCastle * from_p1;
    signal t_normal_to; t_normal_to <== (1 - isCastle) * _to_square;
    signal geom_to_idx; geom_to_idx <== t_castle_to + t_normal_to;

    signal opp_at_to_eff; opp_at_to_eff <== oppAtTo_raw.bit + ep_flag - oppAtTo_raw.bit * ep_flag;

    component cGeom = CheckPieceGeometry();
    cGeom.piece_type  <== piece_type;
    cGeom.mover_color <== _mover_color;
    cGeom.from_square <== _from_square;
    cGeom.to_square   <== geom_to_idx;
    cGeom.opp_at_to   <== opp_at_to_eff;
    signal needsLC; needsLC <== cGeom.needs_lineclear;

    signal geom_or_castle_t; geom_or_castle_t <== cGeom.ok + isCastle;
    signal geom_or_castle_i; geom_or_castle_i <== cGeom.ok * isCastle;
    signal legal_move; legal_move <== geom_or_castle_t - geom_or_castle_i;
    legal_move * (1 - legal_move) === 0;
    legal_move === 1;

    component lc = LineClearRuntime();
    lc.all_board <== selfALL + oppALL;
    lc.from      <== _from_square;
    lc.to        <== _to_square;

    signal lc_ok; lc_ok <== lc.ok; lc_ok * (1 - lc_ok) === 0;
    signal need_lc_no_castle; need_lc_no_castle <== needsLC * (1 - isCastle);
    signal gate_lc; gate_lc <== need_lc_no_castle * (1 - lc_ok);
    gate_lc === 0;

    component toBits = Num2Bits(6); toBits.in <== _to_square;
    signal to_rank2; to_rank2 <== toBits.out[3] + 2*toBits.out[4] + 4*toBits.out[5];

    component eq_r7 = IsEqual(); eq_r7.in[0] <== to_rank2; eq_r7.in[1] <== 7;
    component eq_r0 = IsEqual(); eq_r0.in[0] <== to_rank2; eq_r0.in[1] <== 0;

    component is_white2 = IsZero(); is_white2.in <== _mover_color;
    signal iw2; iw2 <== is_white2.out; signal niw2; niw2 <== 1 - iw2;

    signal lastW; lastW <== iw2  * eq_r7.out;
    signal lastB; lastB <== niw2 * eq_r0.out;
    signal onLast; onLast <== lastW + lastB; onLast * (1 - onLast) === 0;

    component eq_pc0 = IsEqual(); eq_pc0.in[0] <== _promo_choice; eq_pc0.in[1] <== 0;
    signal hasChoice; hasChoice <== 1 - eq_pc0.out; hasChoice * (1 - hasChoice) === 0;

    signal pf_pre; pf_pre <== tPawn * onLast;
    signal promo_flag; promo_flag <== pf_pre * hasChoice;
    promo_flag * (1 - promo_flag) === 0;

    component eq_pc2 = IsEqual(); eq_pc2.in[0] <== _promo_choice; eq_pc2.in[1] <== 2;
    component eq_pc3 = IsEqual(); eq_pc3.in[0] <== _promo_choice; eq_pc3.in[1] <== 3;
    component eq_pc4 = IsEqual(); eq_pc4.in[0] <== _promo_choice; eq_pc4.in[1] <== 4;
    component eq_pc5 = IsEqual(); eq_pc5.in[0] <== _promo_choice; eq_pc5.in[1] <== 5;

    signal promo_is_knight; promo_is_knight <== promo_flag * eq_pc2.out;
    signal promo_is_bishop; promo_is_bishop <== promo_flag * eq_pc3.out;
    signal promo_is_rook;   promo_is_rook   <== promo_flag * eq_pc4.out;
    signal promo_is_queen;  promo_is_queen  <== promo_flag * eq_pc5.out;

    component eq_df0 = IsEqual(); eq_df0.in[0] <== to_file - from_file; eq_df0.in[1] <== 0;
    signal same_file; same_file <== eq_df0.out;

    component eq_dr_plus2  = IsEqual(); eq_dr_plus2.in[0]  <== to_rank;   eq_dr_plus2.in[1]  <== from_rank + 2;
    component eq_dr_minus2 = IsEqual(); eq_dr_minus2.in[0] <== from_rank; eq_dr_minus2.in[1] <== to_rank + 2;

    component eq_fr1 = IsEqual(); eq_fr1.in[0] <== from_rank; eq_fr1.in[1] <== 1; // white start
    component eq_fr6 = IsEqual(); eq_fr6.in[0] <== from_rank; eq_fr6.in[1] <== 6; // black start

    signal start_ok_w; start_ok_w <== iw * eq_fr1.out;
    signal start_ok_b; start_ok_b <== niw * eq_fr6.out;
    signal start_ok;   start_ok   <== start_ok_w + start_ok_b;

    signal dir2_w; dir2_w <== iw  * eq_dr_plus2.out;
    signal dir2_b; dir2_b <== niw * eq_dr_minus2.out;
    signal dir2_ok; dir2_ok <== dir2_w + dir2_b;

    signal dest_empty_for_ds; dest_empty_for_ds <== 1 - oppAtTo_raw.bit;

    signal ds1; ds1 <== tPawn * same_file;
    signal ds2; ds2 <== ds1 * dir2_ok;
    signal ds3; ds3 <== ds2 * start_ok;
    signal ds4; ds4 <== ds3 * dest_empty_for_ds;
    signal will_set_ep; will_set_ep <== ds4;

    signal mid_w; mid_w <== iw  * (_from_square + 8);
    signal mid_b; mid_b <== niw * (_from_square - 8);
    signal mid_sq; mid_sq <== mid_w + mid_b;

    signal next_ep_sq_a; next_ep_sq_a <== will_set_ep * mid_sq;
    signal next_ep_sq_b; next_ep_sq_b <== (1 - will_set_ep) * 0;
    signal next_ep_sq_sel; next_ep_sq_sel <== next_ep_sq_a + next_ep_sq_b;

    component next_ep_ok = LessThan(7); next_ep_ok.in[0] <== next_ep_sq_sel; next_ep_ok.in[1] <== 64; next_ep_ok.out === 1;

    next_ep_flag   <== will_set_ep;
    next_ep_square <== next_ep_sq_sel;

    /* ===================== APPLY MOVE ===================== */
    component ap = ApplyMove();
    ap.self_pawn   <== selfP; ap.self_knight <== selfN; ap.self_bishop <== selfB; ap.self_rook <== selfR; ap.self_queen <== selfQ; ap.self_king <== selfK;
    ap.opp_pawn    <== oppP;  ap.opp_knight  <== oppN;  ap.opp_bishop  <== oppB;  ap.opp_rook  <== oppR;  ap.opp_queen  <== oppQ;  ap.opp_king  <== oppK;

    ap.piece_type  <== piece_type;
    ap.from_square <== _from_square;
    ap.to_square   <== _to_square;

    ap.promo_flag       <== promo_flag;
    ap.promo_is_knight  <== promo_is_knight;
    ap.promo_is_bishop  <== promo_is_bishop;
    ap.promo_is_rook    <== promo_is_rook;
    ap.promo_is_queen   <== promo_is_queen;

    ap.castle_flag      <== isCastle;
    ap.rook_from_square <== cCastle.rook_from_sq;
    ap.rook_to_square   <== cCastle.rook_to_sq;

    ap.ep_flag              <== ep_flag;
    ap.ep_captured_square   <== ep_captured_square;

    signal next_self_pawn2;   next_self_pawn2   <== ap.next_self_pawn;
    signal next_self_knight2; next_self_knight2 <== ap.next_self_knight;
    signal next_self_bishop2; next_self_bishop2 <== ap.next_self_bishop;
    signal next_self_rook2;   next_self_rook2   <== ap.next_self_rook;
    signal next_self_queen2;  next_self_queen2  <== ap.next_self_queen;
    signal next_self_king2;   next_self_king2   <== ap.next_self_king;

    signal next_opp_pawn2;    next_opp_pawn2    <== ap.next_opp_pawn;
    signal next_opp_knight2;  next_opp_knight2  <== ap.next_opp_knight;
    signal next_opp_bishop2;  next_opp_bishop2  <== ap.next_opp_bishop;
    signal next_opp_rook2;    next_opp_rook2    <== ap.next_opp_rook;
    signal next_opp_queen2;   next_opp_queen2   <== ap.next_opp_queen;
    signal next_opp_king2;    next_opp_king2    <== ap.next_opp_king;

    // Map back to global next boards (pairwise splits) — NOW AS PUBLIC OUTPUTS
    signal output next_wP; signal output next_wN; signal output next_wB; signal output next_wR; signal output next_wQ; signal output next_wK;
    signal output next_bP; signal output next_bN; signal output next_bB; signal output next_bR; signal output next_bQ; signal output next_bK;

    signal nwP_a; nwP_a <== iw  * next_self_pawn2;    signal nwP_b; nwP_b <== niw * next_opp_pawn2;    next_wP <== nwP_a + nwP_b;
    signal nwN_a; nwN_a <== iw  * next_self_knight2;  signal nwN_b; nwN_b <== niw * next_opp_knight2;  next_wN <== nwN_a + nwN_b;
    signal nwB_a; nwB_a <== iw  * next_self_bishop2;  signal nwB_b; nwB_b <== niw * next_opp_bishop2;  next_wB <== nwB_a + nwB_b;
    signal nwR_a; nwR_a <== iw  * next_self_rook2;    signal nwR_b; nwR_b <== niw * next_opp_rook2;    next_wR <== nwR_a + nwR_b;
    signal nwQ_a; nwQ_a <== iw  * next_self_queen2;   signal nwQ_b; nwQ_b <== niw * next_opp_queen2;   next_wQ <== nwQ_a + nwQ_b;
    signal nwK_a; nwK_a <== iw  * next_self_king2;    signal nwK_b; nwK_b <== niw * next_opp_king2;    next_wK <== nwK_a + nwK_b;

    signal nbP_a; nbP_a <== iw  * next_opp_pawn2;     signal nbP_b; nbP_b <== niw * next_self_pawn2;    next_bP <== nbP_a + nbP_b;
    signal nbN_a; nbN_a <== iw  * next_opp_knight2;   signal nbN_b; nbN_b <== niw * next_self_knight2;  next_bN <== nbN_a + nbN_b;
    signal nbB_a; nbB_a <== iw  * next_opp_bishop2;   signal nbB_b; nbB_b <== niw * next_self_bishop2;  next_bB <== nbB_a + nbB_b;
    signal nbR_a; nbR_a <== iw  * next_opp_rook2;     signal nbR_b; nbR_b <== niw * next_self_rook2;    next_bR <== nbR_a + nbR_b;
    signal nbQ_a; nbQ_a <== iw  * next_opp_queen2;    signal nbQ_b; nbQ_b <== niw * next_self_queen2;   next_bQ <== nbQ_a + nbQ_b;
    signal nbK_a; nbK_a <== iw  * next_opp_king2;     signal nbK_b; nbK_b <== niw * next_self_king2;    next_bK <== nbK_a + nbK_b;

    /* ---- King safety on POST-move boards ---- */
    component safe = KingSafeRuntime_NoWitness();
    safe.occ <== next_wP + next_wN + next_wB + next_wR + next_wQ + next_wK
               + next_bP + next_bN + next_bB + next_bR + next_bQ + next_bK;

    signal oR_a; oR_a <== niw * next_wR;  signal oR_b; oR_b <== iw * next_bR;  safe.opp_rooks   <== oR_a + oR_b;
    signal oB_a; oB_a <== niw * next_wB;  signal oB_b; oB_b <== iw * next_bB;  safe.opp_bishops <== oB_a + oB_b;
    signal oQ_a; oQ_a <== niw * next_wQ;  signal oQ_b; oQ_b <== iw * next_bQ;  safe.opp_queens  <== oQ_a + oQ_b;
    signal oN_a; oN_a <== niw * next_wN;  signal oN_b; oN_b <== iw * next_bN;  safe.opp_knights <== oN_a + oN_b;
    signal oP_a; oP_a <== niw * next_wP;  signal oP_b; oP_b <== iw * next_bP;  safe.opp_pawns   <== oP_a + oP_b;
    signal oK_a; oK_a <== niw * next_wK;  signal oK_b; oK_b <== iw * next_bK;  safe.opp_king    <== oK_a + oK_b;

    safe.king_sq  <== _my_king_sq;
    safe.my_color <== _mover_color;

    /* ---- Opponent-in-check flag (POST-move) ---- */
    // Public output: 1 iff opponent king is under attack after my move
    signal output opp_in_check;
    component safeOpp = KingSafeRuntime_NoWitness();
    safeOpp.occ <== safe.occ;  // same post-move occupancy

    // "Opponent" (relative to their king) = **my** pieces after move
    signal aR_a; aR_a <== iw  * next_wR;  signal aR_b; aR_b <== niw * next_bR;  safeOpp.opp_rooks   <== aR_a + aR_b;
    signal aB_a; aB_a <== iw  * next_wB;  signal aB_b; aB_b <== niw * next_bB;  safeOpp.opp_bishops <== aB_a + aB_b;
    signal aQ_a; aQ_a <== iw  * next_wQ;  signal aQ_b; aQ_b <== niw * next_bQ;  safeOpp.opp_queens  <== aQ_a + aQ_b;
    signal aN_a; aN_a <== iw  * next_wN;  signal aN_b; aN_b <== niw * next_bN;  safeOpp.opp_knights <== aN_a + aN_b;
    signal aP_a; aP_a <== iw  * next_wP;  signal aP_b; aP_b <== niw * next_bP;  safeOpp.opp_pawns   <== aP_a + aP_b;
    signal aK_a; aK_a <== iw  * next_wK;  signal aK_b; aK_b <== niw * next_bK;  safeOpp.opp_king    <== aK_a + aK_b;

    // We are checking **their** king → set my_color to opponent’s color
    safeOpp.my_color <== 1 - _mover_color;
    safeOpp.king_sq  <== _opp_king_sq;  // post-move opponent king square

    // in-check = NOT safe
    opp_in_check <== 1 - safeOpp.ok;
    opp_in_check * (1 - opp_in_check) === 0;

    /* ---- NEXT CASTLING RIGHTS (post-move, quadratic-safe) ---- */
    signal rights0; rights0 <== _castle_rights;

    component isWhiteMover = IsZero(); isWhiteMover.in <== _mover_color;
    signal mw; mw <== isWhiteMover.out;
    signal mb; mb <== 1 - mw;

    component isKing  = IsEqual(); isKing.in[0]  <== piece_type; isKing.in[1]  <== 6;
    component isRook  = IsEqual(); isRook.in[0]  <== piece_type; isRook.in[1]  <== 4;

    component eq_from_a1 = IsEqual(); eq_from_a1.in[0] <== _from_square; eq_from_a1.in[1] <== 0;
    component eq_from_h1 = IsEqual(); eq_from_h1.in[0] <== _from_square; eq_from_h1.in[1] <== 7;
    component eq_from_a8 = IsEqual(); eq_from_a8.in[0] <== _from_square; eq_from_a8.in[1] <== 56;
    component eq_from_h8 = IsEqual(); eq_from_h8.in[0] <== _from_square; eq_from_h8.in[1] <== 63;

    component eq_to_a1 = IsEqual(); eq_to_a1.in[0] <== _to_square; eq_to_a1.in[1] <== 0;
    component eq_to_h1 = IsEqual(); eq_to_h1.in[0] <== _to_square; eq_to_h1.in[1] <== 7;
    component eq_to_a8 = IsEqual(); eq_to_a8.in[0] <== _to_square; eq_to_a8.in[1] <== 56;
    component eq_to_h8 = IsEqual(); eq_to_h8.in[0] <== _to_square; eq_to_h8.in[1] <== 63;

    component oppR_at_a1 = SelectBit64(); oppR_at_a1.packed <== oppR; oppR_at_a1.idx <== 0;
    component oppR_at_h1 = SelectBit64(); oppR_at_h1.packed <== oppR; oppR_at_h1.idx <== 7;
    component oppR_at_a8 = SelectBit64(); oppR_at_a8.packed <== oppR; oppR_at_a8.idx <== 56;
    component oppR_at_h8 = SelectBit64(); oppR_at_h8.packed <== oppR; oppR_at_h8.idx <== 63;

    signal moved_w_king; moved_w_king <== mw * isKing.out;
    signal moved_b_king; moved_b_king <== mb * isKing.out;

    signal t_mw_isR; t_mw_isR <== mw * isRook.out;
    signal t_mb_isR; t_mb_isR <== mb * isRook.out;

    signal moved_w_rook_a1; moved_w_rook_a1 <== t_mw_isR * eq_from_a1.out;
    signal moved_w_rook_h1; moved_w_rook_h1 <== t_mw_isR * eq_from_h1.out;
    signal moved_b_rook_a8; moved_b_rook_a8 <== t_mb_isR * eq_from_a8.out;
    signal moved_b_rook_h8; moved_b_rook_h8 <== t_mb_isR * eq_from_h8.out;

    signal t_mw_to_a1; t_mw_to_a1 <== mw * eq_to_a1.out;
    signal t_mw_to_h1; t_mw_to_h1 <== mw * eq_to_h1.out;
    signal t_mb_to_a8; t_mb_to_a8 <== mb * eq_to_a8.out;
    signal t_mb_to_h8; t_mb_to_h8 <== mb * eq_to_h8.out;

    signal cap_wq_rook; cap_wq_rook <== t_mw_to_a1 * oppR_at_a1.bit;
    signal cap_wk_rook; cap_wk_rook <== t_mw_to_h1 * oppR_at_h1.bit;
    signal cap_bq_rook; cap_bq_rook <== t_mb_to_a8 * oppR_at_a8.bit;
    signal cap_bk_rook; cap_bk_rook <== t_mb_to_h8 * oppR_at_h8.bit;

    signal clr_wk; clr_wk <== moved_w_king + moved_w_rook_h1 + cap_wk_rook;           // wk bit (8)
    signal clr_wq; clr_wq <== moved_w_king + moved_w_rook_a1 + cap_wq_rook;           // wq bit (4)
    signal clr_bk; clr_bk <== moved_b_king + moved_b_rook_h8 + cap_bk_rook;           // bk bit (2)
    signal clr_bq; clr_bq <== moved_b_king + moved_b_rook_a8 + cap_bq_rook;           // bq bit (1)

    clr_wk * (1 - clr_wk) === 0; clr_wq * (1 - clr_wq) === 0;
    clr_bk * (1 - clr_bk) === 0; clr_bq * (1 - clr_bq) === 0;

    // Decompose _castle_rights into individual bits
    component rightsBits = Num2Bits(4);
    rightsBits.in <== rights0;

    // Extract individual bits for wk, wq, bk, bq
    signal wk_bit; wk_bit <== rightsBits.out[3];
    signal wq_bit; wq_bit <== rightsBits.out[2];
    signal bk_bit; bk_bit <== rightsBits.out[1];
    signal bq_bit; bq_bit <== rightsBits.out[0];

    // Intermediate calculations for each bit
    signal clr_wk_valid; clr_wk_valid <== clr_wk * wk_bit;
    signal clr_wq_valid; clr_wq_valid <== clr_wq * wq_bit;
    signal clr_bk_valid; clr_bk_valid <== clr_bk * bk_bit;
    signal clr_bq_valid; clr_bq_valid <== clr_bq * bq_bit;

    // Combine the results into rights1
    signal rights1_intermediate1; rights1_intermediate1 <== rights0 - 8 * clr_wk_valid;
    signal rights1_intermediate2; rights1_intermediate2 <== rights1_intermediate1 - 4 * clr_wq_valid;
    signal rights1_intermediate3; rights1_intermediate3 <== rights1_intermediate2 - 2 * clr_bk_valid;
    signal rights1; rights1 <== rights1_intermediate3 - 1 * clr_bq_valid;

    component rights_ok = LessThan(5); rights_ok.in[0] <== rights1; rights_ok.in[1] <== 16; rights_ok.out === 1;

    next_castle_rights <== rights1;
}
