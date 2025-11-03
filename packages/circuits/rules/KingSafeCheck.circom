pragma circom 2.0.0;

include "circomlib/circuits/bitify.circom";      // Num2Bits
include "circomlib/circuits/comparators.circom"; // IsEqual, LessThan
include "./_helpers.circom";                      // SelectFromBits64

/* -------------------------------------------------------------------------- */
/* KingSafeRuntime_NoWitness (boards decomposed once; gated indices + checks) */
/* -------------------------------------------------------------------------- */
template KingSafeRuntime_NoWitness() {
    // Inputs
    signal input occ;            // u64 (self | opp)
    signal input opp_rooks;      // u64
    signal input opp_bishops;    // u64
    signal input opp_queens;     // u64
    signal input opp_knights;    // u64
    signal input opp_pawns;      // u64
    signal input opp_king;       // u64
    signal input king_sq;        // 0..63
    signal input my_color;       // 0 white, 1 black

    // Output
    signal output ok;

    // Directions (constants)
    var STEP[8]     = [1,-1,8,-8,9,-9,7,-7];
    var DF[8]       = [1,-1,0,0, 1,-1, 1,-1];
    var DR[8]       = [0, 0,1,-1,1, 1,-1,-1];
    var IS_ORTHO[8] = [1,1,1,1,0,0,0,0];

    // King coords
    component K = Num2Bits(6);  K.in <== king_sq;
    signal kf <== K.out[0] + 2*K.out[1] + 4*K.out[2];
    signal kr <== K.out[3] + 2*K.out[4] + 4*K.out[5];

    /* ----------- Decompose each bitboard exactly once (global) -------- */
    component occBits        = Num2Bits(64); occBits.in        <== occ;
    component rookBits       = Num2Bits(64); rookBits.in       <== opp_rooks;
    component bishopBits     = Num2Bits(64); bishopBits.in     <== opp_bishops;
    component queenBits      = Num2Bits(64); queenBits.in      <== opp_queens;
    component knightBits     = Num2Bits(64); knightBits.in     <== opp_knights;
    component pawnBits       = Num2Bits(64); pawnBits.in       <== opp_pawns;
    component oppKingBits    = Num2Bits(64); oppKingBits.in    <== opp_king;

    // -------------------- Arrays & components (ALL hoisted) --------------------
    signal file_plus_m[8][7];
    signal rank_plus_m[8][7];

    component kf_lt_bound[8][7];
    component m_lt_kf1[8][7];
    component kr_lt_bound[8][7];
    component m_lt_kr1[8][7];

    signal in_file_m[8][7];
    signal in_rank_m[8][7];
    signal in_bounds_m[8][7];
    signal inb_mul[8][7];

    signal idx_raw[8][7];
    signal one_minus_inb[8][7];
    signal idx_sel_t1[8][7];
    signal idx_sel_t2[8][7];
    signal idx_sel[8][7];

    component sel_occ[8][7];  // SelectFromBits64
    signal occ_bit[8][7];
    signal occ_eff[8][7];

    signal one_minus_occ[8][7];
    signal prefixE[8][8];
    signal first_blocker_m[8][7];

    component sR_sel[8][7];   // SelectFromBits64
    component sB_sel[8][7];   // SelectFromBits64
    component sQ_sel[8][7];   // SelectFromBits64

    signal rq_mul[8][7];
    signal rq[8][7];
    signal bq_mul[8][7];
    signal bq[8][7];
    signal badHit[8][7];
    signal contrib[8][7];

    signal accA[8][8];
    component accZero[8];
    signal ok_ray[8];

    /* NEW: explicit <64 checkers for every ray-step index */
    component idx64_ok[8][7];

    // Instantiate component arrays once (allowed: component instantiation in loops)
    for (var d = 0; d < 8; d++) {
        for (var m = 0; m < 7; m++) {
            kf_lt_bound[d][m] = LessThan(4);
            m_lt_kf1[d][m]    = LessThan(4);
            kr_lt_bound[d][m] = LessThan(4);
            m_lt_kr1[d][m]    = LessThan(4);

            sel_occ[d][m]     = SelectFromBits64();
            sR_sel[d][m]      = SelectFromBits64();
            sB_sel[d][m]      = SelectFromBits64();
            sQ_sel[d][m]      = SelectFromBits64();

            idx64_ok[d][m]    = LessThan(7);
        }
        accZero[d] = IsEqual();
    }

    // -------------------- Build rays --------------------
    for (var d = 0; d < 8; d++) {
        var step_d = STEP[d];
        var df = DF[d];
        var dr = DR[d];
        var isOrthoConst = IS_ORTHO[d];

        prefixE[d][0] <== 1;

        for (var mm = 1; mm <= 7; mm++) {
            var m = mm;

            file_plus_m[d][m-1] <== kf + (df * m);
            rank_plus_m[d][m-1] <== kr + (dr * m);

            kf_lt_bound[d][m-1].in[0] <== kf;
            kf_lt_bound[d][m-1].in[1] <== (8 - m);
            m_lt_kf1[d][m-1].in[0]    <== m;
            m_lt_kf1[d][m-1].in[1]    <== kf + 1;

            kr_lt_bound[d][m-1].in[0] <== kr;
            kr_lt_bound[d][m-1].in[1] <== (8 - m);
            m_lt_kr1[d][m-1].in[0]    <== m;
            m_lt_kr1[d][m-1].in[1]    <== kr + 1;

            in_file_m[d][m-1] <==
                ((df==1) ? 1 : 0) * kf_lt_bound[d][m-1].out
              + ((df==-1)? 1 : 0) * m_lt_kf1[d][m-1].out
              + ((df==0) ? 1 : 0) * 1;

            in_rank_m[d][m-1] <==
                ((dr==1) ? 1 : 0) * kr_lt_bound[d][m-1].out
              + ((dr==-1)? 1 : 0) * m_lt_kr1[d][m-1].out
              + ((dr==0) ? 1 : 0) * 1;

            inb_mul[d][m-1]     <== in_file_m[d][m-1] * in_rank_m[d][m-1];
            in_bounds_m[d][m-1] <== inb_mul[d][m-1];

            idx_raw[d][m-1] <== (rank_plus_m[d][m-1] * 8) + file_plus_m[d][m-1];

            one_minus_inb[d][m-1] <== 1 - in_bounds_m[d][m-1];
            idx_sel_t1[d][m-1] <== in_bounds_m[d][m-1] * idx_raw[d][m-1];
            idx_sel_t2[d][m-1] <== one_minus_inb[d][m-1] * king_sq;
            idx_sel[d][m-1]   <== idx_sel_t1[d][m-1] + idx_sel_t2[d][m-1];

            /* NEW: enforce idx_sel < 64 explicitly */
            idx64_ok[d][m-1].in[0] <== idx_sel[d][m-1];
            idx64_ok[d][m-1].in[1] <== 64;
            idx64_ok[d][m-1].out === 1;

            /* selectors wired to pre-decomposed bits (assignments only) */
            sel_occ[d][m-1].idx <== idx_sel[d][m-1];
            sR_sel[d][m-1].idx  <== idx_sel[d][m-1];
            sB_sel[d][m-1].idx  <== idx_sel[d][m-1];
            sQ_sel[d][m-1].idx  <== idx_sel[d][m-1];

            for (var i = 0; i < 64; i++) {
                sel_occ[d][m-1].bits[i] <== occBits.out[i];
                sR_sel[d][m-1].bits[i]  <== rookBits.out[i];
                sB_sel[d][m-1].bits[i]  <== bishopBits.out[i];
                sQ_sel[d][m-1].bits[i]  <== queenBits.out[i];
            }

            occ_bit[d][m-1] <== sel_occ[d][m-1].bit;
            occ_eff[d][m-1] <== in_bounds_m[d][m-1] * occ_bit[d][m-1];

            one_minus_occ[d][m-1] <== 1 - occ_eff[d][m-1];
            prefixE[d][m] <== prefixE[d][m-1] * one_minus_occ[d][m-1];

            first_blocker_m[d][m-1] <== prefixE[d][m-1] * occ_eff[d][m-1];

            rq_mul[d][m-1] <== sR_sel[d][m-1].bit * sQ_sel[d][m-1].bit;
            rq[d][m-1]     <== sR_sel[d][m-1].bit + sQ_sel[d][m-1].bit - rq_mul[d][m-1];

            bq_mul[d][m-1] <== sB_sel[d][m-1].bit * sQ_sel[d][m-1].bit;
            bq[d][m-1]     <== sB_sel[d][m-1].bit + sQ_sel[d][m-1].bit - bq_mul[d][m-1];

            badHit[d][m-1] <== isOrthoConst * rq[d][m-1] + (1 - isOrthoConst) * bq[d][m-1];
            contrib[d][m-1] <== first_blocker_m[d][m-1] * badHit[d][m-1];
        }

        accA[d][0] <== 0;
        accA[d][1] <== accA[d][0] + contrib[d][0];
        accA[d][2] <== accA[d][1] + contrib[d][1];
        accA[d][3] <== accA[d][2] + contrib[d][2];
        accA[d][4] <== accA[d][3] + contrib[d][3];
        accA[d][5] <== accA[d][4] + contrib[d][4];
        accA[d][6] <== accA[d][5] + contrib[d][5];
        accA[d][7] <== accA[d][6] + contrib[d][6];

        accZero[d].in[0] <== accA[d][7];
        accZero[d].in[1] <== 0;
        ok_ray[d] <== accZero[d].out;
        ok_ray[d] * (1 - ok_ray[d]) === 0;
    }

    // -------------------- Knights (GATED IDX + explicit <64) --------------------
    signal f_p1 <== kf + 1;  signal f_p2 <== kf + 2;
    signal f_m1 <== kf - 1;  signal f_m2 <== kf - 2;
    signal r_p1 <== kr + 1;  signal r_p2 <== kr + 2;
    signal r_m1 <== kr - 1;  signal r_m2 <== kr - 2;

    component f_p1_lt8 = LessThan(4); f_p1_lt8.in[0] <== f_p1; f_p1_lt8.in[1] <== 8;
    component f_p2_lt8 = LessThan(4); f_p2_lt8.in[0] <== f_p2; f_p2_lt8.in[1] <== 8;
    component f_m1_lt8 = LessThan(4); f_m1_lt8.in[0] <== f_m1; f_m1_lt8.in[1] <== 8;
    component f_m2_lt8 = LessThan(4); f_m2_lt8.in[0] <== f_m2; f_m2_lt8.in[1] <== 8;

    component r_p1_lt8 = LessThan(4); r_p1_lt8.in[0] <== r_p1; r_p1_lt8.in[1] <== 8;
    component r_p2_lt8 = LessThan(4); r_p2_lt8.in[0] <== r_p2; r_p2_lt8.in[1] <== 8;
    component r_m1_lt8 = LessThan(4); r_m1_lt8.in[0] <== r_m1; r_m1_lt8.in[1] <== 8;
    component r_m2_lt8 = LessThan(4); r_m2_lt8.in[0] <== r_m2; r_m2_lt8.in[1] <== 8;

    signal idx_k1 <== (r_p2 * 8) + f_p1;   signal idx_k2 <== (r_p1 * 8) + f_p2;
    signal idx_k3 <== (r_m1 * 8) + f_p2;   signal idx_k4 <== (r_m2 * 8) + f_p1;
    signal idx_k5 <== (r_m2 * 8) + f_m1;   signal idx_k6 <== (r_m1 * 8) + f_m2;
    signal idx_k7 <== (r_p1 * 8) + f_m2;   signal idx_k8 <== (r_p2 * 8) + f_m1;

    // Add these four once (near the knight section):
    component kf_ge1 = LessThan(4); kf_ge1.in[0] <== 0; kf_ge1.in[1] <== kf;   // kf >= 1
    component kf_ge2 = LessThan(4); kf_ge2.in[0] <== 1; kf_ge2.in[1] <== kf;   // kf >= 2
    component kr_ge1 = LessThan(4); kr_ge1.in[0] <== 0; kr_ge1.in[1] <== kr;   // kr >= 1
    component kr_ge2 = LessThan(4); kr_ge2.in[0] <== 1; kr_ge2.in[1] <== kr;   // kr >= 2

    // Then define in-bounds flags like this:
    signal in_k1 <== f_p1_lt8.out * r_p2_lt8.out;   // ( +1 , +2 )
    signal in_k2 <== f_p2_lt8.out * r_p1_lt8.out;   // ( +2 , +1 )
    signal in_k3 <== f_p2_lt8.out * kr_ge1.out;     // ( +2 , -1 ) needs kr>=1
    signal in_k4 <== f_p1_lt8.out * kr_ge2.out;     // ( +1 , -2 ) needs kr>=2
    signal in_k5 <== kf_ge1.out   * kr_ge2.out;     // ( -1 , -2 ) needs kf>=1,kr>=2
    signal in_k6 <== kf_ge2.out   * kr_ge1.out;     // ( -2 , -1 ) needs kf>=2,kr>=1
    signal in_k7 <== kf_ge2.out   * r_p1_lt8.out;   // ( -2 , +1 )
    signal in_k8 <== kf_ge1.out   * r_p2_lt8.out;   // ( -1 , +2 )


    // Gate to [0..63] before selector (one mult per line)
    signal t_k1a; t_k1a <== in_k1 * idx_k1;  signal t_k1b; t_k1b <== (1 - in_k1) * king_sq;  signal idx_k1_sel <== t_k1a + t_k1b;
    signal t_k2a; t_k2a <== in_k2 * idx_k2;  signal t_k2b; t_k2b <== (1 - in_k2) * king_sq;  signal idx_k2_sel <== t_k2a + t_k2b;
    signal t_k3a; t_k3a <== in_k3 * idx_k3;  signal t_k3b; t_k3b <== (1 - in_k3) * king_sq;  signal idx_k3_sel <== t_k3a + t_k3b;
    signal t_k4a; t_k4a <== in_k4 * idx_k4;  signal t_k4b; t_k4b <== (1 - in_k4) * king_sq;  signal idx_k4_sel <== t_k4a + t_k4b;
    signal t_k5a; t_k5a <== in_k5 * idx_k5;  signal t_k5b; t_k5b <== (1 - in_k5) * king_sq;  signal idx_k5_sel <== t_k5a + t_k5b;
    signal t_k6a; t_k6a <== in_k6 * idx_k6;  signal t_k6b; t_k6b <== (1 - in_k6) * king_sq;  signal idx_k6_sel <== t_k6a + t_k6b;
    signal t_k7a; t_k7a <== in_k7 * idx_k7;  signal t_k7b; t_k7b <== (1 - in_k7) * king_sq;  signal idx_k7_sel <== t_k7a + t_k7b;
    signal t_k8a; t_k8a <== in_k8 * idx_k8;  signal t_k8b; t_k8b <== (1 - in_k8) * king_sq;  signal idx_k8_sel <== t_k8a + t_k8b;

    /* Explicit < 64 checks for each knight index */
    component nk_ok1 = LessThan(7); nk_ok1.in[0] <== idx_k1_sel; nk_ok1.in[1] <== 64; nk_ok1.out === 1;
    component nk_ok2 = LessThan(7); nk_ok2.in[0] <== idx_k2_sel; nk_ok2.in[1] <== 64; nk_ok2.out === 1;
    component nk_ok3 = LessThan(7); nk_ok3.in[0] <== idx_k3_sel; nk_ok3.in[1] <== 64; nk_ok3.out === 1;
    component nk_ok4 = LessThan(7); nk_ok4.in[0] <== idx_k4_sel; nk_ok4.in[1] <== 64; nk_ok4.out === 1;
    component nk_ok5 = LessThan(7); nk_ok5.in[0] <== idx_k5_sel; nk_ok5.in[1] <== 64; nk_ok5.out === 1;
    component nk_ok6 = LessThan(7); nk_ok6.in[0] <== idx_k6_sel; nk_ok6.in[1] <== 64; nk_ok6.out === 1;
    component nk_ok7 = LessThan(7); nk_ok7.in[0] <== idx_k7_sel; nk_ok7.in[1] <== 64; nk_ok7.out === 1;
    component nk_ok8 = LessThan(7); nk_ok8.in[0] <== idx_k8_sel; nk_ok8.in[1] <== 64; nk_ok8.out === 1;

    component nk1 = SelectFromBits64();
    component nk2 = SelectFromBits64();
    component nk3 = SelectFromBits64();
    component nk4 = SelectFromBits64();
    component nk5 = SelectFromBits64();
    component nk6 = SelectFromBits64();
    component nk7 = SelectFromBits64();
    component nk8 = SelectFromBits64();

    nk1.idx <== idx_k1_sel; nk2.idx <== idx_k2_sel; nk3.idx <== idx_k3_sel; nk4.idx <== idx_k4_sel;
    nk5.idx <== idx_k5_sel; nk6.idx <== idx_k6_sel; nk7.idx <== idx_k7_sel; nk8.idx <== idx_k8_sel;

    for (var i = 0; i < 64; i++) {
        nk1.bits[i] <== knightBits.out[i];
        nk2.bits[i] <== knightBits.out[i];
        nk3.bits[i] <== knightBits.out[i];
        nk4.bits[i] <== knightBits.out[i];
        nk5.bits[i] <== knightBits.out[i];
        nk6.bits[i] <== knightBits.out[i];
        nk7.bits[i] <== knightBits.out[i];
        nk8.bits[i] <== knightBits.out[i];
    }

    signal accN[9];
    accN[0] <== 0;
    accN[1] <== accN[0] + in_k1 * nk1.bit;
    accN[2] <== accN[1] + in_k2 * nk2.bit;
    accN[3] <== accN[2] + in_k3 * nk3.bit;
    accN[4] <== accN[3] + in_k4 * nk4.bit;
    accN[5] <== accN[4] + in_k5 * nk5.bit;
    accN[6] <== accN[5] + in_k6 * nk6.bit;
    accN[7] <== accN[6] + in_k7 * nk7.bit;
    accN[8] <== accN[7] + in_k8 * nk8.bit;
    signal knight_hits <== accN[8];

    // -------------------- Pawns (opp perspective, GATED IDX + <64) -----------
    signal oppIsWhite <== my_color;   // opponent is white iff I'm black (0=white,1=black)

    // Reuse f_p1, f_m1 from above; define rank up/down
    signal r_up  <== kr + 1;
    signal r_dn  <== kr - 1;

    // Safe upper-bound checks for “+1” steps (always non-negative)
    component f_p1_lt8b = LessThan(4); f_p1_lt8b.in[0] <== f_p1; f_p1_lt8b.in[1] <== 8;  // kf+1 < 8  => kf <= 6
    component r_up_lt8  = LessThan(4); r_up_lt8.in[0]  <== r_up; r_up_lt8.in[1]  <== 8;  // kr+1 < 8  => kr <= 6

    // For “-1” steps, DO NOT compare negatives (kf-1, kr-1) to 8.
    // Gate with direct lower-bound checks on kf/kr instead.
    // component kf_ge1 = LessThan(4); kf_ge1.in[0] <== 0; kf_ge1.in[1] <== kf;   // kf >= 1
    // component kr_ge1 = LessThan(4); kr_ge1.in[0] <== 0; kr_ge1.in[1] <== kr;   // kr >= 1

    // Precompute the four target indices (they may be negative algebraically,
    // but we will gate them before using in any selector).
    signal idx_up_p1 <== (r_up * 8) + f_p1;   // ( +rank , +file )
    signal idx_up_m1 <== (r_up * 8) + f_m1;   // ( +rank , -file )
    signal idx_dn_p1 <== (r_dn * 8) + f_p1;   // ( -rank , +file )
    signal idx_dn_m1 <== (r_dn * 8) + f_m1;   // ( -rank , -file )

    // In-bounds flags (quadratic):
    // white pawns: attack “up” (kr+1), black pawns: “down” (kr-1).
    // Up-right:   kf+1 in [0..7] and kr+1 in [0..7]
    signal in_up_p1 <== f_p1_lt8b.out * r_up_lt8.out;
    // Up-left:    kf-1 valid and kr+1 valid  => kf>=1 && kr+1<8
    signal in_up_m1 <== kf_ge1.out * r_up_lt8.out;
    // Down-right: kf+1 valid and kr-1 valid  => kf+1<8 && kr>=1
    signal in_dn_p1 <== f_p1_lt8b.out * kr_ge1.out;
    // Down-left:  kf-1 valid and kr-1 valid  => kf>=1  && kr>=1
    signal in_dn_m1 <== kf_ge1.out * kr_ge1.out;

    // Gate indices to [0..63] before selection (one mult per line)
    signal t_up1a; t_up1a <== in_up_p1 * idx_up_p1;  signal t_up1b; t_up1b <== (1 - in_up_p1) * king_sq;  signal idx_up_p1_sel <== t_up1a + t_up1b;
    signal t_up2a; t_up2a <== in_up_m1 * idx_up_m1;  signal t_up2b; t_up2b <== (1 - in_up_m1) * king_sq;  signal idx_up_m1_sel <== t_up2a + t_up2b;
    signal t_dn1a; t_dn1a <== in_dn_p1 * idx_dn_p1;  signal t_dn1b; t_dn1b <== (1 - in_dn_p1) * king_sq;  signal idx_dn_p1_sel <== t_dn1a + t_dn1b;
    signal t_dn2a; t_dn2a <== in_dn_m1 * idx_dn_m1;  signal t_dn2b; t_dn2b <== (1 - in_dn_m1) * king_sq;  signal idx_dn_m1_sel <== t_dn2a + t_dn2b;

    // Selectors (bits wired outside loops as you already do)
    component p_up_p1 = SelectFromBits64();
    component p_up_m1 = SelectFromBits64();
    component p_dn_p1 = SelectFromBits64();
    component p_dn_m1 = SelectFromBits64();

    p_up_p1.idx <== idx_up_p1_sel;
    p_up_m1.idx <== idx_up_m1_sel;
    p_dn_p1.idx <== idx_dn_p1_sel;
    p_dn_m1.idx <== idx_dn_m1_sel;

    for (var i = 0; i < 64; i++) {
        p_up_p1.bits[i] <== pawnBits.out[i];
        p_up_m1.bits[i] <== pawnBits.out[i];
        p_dn_p1.bits[i] <== pawnBits.out[i];
        p_dn_m1.bits[i] <== pawnBits.out[i];
    }

    // Explicit <64 checks (LessThan(7) because 64 needs 7 bits)
    component pu_ok1 = LessThan(7); pu_ok1.in[0] <== idx_up_p1_sel; pu_ok1.in[1] <== 64; pu_ok1.out === 1;
    component pu_ok2 = LessThan(7); pu_ok2.in[0] <== idx_up_m1_sel; pu_ok2.in[1] <== 64; pu_ok2.out === 1;
    component pd_ok1 = LessThan(7); pd_ok1.in[0] <== idx_dn_p1_sel; pd_ok1.in[1] <== 64; pd_ok1.out === 1;
    component pd_ok2 = LessThan(7); pd_ok2.in[0] <== idx_dn_m1_sel; pd_ok2.in[1] <== 64; pd_ok2.out === 1;

    // Finally compute pawn hits using the corrected color flag:
    signal up1; up1 <== in_up_p1 * p_up_p1.bit;
    signal up2; up2 <== in_up_m1 * p_up_m1.bit;
    signal dn1; dn1 <== in_dn_p1 * p_dn_p1.bit;
    signal dn2; dn2 <== in_dn_m1 * p_dn_m1.bit;

    signal pawn_up_hits <== up1 + up2;
    signal pawn_dn_hits <== dn1 + dn2;

    signal t_pu;       t_pu       <== oppIsWhite * pawn_up_hits;
    signal oneMinusOW; oneMinusOW <== 1 - oppIsWhite;
    signal t_pd;       t_pd       <== oneMinusOW * pawn_dn_hits;
    signal pawn_hits;  pawn_hits  <== t_pu + t_pd;

    // -------------------- Opp king adjacency (GATED IDX + <64) --------------
    signal kf_p1 <== kf + 1; signal kf_m1 <== kf - 1;
    signal kr_p1 <== kr + 1; signal kr_m1 <== kr - 1;

    // Only compare non-negative things to 8
    component kf_p1_lt8 = LessThan(4); kf_p1_lt8.in[0] <== kf_p1; kf_p1_lt8.in[1] <== 8;
    component kr_p1_lt8 = LessThan(4); kr_p1_lt8.in[0] <== kr_p1; kr_p1_lt8.in[1] <== 8;

    // For “-1” steps, use lower-bound checks instead of comparing (kf-1) or (kr-1) to 8
    // component kf_ge1 = LessThan(4); kf_ge1.in[0] <== 0; kf_ge1.in[1] <== kf;   // kf >= 1
    // component kr_ge1 = LessThan(4); kr_ge1.in[0] <== 0; kr_ge1.in[1] <== kr;   // kr >= 1

    signal idx_a <== (kr     * 8) + kf_p1;   // ( 0,+1 )
    signal idx_b <== (kr     * 8) + kf_m1;   // ( 0,-1 )
    signal idx_c <== (kr_p1  * 8) + kf;      // (+1, 0)
    signal idx_d <== (kr_m1  * 8) + kf;      // (-1, 0)
    signal idx_e <== (kr_p1  * 8) + kf_p1;   // (+1,+1)
    signal idx_f <== (kr_p1  * 8) + kf_m1;   // (+1,-1)
    signal idx_g <== (kr_m1  * 8) + kf_p1;   // (-1,+1)
    signal idx_h <== (kr_m1  * 8) + kf_m1;   // (-1,-1)

    // In-bounds flags (all quadratic-safe, no negatives to LessThan)
    signal in_a <== kf_p1_lt8.out;                 // kf+1 < 8
    signal in_b <== kf_ge1.out;                    // kf   >= 1
    signal in_c <== kr_p1_lt8.out;                 // kr+1 < 8
    signal in_d <== kr_ge1.out;                    // kr   >= 1
    signal in_e <== kf_p1_lt8.out * kr_p1_lt8.out; // kf+1 < 8 && kr+1 < 8
    signal in_f <== kf_ge1.out     * kr_p1_lt8.out;// kf   >= 1 && kr+1 < 8
    signal in_g <== kf_p1_lt8.out * kr_ge1.out;    // kf+1 < 8 && kr   >= 1
    signal in_h <== kf_ge1.out     * kr_ge1.out;   // kf   >= 1 && kr   >= 1

    // Gate indices before selection (1 mult per term)
    signal t_aa; t_aa <== in_a * idx_a;   signal t_ab; t_ab <== (1 - in_a) * king_sq;   signal idx_a_sel <== t_aa + t_ab;
    signal t_ba; t_ba <== in_b * idx_b;   signal t_bb; t_bb <== (1 - in_b) * king_sq;   signal idx_b_sel <== t_ba + t_bb;
    signal t_ca; t_ca <== in_c * idx_c;   signal t_cb; t_cb <== (1 - in_c) * king_sq;   signal idx_c_sel <== t_ca + t_cb;
    signal t_da; t_da <== in_d * idx_d;   signal t_db; t_db <== (1 - in_d) * king_sq;   signal idx_d_sel <== t_da + t_db;
    signal t_ea; t_ea <== in_e * idx_e;   signal t_eb; t_eb <== (1 - in_e) * king_sq;   signal idx_e_sel <== t_ea + t_eb;
    signal t_fa; t_fa <== in_f * idx_f;   signal t_fb; t_fb <== (1 - in_f) * king_sq;   signal idx_f_sel <== t_fa + t_fb;
    signal t_ga; t_ga <== in_g * idx_g;   signal t_gb; t_gb <== (1 - in_g) * king_sq;   signal idx_g_sel <== t_ga + t_gb;
    signal t_ha; t_ha <== in_h * idx_h;   signal t_hb; t_hb <== (1 - in_h) * king_sq;   signal idx_h_sel <== t_ha + t_hb;

    // < 64 checks (you already had these)
    component ka_ok = LessThan(7); ka_ok.in[0] <== idx_a_sel; ka_ok.in[1] <== 64; ka_ok.out === 1;
    component kb_ok = LessThan(7); kb_ok.in[0] <== idx_b_sel; kb_ok.in[1] <== 64; kb_ok.out === 1;
    component kc_ok = LessThan(7); kc_ok.in[0] <== idx_c_sel; kc_ok.in[1] <== 64; kc_ok.out === 1;
    component kd_ok = LessThan(7); kd_ok.in[0] <== idx_d_sel; kd_ok.in[1] <== 64; kd_ok.out === 1;
    component ke_ok = LessThan(7); ke_ok.in[0] <== idx_e_sel; ke_ok.in[1] <== 64; ke_ok.out === 1;
    component kf_ok = LessThan(7); kf_ok.in[0] <== idx_f_sel; kf_ok.in[1] <== 64; kf_ok.out === 1;
    component kg_ok = LessThan(7); kg_ok.in[0] <== idx_g_sel; kg_ok.in[1] <== 64; kg_ok.out === 1;
    component kh_ok = LessThan(7); kh_ok.in[0] <== idx_h_sel; kh_ok.in[1] <== 64; kh_ok.out === 1;

    component ok_a = SelectFromBits64();
    component ok_b = SelectFromBits64();
    component ok_c = SelectFromBits64();
    component ok_d = SelectFromBits64();
    component ok_e = SelectFromBits64();
    component ok_f = SelectFromBits64();
    component ok_g = SelectFromBits64();
    component ok_h = SelectFromBits64();

    ok_a.idx <== idx_a_sel; ok_b.idx <== idx_b_sel; ok_c.idx <== idx_c_sel; ok_d.idx <== idx_d_sel;
    ok_e.idx <== idx_e_sel; ok_f.idx <== idx_f_sel; ok_g.idx <== idx_g_sel; ok_h.idx <== idx_h_sel;

    for (var i = 0; i < 64; i++) {
        ok_a.bits[i] <== oppKingBits.out[i];
        ok_b.bits[i] <== oppKingBits.out[i];
        ok_c.bits[i] <== oppKingBits.out[i];
        ok_d.bits[i] <== oppKingBits.out[i];
        ok_e.bits[i] <== oppKingBits.out[i];
        ok_f.bits[i] <== oppKingBits.out[i];
        ok_g.bits[i] <== oppKingBits.out[i];
        ok_h.bits[i] <== oppKingBits.out[i];
    }

    signal accK[9];
    accK[0] <== 0;
    accK[1] <== accK[0] + in_a * ok_a.bit;
    accK[2] <== accK[1] + in_b * ok_b.bit;
    accK[3] <== accK[2] + in_c * ok_c.bit;
    accK[4] <== accK[3] + in_d * ok_d.bit;
    accK[5] <== accK[4] + in_e * ok_e.bit;
    accK[6] <== accK[5] + in_f * ok_f.bit;
    accK[7] <== accK[6] + in_g * ok_g.bit;
    accK[8] <== accK[7] + in_h * ok_h.bit;
    signal king_adj_hits <== accK[8];


    // -------------------- Combine --------------------
    signal accR[9];
    accR[0] <== 1;
    accR[1] <== accR[0] * ok_ray[0];
    accR[2] <== accR[1] * ok_ray[1];
    accR[3] <== accR[2] * ok_ray[2];
    accR[4] <== accR[3] * ok_ray[3];
    accR[5] <== accR[4] * ok_ray[4];
    accR[6] <== accR[5] * ok_ray[5];
    accR[7] <== accR[6] * ok_ray[6];
    accR[8] <== accR[7] * ok_ray[7];
    signal rays_ok <== accR[8];

    component noneNPK = IsEqual();
    noneNPK.in[0] <== knight_hits + pawn_hits + king_adj_hits;
    noneNPK.in[1] <== 0;

    ok <== rays_ok * noneNPK.out;
}

