pragma circom 2.0.0;
include "_helpers.circom"; // SelectBit64

// Asserts: destination square is NOT occupied by self
template CheckDestinationEmptyOrOpponent_assert_ok() {
    signal input self_board;     // u64
    signal input opponent_board; // u64 (kept for interface / reuse elsewhere)
    signal input dest_square;    // 0..63
    signal output ok;

    component s = SelectBit64(); s.packed <== self_board;     s.idx <== dest_square;
    component o = SelectBit64(); o.packed <== opponent_board; o.idx <== dest_square; // optional reuse

    // self must be 0 at dest
    s.bit * (1 - s.bit) === 0;
    ok <== 1 - s.bit;
    ok * (1 - ok) === 0;
    ok === 1;
}
