'use client';

export default function MotionBackground() {
  return (
    <>
      <div className="pointer-events-none fixed inset-0 overflow-hidden">
        <div className="absolute inset-0 bg-[radial-gradient(60%_40%_at_50%_0%,rgba(94,234,212,0.10)_0%,transparent_60%)] animate-bg-pan" />
        <div className="absolute inset-0 bg-[radial-gradient(40%_30%_at_80%_20%,rgba(147,197,253,0.10)_0%,transparent_60%)] animate-bg-pan-slow mix-blend-screen" />
        <div className="absolute inset-0 opacity-[0.10] [background-image:radial-gradient(circle_at_20%_20%,rgba(255,255,255,0.22)_0,transparent_20%),radial-gradient(circle_at_80%_30%,rgba(255,255,255,0.18)_0,transparent_18%),radial-gradient(circle_at_60%_80%,rgba(255,255,255,0.20)_0,transparent_18%)] animate-sparkles" />
        <div className="absolute inset-0 [--ang:0deg] [mask-image:radial-gradient(60%_40%_at_50%_50%,black,transparent_70%)] bg-[conic-gradient(from_var(--ang),rgba(255,255,255,0.06),transparent_40%,rgba(255,255,255,0.06))] animate-sweep" />
      </div>

      <style jsx global>{`
        @keyframes bg-pan {
          0% { transform: translate3d(-2%, -1%, 0) scale(1.02); }
          50% { transform: translate3d(1%, 1%, 0) scale(1.035); }
          100% { transform: translate3d(-2%, -1%, 0) scale(1.02); }
        }
        @keyframes bg-pan-slow {
          0% { transform: translate3d(1%, -1%, 0) scale(1.02); }
          50% { transform: translate3d(-1%, 1%, 0) scale(1.035); }
          100% { transform: translate3d(1%, -1%, 0) scale(1.02); }
        }
        @keyframes sparkles {
          0%,100% { opacity:.08; filter:brightness(1); }
          50% { opacity:.16; filter:brightness(1.15); }
        }
        @keyframes sweep {
          0% { --ang: 0deg; opacity:.25; }
          50% { --ang: 180deg; opacity:.35; }
          100% { --ang: 360deg; opacity:.25; }
        }
        .animate-bg-pan { animation: bg-pan 12s ease-in-out infinite; }
        .animate-bg-pan-slow { animation: bg-pan-slow 20s ease-in-out infinite; }
        .animate-sparkles { animation: sparkles 7s ease-in-out infinite; }
        .animate-sweep { animation: sweep 14s linear infinite; }
      `}</style>
    </>
  );
}

