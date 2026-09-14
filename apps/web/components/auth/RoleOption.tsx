'use client';

interface RoleOptionProps {
  label: string;
  description: string;
  icon: React.ReactNode;
  selected: boolean;
  onSelect: () => void;
}

export function RoleOption({
  label,
  description,
  icon,
  selected,
  onSelect,
}: RoleOptionProps) {
  return (
    <button
      type="button"
      onClick={onSelect}
      aria-pressed={selected}
      className={`w-full flex items-center gap-4 rounded-card border px-4 py-4 text-left transition-colors ${
        selected
          ? 'border-agrilink-gold bg-agrilink-gold/10'
          : 'border-white/15 bg-white/[0.04] hover:bg-white/[0.07]'
      }`}
    >
      <span
        className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-full text-lg ${
          selected
            ? 'bg-agrilink-gold text-agrilink-green-dark'
            : 'bg-white/10 text-white'
        }`}
      >
        {icon}
      </span>
      <span>
        <span className="block font-semibold text-white">{label}</span>
        <span className="block text-xs text-white/60">{description}</span>
      </span>
    </button>
  );
}
