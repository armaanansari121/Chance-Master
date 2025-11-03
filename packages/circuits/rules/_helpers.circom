pragma circom 2.0.0;

include "circomlib/circuits/bitify.circom"; // Num2Bits

/* DotMask64:
   Decompose a packed u64 and take a dot with a 64-length 0/1 mask.
   Mask entries are expected to be constants; multiplication-by-constant is linear in R1CS.
*/
template DotMask64() {
    signal input value;        // u64 packed
    signal input mask[64];     // 0/1 constants (wire them at instantiation)
    signal output sum;

    component bits = Num2Bits(64); bits.in <== value;

    signal acc[65];
    acc[0] <== 0;

    for (var i = 0; i < 64; i++) {
        // constant * signal is linear; no new signal declarations inside the loop
        acc[i+1] <== acc[i] + mask[i] * bits.out[i];
    }

    sum <== acc[64];
}

/* SelectBit64:
   Return bit at index `idx` (0..63) from a packed u64 without 64× IsEqual.
   Built as a staged MUX tree; no signal declarations inside loops.
*/
template SelectBit64() {
    signal input packed;   // u64
    signal input idx;      // 0..63
    signal output bit;     // 0/1

    // Decompose once
    component b  = Num2Bits(64); b.in  <== packed;   // bits LSB..MSB
    component id = Num2Bits(6);  id.in <== idx;      // proves idx < 64

    // Predeclare the levels outside the loops (Circom scoping rule)
    signal l0[32];
    signal l1[16];
    signal l2[8];
    signal l3[4];
    signal l4[2];

    // Level 0: 64 -> 32 (pairwise select by id.out[0])
    for (var i = 0; i < 32; i++) {
        // l0[i] = select(id0, b[2*i], b[2*i+1]) = a + s*(c - a)
        l0[i] <== b.out[2*i] + id.out[0] * (b.out[2*i+1] - b.out[2*i]);
    }

    // Level 1: 32 -> 16 (by id.out[1])
    for (var i = 0; i < 16; i++) {
        l1[i] <== l0[2*i] + id.out[1] * (l0[2*i+1] - l0[2*i]);
    }

    // Level 2: 16 -> 8 (by id.out[2])
    for (var i = 0; i < 8; i++) {
        l2[i] <== l1[2*i] + id.out[2] * (l1[2*i+1] - l1[2*i]);
    }

    // Level 3: 8 -> 4 (by id.out[3])
    for (var i = 0; i < 4; i++) {
        l3[i] <== l2[2*i] + id.out[3] * (l2[2*i+1] - l2[2*i]);
    }

    // Level 4: 4 -> 2 (by id.out[4])
    for (var i = 0; i < 2; i++) {
        l4[i] <== l3[2*i] + id.out[4] * (l3[2*i+1] - l3[2*i]);
    }

    // Level 5: 2 -> 1 (by id.out[5])
    bit <== l4[0] + id.out[5] * (l4[1] - l4[0]);

    // Keep boolean (inputs are bits, but we can enforce it)
    bit * (1 - bit) === 0;
}

/* SelectFromBits64:
   Bits-first selector: parent provides bits[64] directly.
   Same staged MUX as above, but avoids re-decomposition of a packed word.
*/
template SelectFromBits64() {
    signal input bits[64];  // LSB..MSB, provided by caller
    signal input idx;       // 0..63
    signal output bit;      // 0/1

    component id = Num2Bits(6); id.in <== idx;

    // predeclared levels (no signal declarations in loops)
    signal l0[32];
    signal l1[16];
    signal l2[8];
    signal l3[4];
    signal l4[2];

    for (var i = 0; i < 32; i++) { l0[i] <== bits[2*i] + id.out[0]*(bits[2*i+1]-bits[2*i]); }
    for (var i = 0; i < 16; i++) { l1[i] <== l0[2*i]   + id.out[1]*(l0[2*i+1]-l0[2*i]); }
    for (var i = 0; i < 8;  i++) { l2[i] <== l1[2*i]   + id.out[2]*(l1[2*i+1]-l1[2*i]); }
    for (var i = 0; i < 4;  i++) { l3[i] <== l2[2*i]   + id.out[3]*(l2[2*i+1]-l2[2*i]); }
    for (var i = 0; i < 2;  i++) { l4[i] <== l3[2*i]   + id.out[4]*(l3[2*i+1]-l3[2*i]); }

    bit <== l4[0] + id.out[5]*(l4[1]-l4[0]);
    bit * (1 - bit) === 0;   // boolean
}

// Pow2_64: returns 2^idx as a field element (idx in 0..63)
template Pow2_64() {
    signal input idx;   // 0..63
    signal output out;  // 2^idx

    component id = Num2Bits(6); id.in <== idx;

    // Predeclare levels; only assignments inside loops
    signal l0[32];
    signal l1[16];
    signal l2[8];
    signal l3[4];
    signal l4[2];

    // Base constants at level-0: (2^(2*i)) vs (2^(2*i+1))
    for (var i = 0; i < 32; i++) {
        // select between two constants with id.out[0]
        l0[i] <== ((1 << (2*i))) + id.out[0] * ((1 << (2*i + 1)) - (1 << (2*i)));
    }
    for (var i = 0; i < 16; i++) { l1[i] <== l0[2*i] + id.out[1] * (l0[2*i+1] - l0[2*i]); }
    for (var i = 0; i < 8;  i++) { l2[i] <== l1[2*i] + id.out[2] * (l1[2*i+1] - l1[2*i]); }
    for (var i = 0; i < 4;  i++) { l3[i] <== l2[2*i] + id.out[3] * (l2[2*i+1] - l2[2*i]); }
    for (var i = 0; i < 2;  i++) { l4[i] <== l3[2*i] + id.out[4] * (l3[2*i+1] - l3[2*i]); }

    out <== l4[0] + id.out[5] * (l4[1] - l4[0]);
}

// helpers/ExactlyOneBit64.circom (you can append to _helpers.circom)
template ExactlyOneBit64() {
    signal input packed;   // u64
    signal output ok;      // == 1 iff popcount == 1

    component bits = Num2Bits(64); bits.in <== packed;

    signal acc[65];
    acc[0] <== 0;
    for (var i = 0; i < 64; i++) {
        acc[i+1] <== acc[i] + bits.out[i];
    }

    component is1 = IsEqual();
    is1.in[0] <== acc[64];
    is1.in[1] <== 1;

    ok <== is1.out;
    ok * (1 - ok) === 0;
    ok === 1;
}
