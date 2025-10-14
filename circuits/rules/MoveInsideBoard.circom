pragma circom 2.0.0;
include "circomlib/circuits/bitify.circom";      // Num2Bits
include "circomlib/circuits/comparators.circom"; // IsEqual

// ok == 1 iff from_square and to_square are both in [0..63] AND from != to
template MoveInsideBoard() {
    signal input from_square;
    signal input to_square;
    signal output ok;

    // Prove both < 64
    component fb = Num2Bits(6); fb.in <== from_square;
    component tb = Num2Bits(6); tb.in <== to_square;

    // from != to  → neq = 1 - (from == to)
    component eq = IsEqual();
    eq.in[0] <== from_square;
    eq.in[1] <== to_square;

    ok <== 1 - eq.out;
    ok * (1 - ok) === 0;
    ok === 1;
}