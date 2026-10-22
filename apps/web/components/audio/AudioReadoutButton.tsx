'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useTranslation } from '../../lib/i18n/I18nContext';

interface AudioReadoutButtonProps {
  marketName: string;
  marketNameAfaanOromoo?: string;
  cropName: string;
  cropNameAfaanOromoo?: string;
  quantityKg: number;
  netRevenue: string | number;
  transportCost: string | number;
  className?: string;
}

export function AudioReadoutButton({
  marketName,
  marketNameAfaanOromoo,
  cropName,
  cropNameAfaanOromoo,
  quantityKg,
  netRevenue,
  transportCost,
  className = '',
}: AudioReadoutButtonProps) {
  const { locale, t } = useTranslation();
  const [isPlaying, setIsPlaying] = useState(false);
  const [showSubtitle, setShowSubtitle] = useState(false);
  const [spokenText, setSpokenText] = useState('');
  const utteranceRef = useRef<SpeechSynthesisUtterance | null>(null);

  // Construct localized spoken script string dynamically
  useEffect(() => {
    let script = '';
    const targetCrop = locale === 'om' ? cropNameAfaanOromoo || cropName : cropName;
    const targetMarket = locale === 'om' ? marketNameAfaanOromoo || marketName : marketName;

    if (locale === 'om') {
      script = `Gabaan filatamaan ${targetMarket} dha. ${targetCrop} kiiloo ${quantityKg} yoo gurgurtan, galii qulqulluu birrii ${netRevenue} argattu. Baasiin geejjibaa birrii ${transportCost} ta'a.`;
    } else if (locale === 'am') {
      script = `የተመረጠው ገበያ ${targetMarket} ነው። ${quantityKg} ኪሎ ${targetCrop} ሲሸጡ፣ የተጣራ ገቢ ${netRevenue} ብር ያገኛሉ። የመጓጓዣ ወጪ ${transportCost} ብር ነው።`;
    } else {
      script = `The recommended market is ${targetMarket}. For ${quantityKg} kilograms of ${targetCrop}, your estimated net take-home revenue is ${netRevenue} Birr, with estimated transport cost of ${transportCost} Birr.`;
    }

    setSpokenText(script);
  }, [locale, marketName, marketNameAfaanOromoo, cropName, cropNameAfaanOromoo, quantityKg, netRevenue, transportCost]);

  // Cleanup speech synthesis on unmount
  useEffect(() => {
    return () => {
      if (typeof window !== 'undefined' && 'speechSynthesis' in window) {
        window.speechSynthesis.cancel();
      }
    };
  }, []);

  const handlePlayToggle = () => {
    if (typeof window === 'undefined') return;

    if (isPlaying) {
      if ('speechSynthesis' in window) {
        window.speechSynthesis.cancel();
      }
      setIsPlaying(false);
      setShowSubtitle(false);
      return;
    }

    setShowSubtitle(true);

    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel(); // Stop any pending speech

      const utterance = new SpeechSynthesisUtterance(spokenText);
      utteranceRef.current = utterance;

      // Rate slightly slower (0.88x) for clear comprehension by farmers
      utterance.rate = 0.88;
      utterance.pitch = 1.0;

      // Select matching voice if available on user device
      const voices = window.speechSynthesis.getVoices();
      const langCode = locale === 'om' ? 'om' : locale === 'am' ? 'am' : 'en';
      const matchedVoice = voices.find((v) => v.lang.startsWith(langCode));
      if (matchedVoice) {
        utterance.voice = matchedVoice;
      }

      utterance.onstart = () => {
        setIsPlaying(true);
      };

      utterance.onend = () => {
        setIsPlaying(false);
        setTimeout(() => setShowSubtitle(false), 3000);
      };

      utterance.onerror = () => {
        setIsPlaying(false);
        playFallbackChime();
      };

      window.speechSynthesis.speak(utterance);
    } else {
      // Fallback for browsers without SpeechSynthesis
      playFallbackChime();
      setIsPlaying(true);
      setTimeout(() => {
        setIsPlaying(false);
        setTimeout(() => setShowSubtitle(false), 4000);
      }, 4000);
    }
  };

  // Play pleasant acoustic harmonic chime when native TTS voice is unavailable
  const playFallbackChime = () => {
    try {
      const AudioCtx =
        window.AudioContext ||
        (window as unknown as { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;
      if (AudioCtx) {
        const ctx = new AudioCtx();
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(523.25, ctx.currentTime); // C5
        osc.frequency.exponentialRampToValueAtTime(659.25, ctx.currentTime + 0.2); // E5
        gain.gain.setValueAtTime(0.15, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.4);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start();
        osc.stop(ctx.currentTime + 0.4);
      }
    } catch {
      // Ignore
    }
  };

  return (
    <div className={`relative inline-flex flex-col items-center ${className}`}>
      <button
        type="button"
        onClick={handlePlayToggle}
        className={`flex items-center gap-2 px-3 py-1.5 rounded-full text-xs font-semibold transition-all shadow-md focus:outline-none focus:ring-2 focus:ring-agrilink-gold ${
          isPlaying
            ? 'bg-agrilink-gold text-agrilink-green-dark animate-pulse shadow-agrilink-gold/30'
            : 'bg-white/10 hover:bg-white/20 text-agrilink-gold border border-agrilink-gold/40'
        }`}
        aria-label={
          isPlaying
            ? t('actions.stop', { defaultValue: 'Stop' })
            : `${t('actions.listen', { defaultValue: 'Listen' })}: ${spokenText}`
        }
        aria-pressed={isPlaying}
      >
        {isPlaying ? (
          <>
            {/* Animated Equalizer Wave */}
            <span className="flex items-center gap-0.5 h-3.5">
              <span className="w-1 bg-agrilink-green-dark h-full animate-[bounce_0.6s_ease-in-out_infinite]" />
              <span className="w-1 bg-agrilink-green-dark h-2/3 animate-[bounce_0.8s_ease-in-out_infinite]" />
              <span className="w-1 bg-agrilink-green-dark h-full animate-[bounce_0.7s_ease-in-out_infinite]" />
            </span>
            <span className="uppercase text-[10px] tracking-wider font-bold">
              {t('actions.stop', { defaultValue: 'Dhaabi' })}
            </span>
          </>
        ) : (
          <>
            {/* High-visibility Speaker Icon */}
            <svg className="w-4 h-4 text-agrilink-gold" fill="currentColor" viewBox="0 0 20 20">
              <path
                fillRule="evenodd"
                d="M9.383 3.076A1 1 0 0110 4v12a1 1 0 01-1.707.707L4.586 13H2a1 1 0 01-1-1V8a1 1 0 011-1h2.586l3.707-3.707a1 1 0 011.09-.217zM14.657 2.929a1 1 0 011.414 0A9.972 9.972 0 0119 10a9.972 9.972 0 01-2.929 7.071 1 1 0 01-1.414-1.414A7.971 7.971 0 0017 10c0-2.21-.894-4.208-2.343-5.657a1 1 0 010-1.414zm-2.829 2.828a1 1 0 011.415 0A5.983 5.983 0 0115 10a5.984 5.984 0 01-1.757 4.243 1 1 0 01-1.415-1.415A3.984 3.984 0 0013 10a3.983 3.983 0 00-1.172-2.828 1 1 0 010-1.415z"
                clipRule="evenodd"
              />
            </svg>
            <span className="font-bold text-[11px] tracking-wide">
              {t('actions.listen', { defaultValue: 'Dhaggeeffadhaa' })}
            </span>
          </>
        )}
      </button>

      {/* Synchronized accessible speech caption bubble */}
      {showSubtitle && (
        <div
          className="mt-2 p-2.5 max-w-xs rounded-xl bg-agrilink-green-dark/95 border border-agrilink-gold/40 text-[11px] text-white shadow-xl animate-in fade-in slide-in-from-top-1 text-center"
          role="status"
          aria-live="polite"
        >
          <p className="leading-snug italic text-white/90">&ldquo;{spokenText}&rdquo;</p>
        </div>
      )}
    </div>
  );
}
