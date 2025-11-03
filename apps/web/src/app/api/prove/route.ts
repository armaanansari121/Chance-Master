import { NextRequest, NextResponse } from 'next/server';

type ProveRequest = { fen: string; move: string, dice: [number, number, number] };
type ProverOk = { valid: true; proof: unknown };
type ProverErr = { valid: false; error: string; error_details: unknown };
type ProverResponse = ProverOk | ProverErr;

export async function POST(req: NextRequest) {
  const { fen, move, dice } = (await req.json()) as ProveRequest;

  try {
    const r = await fetch('http://prover:8000/prove', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ fen, move, dice }),
    });

    const data = (await r.json()) as ProverResponse;
    return NextResponse.json(data, { status: r.ok ? 200 : 400 });
  } catch (e: unknown) {
    return NextResponse.json({ valid: false, error: 'Prover unreachable', error_details: e } satisfies ProverErr, {
      status: 502,
    });
  }
}

