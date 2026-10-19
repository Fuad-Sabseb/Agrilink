export function Card({
  children,
  className = '',
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div
      className={`w-full rounded-card bg-white/[0.06] border border-white/10 p-6 sm:p-8 ${className}`}
    >
      {children}
    </div>
  );
}
