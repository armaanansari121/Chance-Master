// circuits/rules/LineClearRuntime.circom
pragma circom 2.0.0;

include "circomlib/circuits/bitify.circom";      // Num2Bits
include "circomlib/circuits/comparators.circom"; // IsEqual, LessThan
include "./_helpers.circom";                      // SelectBit64

// |a-b| for 0..7 with <=1 signal×signal multiply per row
template AbsDiff4() {
    signal input a; // 0..7
    signal input b; // 0..7
    signal output out;

    component lt = LessThan(4); lt.in[0] <== a; lt.in[1] <== b; // a<b?
    component eq = IsEqual();   eq.in[0] <== a; eq.in[1] <== b; // a==b?

    signal ge; ge <== lt.out + eq.out;          // (b>=a) ∈ {0,1}
    signal dpos; dpos <== b - a;                // linear
    signal dneg; dneg <== a - b;                // linear

    signal t1; t1 <== ge * dpos;                // mult
    signal oneMinusGe; oneMinusGe <== 1 - ge;   // linear
    signal t2; t2 <== oneMinusGe * dneg;        // mult
    out <== t1 + t2;                             // linear
}

// Runtime line-clear for rook/bishop/queen.
// Ensures squares strictly between `from` and `to` are empty,
// and that `to` lies exactly k*step away along a rank/file/diag.
template LineClearRuntime() {
    signal input all_board; // u64 occupancy (self|opp)
    signal input from;      // 0..63
    signal input to;        // 0..63
    signal output ok;

    component F = Num2Bits(6); F.in <== from;
    component T = Num2Bits(6); T.in <== to;

    signal ff <== F.out[0] + 2*F.out[1] + 4*F.out[2];
    signal fr <== F.out[3] + 2*F.out[4] + 4*F.out[5];
    signal tf <== T.out[0] + 2*T.out[1] + 4*T.out[2];
    signal tr <== T.out[3] + 2*T.out[4] + 4*T.out[5];

    component eqF = IsEqual(); eqF.in[0] <== ff;   eqF.in[1] <== tf;
    component eqR = IsEqual(); eqR.in[0] <== fr;   eqR.in[1] <== tr;
    component eqS = IsEqual(); eqS.in[0] <== from; eqS.in[1] <== to;
    signal notSame <== 1 - eqS.out;

    component adf = AbsDiff4(); adf.a <== ff; adf.b <== tf;
    component adr = AbsDiff4(); adr.a <== fr; adr.b <== tr;
    component eqDxDy = IsEqual(); eqDxDy.in[0] <== adf.out; eqDxDy.in[1] <== adr.out;

    signal prod_eqF_eqR;       prod_eqF_eqR <== eqF.out * eqR.out;              // mult
    signal sameLine_or;        sameLine_or <== eqF.out + eqR.out - prod_eqF_eqR;

    signal prod_sameLine_diag; prod_sameLine_diag <== sameLine_or * eqDxDy.out; // mult
    signal aligned;            aligned <== sameLine_or + eqDxDy.out - prod_sameLine_diag;

    component adf_lt_adr = LessThan(4); adf_lt_adr.in[0] <== adf.out; adf_lt_adr.in[1] <== adr.out;
    signal t_max1; t_max1 <== adf_lt_adr.out * adr.out;           // mult
    signal oneMinus; oneMinus <== 1 - adf_lt_adr.out;             // linear
    signal t_max2; t_max2 <== oneMinus * adf.out;                 // mult
    signal k; k <== t_max1 + t_max2;                              // linear

    component ff_lt_tf = LessThan(4); ff_lt_tf.in[0] <== ff; ff_lt_tf.in[1] <== tf;
    component tf_lt_ff = LessThan(4); tf_lt_ff.in[0] <== tf; tf_lt_ff.in[1] <== ff;
    signal sF_pos <== ff_lt_tf.out;
    signal sF_neg <== tf_lt_ff.out;

    component fr_lt_tr = LessThan(4); fr_lt_tr.in[0] <== fr; fr_lt_tr.in[1] <== tr;
    component tr_lt_fr = LessThan(4); tr_lt_fr.in[0] <== tr; tr_lt_fr.in[1] <== fr;
    signal sR_pos <== fr_lt_tr.out;
    signal sR_neg <== tr_lt_fr.out;

    signal notEqF; notEqF <== 1 - eqF.out;
    signal notEqR; notEqR <== 1 - eqR.out;

    signal isRookHoriz; isRookHoriz <== eqR.out * notEqF;          // mult
    signal isRookVert;  isRookVert  <== eqF.out * notEqR;          // mult
    signal t_notEqF_notEqR; t_notEqF_notEqR <== notEqF * notEqR;   // mult
    signal isDiag; isDiag <== t_notEqF_notEqR * eqDxDy.out;        // mult

    signal step_h; step_h <== sF_pos * 1 + sF_neg * (-1);
    signal step_v; step_v <== sR_pos * 8 + sR_neg * (-8);

    signal t_pp; t_pp <== sF_pos * sR_pos;                         // mult
    signal t_nn; t_nn <== sF_neg * sR_neg;                         // mult
    signal t_pn; t_pn <== sF_pos * sR_neg;                         // mult
    signal t_np; t_np <== sF_neg * sR_pos;                         // mult
    signal step_d; step_d <== t_pp*9 + t_nn*(-9) + t_pn*(-7) + t_np*7;

    signal t_rh; t_rh <== isRookHoriz * step_h;                    // mult
    signal t_rv; t_rv <== isRookVert  * step_v;                    // mult
    signal step_r; step_r <== t_rh + t_rv;

    signal t_d;  t_d  <== isDiag * step_d;                         // mult
    signal step; step <== step_r + t_d;

    signal k_step;    k_step <== k * step;                         // mult
    signal expected_to; expected_to <== from + k_step;             // linear
    component eqTo = IsEqual(); eqTo.in[0] <== to; eqTo.in[1] <== expected_to;

    // -------- iterate m = 1..k-1 and require emptiness (GATED INDICES) --------
    // Predeclare arrays/components (no declarations inside the loop)
    signal idx_m[7];
    signal idx_sel[7];
    signal t_gate_a[7];
    signal t_gate_b[7];
    signal t_occ[7];
    signal occ_is_empty[7];

    component m_lt_k[7];
    component occSel[7];
    component idx_ok[7];

    m_lt_k[0] = LessThan(4);  m_lt_k[1] = LessThan(4);  m_lt_k[2] = LessThan(4);
    m_lt_k[3] = LessThan(4);  m_lt_k[4] = LessThan(4);  m_lt_k[5] = LessThan(4);
    m_lt_k[6] = LessThan(4);

    occSel[0] = SelectBit64(); occSel[1] = SelectBit64(); occSel[2] = SelectBit64();
    occSel[3] = SelectBit64(); occSel[4] = SelectBit64(); occSel[5] = SelectBit64();
    occSel[6] = SelectBit64();

    idx_ok[0] = LessThan(7); idx_ok[1] = LessThan(7); idx_ok[2] = LessThan(7);
    idx_ok[3] = LessThan(7); idx_ok[4] = LessThan(7); idx_ok[5] = LessThan(7);
    idx_ok[6] = LessThan(7);

    for (var m = 1; m <= 7; m++) {
        m_lt_k[m-1].in[0] <== m;
        m_lt_k[m-1].in[1] <== k;

        // Raw index along the ray (can be out of [0..63] for m >= k)
        idx_m[m-1] <== from + m * step;               // linear (m is const)

        // Gate index: if (m<k) use idx_m, else fallback to 'from' (safe in-range)
        t_gate_a[m-1] <== m_lt_k[m-1].out * idx_m[m-1];     // mult
        t_gate_b[m-1] <== (1 - m_lt_k[m-1].out) * from;     // mult
        idx_sel[m-1]  <== t_gate_a[m-1] + t_gate_b[m-1];    // linear

        // Defend: prove gated index < 64
        idx_ok[m-1].in[0] <== idx_sel[m-1];
        idx_ok[m-1].in[1] <== 64;
        idx_ok[m-1].out === 1;

        // Safe selection
        occSel[m-1].packed <== all_board;
        occSel[m-1].idx    <== idx_sel[m-1];

        // Only enforce emptiness when m<k
        t_occ[m-1]        <== m_lt_k[m-1].out * occSel[m-1].bit;  // mult
        occ_is_empty[m-1] <== 1 - t_occ[m-1];
    }

    // AND all empties using an accumulator (no self-assignment)
    signal acc_empty[8];
    acc_empty[0] <== 1;
    for (var i = 0; i < 7; i++) {
        acc_empty[i+1] <== acc_empty[i] * occ_is_empty[i];  // mult
    }
    signal all_empty <== acc_empty[7];

    // final
    signal okGeom; okGeom <== aligned * notSame;   // mult
    signal okTerm; okTerm <== okGeom * eqTo.out;   // mult
    ok <== okTerm * all_empty;                     // mult
}
