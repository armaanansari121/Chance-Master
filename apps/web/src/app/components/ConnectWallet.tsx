'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import { useAccount, useConnect, useDisconnect } from '@starknet-react/core';
import { ControllerConnector } from '@cartridge/connector';
import { toast } from 'sonner';
import Image from 'next/image';

function shortAddr(addr?: string) {
  if (!addr) return '';
  return `${addr.slice(0, 6)}…${addr.slice(-4)}`;
}

export default function ConnectWallet() {
  const { connectors, connectAsync, status } = useConnect();
  const { disconnect } = useDisconnect();
  const { address, connector } = useAccount();

  const controllerConnector = useMemo(
    () =>
      (connector as ControllerConnector) ||
      (connectors.find((c) => c instanceof ControllerConnector) as ControllerConnector | undefined),
    [connector, connectors]
  );

  const [username, setUsername] = useState<string>();
  useEffect(() => {
    let alive = true;
    (async () => {
      if (!controllerConnector || !address) {
        if (alive) setUsername(undefined);
        return;
      }
      try {
        const u = await controllerConnector.username();
        if (alive) setUsername(u ?? undefined);
      } catch {
        if (alive) setUsername(undefined);
      }
    })();
    return () => {
      alive = false;
    };
  }, [controllerConnector, address]);

  const [open, setOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const onClick = (e: MouseEvent) => {
      if (!menuRef.current?.contains(e.target as Node)) setOpen(false);
    };
    window.addEventListener('click', onClick);
    return () => window.removeEventListener('click', onClick);
  }, []);

  const onLogin = async () => {
    if (!controllerConnector) return;
    try {
      await connectAsync({ connector: controllerConnector });
    } catch (e: any) {
      console.warn('[cartridge connect] rejected', e);
      toast.error(e?.message ?? 'Login cancelled');
    }
  };

  const openInventory = async () => {
    try {
      await controllerConnector?.controller?.openProfile('inventory');
    } catch (e: any) {
      console.warn('[cartridge openProfile] rejected', e);
      toast.error(e?.message || 'Could not open Cartridge');
    }
  };

  if (!address) {
    return (
      <button
        onClick={onLogin}
        disabled={status === 'pending'}
        className="rounded-lg bg-emerald-400 px-3 py-2 text-sm font-medium text-black transition-transform hover:scale-[1.02] active:scale-[0.98]"
      >
        {status === 'pending' ? 'Connecting…' : 'Login with Cartridge'}
      </button>
    );
  }

  const mainLabel = username ?? shortAddr(address);
  const subLabel = shortAddr(address);

  return (
    <div className="relative" ref={menuRef}>
      <button
        onClick={() => setOpen((v) => !v)}
        className="flex items-center gap-2 rounded-lg border border-white/15 bg-white/[0.03] px-3 py-2 text-sm hover:bg-white/[0.06]"
        aria-expanded={open}
        aria-haspopup="menu"
      >
        <Image
          src="/cartridge.png"
          alt="Cartridge"
          width={24}
          height={24}
          className="opacity-90"
          priority
        />
        <div className="flex flex-col items-start leading-tight">
          <span className="text-white/90">{mainLabel}</span>
          <span className="text-[11px] text-white/50">{subLabel}</span>
        </div>
        <svg width="14" height="14" viewBox="0 0 24 24" className={`ml-1 opacity-70 transition-transform ${open ? 'rotate-180' : ''}`}>
          <path fill="currentColor" d="M7 10l5 5 5-5z" />
        </svg>
      </button>

      {open && (
        <div role="menu" className="absolute right-0 mt-2 w-48 rounded-lg border border-white/10 bg-[#0b1114] p-2 shadow-lg">
          <button
            className="w-full rounded-md px-3 py-2 text-left text-sm hover:bg-white/5"
            onClick={() => {
              setOpen(false);
              openInventory();
            }}
          >
            Profile
          </button>

          <div className="my-2 h-px bg-white/10" />

          <button
            className="w-full rounded-md px-3 py-2 text-left text-sm text-red-300 hover:bg-white/5"
            onClick={() => {
              setOpen(false);
              disconnect();
            }}
          >
            Disconnect
          </button>
        </div>
      )}
    </div>
  );
}

