// BoardHash12_emit.circom
pragma circom 2.0.0;
include "circomlib/circuits/poseidon.circom";

// Canonical order (freeze this):
// white_pawn, white_knight, white_bishop, white_rook, white_queen, white_king,
// black_pawn, black_knight, black_bishop, black_rook, black_queen, black_king

template BoardHash12() {
    signal input white_pawn;
    signal input white_knight;
    signal input white_bishop;
    signal input white_rook;
    signal input white_queen;
    signal input white_king;
    signal input black_pawn;
    signal input black_knight;
    signal input black_bishop;
    signal input black_rook;
    signal input black_queen;
    signal input black_king;

    signal output hash_out;   // will be public at top-level main

    component H = Poseidon(12);
    H.inputs[0]  <== white_pawn;
    H.inputs[1]  <== white_knight;
    H.inputs[2]  <== white_bishop;
    H.inputs[3]  <== white_rook;
    H.inputs[4]  <== white_queen;
    H.inputs[5]  <== white_king;
    H.inputs[6]  <== black_pawn;
    H.inputs[7]  <== black_knight;
    H.inputs[8]  <== black_bishop;
    H.inputs[9]  <== black_rook;
    H.inputs[10] <== black_queen;
    H.inputs[11] <== black_king;

    hash_out <== H.out;
}