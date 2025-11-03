// apps/web/src/app/components/Dice.tsx
'use client';

import { useEffect, useMemo } from 'react';

// Circuit: 1..6 -> pawn, knight, bishop, rook, queen, king
// UI: 0 = none (not sent to circuit)
const PIECE_GLYPHS = ['—', '♙', '♘', '♗', '♖', '♕', '♔'] as const; // index 0..6
const PIECE_LABELS = ['none', 'pawn', 'knight', 'bishop', 'rook', 'queen', 'king'] as const;

const labelFor = (v: number) => PIECE_LABELS[Math.max(0, Math.min(6, v))];

export function DiceTray({
  values,
  rolling,
  onRoll,
  title = 'Dice',
  active, // 'w' | 'b'
}: {
  values: number[]; // 0 none, 1..6 piece_type
  rolling: boolean;
  onRoll?: () => void;
  title?: string;
  active?: 'w' | 'b';
}) {
  const ring =
    active === 'w'
      ? 'ring-2 ring-emerald-400/60'
      : active === 'b'
        ? 'ring-2 ring-indigo-400/60'
        : 'ring-1 ring-white/10';

  const dot =
    active === 'w'
      ? 'bg-emerald-400'
      : active === 'b'
        ? 'bg-indigo-400'
        : 'bg-white/40';

  const who = active === 'w' ? 'White to move' : active === 'b' ? 'Black to move' : title;

  return (
    <div className={`rounded-xl border border-white/10 bg-white/[0.03] p-4 ${ring}`}>
      <div className="mb-3 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className={`h-2.5 w-2.5 rounded-full ${dot}`} />
          <div className="text-sm text-white/80">{who}</div>
        </div>
        {onRoll ? (
          <button
            onClick={onRoll}
            disabled={rolling}
            className="btn btn-primary px-3 py-1.5 text-xs"
            aria-busy={rolling}
          >
            {rolling ? 'Rolling…' : 'Roll'}
          </button>
        ) : null}
      </div>
      <div className="flex flex-wrap items-center gap-2">
        {values.map((v, i) => (
          <Die key={i} value={v} rolling={rolling} />
        ))}
      </div>
    </div>
  );
}

function Die({ value, rolling }: { value: number; rolling: boolean }) {
  const v = useMemo(() => Math.max(0, Math.min(6, Number.isFinite(value) ? value : 0)), [value]);
  const glyph = PIECE_GLYPHS[v];
  const label = labelFor(v);
  useEffect(() => { }, [rolling]);

  return (
    <div
      className={`dice-tile ${rolling ? 'animate-dice' : ''}`}
      role="img"
      aria-label={`die: ${label}`}
      title={label}
    >
      <div className="flex flex-col items-center leading-none select-none">
        <div style={{ fontSize: 22, lineHeight: 1 }}>{glyph}</div>
        <div className="dice-label">{label}</div>
      </div>
    </div>
  );
}

