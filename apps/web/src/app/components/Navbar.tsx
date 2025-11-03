'use client';

import Link from 'next/link';
import Image from 'next/image';
import ConnectWallet from './ConnectWallet';
import Logo from '../../../public/Logo.png'
import QueueButton from './QueueButton';

export default function Navbar() {
  return (
    <header className="fixed inset-x-0 top-0 z-50 w-full border-b border-white/10 bg-[#0a0b0f]/60 backdrop-blur-md">
      <div className="mx-auto flex h-14 max-w-6xl items-center justify-between px-4 sm:px-6">
        <Link href="/" className="group inline-flex items-center gap-2">
          <Image
            src={Logo}
            alt="Chance Master"
            width={48}
            height={48}
            priority
            className="opacity-90 group-hover:opacity-100"
          />
          <span className="text-sm font-semibold tracking-wide text-white/90 group-hover:text-white">
            Chance Master
          </span>
        </Link>

        <div className="flex items-center gap-2">
          <QueueButton />
          <ConnectWallet />
        </div>
      </div>
    </header>
  );
}

