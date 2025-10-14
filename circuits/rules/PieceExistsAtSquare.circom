pragma circom 2.0.0;
include "_helpers.circom"; // SelectBit64

// Asserts: bitboard[from_square] == 1
template PieceExistsAtSquare_assert_ok() {
    signal input bitboard;     // u64 (LSB = square 0)
    signal input from_square;  // 0..63
    signal output ok;

    component sel = SelectBit64();
    sel.packed <== bitboard;
    sel.idx    <== from_square;

    ok <== sel.bit;
    ok * (1 - ok) === 0;
    ok === 1;
}
