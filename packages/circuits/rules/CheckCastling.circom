// circuits/rules/CheckCastling.circom  (DROP-IN, Circom 2, quadratic-only)
pragma circom 2.0.0;

include "circomlib/circuits/bitify.circom";       // Num2Bits
include "circomlib/circuits/comparators.circom";  // IsEqual, IsZero
include "_helpers.circom";                     // SelectFromBits64

/* ------------ tiny OR helpers (pairwise only) ------------ */
template Or2() {
    signal input a; signal input b;
    signal output o;
    signal ab; ab <== a * b;
    signal s;  s  <== a + b;
    o <== s - ab;
}
template Or3() {
    signal input a; signal input b; signal input c;
    signal output o;
    component o1 = Or2(); o1.a <== a; o1.b <== b;
    component o2 = Or2(); o2.a <== o1.o; o2.b <== c;
    o <== o2.o;
}
/* Parametric OR over n >= 2 boolean signals; chained Or2 (a + b - a*b). */
template ORn(n) {
    signal input x[n];
    signal output o;

    component g[n-1];
    signal acc[n];

    acc[0] <== x[0];
    for (var i = 0; i < n-1; i++) {
        g[i] = Or2();
        g[i].a <== acc[i];
        g[i].b <== x[i+1];
        acc[i+1] <== g[i].o;
    }
    o <== acc[n-1];
}

