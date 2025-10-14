pragma circom 2.0.0;
include "circomlib/circuits/comparators.circom"; // IsEqual

// Asserts: piece_type ∈ {dice[0], dice[1], dice[2]}
// Works with duplicate dice values
template CheckDiceInclusion() {
    signal input piece_type;    // 1..6, per your encoding
    signal input dice[3];       // may contain duplicates
    signal output ok;

    component e0 = IsEqual(); e0.in[0] <== piece_type; e0.in[1] <== dice[0];
    component e1 = IsEqual(); e1.in[0] <== piece_type; e1.in[1] <== dice[1];
    component e2 = IsEqual(); e2.in[0] <== piece_type; e2.in[1] <== dice[2];

    // ok = e0 OR e1 OR e2 = 1 - (1-e0)(1-e1)(1-e2)
    signal t01;  t01  <== (1 - e0.out) * (1 - e1.out);
    signal none; none <== t01 * (1 - e2.out);
    ok   <== 1 - none;

    ok * (1 - ok) === 0;
    ok === 1;
}