interface AlertProps {
  variant: 'error' | 'success';
  children: React.ReactNode;
}

export function Alert({ variant, children }: AlertProps) {
  const styles =
    variant === 'error'
      ? 'bg-agrilink-error/15 border-agrilink-error/40 text-red-200'
      : 'bg-agrilink-success/15 border-agrilink-success/40 text-green-200';

  return (
    <div
      role={variant === 'error' ? 'alert' : 'status'}
      className={`rounded-2xl border px-4 py-3 text-sm ${styles}`}
    >
      {children}
    </div>
  );
}