/* ----------------- ORTH rays ----------------- */
template OrthRay_len2(i1,i2) {
    signal input occBits[64]; signal input rookBits[64]; signal input queenBits[64];
    signal output hit;

    component s1o = SelectFromBits64(); s1o.idx <== i1;
    component s2o = SelectFromBits64(); s2o.idx <== i2;

    component s1r = SelectFromBits64(); s1r.idx <== i1;
    component s2r = SelectFromBits64(); s2r.idx <== i2;

    component s1q = SelectFromBits64(); s1q.idx <== i1;
    component s2q = SelectFromBits64(); s2q.idx <== i2;

    for (var i = 0; i < 64; i++) {
        s1o.bits[i] <== occBits[i]; s2o.bits[i] <== occBits[i];
        s1r.bits[i] <== rookBits[i]; s2r.bits[i] <== rookBits[i];
        s1q.bits[i] <== queenBits[i]; s2q.bits[i] <== queenBits[i];
    }

    signal pref0; pref0 <== 1;
    signal occ1; occ1 <== s1o.bit; signal not1; not1 <== 1 - occ1; signal pref1; pref1 <== pref0 * not1;
    signal occ2; occ2 <== s2o.bit;

    signal rq1m; rq1m <== s1r.bit * s1q.bit; signal rq1; rq1 <== s1r.bit + s1q.bit - rq1m;
    signal rq2m; rq2m <== s2r.bit * s2q.bit; signal rq2; rq2 <== s2r.bit + s2q.bit - rq2m;

    signal first1; first1 <== pref0 * occ1;
    signal first2; first2 <== pref1 * occ2;

    signal h1; h1 <== first1 * rq1;
    signal h2; h2 <== first2 * rq2;

    hit <== h1 + h2;
}
template OrthRay_len3(i1,i2,i3) {
    signal input occBits[64]; signal input rookBits[64]; signal input queenBits[64];
    signal output hit;

    component s1o = SelectFromBits64(); s1o.idx <== i1;
    component s2o = SelectFromBits64(); s2o.idx <== i2;
    component s3o = SelectFromBits64(); s3o.idx <== i3;

    component s1r = SelectFromBits64(); s1r.idx <== i1;
    component s2r = SelectFromBits64(); s2r.idx <== i2;
    component s3r = SelectFromBits64(); s3r.idx <== i3;

    component s1q = SelectFromBits64(); s1q.idx <== i1;
    component s2q = SelectFromBits64(); s2q.idx <== i2;
    component s3q = SelectFromBits64(); s3q.idx <== i3;

    for (var i = 0; i < 64; i++) {
        s1o.bits[i] <== occBits[i]; s2o.bits[i] <== occBits[i]; s3o.bits[i] <== occBits[i];
        s1r.bits[i] <== rookBits[i]; s2r.bits[i] <== rookBits[i]; s3r.bits[i] <== rookBits[i];
        s1q.bits[i] <== queenBits[i]; s2q.bits[i] <== queenBits[i]; s3q.bits[i] <== queenBits[i];
    }

    signal pref0; pref0 <== 1;

    signal occ1; occ1 <== s1o.bit; signal not1; not1 <== 1 - occ1; signal p1; p1 <== pref0 * not1;
    signal occ2; occ2 <== s2o.bit; signal not2; not2 <== 1 - occ2; signal p2; p2 <== p1 * not2;
    signal occ3; occ3 <== s3o.bit;

    signal rq1m; rq1m <== s1r.bit * s1q.bit; signal rq1; rq1 <== s1r.bit + s1q.bit - rq1m;
    signal rq2m; rq2m <== s2r.bit * s2q.bit; signal rq2; rq2 <== s2r.bit + s2q.bit - rq2m;
    signal rq3m; rq3m <== s3r.bit * s3q.bit; signal rq3; rq3 <== s3r.bit + s3q.bit - rq3m;

    signal first1; first1 <== pref0 * occ1;
    signal first2; first2 <== p1 * occ2;
    signal first3; first3 <== p2 * occ3;

    signal h1; h1 <== first1 * rq1;
    signal h2; h2 <== first2 * rq2;
    signal h3; h3 <== first3 * rq3;

    signal s12; s12 <== h1 + h2;
    hit <== s12 + h3;
}
template OrthRay_len4(i1,i2,i3,i4) {
    signal input occBits[64]; signal input rookBits[64]; signal input queenBits[64];
    signal output hit;

    component base = OrthRay_len3(i1,i2,i3);
    for (var i = 0; i < 64; i++) {
        base.occBits[i]  <== occBits[i];
        base.rookBits[i] <== rookBits[i];
        base.queenBits[i]<== queenBits[i];
    }

    component s4o = SelectFromBits64(); s4o.idx <== i4;
    component s4r = SelectFromBits64(); s4r.idx <== i4;
    component s4q = SelectFromBits64(); s4q.idx <== i4;
    for (var j = 0; j < 64; j++) { s4o.bits[j] <== occBits[j]; s4r.bits[j] <== rookBits[j]; s4q.bits[j] <== queenBits[j]; }

    component s1o = SelectFromBits64(); s1o.idx <== i1;
    component s2o = SelectFromBits64(); s2o.idx <== i2;
    component s3o = SelectFromBits64(); s3o.idx <== i3;
    for (var k = 0; k < 64; k++) { s1o.bits[k] <== occBits[k]; s2o.bits[k] <== occBits[k]; s3o.bits[k] <== occBits[k]; }

    signal p0; p0 <== 1;
    signal p1; p1 <== p0 * (1 - s1o.bit);
    signal p2; p2 <== p1 * (1 - s2o.bit);
    signal p3; p3 <== p2 * (1 - s3o.bit);

    signal rq4m; rq4m <== s4r.bit * s4q.bit; signal rq4; rq4 <== s4r.bit + s4q.bit - rq4m;

    signal first4; first4 <== p3 * s4o.bit;
    signal h4; h4 <== first4 * rq4;

    hit <== base.hit + h4;
}
template OrthRay_len5(i1,i2,i3,i4,i5) {
    signal input occBits[64]; signal input rookBits[64]; signal input queenBits[64];
    signal output hit;

    component base = OrthRay_len4(i1,i2,i3,i4);
    for (var i = 0; i < 64; i++) { base.occBits[i] <== occBits[i]; base.rookBits[i] <== rookBits[i]; base.queenBits[i] <== queenBits[i]; }

    component s5o = SelectFromBits64(); s5o.idx <== i5;
    component s5r = SelectFromBits64(); s5r.idx <== i5;
    component s5q = SelectFromBits64(); s5q.idx <== i5;
    for (var j = 0; j < 64; j++) { s5o.bits[j] <== occBits[j]; s5r.bits[j] <== rookBits[j]; s5q.bits[j] <== queenBits[j]; }

    component s1o = SelectFromBits64(); s1o.idx <== i1;
    component s2o = SelectFromBits64(); s2o.idx <== i2;
    component s3o = SelectFromBits64(); s3o.idx <== i3;
    component s4o = SelectFromBits64(); s4o.idx <== i4;
    for (var k = 0; k < 64; k++) { s1o.bits[k] <== occBits[k]; s2o.bits[k] <== occBits[k]; s3o.bits[k] <== occBits[k]; s4o.bits[k] <== occBits[k]; }

    signal p0; p0 <== 1;
    signal p1; p1 <== p0 * (1 - s1o.bit);
    signal p2; p2 <== p1 * (1 - s2o.bit);
    signal p3; p3 <== p2 * (1 - s3o.bit);
    signal p4; p4 <== p3 * (1 - s4o.bit);

    signal rq5m; rq5m <== s5r.bit * s5q.bit; signal rq5; rq5 <== s5r.bit + s5q.bit - rq5m;
    signal first5; first5 <== p4 * s5o.bit;
    signal h5; h5 <== first5 * rq5;

    hit <== base.hit + h5;
}
template OrthRay_len6(i1,i2,i3,i4,i5,i6) {
    signal input occBits[64]; signal input rookBits[64]; signal input queenBits[64];
    signal output hit;

    component base = OrthRay_len5(i1,i2,i3,i4,i5);
    for (var i = 0; i < 64; i++) { base.occBits[i] <== occBits[i]; base.rookBits[i] <== rookBits[i]; base.queenBits[i] <== queenBits[i]; }

    component s6o = SelectFromBits64(); s6o.idx <== i6;
    component s6r = SelectFromBits64(); s6r.idx <== i6;
    component s6q = SelectFromBits64(); s6q.idx <== i6;
    for (var j = 0; j < 64; j++) { s6o.bits[j] <== occBits[j]; s6r.bits[j] <== rookBits[j]; s6q.bits[j] <== queenBits[j]; }

    component s1o = SelectFromBits64(); s1o.idx <== i1;
    component s2o = SelectFromBits64(); s2o.idx <== i2;
    component s3o = SelectFromBits64(); s3o.idx <== i3;
    component s4o = SelectFromBits64(); s4o.idx <== i4;
    component s5o = SelectFromBits64(); s5o.idx <== i5;
    for (var k = 0; k < 64; k++) {
        s1o.bits[k] <== occBits[k]; s2o.bits[k] <== occBits[k]; s3o.bits[k] <== occBits[k];
        s4o.bits[k] <== occBits[k]; s5o.bits[k] <== occBits[k];
    }

    signal p0; p0 <== 1;
    signal p1; p1 <== p0 * (1 - s1o.bit);
    signal p2; p2 <== p1 * (1 - s2o.bit);
    signal p3; p3 <== p2 * (1 - s3o.bit);
    signal p4; p4 <== p3 * (1 - s4o.bit);
    signal p5; p5 <== p4 * (1 - s5o.bit);

    signal rq6m; rq6m <== s6r.bit * s6q.bit; signal rq6; rq6 <== s6r.bit + s6q.bit - rq6m;
    signal first6; first6 <== p5 * s6o.bit;
    signal h6; h6 <== first6 * rq6;

    hit <== base.hit + h6;
}
template OrthRay_len7(i1,i2,i3,i4,i5,i6,i7) {
    signal input occBits[64]; signal input rookBits[64]; signal input queenBits[64];
    signal output hit;

    component base = OrthRay_len6(i1,i2,i3,i4,i5,i6);
    for (var i = 0; i < 64; i++) { base.occBits[i] <== occBits[i]; base.rookBits[i] <== rookBits[i]; base.queenBits[i] <== queenBits[i]; }

    component s7o = SelectFromBits64(); s7o.idx <== i7;
    component s7r = SelectFromBits64(); s7r.idx <== i7;
    component s7q = SelectFromBits64(); s7q.idx <== i7;
    for (var j = 0; j < 64; j++) { s7o.bits[j] <== occBits[j]; s7r.bits[j] <== rookBits[j]; s7q.bits[j] <== queenBits[j]; }

    component s1o = SelectFromBits64(); s1o.idx <== i1;
    component s2o = SelectFromBits64(); s2o.idx <== i2;
    component s3o = SelectFromBits64(); s3o.idx <== i3;
    component s4o = SelectFromBits64(); s4o.idx <== i4;
    component s5o = SelectFromBits64(); s5o.idx <== i5;
    component s6o = SelectFromBits64(); s6o.idx <== i6;
    for (var k = 0; k < 64; k++) {
        s1o.bits[k] <== occBits[k]; s2o.bits[k] <== occBits[k]; s3o.bits[k] <== occBits[k];
        s4o.bits[k] <== occBits[k]; s5o.bits[k] <== occBits[k]; s6o.bits[k] <== occBits[k];
    }

    signal p0; p0 <== 1;
    signal p1; p1 <== p0 * (1 - s1o.bit);
    signal p2; p2 <== p1 * (1 - s2o.bit);
    signal p3; p3 <== p2 * (1 - s3o.bit);
    signal p4; p4 <== p3 * (1 - s4o.bit);
    signal p5; p5 <== p4 * (1 - s5o.bit);
    signal p6; p6 <== p5 * (1 - s6o.bit);

    signal rq7m; rq7m <== s7r.bit * s7q.bit; signal rq7; rq7 <== s7r.bit + s7q.bit - rq7m;
    signal first7; first7 <== p6 * s7o.bit;
    signal h7; h7 <== first7 * rq7;

    hit <== base.hit + h7;
}

