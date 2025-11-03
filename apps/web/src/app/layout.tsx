import type { Metadata } from 'next';
import './globals.css';
import { Toaster } from 'sonner';
import Navbar from './components/Navbar';
import { SparklesCore } from './components/Sparkles';
import StarknetProvider from './components/StarknetProvider';

export const metadata: Metadata = {
  title: 'Chance Master',
  description: 'Fully onchain chess with zk proofs on Starknet',
  icons: {
    icon: [{ url: '/Logo.png', type: 'image/png' }],        // favicon / tab icon
    shortcut: ['/Logo.png'],
    apple: [{ url: '/Logo.png' }],                          // iOS home screen icon (uses same file)
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="min-h-screen bg-[#0a0b0f] text-white antialiased selection:bg-white/10 selection:text-white">
        {/* existing glow layers */}
        <div className="pointer-events-none fixed inset-0 bg-[radial-gradient(60%_40%_at_50%_0%,rgba(94,234,212,0.15)_0%,transparent_60%)]" />
        <div className="pointer-events-none fixed inset-0 bg-[radial-gradient(40%_30%_at_80%_20%,rgba(147,197,253,0.12)_0%,transparent_60%)]" />
        <div className="pointer-events-none fixed inset-0 mix-blend-soft-light opacity-[0.07] [background-image:url('/window.svg')]" />

        <div className="pointer-events-none fixed inset-0 -z-10">
          <SparklesCore
            id="tsparticlesfullpage"
            background="transparent"
            minSize={0.6}
            maxSize={1.4}
            particleDensity={100}
            className="h-full w-full"
            particleColor="#FFFFFF"
          />
        </div>

        <StarknetProvider>
          <Navbar />
          <div className="h-14" />
          {children}
          <Toaster
            position="bottom-right"
            theme="dark"
            closeButton
            visibleToasts={6}
            expand={true}
            duration={5000}
            toastOptions={{
              classNames: {
                toast:
                  // glassy dark card + subtle emerald glow
                  'rounded-xl border border-white/10 ' +
                  'bg-[linear-gradient(180deg,rgba(17,27,34,0.95),rgba(11,19,24,0.92))] ' +
                  'shadow-[0_10px_30px_rgba(16,185,129,0.12)] ' +
                  'ring-1 ring-white/5 backdrop-blur-md',
                title: 'text-white/90',
                description: 'text-white/65',
                actionButton:
                  'rounded-md bg-emerald-500/15 text-emerald-300 hover:bg-emerald-500/25 ' +
                  'px-2 py-1 text-xs border border-emerald-400/20',
                cancelButton:
                  'rounded-md bg-white/5 text-white/80 hover:bg-white/10 ' +
                  'px-2 py-1 text-xs border border-white/10',
                icon: 'text-emerald-300',
                closeButton:
                  'text-white/60 hover:text-white/90 ' +
                  'hover:bg-white/5 rounded-md',
              },
            }}
          />

        </StarknetProvider>
      </body>
    </html>
  );
}

