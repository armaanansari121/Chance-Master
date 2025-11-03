'use client';

type AsyncFn<T> = () => Promise<T>;

export type OptimisticOpts<T> = {
  optimistic?: boolean;
  onOptimistic?: () => void;
  onConfirm?: (res: T) => void;
  onRevert?: (err: unknown) => void;
};

export async function invokeOptimistic<T>(fn: AsyncFn<T>, opts: OptimisticOpts<T> = {}) {
  const { optimistic = true, onOptimistic, onConfirm, onRevert } = opts;
  if (optimistic) onOptimistic?.();
  try {
    const res = await fn();
    onConfirm?.(res);
    return res;
  } catch (err) {
    if (optimistic) onRevert?.(err);
    throw err;
  }
}

