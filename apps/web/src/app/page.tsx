'use client';

import Link from 'next/link';
import Image from 'next/image';
import { motion, type Transition } from 'framer-motion';

const spring: Transition = { type: 'spring', stiffness: 260, damping: 26 };

function Section({ children, delay = 0 }: { children: React.ReactNode; delay?: number }) {
  return (
    <motion.section
      initial={{ y: 12, opacity: 0 }}
      whileInView={{ y: 0, opacity: 1 }}
      viewport={{ once: true, amount: 0.2 }}
      transition={{ ...spring, delay }}
      className="w-full"
    >
      {children}
    </motion.section>
  );
}

function Feature({ icon, title, desc, i = 0 }: { icon: string; title: string; desc: string; i?: number }) {
  return (
    <motion.div
      initial={{ y: 10, opacity: 0 }}
      whileInView={{ y: 0, opacity: 1 }}
      viewport={{ once: true, amount: 0.3 }}
      transition={{ ...spring, delay: 0.1 * i }}
      className="rounded-xl border border-white/10 bg-white/[0.03] p-4 text-left"
    >
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
    <div className="container mx-auto max-w-6xl px-6 py-14 sm:py-20 space-y-8 sm:space-y-10">
      {children}
    </div>
  );
}

export default function Home() {
  return (
    <main className="relative">
      <Stack>
        <Section>
          <div className="flex flex-col items-center gap-8 text-center">
            <div className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-3 py-1 text-xs text-white/70">
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-400/80" />
              Starknet • zk-powered dice chess
            </div>

            <motion.h1
              className="text-balance bg-gradient-to-b from-white to-white/70 bg-clip-text font-semibold leading-tight text-transparent text-5xl sm:text-6xl md:text-7xl"
              layout
              transition={spring}
            >
              Chance Master
            </motion.h1>

            <p className="text-pretty max-w-2xl text-white/70">
              Play dice chess on Starknet. Every move is proven with zero-knowledge proofs and verified on-chain — fast
              updates, sponsored gas, no wallet drama.
            </p>

            <div className="flex flex-wrap items-center justify-center gap-3">
              <Link
                href="/chess"
                className="rounded-lg bg-emerald-400 px-5 py-3 text-sm font-medium text-black transition-transform hover:scale-[1.02] active:scale-[0.98]"
              >
                Play now
              </Link>
              <a
                href="https://github.com/dojoengine/dojo-starter"
                target="_blank"
                rel="noreferrer"
                className="rounded-lg border border-white/15 bg-white/[0.03] px-5 py-3 text-sm font-medium text-white/90 hover:bg-white/[0.06]"
              >
                Docs / Repo
              </a>
            </div>

            <div className="mt-10 grid w-full grid-cols-1 gap-4 sm:grid-cols-3">
              <Feature icon="/globe.svg" title="Gas-sponsored" desc="AVNU-style paymaster accounts. Smooth on testnet." i={0} />
              <Feature icon="/file.svg" title="Proved moves" desc="Groth16 zk-SNARKs checked on Starknet for every move." i={1} />
              <Feature icon="/window.svg" title="Live sync" desc="Torii + websockets for instant board updates." i={2} />
            </div>

            <motion.div
              initial={{ scale: 0.98, opacity: 0 }}
              whileInView={{ scale: 1, opacity: 1 }}
              viewport={{ once: true, amount: 0.3 }}
              transition={{ ...spring, delay: 0.1 }}
              className="relative mt-12 w-full overflow-hidden rounded-2xl border border-white/10 bg-white/[0.02] p-3"
            >
              <div className="rounded-xl bg-gradient-to-b from-white/5 to-transparent p-3">
                <div className="aspect-[16/9] w-full rounded-lg bg-[linear-gradient(90deg,transparent_49%,rgba(255,255,255,0.05)_50%,transparent_51%),linear-gradient(transparent_49%,rgba(255,255,255,0.05)_50%,transparent_51%)] bg-[size:40px_40px]">
                  <div className="flex h-full items-center justify-center text-white/50">
                    <span className="rounded-md border border-white/10 bg-black/30 px-3 py-1 text-xs">Screenshot placeholder</span>
                  </div>
                </div>
              </div>
            </motion.div>
          </div>
        </Section>

        <Section delay={0.05}>
          <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-6 sm:p-8">
            <h2 className="mb-3 text-xl font-semibold">What is dice chess?</h2>
            <p className="text-white/70">
              A chess variant where dice decide which pieces are allowed to move. You roll three d6 each turn; faces map to piece types:
              1 pawn, 2 knight, 3 bishop, 4 rook, 5 queen, 6 king. Move any one piece whose type appears. If none can move, wait for a usable roll.
            </p>
            <div className="mt-4 grid gap-2 text-sm text-white/70 sm:grid-cols-2">
              <div className="rounded-lg border border-white/10 bg-white/[0.02] p-3">• Doubles/triples just improve odds.</div>
              <div className="rounded-lg border border-white/10 bg-white/[0.02] p-3">• Standard chess rules apply; promotion to queen.</div>
            </div>
            <p className="mt-3 text-xs text-white/50">Dice-chess variants differ; we use the three-dice mapping above.</p>
          </div>
        </Section>

        <Section delay={0.08}>
          <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-6 sm:p-8">
            <h2 className="mb-3 text-xl font-semibold">How to play</h2>
            <ol className="space-y-3 text-left text-white/80">
              <li><span className="font-medium text-white">1. Roll the dice.</span> Three results enable piece types for this turn.</li>
              <li><span className="font-medium text-white">2. Make a legal move.</span> Move a rolled type; we generate a zk-proof.</li>
              <li><span className="font-medium text-white">3. Verify on-chain.</span> Proofs are verified on Starknet; board updates instantly.</li>
              <li><span className="font-medium text-white">4. No legal piece?</span> Skip action until a usable roll appears.</li>
            </ol>

            <div className="mt-6 rounded-xl border border-white/10 bg-black/20 p-4">
              <h3 className="mb-2 text-sm font-semibold text-white/90">Claims system</h3>
              <ul className="mt-2 list-disc space-y-1 pl-5 text-sm text-white/70">
                <li><span className="text-white">Claim Checkmate</span> — assert mate; opponent accepts or challenges.</li>
                <li><span className="text-white">Claim Stalemate</span> — assert no legal moves without check.</li>
                <li><span className="text-white">Adjudication</span> — resolve disputes from proofs and move history.</li>
              </ul>
            </div>
          </div>
        </Section>

        <Section delay={0.1}>
          <div className="rounded-2xl border border-white/10 bg-white/[0.03] p-6 sm:p-8">
            <h2 className="mb-3 text-xl font-semibold">Under the hood</h2>
            <div className="grid gap-4 sm:grid-cols-3">
              <div className="rounded-lg border border-white/10 bg-white/[0.02] p-3">
                <div className="text-sm font-medium text-white/90">zk-proofs</div>
                <p className="mt-1 text-sm text-white/70">Each move produces a succinct Groth16 proof of a valid transition.</p>
              </div>
              <div className="rounded-lg border border-white/10 bg-white/[0.02] p-3">
                <div className="text-sm font-medium text-white/90">On-chain verify</div>
                <p className="mt-1 text-sm text-white/70">Proofs verify on Starknet for tamper-evident state.</p>
              </div>
              <div className="rounded-lg border border-white/10 bg-white/[0.02] p-3">
                <div className="text-sm font-medium text-white/90">Live UX</div>
                <p className="mt-1 text-sm text-white/70">Torii + websockets for instant updates; paymasters for smooth gas.</p>
              </div>
            </div>
          </div>
        </Section>

        <footer className="grid grid-cols-1 items-center gap-4 border-t border-white/10 py-6 text-sm text-white/60 sm:grid-cols-3">
          <div className="flex items-center gap-2">
            <Image src="/vercel.svg" alt="" width={16} height={16} className="opacity-60 invert" />
            <span>Next.js + Tailwind</span>
          </div>
          <div className="text-center">© {new Date().getFullYear()} Chance Master</div>
          <div className="flex justify-end gap-4">
            <a href="https://x.com/ohayo_dojo" target="_blank" rel="noreferrer" className="hover:text-white">X</a>
            <a href="https://discord.gg/FB2wR6uF" target="_blank" rel="noreferrer" className="hover:text-white">Discord</a>
            <a href="https://github.com/dojoengine/dojo-starter" target="_blank" rel="noreferrer" className="hover:text-white">GitHub</a>
          </div>
        </footer>
      </Stack>
    </main>
  );
}

