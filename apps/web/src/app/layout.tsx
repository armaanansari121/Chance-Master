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
    icon: [{ url: '../../public/Logo.png', type: 'image/png' }],        // favicon / tab icon
    shortcut: ['../../public/Logo.png'],
    apple: [{ url: '../../public/Logo.png' }],                          // iOS home screen icon (uses same file)
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
          <Toaster richColors position="bottom-right" closeButton />
        </StarknetProvider>
      </body>
    </html>
  );
}

