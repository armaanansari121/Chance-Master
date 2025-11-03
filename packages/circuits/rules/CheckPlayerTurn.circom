pragma circom 2.0.0;
include "circomlib/circuits/comparators.circom"; // IsEqual

template CheckPlayerTurn() {
    signal input turn;          // 0 or 1
    signal input player_color;  // 0 or 1
    signal output ok;

    component eq = IsEqual(); 
    eq.in[0] <== turn; 
    eq.in[1] <== player_color;

    ok <== eq.out;
    ok * (1 - ok) === 0;
    ok === 1;
}
