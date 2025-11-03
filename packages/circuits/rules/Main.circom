pragma circom 2.0.0;

include "Orchestrator.circom";

template Main() {
    // 0..23 — Orchestrator INPUTS (public, original names)
    signal input wP;                 // 0
    signal input wN;                 // 1
    signal input wB;                 // 2
    signal input wR;                 // 3
    signal input wQ;                 // 4
    signal input wK;                 // 5
    signal input bP;                 // 6
    signal input bN;                 // 7
    signal input bB;                 // 8
    signal input bR;                 // 9
    signal input bQ;                 // 10
    signal input bK;                 // 11

    signal input _mover_color;       // 12
    signal input _turn;              // 13
    signal input _from_square;       // 14
    signal input _to_square;         // 15
    signal input _promo_choice;      // 16
    signal input _dice0;             // 17
    signal input _dice1;             // 18
    signal input _dice2;             // 19
    signal input _castle_rights;     // 20
    signal input _my_king_sq;        // 21
    signal input _prev_ep_flag;      // 22
    signal input _prev_ep_square;    // 23

    // 24..38 — EXPECTED Orchestrator OUTPUTS we verify
    signal input expected_next_castle_rights; // 24
    signal input expected_next_ep_flag;       // 25
    signal input expected_next_ep_square;     // 26  <-- NEW

    signal input expected_next_wP;            // 27
    signal input expected_next_wN;            // 28
    signal input expected_next_wB;            // 29
    signal input expected_next_wR;            // 30
    signal input expected_next_wQ;            // 31
    signal input expected_next_wK;            // 32
    signal input expected_next_bP;            // 33
    signal input expected_next_bN;            // 34
    signal input expected_next_bB;            // 35
    signal input expected_next_bR;            // 36
    signal input expected_next_bQ;            // 37
    signal input expected_next_bK;            // 38
    signal input _opp_king_sq;                // 39  (post-move opponent king square)
    signal input expected_opp_in_check;       // 40  (bool)

    // Instantiate original Orchestrator
    component core = Orchestrator();

    // Wire inputs straight through (all public)
    core.wP <== wP; core.wN <== wN; core.wB <== wB; core.wR <== wR; core.wQ <== wQ; core.wK <== wK;
    core.bP <== bP; core.bN <== bN; core.bB <== bB; core.bR <== bR; core.bQ <== bQ; core.bK <== bK;

    core._mover_color    <== _mover_color;
    core._turn           <== _turn;
    core._from_square    <== _from_square;
    core._to_square      <== _to_square;
    core._promo_choice   <== _promo_choice;
    core._dice0          <== _dice0;
    core._dice1          <== _dice1;
    core._dice2          <== _dice2;
    core._castle_rights  <== _castle_rights;
    core._my_king_sq     <== _my_king_sq;
    core._prev_ep_flag   <== _prev_ep_flag;
    core._prev_ep_square <== _prev_ep_square;
    core._opp_king_sq    <== _opp_king_sq;

    // Verify selected outputs
    expected_next_castle_rights === core.next_castle_rights;
    expected_next_ep_flag       === core.next_ep_flag;
    expected_next_ep_square     === core.next_ep_square; // <-- NEW bind

    expected_next_wP === core.next_wP;
    expected_next_wN === core.next_wN;
    expected_next_wB === core.next_wB;
    expected_next_wR === core.next_wR;
    expected_next_wQ === core.next_wQ;
    expected_next_wK === core.next_wK;

    expected_next_bP === core.next_bP;
    expected_next_bN === core.next_bN;
    expected_next_bB === core.next_bB;
    expected_next_bR === core.next_bR;
    expected_next_bQ === core.next_bQ;
    expected_next_bK === core.next_bK;
    expected_opp_in_check === core.opp_in_check;
}

// Expose exactly the 0..38 input names defined above
component main { public [
  wP, wN, wB, wR, wQ, wK,
  bP, bN, bB, bR, bQ, bK,
  _mover_color, _turn, _from_square, _to_square,
  _promo_choice, _dice0, _dice1, _dice2,
  _castle_rights, _my_king_sq, _prev_ep_flag, _prev_ep_square,
  expected_next_castle_rights, expected_next_ep_flag, expected_next_ep_square,
  expected_next_wP, expected_next_wN, expected_next_wB, expected_next_wR,
  expected_next_wQ, expected_next_wK, expected_next_bP, expected_next_bN,
  expected_next_bB, expected_next_bR, expected_next_bQ, expected_next_bK,
  _opp_king_sq, expected_opp_in_check
] } = Main();

