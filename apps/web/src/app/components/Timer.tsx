// apps/web/src/app/components/Timer.tsx
'use client';

import { useEffect, useRef, useState } from 'react';

type Accent = 'white' | 'black' | undefined;

export default function Timer({
  label,
  initial,
  running,
  invert = false,
  onTimeout,
  accent,            // 'white' -> emerald ring, 'black' -> purple ring
}: {
  label: string;
  initial: number;
  running: boolean;
  invert?: boolean;
  onTimeout?: () => void;
  accent?: Accent;
}) {
  const [ms, setMs] = useState(initial);
  const last = useRef<number | null>(null);

  // keep ms in sync when parent sends a new initial value
  useEffect(() => { setMs(initial); }, [initial]);

  useEffect(() => {
    if (!running) { last.current = null; return; }
    let id = 0;
    const raf = () => {
      const now = performance.now();
      if (last.current != null) {
        const delta = now - last.current;
        setMs((v) => {
          const nv = Math.max(0, v - delta);
          if (nv === 0 && onTimeout) onTimeout();
          return nv;
        });
      }
      last.current = now;
      id = requestAnimationFrame(raf);
    };
    id = requestAnimationFrame(raf);
    return () => cancelAnimationFrame(id);
  }, [running, onTimeout]);

  const s = Math.floor(ms / 1000);
  const mm = String(Math.floor(s / 60)).padStart(2, '0');
  const ss = String(s % 60).padStart(2, '0');

  // ring only when this timer is actually running
  const ringClass =
    running && accent === 'white'
      ? 'ring-1 ring-emerald-500/60'
      : running && accent === 'black'
        ? 'ring-1 ring-purple-500/60'
        : 'ring-0';

  return (
    <div className={`glass-card p-3 ${ringClass}`}>
      <div className="text-xs text-white/60">{label}</div>
      <div className={`mt-1 font-mono text-2xl tabular-nums ${invert ? 'text-white' : 'text-white'}`}>
        {mm}:{ss}
      </div>
    </div>
  );
}

