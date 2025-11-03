// src/app/lib/torii-graphql.ts
import { createClient, Client } from 'graphql-ws';

export const TORII_HTTP = process.env.NEXT_PUBLIC_TORII_HTTP ?? 'http://localhost:8080/graphql';
export const TORII_WS = process.env.NEXT_PUBLIC_TORII_WS ?? 'ws://localhost:8080/graphql';

export async function gqlFetch<T>(query: string, variables?: Record<string, any>, signal?: AbortSignal): Promise<T> {
  const res = await fetch(TORII_HTTP, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ query, variables }),
    signal,
  });
  const json = await res.json();
  if (!res.ok || json.errors?.length) throw new Error(json.errors?.[0]?.message ?? `GraphQL HTTP ${res.status}`);
  return json.data as T;
}

let wsClient: Client | null = null;
export function getWsClient() {
  if (!wsClient) {
    wsClient = createClient({
      url: TORII_WS,
      retryAttempts: Infinity,
      retryWait: async (n) => new Promise(r => setTimeout(r, Math.min(1000 * 2 ** Math.min(n, 4), 15000))),
    });
  }
  return wsClient;
}

