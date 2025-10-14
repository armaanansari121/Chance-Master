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
include "BoardHash.circom";                         // template BoardHash12
include "KingSafeCheck.circom";                     // template KingSafeRuntime_NoWitness
include "CheckCastling.circom";                     // template CheckCastling
include "NoBitCollisions.circom";                   // template NoBitCollisions12

/* Split BN254 Poseidon felt into Cairo u256 limbs */
template FeltToUint256() {
    signal input  x;
    signal output low;   // 0..2^128-1
    signal output high;  // 0..2^128-1

    component bits = Num2Bits(256); bits.in <== x;

    signal accL[129]; accL[0] <== 0;
    for (var i = 0; i < 128; i++) { accL[i+1] <== accL[i] + bits.out[i] * (1 << i); }
    low <== accL[128];

    signal accH[129]; accH[0] <== 0;
    for (var j = 0; j < 128; j++) { accH[j+1] <== accH[j] + bits.out[128+j] * (1 << j); }
    high <== accH[128];
}

/* ============== MAIN (promotion + castling + en passant + no-collision) ==============

Public outputs (contract decodes in this order):
0  contract_addr_felt
1  game_id_low      2  game_id_high
3  rng_nonce_low    4  rng_nonce_high
5  mover_addr_felt
6  mover_color      7  turn
8  from_square      9  to_square
10 promo_choice
11 dice0           12 dice1          13 dice2
14 castle_rights
15 prev_hash_low   16 prev_hash_high
17 next_hash_low   18 next_hash_high
19 prev_ep_flag    20 prev_ep_square
21 next_ep_flag    22 next_ep_square
*/
template Orchestrator() {
    // ---- PUBLIC CONTEXT (emitted) ----
    signal output contract_addr_felt;
    signal output game_id_low;   signal output game_id_high;
    signal output rng_nonce_low; signal output rng_nonce_high;
    signal output mover_addr_felt;
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

    signal output prev_hash_low;   signal output prev_hash_high;
    signal output next_hash_low;   signal output next_hash_high;

    // EP public state (previous and next half-move)
    signal output prev_ep_flag;     // 0/1
    signal output prev_ep_square;   // 0..63 (meaningful only if flag=1)
    signal output next_ep_flag;     // 0/1
    signal output next_ep_square;   // 0..63 (meaningful only if flag=1)

    // ---- PRIVATE PRE-STATE (12 bitboards) ----
    signal input wP; signal input wN; signal input wB; signal input wR; signal input wQ; signal input wK;
    signal input bP; signal input bN; signal input bB; signal input bR; signal input bQ; signal input bK;

    // ---- PRIVATE CONTEXT (fed by prover, re-emitted) ----
    signal input _contract_addr_felt;
    signal input _game_id_low;   signal input _game_id_high;
    signal input _rng_nonce_low; signal input _rng_nonce_high;
    signal input _mover_addr_felt;
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

    // Previous en passant state (from last half-move)
    signal input _prev_ep_flag;   // 0/1
    signal input _prev_ep_square; // 0..63 (only meaningful if flag=1)

    // Re-emit as publics
    contract_addr_felt <== _contract_addr_felt;
    game_id_low        <== _game_id_low;    game_id_high   <== _game_id_high;
    rng_nonce_low      <== _rng_nonce_low;  rng_nonce_high <== _rng_nonce_high;
    mover_addr_felt    <== _mover_addr_felt;

    mover_color        <== _mover_color;    turn           <== _turn;
    from_square        <== _from_square;    to_square      <== _to_square;

    promo_choice       <== _promo_choice;

    dice0              <== _dice0;          dice1          <== _dice1;          dice2 <== _dice2;

    castle_rights      <== _castle_rights;

    prev_ep_flag       <== _prev_ep_flag;
    prev_ep_square     <== _prev_ep_square;

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
    // Decompose from/to to get file/rank
    component FB = Num2Bits(6); FB.in <== _from_square;
    component TB = Num2Bits(6); TB.in <== _to_square;
    signal from_file; from_file <== FB.out[0] + 2*FB.out[1] + 4*FB.out[2];
    signal to_file;   to_file   <== TB.out[0] + 2*TB.out[1] + 4*TB.out[2];
    signal from_rank; from_rank <== FB.out[3] + 2*FB.out[4] + 4*FB.out[5];
    signal to_rank;   to_rank   <== TB.out[3] + 2*TB.out[4] + 4*TB.out[5];

    // |df|==1
    signal df; df <== to_file - from_file;
    signal df2; df2 <== df * df;
    component eq_df2_1 = IsEqual(); eq_df2_1.in[0] <== df2; eq_df2_1.in[1] <== 1;
    signal abs_df_is1; abs_df_is1 <== eq_df2_1.out; abs_df_is1 * (1 - abs_df_is1) === 0;

    // dir +1 for white, -1 for black
    component eq_dr_plus1  = IsEqual(); eq_dr_plus1.in[0]  <== to_rank;   eq_dr_plus1.in[1]  <== from_rank + 1;
    component eq_dr_minus1 = IsEqual(); eq_dr_minus1.in[0] <== from_rank; eq_dr_minus1.in[1] <== to_rank + 1;
    signal dr_plus1;  dr_plus1  <== eq_dr_plus1.out;
    signal dr_minus1; dr_minus1 <== eq_dr_minus1.out;

    signal dir_match_w; dir_match_w <== iw  * dr_plus1;
    signal dir_match_b; dir_match_b <== niw * dr_minus1;
    signal dir_match;   dir_match   <== dir_match_w + dir_match_b;

    // piece is pawn?
    component isPawn = IsEqual(); isPawn.in[0] <== piece_type; isPawn.in[1] <== 1;
    signal tPawn; tPawn <== isPawn.out; tPawn * (1 - tPawn) === 0;

    // Destination equals previous EP square?
    component eq_to_prevEP = IsEqual(); eq_to_prevEP.in[0] <== _to_square; eq_to_prevEP.in[1] <== _prev_ep_square;

    // opp occupancy at 'to' (must be empty for EP capture)
    component oppAtTo_raw = SelectBit64(); oppAtTo_raw.packed <== oppALL; oppAtTo_raw.idx <== _to_square;

    // Candidate EP flag before extra checks
    signal ep_candidate_t1; ep_candidate_t1 <== tPawn * _prev_ep_flag;
    signal ep_candidate_t2; ep_candidate_t2 <== ep_candidate_t1 * eq_to_prevEP.out;
    signal ep_candidate_t3; ep_candidate_t3 <== ep_candidate_t2 * abs_df_is1;
    signal ep_candidate;    ep_candidate    <== ep_candidate_t3 * dir_match;

    // Enforce “to” is empty if EP is used
    signal ep_to_empty_ok; ep_to_empty_ok <== 1 - (ep_candidate * oppAtTo_raw.bit);
    ep_to_empty_ok === 1;

    // Captured square: to±8 depending on color, gated by ep_candidate
    signal to_minus8; to_minus8 <== _to_square - 8;
    signal to_plus8;  to_plus8  <== _to_square + 8;

    // Build color-based raw target (no out-of-range exposure)
    signal cap_raw_w; cap_raw_w <== iw  * to_minus8;
    signal cap_raw_b; cap_raw_b <== niw * to_plus8;
    signal cap_raw;   cap_raw   <== cap_raw_w + cap_raw_b;

    // Gate index to be safe when ep not used: idx = ep? cap_raw : to
    signal cap_sel_a; cap_sel_a <== ep_candidate * cap_raw;
    signal cap_sel_b; cap_sel_b <== (1 - ep_candidate) * _to_square;
    signal ep_captured_square; ep_captured_square <== cap_sel_a + cap_sel_b;

    // Prove < 64
    component ep_idx_ok = LessThan(7);
    ep_idx_ok.in[0] <== ep_captured_square;
    ep_idx_ok.in[1] <== 64;
    ep_idx_ok.out === 1;

    // Ensure there is an opponent pawn at captured square when EP is used
    component oppPawnAtCap = SelectBit64();
    oppPawnAtCap.packed <== oppP;
    oppPawnAtCap.idx    <== ep_captured_square;

    signal ep_has_pawn; ep_has_pawn <== ep_candidate * oppPawnAtCap.bit;
    // Equivalent to: if ep_candidate=1 then bit must be 1
    signal ep_need_ok; ep_need_ok <== ep_candidate - ep_has_pawn;
    ep_need_ok === 0;

    // Final EP flag (boolean)
    signal ep_flag; ep_flag <== ep_candidate;
    ep_flag * (1 - ep_flag) === 0;

    /* ---- Gate geometry 'to' so CheckPieceGeometry never asserts on castle ---- */
    signal from_p1; from_p1 <== _from_square + 1;
    signal t_castle_to; t_castle_to <== isCastle * from_p1;
    signal t_normal_to; t_normal_to <== (1 - isCastle) * _to_square;
    signal geom_to_idx; geom_to_idx <== t_castle_to + t_normal_to;

    /* ---- Effective opp_at_to for geometry: OR(raw, ep_flag) ---- */
    signal opp_at_to_eff; opp_at_to_eff <== oppAtTo_raw.bit + ep_flag - oppAtTo_raw.bit * ep_flag;

    /* ---- Geometry (fed with gated idx + opp_at_to_eff) ---- */
    component cGeom = CheckPieceGeometry();
    cGeom.piece_type  <== piece_type;
    cGeom.mover_color <== _mover_color;
    cGeom.from_square <== _from_square;
    cGeom.to_square   <== geom_to_idx;
    cGeom.opp_at_to   <== opp_at_to_eff;
    signal needsLC; needsLC <== cGeom.needs_lineclear;

    /* ---- Combine legality: (regular geometry) OR (castling) ---- */
    signal geom_or_castle_t; geom_or_castle_t <== cGeom.ok + isCastle;
    signal geom_or_castle_i; geom_or_castle_i <== cGeom.ok * isCastle;
    signal legal_move; legal_move <== geom_or_castle_t - geom_or_castle_i;
    legal_move * (1 - legal_move) === 0;
    legal_move === 1;

    /* ---- Conditional Line Clear (only when needed AND not castling) ---- */
    component lc = LineClearRuntime();
    lc.all_board <== selfALL + oppALL;
    lc.from      <== _from_square;
    lc.to        <== _to_square;

    signal lc_ok; lc_ok <== lc.ok; lc_ok * (1 - lc_ok) === 0;
    signal need_lc_no_castle; need_lc_no_castle <== needsLC * (1 - isCastle);
    signal gate_lc; gate_lc <== need_lc_no_castle * (1 - lc_ok);
    gate_lc === 0;

    /* ===================== PROMOTION FLAGS (pairwise only) ===================== */
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

    /* ===================== NEXT EP STATE (double-step creation) ===================== */
    // same_file?
    component eq_df0 = IsEqual(); eq_df0.in[0] <== to_file - from_file; eq_df0.in[1] <== 0;
    signal same_file; same_file <== eq_df0.out;

    // |dr| == 2 with color-correct direction and start rank
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

    // Destination must be empty for double-step (already implied by geometry + line clear, we also gate by oppAtTo==0)
    signal dest_empty_for_ds; dest_empty_for_ds <== 1 - oppAtTo_raw.bit;

    signal ds1; ds1 <== tPawn * same_file;
    signal ds2; ds2 <== ds1 * dir2_ok;
    signal ds3; ds3 <== ds2 * start_ok;
    signal ds4; ds4 <== ds3 * dest_empty_for_ds;
    signal will_set_ep; will_set_ep <== ds4;  // boolean due to ANDs

    // Next EP square = from ± 8 (the skipped square)
    signal mid_w; mid_w <== iw  * (_from_square + 8);
    signal mid_b; mid_b <== niw * (_from_square - 8);
    signal mid_sq; mid_sq <== mid_w + mid_b;

    signal next_ep_sq_a; next_ep_sq_a <== will_set_ep * mid_sq;
    signal next_ep_sq_b; next_ep_sq_b <== (1 - will_set_ep) * 0;
    signal next_ep_sq_sel; next_ep_sq_sel <== next_ep_sq_a + next_ep_sq_b;

    // Range proof for next_ep_sq_sel
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

    // EN PASSANT wiring
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

    // Map back to global next boards (pairwise splits)
    signal next_wP; signal next_wN; signal next_wB; signal next_wR; signal next_wQ; signal next_wK;
    signal next_bP; signal next_bN; signal next_bB; signal next_bR; signal next_bQ; signal next_bK;

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

    signal oR_a; oR_a <== niw * wR;  signal oR_b; oR_b <== iw * bR;  safe.opp_rooks   <== oR_a + oR_b;
    signal oB_a; oB_a <== niw * wB;  signal oB_b; oB_b <== iw * bB;  safe.opp_bishops <== oB_a + oB_b;
    signal oQ_a; oQ_a <== niw * wQ;  signal oQ_b; oQ_b <== iw * bQ;  safe.opp_queens  <== oQ_a + oQ_b;
    signal oN_a; oN_a <== niw * wN;  signal oN_b; oN_b <== iw * bN;  safe.opp_knights <== oN_a + oN_b;
    signal oP_a; oP_a <== niw * wP;  signal oP_b; oP_b <== iw * bP;  safe.opp_pawns   <== oP_a + oP_b;
    signal oK_a; oK_a <== niw * wK;  signal oK_b; oK_b <== iw * bK;  safe.opp_king    <== oK_a + oK_b;

    safe.king_sq  <== _my_king_sq;
    safe.my_color <== _mover_color;

    /* ---- Hash PRE and NEXT, then split to u256 ---- */
    component Hprev = BoardHash12();
    Hprev.white_pawn   <== wP;   Hprev.white_knight <== wN;   Hprev.white_bishop <== wB;
    Hprev.white_rook   <== wR;   Hprev.white_queen  <== wQ;   Hprev.white_king   <== wK;
    Hprev.black_pawn   <== bP;   Hprev.black_knight <== bN;   Hprev.black_bishop <== bB;
    Hprev.black_rook   <== bR;   Hprev.black_queen  <== bQ;   Hprev.black_king   <== bK;

    component Hnext = BoardHash12();
    Hnext.white_pawn   <== next_wP;   Hnext.white_knight <== next_wN;   Hnext.white_bishop <== next_wB;
    Hnext.white_rook   <== next_wR;   Hnext.white_queen  <== next_wQ;   Hnext.white_king   <== next_wK;
    Hnext.black_pawn   <== next_bP;   Hnext.black_knight <== next_bN;   Hnext.black_bishop <== next_bB;
    Hnext.black_rook   <== next_bR;   Hnext.black_queen  <== next_bQ;   Hnext.black_king   <== next_bK;

    component splitPrev = FeltToUint256(); splitPrev.x <== Hprev.hash_out;
    component splitNext = FeltToUint256(); splitNext.x <== Hnext.hash_out;

    prev_hash_low  <== splitPrev.low;   prev_hash_high <== splitPrev.high;
    next_hash_low  <== splitNext.low;   next_hash_high <== splitNext.high;
}

component main = Orchestrator();

/*
INPUT ={
  "wP": 0, "wN": 0, "wB": 0, "wR": 0, "wQ": 0, "wK": 0,
  "bP": 0,  "bN": 0, "bB": 0, "bR": 9223372036854775808, "bQ": 0, "bK": 1152921504606846976,
  "_contract_addr_felt": 1, "_game_id_low": 3, "_game_id_high": 0,
  "_rng_nonce_low": 44, "_rng_nonce_high": 0, "_mover_addr_felt": 2,
  "_mover_color": 1, "_turn": 1,
  "_from_square": 60, "_to_square": 62,
  "_promo_choice": 0, "_dice0": 6, "_dice1": 5, "_dice2": 3,
  "_castle_rights": 15, "_my_king_sq": 62,
  "_prev_ep_flag": 0, "_prev_ep_square": 0
}

*/
