'use client';

import Link from 'next/link';
import Image from 'next/image';
import { motion, type Transition } from 'framer-motion';
import { useEffect, useState } from 'react';

const spring: Transition = { type: 'spring', stiffness: 260, damping: 26 };

function Section({
  children,
  delay = 0,
  immediate = false, // <- immediate: animate right away (no whileInView)
}: {
  children: React.ReactNode;
  delay?: number;
  immediate?: boolean;
}) {
  if (immediate) {
    return (
      <motion.section
        initial={{ y: 12, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ ...spring, delay }}
        className="w-full"
        style={{ willChange: 'transform, opacity' }}
      >
        {children}
      </motion.section>
    );
  }

  return (
    <motion.section
      initial={{ y: 12, opacity: 0 }}
      whileInView={{ y: 0, opacity: 1 }}
      viewport={{ once: true, amount: 0 }} // trigger as soon as it touches viewport
      transition={{ ...spring, delay }}
      className="w-full"
      style={{ willChange: 'transform, opacity' }}
    >
      {children}
    </motion.section>
  );
}

function Chip({ children }: { children: React.ReactNode }) {
  return (
    <span className="inline-flex items-center gap-1 rounded-full border border-white/10 bg-white/5 px-2.5 py-1 text-[11px] font-medium text-white/75">
      {children}
    </span>
  );
}

function Feature({
  icon,
  title,
  desc,
  i = 0,
}: {
  icon: string;
  title: string;
  desc: string;
  i?: number;
}) {
  return (
    <motion.div
      initial={{ y: 10, opacity: 0 }}
      whileInView={{ y: 0, opacity: 1 }}
      viewport={{ once: true, amount: 0.2 }}
      transition={{ ...spring, delay: 0.08 * i }}
      className="group relative rounded-xl border border-white/10 bg-white/[0.03] p-4 text-left"
      style={{ willChange: 'transform, opacity' }}
    >
      {/* Hover glow */}
      <div
        className="
          pointer-events-none absolute inset-0 -z-10
          opacity-0 transition-opacity duration-300 ease-out
          group-hover:opacity-100
          before:absolute before:inset-0 before:rounded-[18px]
          before:bg-[radial-gradient(45%_50%_at_50%_50%,rgba(34,197,94,0.45)_0%,rgba(34,197,94,0.18)_42%,transparent_70%)]
          before:blur-[18px] before:opacity-90 before:scale-95
          group-hover:before:scale-100 before:transition-transform before:duration-300 before:ease-out
        "
      />
      <div className="mb-3 flex items-center gap-2">
        <Image src={icon} alt="" width={16} height={16} className="opacity-80 invert" />
        <h3 className="font-medium">{title}</h3>
      </div>
      <p className="text-sm text-white/70">{desc}</p>
    </motion.div>
  );
}

function Stack({ children }: { children: React.ReactNode }) {
  return (
    <div className="container mx-auto max-w-6xl space-y-8 px-6 py-14 sm:space-y-10 sm:py-20">
      {children}
    </div>
  );
}