/* ----------------- DIAG rays ----------------- */
template DiagRay_len2(i1,i2) {
    signal input occBits[64]; signal input bishopBits[64]; signal input queenBits[64];
    signal output hit;

    component s1o = SelectFromBits64(); s1o.idx <== i1;
    component s2o = SelectFromBits64(); s2o.idx <== i2;

    component s1b = SelectFromBits64(); s1b.idx <== i1;
    component s2b = SelectFromBits64(); s2b.idx <== i2;

    component s1q = SelectFromBits64(); s1q.idx <== i1;
    component s2q = SelectFromBits64(); s2q.idx <== i2;

    for (var i = 0; i < 64; i++) {
        s1o.bits[i] <== occBits[i]; s2o.bits[i] <== occBits[i];
        s1b.bits[i] <== bishopBits[i]; s2b.bits[i] <== bishopBits[i];
        s1q.bits[i] <== queenBits[i]; s2q.bits[i] <== queenBits[i];
    }

    signal pref0; pref0 <== 1;
    signal occ1; occ1 <== s1o.bit; signal not1; not1 <== 1 - occ1; signal pref1; pref1 <== pref0 * not1;
    signal occ2; occ2 <== s2o.bit;

    signal bq1m; bq1m <== s1b.bit * s1q.bit; signal bq1; bq1 <== s1b.bit + s1q.bit - bq1m;
    signal bq2m; bq2m <== s2b.bit * s2q.bit; signal bq2; bq2 <== s2b.bit + s2q.bit - bq2m;

    signal first1; first1 <== pref0 * occ1;
    signal first2; first2 <== pref1 * occ2;

    signal h1; h1 <== first1 * bq1;
    signal h2; h2 <== first2 * bq2;

    hit <== h1 + h2;
}
template DiagRay_len3(i1,i2,i3) {
    signal input occBits[64]; signal input bishopBits[64]; signal input queenBits[64];
    signal output hit;

    component s1o = SelectFromBits64(); s1o.idx <== i1;
    component s2o = SelectFromBits64(); s2o.idx <== i2;
    component s3o = SelectFromBits64(); s3o.idx <== i3;

    component s1b = SelectFromBits64(); s1b.idx <== i1;
    component s2b = SelectFromBits64(); s2b.idx <== i2;
    component s3b = SelectFromBits64(); s3b.idx <== i3;

    component s1q = SelectFromBits64(); s1q.idx <== i1;
    component s2q = SelectFromBits64(); s2q.idx <== i2;
    component s3q = SelectFromBits64(); s3q.idx <== i3;

    for (var i = 0; i < 64; i++) {
        s1o.bits[i] <== occBits[i]; s2o.bits[i] <== occBits[i]; s3o.bits[i] <== occBits[i];
        s1b.bits[i] <== bishopBits[i]; s2b.bits[i] <== bishopBits[i]; s3b.bits[i] <== bishopBits[i];
        s1q.bits[i] <== queenBits[i]; s2q.bits[i] <== queenBits[i]; s3q.bits[i] <== queenBits[i];
    }

    signal pref0; pref0 <== 1;

    signal occ1; occ1 <== s1o.bit; signal not1; not1 <== 1 - occ1; signal p1; p1 <== pref0 * not1;
    signal occ2; occ2 <== s2o.bit; signal not2; not2 <== 1 - occ2; signal p2; p2 <== p1 * not2;
    signal occ3; occ3 <== s3o.bit;

    signal bq1m; bq1m <== s1b.bit * s1q.bit; signal bq1; bq1 <== s1b.bit + s1q.bit - bq1m;
    signal bq2m; bq2m <== s2b.bit * s2q.bit; signal bq2; bq2 <== s2b.bit + s2q.bit - bq2m;
    signal bq3m; bq3m <== s3b.bit * s3q.bit; signal bq3; bq3 <== s3b.bit + s3q.bit - bq3m;

    signal first1; first1 <== pref0 * occ1;
    signal first2; first2 <== p1 * occ2;
    signal first3; first3 <== p2 * occ3;

    signal h1; h1 <== first1 * bq1;
    signal h2; h2 <== first2 * bq2;
    signal h3; h3 <== first3 * bq3;

    signal s12; s12 <== h1 + h2;
    hit <== s12 + h3;
}
template DiagRay_len4(i1,i2,i3,i4) {
    signal input occBits[64];
    signal input bishopBits[64];
    signal input queenBits[64];
    signal output hit;

    // reuse the first 3 steps
    component base = DiagRay_len3(i1,i2,i3);
    for (var i = 0; i < 64; i++) {
        base.occBits[i]    <== occBits[i];
        base.bishopBits[i] <== bishopBits[i];
        base.queenBits[i]  <== queenBits[i];
    }

    // step 4 selects
    component s4o = SelectFromBits64(); s4o.idx <== i4;
    component s4b = SelectFromBits64(); s4b.idx <== i4;
    component s4q = SelectFromBits64(); s4q.idx <== i4;
    for (var j = 0; j < 64; j++) {
        s4o.bits[j] <== occBits[j];
        s4b.bits[j] <== bishopBits[j];
        s4q.bits[j] <== queenBits[j];
    }

    // to compute prefix empties up to step3, we need the first 3 occ bits again
    component s1o = SelectFromBits64(); s1o.idx <== i1;
    component s2o = SelectFromBits64(); s2o.idx <== i2;
    component s3o = SelectFromBits64(); s3o.idx <== i3;
    for (var k = 0; k < 64; k++) {
        s1o.bits[k] <== occBits[k];
        s2o.bits[k] <== occBits[k];
        s3o.bits[k] <== occBits[k];
    }

    // prefix of empty squares (pairwise mult chain only)
    signal p0; p0 <== 1;
    signal p1; p1 <== p0 * (1 - s1o.bit);
    signal p2; p2 <== p1 * (1 - s2o.bit);
    signal p3; p3 <== p2 * (1 - s3o.bit);

    // attacker presence at step4 (bishop OR queen)
    signal bq4m; bq4m <== s4b.bit * s4q.bit;
    signal bq4;  bq4  <== s4b.bit + s4q.bit - bq4m;

    // first blocker at step4? (i.e., first non-empty there)
    signal first4; first4 <== p3 * s4o.bit;

    // hit if first blocker is a diag attacker
    signal h4; h4 <== first4 * bq4;

    // accumulate with first 3 steps' hits
    hit <== base.hit + h4;
}

