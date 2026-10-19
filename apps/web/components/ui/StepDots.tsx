export function StepDots({
  total,
  current,
}: {
  total: number;
  current: number; // 1-indexed
}) {
  return (
    <div className="flex items-center justify-center gap-2" aria-hidden="true">
      {Array.from({ length: total }).map((_, i) => {
        const stepNumber = i + 1;
        const isActive = stepNumber === current;
        const isDone = stepNumber < current;
        return (
          <span
            key={stepNumber}
            className={`h-1.5 rounded-full transition-all duration-200 ${
              isActive
                ? 'w-6 bg-agrilink-gold'
                : isDone
                  ? 'w-2 bg-agrilink-success'
                  : 'w-2 bg-white/20'
            }`}
          />
        );
      })}
    </div>
  );
}
