export async function proveMove(input: { fen: string; move: string }) {
  const res = await fetch("/api/prove", {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(input),
  });

  if (!res.ok) {
    const msg = await res.text();
    throw new Error(`Prover error (${res.status}): ${msg}`);
  }
  return res.json();
}

