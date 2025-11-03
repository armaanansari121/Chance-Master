export function EndGameDialog({
  result,
  onPlayAgain,
  onHome,
}: {
  result: string;
  onPlayAgain: () => void;
  onHome: () => void;
}) {
  return (
    <div
      className="
        fixed inset-0 z-50 grid place-items-center
        bg-black/60 backdrop-blur-md
      "
      role="dialog"
      aria-modal="true"
      aria-labelledby="endgame-title"
    >
      <div
        className="
          w-[min(92vw,420px)]
          rounded-2xl border border-white/12
          bg-[linear-gradient(180deg,rgba(17,27,34,.95),rgba(11,19,24,.92))]
          shadow-[0_20px_60px_rgba(16,185,129,.18)]
          ring-1 ring-white/5
          p-5
        "
      >
        {/* subtle emerald glow background */}
        <div
          className="
            pointer-events-none absolute inset-0 -z-10 opacity-70
            [mask-image:radial-gradient(60%_50%_at_50%_50%,#000_20%,transparent_70%)]
          "
          aria-hidden
        />

        <div className="mb-3 flex items-center gap-2">
          <span className="inline-flex h-2.5 w-2.5 rounded-full bg-emerald-400/90" />
          <h2 id="endgame-title" className="text-lg font-semibold text-white/90">
            Game Over
          </h2>
        </div>

        <p className="text-white/75">
          {result === 'Draw' ? 'Result: Draw.' : `Result: ${result} wins.`}
        </p>

        <div className="mt-5 grid grid-cols-2 gap-2">
          <button
            onClick={onPlayAgain}
            className="
              rounded-lg bg-emerald-400 px-4 py-2 text-sm font-medium text-black
              transition-transform hover:scale-[1.02] active:scale-[0.98]
            "
          >
            Play again
          </button>
          <button
            onClick={onHome}
            className="
              rounded-lg border border-white/15 bg-white/[0.04] px-4 py-2
              text-sm font-medium text-white/90 hover:bg-white/[0.08]
            "
          >
            Home
          </button>
        </div>

      </div>
    </div>
  );
}

