'use client';

import React from 'react';

interface LiveBuyingNowPulseProps {
  location?: string;
  operatingHours?: string;
  isCompact?: boolean;
}

export function LiveBuyingNowPulse({
  location,
  operatingHours,
  isCompact = false,
}: LiveBuyingNowPulseProps) {
  if (isCompact) {
    return (
      <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[10px] font-black uppercase tracking-wider bg-emerald-500/20 text-emerald-400 border border-emerald-500/40 shadow-sm animate-pulse">
        <span className="relative flex h-2 w-2">
          <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
          <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-500" />
        </span>
        BUYING NOW
      </span>
    );
  }

  return (
    <div className="rounded-xl bg-gradient-to-r from-emerald-950/80 to-agrilink-green-dark border border-emerald-500/40 p-3 shadow-md">
      <div className="flex items-center justify-between gap-2 flex-wrap">
        <div className="flex items-center gap-2">
          <span className="relative flex h-3 w-3">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
            <span className="relative inline-flex rounded-full h-3 w-3 bg-emerald-500" />
          </span>
          <span className="text-xs font-black tracking-wider text-emerald-300 uppercase">
            🟢 AMMA GURGURATAA JIRA · BUYING NOW TODAY
          </span>
        </div>

        {operatingHours && (
          <span className="text-[11px] font-mono text-emerald-200/80 bg-emerald-900/50 px-2 py-0.5 rounded">
            🕒 {operatingHours}
          </span>
        )}
      </div>

      {location && (
        <div className="mt-1.5 text-xs text-white/90 flex items-center gap-1.5">
          <span className="text-emerald-400">📍</span>
          <span className="font-medium text-emerald-100">{location}</span>
        </div>
      )}
    </div>
  );
}
