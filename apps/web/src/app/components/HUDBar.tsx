function formatMs(ms: number) {
  const s = Math.max(0, Math.floor(ms / 1000));
  const m = Math.floor(s / 60);
  const sec = s % 60;
  return `${String(m).padStart(2, '0')}:${String(sec).padStart(2, '0')}`;
}

// helper: 0x-prefixed short address like 0x123456…abcd
function shortAddr(addr?: string | null, left = 6, right = 4): string {
  if (!addr) return '—';
  const raw = addr.trim();
  const has0x = /^0x/i.test(raw);
  const body = raw.replace(/^0x/i, '');
  if (body.length <= left + right) return raw; // already short
  const head = body.slice(0, left);
  const tail = body.slice(-right);
  return `${has0x ? '0x' : ''}${head}…${tail}`;
}

export function HUDBar({
  label,
  address,
  timeMs,
  accent = 'emerald', // 'emerald' | 'purple'
  live = true,
}: {
  label: string;
  address?: string | null;
  timeMs: number;
  accent?: 'emerald' | 'purple';
  live?: boolean;
}) {
  const chip =
    accent === 'emerald'
      ? 'text-emerald-300 bg-emerald-500/10 ring-1 ring-emerald-400/40'
      : 'text-purple-300 bg-purple-500/10 ring-1 ring-purple-400/40';

  const pill =
    accent === 'emerald'
      ? 'bg-emerald-400/15 text-emerald-200 ring-1 ring-emerald-400/30'
      : 'bg-purple-400/15 text-purple-200 ring-1 ring-purple-400/30';

  return (
    <div className="my-2 flex items-center justify-between rounded-xl border border-white/10 bg-white/[0.03] px-3 py-2">
      {/* left: label + address */}
      <div className="flex min-w-0 items-center gap-2">
        <span className={`h-2 w-2 rounded-full ${accent === 'emerald' ? 'bg-emerald-400' : 'bg-purple-400'}`} />
        <div className="truncate text-sm text-white/80">
          <span className="mr-2 font-medium">{label}</span>
          <span className="truncate text-white/65">{shortAddr(address)}</span>
        </div>
      </div>

      {/* right: live chip (if any) + timer */}
      <div className="flex items-center gap-2">
        {live && (
          <span className={`rounded-full px-2 py-0.5 text-[11px] ${chip}`}>live</span>
        )}
        <div className={`rounded-md px-2 py-1 font-mono text-xs tabular-nums ${pill}`}>
          {formatMs(timeMs)}
        </div>
      </div>
    </div>
  );
}