template DiagRay_len6(i1,i2,i3,i4,i5,i6) {
    signal input occBits[64]; signal input bishopBits[64]; signal input queenBits[64];
    signal output hit;

    component b3 = DiagRay_len3(i1,i2,i3);
    for (var i = 0; i < 64; i++) { b3.occBits[i] <== occBits[i]; b3.bishopBits[i] <== bishopBits[i]; b3.queenBits[i] <== queenBits[i]; }

    component s4o = SelectFromBits64(); s4o.idx <== i4;
    component s4b = SelectFromBits64(); s4b.idx <== i4;
    component s4q = SelectFromBits64(); s4q.idx <== i4;
    for (var t1 = 0; t1 < 64; t1++) { s4o.bits[t1] <== occBits[t1]; s4b.bits[t1] <== bishopBits[t1]; s4q.bits[t1] <== queenBits[t1]; }

    component s1o = SelectFromBits64(); s1o.idx <== i1;
    component s2o = SelectFromBits64(); s2o.idx <== i2;
    component s3o = SelectFromBits64(); s3o.idx <== i3;
    for (var t2 = 0; t2 < 64; t2++) { s1o.bits[t2] <== occBits[t2]; s2o.bits[t2] <== occBits[t2]; s3o.bits[t2] <== occBits[t2]; }

    signal p0; p0 <== 1;
    signal p1; p1 <== p0 * (1 - s1o.bit);
    signal p2; p2 <== p1 * (1 - s2o.bit);
    signal p3; p3 <== p2 * (1 - s3o.bit);

    signal bq4m; bq4m <== s4b.bit * s4q.bit; signal bq4; bq4 <== s4b.bit + s4q.bit - bq4m;
    signal first4; first4 <== p3 * s4o.bit;
    signal h4; h4 <== first4 * bq4;

    component s5o = SelectFromBits64(); s5o.idx <== i5;
    component s5b = SelectFromBits64(); s5b.idx <== i5;
    component s5q = SelectFromBits64(); s5q.idx <== i5;

    component s6o = SelectFromBits64(); s6o.idx <== i6;
    component s6b = SelectFromBits64(); s6b.idx <== i6;
    component s6q = SelectFromBits64(); s6q.idx <== i6;

    for (var t3 = 0; t3 < 64; t3++) {
        s5o.bits[t3] <== occBits[t3]; s5b.bits[t3] <== bishopBits[t3]; s5q.bits[t3] <== queenBits[t3];
        s6o.bits[t3] <== occBits[t3]; s6b.bits[t3] <== bishopBits[t3]; s6q.bits[t3] <== queenBits[t3];
    }

    signal p4; p4 <== p3 * (1 - s4o.bit);
    signal bq5m; bq5m <== s5b.bit * s5q.bit; signal bq5; bq5 <== s5b.bit + s5q.bit - bq5m;
    signal first5; first5 <== p4 * s5o.bit;
    signal h5; h5 <== first5 * bq5;

    signal p5; p5 <== p4 * (1 - s5o.bit);
    signal bq6m; bq6m <== s6b.bit * s6q.bit; signal bq6; bq6 <== s6b.bit + s6q.bit - bq6m;
    signal first6; first6 <== p5 * s6o.bit;
    signal h6; h6 <== first6 * bq6;

    signal s456; s456 <== h4 + h5;
    hit <== s456 + h6;
}
template DiagRay_len7(i1,i2,i3,i4,i5,i6,i7) {
    signal input occBits[64]; signal input bishopBits[64]; signal input queenBits[64];
    signal output hit;

    component b6 = DiagRay_len6(i1,i2,i3,i4,i5,i6);
    for (var i = 0; i < 64; i++) { b6.occBits[i] <== occBits[i]; b6.bishopBits[i] <== bishopBits[i]; b6.queenBits[i] <== queenBits[i]; }

    component s7o = SelectFromBits64(); s7o.idx <== i7;
    component s7b = SelectFromBits64(); s7b.idx <== i7;
    component s7q = SelectFromBits64(); s7q.idx <== i7;
    for (var j = 0; j < 64; j++) { s7o.bits[j] <== occBits[j]; s7b.bits[j] <== bishopBits[j]; s7q.bits[j] <== queenBits[j]; }

    component s1o = SelectFromBits64(); s1o.idx <== i1;
    component s2o = SelectFromBits64(); s2o.idx <== i2;
    component s3o = SelectFromBits64(); s3o.idx <== i3;
    component s4o = SelectFromBits64(); s4o.idx <== i4;
    component s5o = SelectFromBits64(); s5o.idx <== i5;
    component s6o = SelectFromBits64(); s6o.idx <== i6;
    for (var k = 0; k < 64; k++) {
        s1o.bits[k] <== occBits[k]; s2o.bits[k] <== occBits[k]; s3o.bits[k] <== occBits[k];
        s4o.bits[k] <== occBits[k]; s5o.bits[k] <== occBits[k]; s6o.bits[k] <== occBits[k];
    }

    signal p0; p0 <== 1;
    signal p1; p1 <== p0 * (1 - s1o.bit);
    signal p2; p2 <== p1 * (1 - s2o.bit);
    signal p3; p3 <== p2 * (1 - s3o.bit);
    signal p4; p4 <== p3 * (1 - s4o.bit);
    signal p5; p5 <== p4 * (1 - s5o.bit);
    signal p6; p6 <== p5 * (1 - s6o.bit);

    signal bq7m; bq7m <== s7b.bit * s7q.bit; signal bq7; bq7 <== s7b.bit + s7q.bit - bq7m;
    signal first7; first7 <== p6 * s7o.bit;
    signal h7; h7 <== first7 * bq7;

    hit <== b6.hit + h7;
}

