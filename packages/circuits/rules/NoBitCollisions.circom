pragma circom 2.0.0;

include "circomlib/circuits/bitify.circom"; // Num2Bits

// Ensures no two of the 12 bitboards have a '1' on the same square.
// Quadratic only (per-square: sum * (1 - sum) === 0). No signal declarations inside loops.
template NoBitCollisions12() {
    // Inputs: 12 u64 bitboards (canonical order)
    signal input wP; signal input wN; signal input wB; signal input wR; signal input wQ; signal input wK;
    signal input bP; signal input bN; signal input bB; signal input bR; signal input bQ; signal input bK;

    // Optional output for uniform interface (always 1)
    signal output ok;

    // Decompose once
    component wPbits = Num2Bits(64); wPbits.in <== wP;
    component wNbits = Num2Bits(64); wNbits.in <== wN;
    component wBbits = Num2Bits(64); wBbits.in <== wB;
    component wRbits = Num2Bits(64); wRbits.in <== wR;
    component wQbits = Num2Bits(64); wQbits.in <== wQ;
    component wKbits = Num2Bits(64); wKbits.in <== wK;

    component bPbits = Num2Bits(64); bPbits.in <== bP;
    component bNbits = Num2Bits(64); bNbits.in <== bN;
    component bBbits = Num2Bits(64); bBbits.in <== bB;
    component bRbits = Num2Bits(64); bRbits.in <== bR;
    component bQbits = Num2Bits(64); bQbits.in <== bQ;
    component bKbits = Num2Bits(64); bKbits.in <== bK;

    // Per-square occupancy sum must be in {0,1}
    signal sumBits[64];
    for (var i = 0; i < 64; i++) {
        sumBits[i] <== wPbits.out[i] + wNbits.out[i] + wBbits.out[i] + wRbits.out[i] + wQbits.out[i] + wKbits.out[i]
                     + bPbits.out[i] + bNbits.out[i] + bBbits.out[i] + bRbits.out[i] + bQbits.out[i] + bKbits.out[i];
        sumBits[i] * (1 - sumBits[i]) === 0;
    }

    ok <== 1;
    ok * (1 - ok) === 0;
    ok === 1;
}