export default function Home() {
  // Optional: ensure we start at top after redirect
  useEffect(() => {
    // In case a previous page had non-zero scroll
    window.scrollTo(0, 0);
  }, []);

  return (
    <main className="relative isolate min-h-screen">
      <Stack>
        {/* HERO: immediate animate so it doesn't wait for intersection */}
        <Section immediate>
          <div className="flex flex-col items-center gap-8 text-center">
            {/* BRAND LOGO — prominent, above badges */}
            <motion.div
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ ...spring, delay: 0.05 }}
              className="rounded-2xl border border-white/10 bg-white/[0.04] p-2 shadow-[0_0_40px_rgba(16,185,129,0.12)]"
              style={{ willChange: 'transform, opacity' }}
            >
              <Image
                src="/Logo.png"
                alt="Chance Master"
                width={84}
                height={84}
                className="h-16 w-16 rounded-xl object-contain sm:h-20 sm:w-20"
                priority
              />
            </motion.div>

            <div className="flex flex-wrap items-center justify-center gap-2">
              <Chip>
                <span className="h-1.5 w-1.5 rounded-full bg-emerald-400/80" />
                zk-verified (anti-cheat)
              </Chip>
              <Chip>
                <span className="h-1.5 w-1.5 rounded-full bg-sky-400/80" />
                real-time multiplayer
              </Chip>
            </div>

            <motion.h1
              className="text-balance bg-gradient-to-b from-white to-white/70 bg-clip-text text-5xl font-semibold leading-tight text-transparent sm:text-6xl md:text-7xl"
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              transition={spring}
              style={{ willChange: 'transform, opacity' }}
            >
              Chance Master
            </motion.h1>

            <p className="max-w-2xl text-pretty text-white/75">
              Fully on-chain dice chess on Starknet. Prove every move with Groth16, prevent cheating by design, and play
              live with instant updates via GraphQL subscriptions.
            </p>

            <div className="flex flex-wrap items-center justify-center gap-3">
              <Link
                href="/match"
                className="rounded-lg bg-emerald-400 px-5 py-3 text-sm font-medium text-black transition-transform hover:scale-[1.02] active:scale-[0.98]"
              >
                Play now
              </Link>
              <a
                href="https://github.com/armaanansari121/Chance-Master"
                target="_blank"
                rel="noreferrer"
                className="rounded-lg border border-white/15 bg-white/[0.03] px-5 py-3 text-sm font-medium text-white/90 hover:bg-white/[0.06]"
              >
                Docs / Repo
              </a>
            </div>

            <div className="mt-10 grid w-full grid-cols-1 gap-4 sm:grid-cols-3">
              <Feature
                icon="/file.svg"
                title="zk-proved gameplay"
                desc="Each move yields a Groth16 proof that it’s legal under dice constraints — no client-side trust."
                i={0}
              />
              <Feature
                icon="/window.svg"
                title="Live multiplayer"
                desc="Torii + GraphQL subscriptions stream board, clock, and claims to both players in real-time."
                i={1}
              />
              <Feature
                icon="/globe.svg"
                title="On-chain verification"
                desc="Proofs are checked by a Cairo BN254 verifier; state only changes when the proof is valid."
                i={2}
              />
            </div>

            <motion.div
              initial={{ scale: 0.98, opacity: 0 }}
              whileInView={{ scale: 1, opacity: 1 }}
              viewport={{ once: true, amount: 0.1 }}
              transition={{ ...spring, delay: 0.1 }}
              className="relative mt-12 w-full overflow-hidden rounded-2xl border border-white/10 bg-white/[0.02] p-3"
              style={{ willChange: 'transform, opacity' }}
            >
              <div className="rounded-xl bg-gradient-to-b from-white/5 to-transparent p-3">
                <div className="aspect-[16/9] w-full rounded-lg bg-[linear-gradient(90deg,transparent_49%,rgba(255,255,255,0.05)_50%,transparent_51%),linear-gradient(transparent_49%,rgba(255,255,255,0.05)_50%,transparent_51%)] bg-[size:40px_40px]">
                  <div className="flex h-full items-center justify-center text-white/50">
                    <span className="rounded-md border border-white/10 bg-black/30 px-3 py-1 text-xs">
                      Screenshot placeholder
                    </span>
                  </div>
                </div>
              </div>
            </motion.div>
          </div>
        </Section>

        {/* WHAT IS DICE CHESS */}
        <Section delay={0.05}>
          <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-6 sm:p-8">
            <h2 className="mb-3 text-xl font-semibold">What is dice chess?</h2>
            <p className="text-white/70">
              A chess variant where dice decide which pieces are allowed to move. Each turn, you roll three d6; faces
              map to piece types (pawn, knight, bishop, rook, queen, king). Move any one rolled type. If none can move,
              you wait for a usable roll. Standard chess rules apply; promotion defaults to queen.
            </p>
            <div className="mt-4 grid gap-2 text-sm text-white/70 sm:grid-cols-2">
              <div className="rounded-lg border border-white/10 bg-white/[0.02] p-3">• Doubles/triples increase options.</div>
              <div className="rounded-lg border border-white/10 bg-white/[0.02] p-3">• All legality is zk-proved.</div>
            </div>
            <p className="mt-3 text-xs text-white/50">This build uses a three-dice mapping to piece types.</p>
          </div>
        </Section>

        {/* HOW IT WORKS */}
        <Section delay={0.08}>
          <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-6 sm:p-8">
            <h2 className="mb-3 text-xl font-semibold">How it works</h2>
            <ol className="space-y-3 text-left text-white/80">
              <li>
                <span className="font-medium text-white">1. Roll.</span> Get three piece types for this turn (shown instantly).
              </li>
              <li>
                <span className="font-medium text-white">2. Prove.</span> The prover (wasm + snarkjs) generates a Groth16 proof for your move.
              </li>
              <li>
                <span className="font-medium text-white">3. Verify on-chain.</span> The BN254 verifier checks the proof; only then is state updated.
              </li>
              <li>
                <span className="font-medium text-white">4. Sync live.</span> Torii pushes board/clock/claim updates to both players in real-time.
              </li>
            </ol>

            <div className="mt-6 grid gap-4 sm:grid-cols-3">
              <Feature
                icon="/file.svg"
                title="Anti-cheat by design"
                desc="Contracts reject moves without valid proofs and matching public inputs."
                i={0}
              />
              <Feature
                icon="/window.svg"
                title="Claims & clocks"
                desc="Checkmate/Stalemate claims, draw offers, and timeouts are handled on-chain."
                i={1}
              />
              <Feature
                icon="/globe.svg"
                title="Fast UX"
                desc="Optimistic UI flips turn locally; chain confirmation lands via subscriptions."
                i={2}
              />
            </div>
          </div>
        </Section>

        {/* TECH SNAPSHOT */}
        <Section delay={0.1}>
          <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-6 sm:p-8">
            <h2 className="mb-3 text-xl font-semibold">Tech snapshot</h2>
            <div className="grid gap-4 sm:grid-cols-3">
              <Feature
                icon="/file.svg"
                title="Circuits"
                desc="Circom rules (move legality, dice inclusion, EP/castling, check safety)."
                i={0}
              />
              <Feature
                icon="/globe.svg"
                title="Verifier"
                desc="Cairo Groth16 BN254 verifier; calldata via Garaga format."
                i={1}
              />
              <Feature
                icon="/window.svg"
                title="Realtime"
                desc="Torii indexer + GraphQL subscriptions keep boards in sync."
                i={2}
              />
            </div>
          </div>
        </Section>

        {/* FOOTER */}
        <footer className="border-t border-white/10 py-10 text-sm">
          <div className="container mx-auto grid max-w-6xl grid-cols-1 gap-8 px-6 sm:grid-cols-4">
            <div className="space-y-3">
              <div className="flex items-center gap-2">
                <Image src="/Logo.png" alt="Chance Master" width={20} height={20} className="rounded-sm" />
                <span className="font-semibold text-white/90">Chance Master</span>
              </div>
              <p className="text-white/60">
                Fully on-chain dice chess with zk-verified moves and real-time multiplayer on Starknet.
              </p>
            </div>

            <div>
              <div className="mb-2 font-medium text-white/80">Product</div>
              <ul className="space-y-1 text-white/70">
                <li><Link href="/chess" className="hover:text-white">Play</Link></li>
                <li><a href="https://github.com/dojoengine/dojo-starter" target="_blank" rel="noreferrer" className="hover:text-white">Docs / Repo</a></li>
              </ul>
            </div>

            <div>
              <div className="mb-2 font-medium text-white/80">Tech</div>
              <ul className="space-y-1 text-white/70">
                <li className="hover:text-white">Groth16 • BN254</li>
                <li className="hover:text-white">Circom • Garaga</li>
                <li className="hover:text-white">Torii • GraphQL</li>
                <li className="hover:text-white">Starknet • Dojo</li>
              </ul>
            </div>

            <div>
              <div className="mb-2 font-medium text-white/80">Community</div>
              <ul className="space-y-1 text-white/70">
                <li><a href="https://x.com/ohayo_dojo" target="_blank" rel="noreferrer" className="hover:text-white">X</a></li>
                <li><a href="https://discord.gg/FB2wR6uF" target="_blank" rel="noreferrer" className="hover:text-white">Discord</a></li>
                <li><a href="https://github.com/dojoengine/dojo-starter" target="_blank" rel="noreferrer" className="hover:text-white">GitHub</a></li>
              </ul>
            </div>
          </div>

          <div className="mt-8">
            <div className="mx-auto max-w-6xl px-6">
              <div className="h-px w-full bg-gradient-to-r from-transparent via-white/15 to-transparent" />
              <div className="mt-4 flex flex-wrap items-center justify-between gap-3 text-white/60">
                <div>© {new Date().getFullYear()} Chance Master</div>
                <div className="flex items-center gap-4">
                  <span className="text-xs">Built with Next.js • Tailwind • Framer Motion</span>
                </div>
              </div>
            </div>
          </div>
        </footer>
      </Stack>
    </main>
  );
}