/* ----------------- MAIN: CheckCastling ----------------- */
template CheckCastling() {
    signal input piece_type;
    signal input mover_color;
    signal input from_square;
    signal input to_square;
    signal input castle_rights;

    signal input selfALL;   // kept for interface
    signal input oppALL;    // kept for interface (not used)

    signal input wR; signal input bR;
    signal input wB; signal input bB;
    signal input wQ; signal input bQ;

    // NEW: for precise local N/P/K checks
    signal input wN; signal input bN;
    signal input wP; signal input bP;
    signal input wK; signal input bK;

    signal input occ_pre;

    signal output is_castle;
    signal output rook_from_sq;
    signal output rook_to_sq;

    /* decode king move / color / rights */
    component isK = IsEqual(); isK.in[0] <== piece_type; isK.in[1] <== 6;
    signal kMove; kMove <== isK.out;

    component isW = IsZero(); isW.in <== mover_color;
    signal iw; iw <== isW.out; signal ib; ib <== 1 - iw;

    component RB = Num2Bits(4); RB.in <== castle_rights;
    signal wk; wk <== RB.out[3]; signal wq; wq <== RB.out[2];
    signal bk; bk <== RB.out[1]; signal bq; bq <== RB.out[0];

    component eq_from_e1 = IsEqual(); eq_from_e1.in[0] <== from_square; eq_from_e1.in[1] <== 4;
    component eq_from_e8 = IsEqual(); eq_from_e8.in[0] <== from_square; eq_from_e8.in[1] <== 60;
    component eq_to_g1   = IsEqual(); eq_to_g1.in[0]   <== to_square;   eq_to_g1.in[1]   <== 6;
    component eq_to_c1   = IsEqual(); eq_to_c1.in[0]   <== to_square;   eq_to_c1.in[1]   <== 2;
    component eq_to_g8   = IsEqual(); eq_to_g8.in[0]   <== to_square;   eq_to_g8.in[1]   <== 62;
    component eq_to_c8   = IsEqual(); eq_to_c8.in[0]   <== to_square;   eq_to_c8.in[1]   <== 58;

    // wcK
    signal t1w; t1w <== kMove * iw;
    signal t2w; t2w <== t1w * eq_from_e1.out;
    signal t3w; t3w <== t2w * eq_to_g1.out;
    signal wcK; wcK <== t3w * wk;

    // wcQ
    signal t1wq; t1wq <== kMove * iw;
    signal t2wq; t2wq <== t1wq * eq_from_e1.out;
    signal t3wq; t3wq <== t2wq * eq_to_c1.out;
    signal wcQ; wcQ <== t3wq * wq;

    // bcK
    signal t1b; t1b <== kMove * ib;
    signal t2b; t2b <== t1b * eq_from_e8.out;
    signal t3b; t3b <== t2b * eq_to_g8.out;
    signal bcK; bcK <== t3b * bk;

    // bcQ
    signal t1bq; t1bq <== kMove * ib;
    signal t2bq; t2bq <== t1bq * eq_from_e8.out;
    signal t3bq; t3bq <== t2bq * eq_to_c8.out;
    signal bcQ; bcQ <== t3bq * bq;

    /* presence and empty path */
    component OB = Num2Bits(64); OB.in <== occ_pre;

    component WRB = Num2Bits(64); WRB.in <== wR;
    component BRB = Num2Bits(64); BRB.in <== bR;

    component wR_h1 = SelectFromBits64(); wR_h1.idx <== 7;
    component wR_a1 = SelectFromBits64(); wR_a1.idx <== 0;
    component bR_h8 = SelectFromBits64(); bR_h8.idx <== 63;
    component bR_a8 = SelectFromBits64(); bR_a8.idx <== 56;
    for (var i1 = 0; i1 < 64; i1++) {
        wR_h1.bits[i1] <== WRB.out[i1]; wR_a1.bits[i1] <== WRB.out[i1];
        bR_h8.bits[i1] <== BRB.out[i1]; bR_a8.bits[i1] <== BRB.out[i1];
    }

    signal rook_ok_wK; rook_ok_wK <== wcK * wR_h1.bit;
    signal rook_ok_wQ; rook_ok_wQ <== wcQ * wR_a1.bit;
    signal rook_ok_bK; rook_ok_bK <== bcK * bR_h8.bit;
    signal rook_ok_bQ; rook_ok_bQ <== bcQ * bR_a8.bit;

    component sel_f1 = SelectFromBits64(); sel_f1.idx <== 5;
    component sel_g1 = SelectFromBits64(); sel_g1.idx <== 6;
    component sel_d1 = SelectFromBits64(); sel_d1.idx <== 3;
    component sel_c1 = SelectFromBits64(); sel_c1.idx <== 2;

    component sel_f8 = SelectFromBits64(); sel_f8.idx <== 61;
    component sel_g8 = SelectFromBits64(); sel_g8.idx <== 62;
    component sel_d8 = SelectFromBits64(); sel_d8.idx <== 59;
    component sel_c8 = SelectFromBits64(); sel_c8.idx <== 58;

    for (var t = 0; t < 64; t++) {
        sel_f1.bits[t] <== OB.out[t]; sel_g1.bits[t] <== OB.out[t];
        sel_d1.bits[t] <== OB.out[t]; sel_c1.bits[t] <== OB.out[t];
        sel_f8.bits[t] <== OB.out[t]; sel_g8.bits[t] <== OB.out[t];
        sel_d8.bits[t] <== OB.out[t]; sel_c8.bits[t] <== OB.out[t];
    }

    signal pwK1; pwK1 <== 1 - sel_f1.bit;  signal pwK2; pwK2 <== rook_ok_wK * pwK1;  signal pwK3; pwK3 <== 1 - sel_g1.bit;  signal path_wK; path_wK <== pwK2 * pwK3;
    signal pwQ1; pwQ1 <== 1 - sel_d1.bit;  signal pwQ2; pwQ2 <== rook_ok_wQ * pwQ1;  signal pwQ3; pwQ3 <== 1 - sel_c1.bit;  signal path_wQ; path_wQ <== pwQ2 * pwQ3;
    signal pbK1; pbK1 <== 1 - sel_f8.bit;  signal pbK2; pbK2 <== rook_ok_bK * pbK1;  signal pbK3; pbK3 <== 1 - sel_g8.bit;  signal path_bK; path_bK <== pbK2 * pbK3;
    signal pbQ1; pbQ1 <== 1 - sel_d8.bit;  signal pbQ2; pbQ2 <== rook_ok_bQ * pbQ1;  signal pbQ3; pbQ3 <== 1 - sel_c8.bit;  signal path_bQ; path_bQ <== pbQ2 * pbQ3;

    /* slider safety: build opponent slider bitboards once */
    signal oneMinusIw; oneMinusIw <== 1 - iw;

    signal oppR_a; oppR_a <== oneMinusIw * wR; signal oppR_b; oppR_b <== iw * bR; signal oppR; oppR <== oppR_a + oppR_b;
    signal oppB_a; oppB_a <== oneMinusIw * wB; signal oppB_b; oppB_b <== iw * bB; signal oppB; oppB <== oppB_a + oppB_b;
    signal oppQ_a; oppQ_a <== oneMinusIw * wQ; signal oppQ_b; oppQ_b <== iw * bQ; signal oppQ; oppQ <== oppQ_a + oppQ_b;

    component OBs = Num2Bits(64); OBs.in <== occ_pre;
    component RBs = Num2Bits(64); RBs.in <== oppR;
    component BBs = Num2Bits(64); BBs.in <== oppB;
    component QBs = Num2Bits(64); QBs.in <== oppQ;

    /* e1 (4) sliders */
    component e1_r = OrthRay_len3(5,6,7);
    component e1_l = OrthRay_len4(3,2,1,0);
    component e1_u = OrthRay_len7(12,20,28,36,44,52,60);
    component e1_ur = DiagRay_len3(13,22,31);
    component e1_ul = DiagRay_len4(11,18,25,32);

    /* f1 (5) sliders */
    component f1_r = OrthRay_len2(6,7);
    component f1_l = OrthRay_len5(4,3,2,1,0);
    component f1_u = OrthRay_len7(13,21,29,37,45,53,61);
    component f1_ur = DiagRay_len2(14,23);
    component f1_ul = DiagRay_len7(12,19,26,33,40,47,54);

    /* c1 (2) sliders */
    component c1_r = OrthRay_len5(3,4,5,6,7);
    component c1_l = OrthRay_len2(1,0);
    component c1_u = OrthRay_len7(10,18,26,34,42,50,58);
    component c1_ur = DiagRay_len6(11,20,29,38,47,56);
    component c1_ul = DiagRay_len3(9,16,23);

    /* e8 (60) sliders */
    component e8_r = OrthRay_len3(61,62,63);
    component e8_l = OrthRay_len4(59,58,57,56);
    component e8_d = OrthRay_len7(52,44,36,28,20,12,4);
    component e8_dr = DiagRay_len7(53,46,39,32,25,18,11);
    component e8_dl = DiagRay_len6(51,42,33,24,15,6);

    /* f8 (61) sliders */
    component f8_r = OrthRay_len2(62,63);
    component f8_l = OrthRay_len5(60,59,58,57,56);
    component f8_d = OrthRay_len7(53,45,37,29,21,13,5);
    component f8_dr = DiagRay_len7(54,47,40,33,26,19,12);
    component f8_dl = DiagRay_len6(52,43,34,25,16,7);

    /* c8 (58) sliders */
    component c8_r = OrthRay_len5(59,60,61,62,63);
    component c8_l = OrthRay_len2(57,56);
    component c8_d = OrthRay_len7(50,42,34,26,18,10,2);
    component c8_dr = DiagRay_len7(51,44,37,30,23,16,9);
    component c8_dl = DiagRay_len6(49,40,31,22,13,4);

    for (var x = 0; x < 64; x++) {
        // e1
        e1_r.occBits[x] <== OBs.out[x]; e1_l.occBits[x] <== OBs.out[x]; e1_u.occBits[x] <== OBs.out[x];
        e1_ur.occBits[x] <== OBs.out[x]; e1_ul.occBits[x] <== OBs.out[x];
        e1_r.rookBits[x] <== RBs.out[x]; e1_l.rookBits[x] <== RBs.out[x]; e1_u.rookBits[x] <== RBs.out[x];
        e1_ur.bishopBits[x] <== BBs.out[x]; e1_ul.bishopBits[x] <== BBs.out[x];
        e1_r.queenBits[x] <== QBs.out[x]; e1_l.queenBits[x] <== QBs.out[x]; e1_u.queenBits[x] <== QBs.out[x];
        e1_ur.queenBits[x] <== QBs.out[x]; e1_ul.queenBits[x] <== QBs.out[x];

        // f1
        f1_r.occBits[x] <== OBs.out[x]; f1_l.occBits[x] <== OBs.out[x]; f1_u.occBits[x] <== OBs.out[x];
        f1_ur.occBits[x] <== OBs.out[x]; f1_ul.occBits[x] <== OBs.out[x];
        f1_r.rookBits[x] <== RBs.out[x]; f1_l.rookBits[x] <== RBs.out[x]; f1_u.rookBits[x] <== RBs.out[x];
        f1_ur.bishopBits[x] <== BBs.out[x]; f1_ul.bishopBits[x] <== BBs.out[x];
        f1_r.queenBits[x] <== QBs.out[x]; f1_l.queenBits[x] <== QBs.out[x]; f1_u.queenBits[x] <== QBs.out[x];
        f1_ur.queenBits[x] <== QBs.out[x]; f1_ul.queenBits[x] <== QBs.out[x];

        // c1
        c1_r.occBits[x] <== OBs.out[x]; c1_l.occBits[x] <== OBs.out[x]; c1_u.occBits[x] <== OBs.out[x];
        c1_ur.occBits[x] <== OBs.out[x]; c1_ul.occBits[x] <== OBs.out[x];
        c1_r.rookBits[x] <== RBs.out[x]; c1_l.rookBits[x] <== RBs.out[x]; c1_u.rookBits[x] <== RBs.out[x];
        c1_ur.bishopBits[x] <== BBs.out[x]; c1_ul.bishopBits[x] <== BBs.out[x];
        c1_r.queenBits[x] <== QBs.out[x]; c1_l.queenBits[x] <== QBs.out[x]; c1_u.queenBits[x] <== QBs.out[x];
        c1_ur.queenBits[x] <== QBs.out[x]; c1_ul.queenBits[x] <== QBs.out[x];

        // e8
        e8_r.occBits[x] <== OBs.out[x]; e8_l.occBits[x] <== OBs.out[x]; e8_d.occBits[x] <== OBs.out[x];
        e8_dr.occBits[x] <== OBs.out[x]; e8_dl.occBits[x] <== OBs.out[x];
        e8_r.rookBits[x] <== RBs.out[x]; e8_l.rookBits[x] <== RBs.out[x]; e8_d.rookBits[x] <== RBs.out[x];
        e8_dr.bishopBits[x] <== BBs.out[x]; e8_dl.bishopBits[x] <== BBs.out[x];
        e8_r.queenBits[x] <== QBs.out[x]; e8_l.queenBits[x] <== QBs.out[x]; e8_d.queenBits[x] <== QBs.out[x];
        e8_dr.queenBits[x] <== QBs.out[x]; e8_dl.queenBits[x] <== QBs.out[x];

        // f8
        f8_r.occBits[x] <== OBs.out[x]; f8_l.occBits[x] <== OBs.out[x]; f8_d.occBits[x] <== OBs.out[x];
        f8_dr.occBits[x] <== OBs.out[x]; f8_dl.occBits[x] <== OBs.out[x];
        f8_r.rookBits[x] <== RBs.out[x]; f8_l.rookBits[x] <== RBs.out[x]; f8_d.rookBits[x] <== RBs.out[x];
        f8_dr.bishopBits[x] <== BBs.out[x]; f8_dl.bishopBits[x] <== BBs.out[x];
        f8_r.queenBits[x] <== QBs.out[x]; f8_l.queenBits[x] <== QBs.out[x]; f8_d.queenBits[x] <== QBs.out[x];
        f8_dr.queenBits[x] <== QBs.out[x]; f8_dl.queenBits[x] <== QBs.out[x];

        // c8
        c8_r.occBits[x] <== OBs.out[x]; c8_l.occBits[x] <== OBs.out[x]; c8_d.occBits[x] <== OBs.out[x];
        c8_dr.occBits[x] <== OBs.out[x]; c8_dl.occBits[x] <== OBs.out[x];
        c8_r.rookBits[x] <== RBs.out[x]; c8_l.rookBits[x] <== RBs.out[x]; c8_d.rookBits[x] <== RBs.out[x];
        c8_dr.bishopBits[x] <== BBs.out[x]; c8_dl.bishopBits[x] <== BBs.out[x];
        c8_r.queenBits[x] <== QBs.out[x]; c8_l.queenBits[x] <== QBs.out[x]; c8_d.queenBits[x] <== QBs.out[x];
        c8_dr.queenBits[x] <== QBs.out[x]; c8_dl.queenBits[x] <== QBs.out[x];
    }

    /* combine slider hits per square -> slider-safe */
    component or_e1_a = Or3(); or_e1_a.a <== e1_r.hit; or_e1_a.b <== e1_l.hit; or_e1_a.c <== e1_u.hit;
    component or_e1_b = Or2(); or_e1_b.a <== e1_ur.hit; or_e1_b.b <== e1_ul.hit;
    component or_e1   = Or2();  or_e1.a   <== or_e1_a.o; or_e1.b   <== or_e1_b.o;
    signal sl_safe_e1; sl_safe_e1 <== 1 - or_e1.o;

    component or_f1_a = Or3(); or_f1_a.a <== f1_r.hit; or_f1_a.b <== f1_l.hit; or_f1_a.c <== f1_u.hit;
    component or_f1_b = Or2(); or_f1_b.a <== f1_ur.hit; or_f1_b.b <== f1_ul.hit;
    component or_f1   = Or2();  or_f1.a   <== or_f1_a.o; or_f1.b   <== or_f1_b.o;
    signal sl_safe_f1; sl_safe_f1 <== 1 - or_f1.o;

    component or_c1_a = Or3(); or_c1_a.a <== c1_r.hit; or_c1_a.b <== c1_l.hit; or_c1_a.c <== c1_u.hit;
    component or_c1_b = Or2(); or_c1_b.a <== c1_ur.hit; or_c1_b.b <== c1_ul.hit;
    component or_c1   = Or2();  or_c1.a   <== or_c1_a.o; or_c1.b   <== or_c1_b.o;
    signal sl_safe_c1; sl_safe_c1 <== 1 - or_c1.o;

    component or_e8_a = Or3(); or_e8_a.a <== e8_r.hit; or_e8_a.b <== e8_l.hit; or_e8_a.c <== e8_d.hit;
    component or_e8_b = Or2(); or_e8_b.a <== e8_dr.hit; or_e8_b.b <== e8_dl.hit;
    component or_e8   = Or2();  or_e8.a   <== or_e8_a.o; or_e8.b   <== or_e8_b.o;
    signal sl_safe_e8; sl_safe_e8 <== 1 - or_e8.o;

    component or_f8_a = Or3(); or_f8_a.a <== f8_r.hit; or_f8_a.b <== f8_l.hit; or_f8_a.c <== f8_d.hit;
    component or_f8_b = Or2(); or_f8_b.a <== f8_dr.hit; or_f8_b.b <== f8_dl.hit;
    component or_f8   = Or2();  or_f8.a   <== or_f8_a.o; or_f8.b   <== or_f8_b.o;
    signal sl_safe_f8; sl_safe_f8 <== 1 - or_f8.o;

    component or_c8_a = Or3(); or_c8_a.a <== c8_r.hit; or_c8_a.b <== c8_l.hit; or_c8_a.c <== c8_d.hit;
    component or_c8_b = Or2(); or_c8_b.a <== c8_dr.hit; or_c8_b.b <== c8_dl.hit;
    component or_c8   = Or2();  or_c8.a   <== or_c8_a.o; or_c8.b   <== or_c8_b.o;
    signal sl_safe_c8; sl_safe_c8 <== 1 - or_c8.o;

    /* ---------- precise N/P/K safety (local) ---------- */
    signal oppN_a; oppN_a <== (1 - iw) * wN; signal oppN_b; oppN_b <== iw * bN; signal oppN; oppN <== oppN_a + oppN_b;
    signal oppP_a; oppP_a <== (1 - iw) * wP; signal oppP_b; oppP_b <== iw * bP; signal oppP; oppP <== oppP_a + oppP_b;
    signal oppK_a; oppK_a <== (1 - iw) * wK; signal oppK_b; oppK_b <== iw * bK; signal oppK; oppK <== oppK_a + oppK_b;

    component NB = Num2Bits(64); NB.in <== oppN;
    component PBw = Num2Bits(64); PBw.in <== wP;
    component PBb = Num2Bits(64); PBb.in <== bP;
    component KB = Num2Bits(64); KB.in <== oppK;

    // e1
    component e1n[4];
    for (var i=0;i<4;i++) { e1n[i] = SelectFromBits64(); }
    e1n[0].idx <== 10; e1n[1].idx <== 14; e1n[2].idx <== 19; e1n[3].idx <== 21;
    component e1k[5];
    for (var j=0;j<5;j++){ e1k[j] = SelectFromBits64(); }
    e1k[0].idx <== 3; e1k[1].idx <== 5; e1k[2].idx <== 11; e1k[3].idx <== 12; e1k[4].idx <== 13;
    component e1pb[2]; e1pb[0] = SelectFromBits64(); e1pb[1] = SelectFromBits64(); e1pb[0].idx <== 11; e1pb[1].idx <== 13;

    for (var z=0; z<64; z++) {
        for (var q=0;q<4;q++){ e1n[q].bits[z] <== NB.out[z]; }
        for (var q2=0;q2<5;q2++){ e1k[q2].bits[z] <== KB.out[z]; }
        e1pb[0].bits[z] <== PBb.out[z]; e1pb[1].bits[z] <== PBb.out[z];
    }
    component e1n_or = ORn(4); for (var q3=0;q3<4;q3++){ e1n_or.x[q3] <== e1n[q3].bit; }
    component e1k_or = ORn(5); for (var q4=0;q4<5;q4++){ e1k_or.x[q4] <== e1k[q4].bit; }
    component e1p_or = Or2(); e1p_or.a <== e1pb[0].bit; e1p_or.b <== e1pb[1].bit;

    // f1
    component f1n[4];
    for (var a=0;a<4;a++){ f1n[a] = SelectFromBits64(); }
    f1n[0].idx <== 11; f1n[1].idx <== 15; f1n[2].idx <== 20; f1n[3].idx <== 22;
    component f1k[5];
    for (var b=0;b<5;b++){ f1k[b] = SelectFromBits64(); }
    f1k[0].idx <== 4; f1k[1].idx <== 6; f1k[2].idx <== 12; f1k[3].idx <== 13; f1k[4].idx <== 14;
    component f1pb[2]; f1pb[0] = SelectFromBits64(); f1pb[1] = SelectFromBits64(); f1pb[0].idx <== 12; f1pb[1].idx <== 14;

    for (var z2=0; z2<64; z2++) {
        for (var q5=0;q5<4;q5++){ f1n[q5].bits[z2] <== NB.out[z2]; }
        for (var q6=0;q6<5;q6++){ f1k[q6].bits[z2] <== KB.out[z2]; }
        f1pb[0].bits[z2] <== PBb.out[z2]; f1pb[1].bits[z2] <== PBb.out[z2];
    }
    component f1n_or = ORn(4); for (var q7=0;q7<4;q7++){ f1n_or.x[q7] <== f1n[q7].bit; }
    component f1k_or = ORn(5); for (var q8=0;q8<5;q8++){ f1k_or.x[q8] <== f1k[q8].bit; }
    component f1p_or = Or2(); f1p_or.a <== f1pb[0].bit; f1p_or.b <== f1pb[1].bit;

    // c1
    component c1n[4];
    for (var c=0;c<4;c++){ c1n[c] = SelectFromBits64(); }
    c1n[0].idx <== 8; c1n[1].idx <== 12; c1n[2].idx <== 17; c1n[3].idx <== 19;
    component c1k[5];
    for (var d=0; d<5; d++){ c1k[d] = SelectFromBits64(); }
    c1k[0].idx <== 1; c1k[1].idx <== 3; c1k[2].idx <== 9; c1k[3].idx <== 10; c1k[4].idx <== 11;
    component c1pb[2]; c1pb[0] = SelectFromBits64(); c1pb[1] = SelectFromBits64(); c1pb[0].idx <== 9; c1pb[1].idx <== 11;

    for (var z3=0; z3<64; z3++) {
        for (var q9=0;q9<4;q9++){ c1n[q9].bits[z3] <== NB.out[z3]; }
        for (var q10=0;q10<5;q10++){ c1k[q10].bits[z3] <== KB.out[z3]; }
        c1pb[0].bits[z3] <== PBb.out[z3]; c1pb[1].bits[z3] <== PBb.out[z3];
    }
    component c1n_or = ORn(4); for (var q11=0;q11<4;q11++){ c1n_or.x[q11] <== c1n[q11].bit; }
    component c1k_or = ORn(5); for (var q12=0;q12<5;q12++){ c1k_or.x[q12] <== c1k[q12].bit; }
    component c1p_or = Or2(); c1p_or.a <== c1pb[0].bit; c1p_or.b <== c1pb[1].bit;

    // e8
    component e8n[4];
    for (var e=0;e<4;e++){ e8n[e] = SelectFromBits64(); }
    e8n[0].idx <== 50; e8n[1].idx <== 43; e8n[2].idx <== 45; e8n[3].idx <== 54;
    component e8k[5];
    for (var f=0; f<5; f++){ e8k[f] = SelectFromBits64(); }
    e8k[0].idx <== 59; e8k[1].idx <== 61; e8k[2].idx <== 51; e8k[3].idx <== 52; e8k[4].idx <== 53;
    component e8pw[2]; e8pw[0] = SelectFromBits64(); e8pw[1] = SelectFromBits64(); e8pw[0].idx <== 51; e8pw[1].idx <== 53;

    for (var z4=0; z4<64; z4++) {
        for (var q13=0;q13<4;q13++){ e8n[q13].bits[z4] <== NB.out[z4]; }
        for (var q14=0;q14<5;q14++){ e8k[q14].bits[z4] <== KB.out[z4]; }
        e8pw[0].bits[z4] <== PBw.out[z4]; e8pw[1].bits[z4] <== PBw.out[z4];
    }
    component e8n_or = ORn(4); for (var q15=0;q15<4;q15++){ e8n_or.x[q15] <== e8n[q15].bit; }
    component e8k_or = ORn(5); for (var q16=0;q16<5;q16++){ e8k_or.x[q16] <== e8k[q16].bit; }
    component e8p_or = Or2(); e8p_or.a <== e8pw[0].bit; e8p_or.b <== e8pw[1].bit;

    // f8
    component f8n[4];
    for (var g=0;g<4;g++){ f8n[g] = SelectFromBits64(); }
    f8n[0].idx <== 51; f8n[1].idx <== 44; f8n[2].idx <== 46; f8n[3].idx <== 55;
    component f8k[5];
    for (var h=0; h<5; h++){ f8k[h] = SelectFromBits64(); }
    f8k[0].idx <== 60; f8k[1].idx <== 62; f8k[2].idx <== 52; f8k[3].idx <== 53; f8k[4].idx <== 54;
    component f8pw[2]; f8pw[0] = SelectFromBits64(); f8pw[1] = SelectFromBits64(); f8pw[0].idx <== 52; f8pw[1].idx <== 54;

    for (var z5=0; z5<64; z5++) {
        for (var q17=0;q17<4;q17++){ f8n[q17].bits[z5] <== NB.out[z5]; }
        for (var q18=0;q18<5;q18++){ f8k[q18].bits[z5] <== KB.out[z5]; }
        f8pw[0].bits[z5] <== PBw.out[z5]; f8pw[1].bits[z5] <== PBw.out[z5];
    }
    component f8n_or = ORn(4); for (var q19=0;q19<4;q19++){ f8n_or.x[q19] <== f8n[q19].bit; }
    component f8k_or = ORn(5); for (var q20=0;q20<5;q20++){ f8k_or.x[q20] <== f8k[q20].bit; }
    component f8p_or = Or2(); f8p_or.a <== f8pw[0].bit; f8p_or.b <== f8pw[1].bit;

    // c8
    component c8n[4];
    for (var u=0;u<4;u++){ c8n[u] = SelectFromBits64(); }
    c8n[0].idx <== 48; c8n[1].idx <== 41; c8n[2].idx <== 43; c8n[3].idx <== 52;
    component c8k[5];
    for (var v=0; v<5; v++){ c8k[v] = SelectFromBits64(); }
    c8k[0].idx <== 57; c8k[1].idx <== 59; c8k[2].idx <== 49; c8k[3].idx <== 50; c8k[4].idx <== 51;
    component c8pw[2]; c8pw[0] = SelectFromBits64(); c8pw[1] = SelectFromBits64(); c8pw[0].idx <== 49; c8pw[1].idx <== 51;

    for (var z6=0; z6<64; z6++) {
        for (var q21=0;q21<4;q21++){ c8n[q21].bits[z6] <== NB.out[z6]; }
        for (var q22=0;q22<5;q22++){ c8k[q22].bits[z6] <== KB.out[z6]; }
        c8pw[0].bits[z6] <== PBw.out[z6]; c8pw[1].bits[z6] <== PBw.out[z6];
    }
    component c8n_or = ORn(4); for (var q23=0;q23<4;q23++){ c8n_or.x[q23] <== c8n[q23].bit; }
    component c8k_or = ORn(5); for (var q24=0;q24<5;q24++){ c8k_or.x[q24] <== c8k[q24].bit; }
    component c8p_or = Or2(); c8p_or.a <== c8pw[0].bit; c8p_or.b <== c8pw[1].bit;

    // N/P/K safety for each square
    component e1_nk = Or3(); e1_nk.a <== e1n_or.o; e1_nk.b <== e1k_or.o; e1_nk.c <== e1p_or.o; signal npk_safe_e1; npk_safe_e1 <== 1 - e1_nk.o;
    component f1_nk = Or3(); f1_nk.a <== f1n_or.o; f1_nk.b <== f1k_or.o; f1_nk.c <== f1p_or.o; signal npk_safe_f1; npk_safe_f1 <== 1 - f1_nk.o;
    component c1_nk = Or3(); c1_nk.a <== c1n_or.o; c1_nk.b <== c1k_or.o; c1_nk.c <== c1p_or.o; signal npk_safe_c1; npk_safe_c1 <== 1 - c1_nk.o;

    component e8_nk = Or3(); e8_nk.a <== e8n_or.o; e8_nk.b <== e8k_or.o; e8_nk.c <== e8p_or.o; signal npk_safe_e8; npk_safe_e8 <== 1 - e8_nk.o;
    component f8_nk = Or3(); f8_nk.a <== f8n_or.o; f8_nk.b <== f8k_or.o; f8_nk.c <== f8p_or.o; signal npk_safe_f8; npk_safe_f8 <== 1 - f8_nk.o;
    component c8_nk = Or3(); c8_nk.a <== c8n_or.o; c8_nk.b <== c8k_or.o; c8_nk.c <== c8p_or.o; signal npk_safe_c8; npk_safe_c8 <== 1 - c8_nk.o;

    /* combine N/P/K and slider safety per flank (pairwise chains only) */
    signal swK_t1; swK_t1 <== npk_safe_e1 * sl_safe_e1; signal swK_t2; swK_t2 <== swK_t1 * npk_safe_f1; signal safe_wK; safe_wK <== swK_t2 * sl_safe_f1;
    signal swQ_t1; swQ_t1 <== npk_safe_e1 * sl_safe_e1; signal swQ_t2; swQ_t2 <== swQ_t1 * npk_safe_c1; signal safe_wQ; safe_wQ <== swQ_t2 * sl_safe_c1;

    signal sbK_t1; sbK_t1 <== npk_safe_e8 * sl_safe_e8; signal sbK_t2; sbK_t2 <== sbK_t1 * npk_safe_f8; signal safe_bK; safe_bK <== sbK_t2 * sl_safe_f8;
    signal sbQ_t1; sbQ_t1 <== npk_safe_e8 * sl_safe_e8; signal sbQ_t2; sbQ_t2 <== sbQ_t1 * npk_safe_c8; signal safe_bQ; safe_bQ <== sbQ_t2 * sl_safe_c8;

    /* final flank checks */
    signal chk_wK; chk_wK <== path_wK * safe_wK;
    signal chk_wQ; chk_wQ <== path_wQ * safe_wQ;
    signal chk_bK; chk_bK <== path_bK * safe_bK;
    signal chk_bQ; chk_bQ <== path_bQ * safe_bQ;

    component orW = Or2(); orW.a <== chk_wK; orW.b <== chk_wQ;
    component orB = Or2(); orB.a <== chk_bK; orB.b <== chk_bQ;
    component orWB = Or2(); orWB.a <== orW.o; orWB.b <== orB.o;
    is_castle <== orWB.o;

    /* rook squares (const×signal only; sums separated) */
    signal RFa1; RFa1 <== chk_wK * 7;  signal RFa2; RFa2 <== chk_wQ * 0;
    signal RFa3; RFa3 <== chk_bK * 63; signal RFa4; RFa4 <== chk_bQ * 56;
    signal RFa12; RFa12 <== RFa1 + RFa2; signal RFa34; RFa34 <== RFa3 + RFa4; rook_from_sq <== RFa12 + RFa34;

    signal RTa1; RTa1 <== chk_wK * 5;  signal RTa2; RTa2 <== chk_wQ * 3;
    signal RTa3; RTa3 <== chk_bK * 61; signal RTa4; RTa4 <== chk_bQ * 59;
    signal RTa12; RTa12 <== RTa1 + RTa2; signal RTa34; RTa34 <== RTa3 + RTa4; rook_to_sq <== RTa12 + RTa34;
}
