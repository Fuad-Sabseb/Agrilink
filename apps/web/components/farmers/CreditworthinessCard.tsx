'use client';

import { useState, useEffect } from 'react';
import { Card } from '../ui/Card';
import { Button } from '../ui/Button';
import { farmersApi } from '../../lib/farmers/api-client';
import type { CreditworthinessProfile } from '../../lib/farmers/types';

export function CreditworthinessCard() {
  const [profile, setProfile] = useState<CreditworthinessProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [showDetails, setShowDetails] = useState(false);
  const [showCertificate, setShowCertificate] = useState(false);

  useEffect(() => {
    farmersApi
      .getCreditworthinessProfile()
      .then((data) => {
        setProfile(data);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message || 'Could not load creditworthiness score');
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <Card>
        <div className="flex items-center justify-center py-6">
          <div className="h-6 w-6 rounded-full border-2 border-white/20 border-t-agrilink-gold animate-spin" />
        </div>
      </Card>
    );
  }

  if (error || !profile) {
    return null; // Gracefully degrade if endpoint is unavailable
  }

  const score = profile.creditScore;
  const isExcellent = score >= 80;
  const isGood = score >= 70 && score < 80;

  const scoreBadgeBg = isExcellent
    ? 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'
    : isGood
    ? 'bg-blue-500/20 text-blue-400 border border-blue-500/30'
    : 'bg-amber-500/20 text-amber-400 border border-amber-500/30';

  return (
    <>
      <Card>
        <div className="space-y-4">
          {/* Header */}
          <div className="flex items-start justify-between">
            <div>
              <div className="flex items-center gap-2">
                <span className="text-lg">💳</span>
                <h3 className="text-white font-semibold text-base">
                  Qulqullina Liqii Qonnaan Bulaa
                </h3>
              </div>
              <p className="text-xs text-white/50 mt-0.5">
                Digital Creditworthiness & Bank Eligibility (Jimma Zone)
              </p>
            </div>
            <div className={`px-2.5 py-1 rounded-full text-xs font-semibold ${scoreBadgeBg}`}>
              {profile.grade}
            </div>
          </div>

          {/* Score & Loan Banner */}
          <div className="rounded-xl bg-white/5 border border-white/10 p-4 space-y-3">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-xs uppercase tracking-wider text-white/40 font-medium">
                  Qabxii Liqii (Credit Score)
                </p>
                <div className="flex items-baseline gap-1 mt-0.5">
                  <span className="text-3xl font-extrabold text-white">{score}</span>
                  <span className="text-xs text-white/40">/ 100</span>
                </div>
              </div>
              <div className="text-right">
                <p className="text-xs uppercase tracking-wider text-white/40 font-medium">
                  Hamma Liqii Eeyyamame
                </p>
                <p className="text-lg font-bold text-agrilink-gold mt-0.5">
                  {profile.maxLoanEligibilityETB.toLocaleString()} ETB
                </p>
                <p className="text-[11px] text-white/50">{profile.riskTier}</p>
              </div>
            </div>

            {/* Score Progress Bar */}
            <div className="space-y-1">
              <div className="h-2.5 w-full bg-white/10 rounded-full overflow-hidden">
                <div
                  className={`h-full rounded-full transition-all duration-700 ${
                    isExcellent ? 'bg-emerald-400' : isGood ? 'bg-blue-400' : 'bg-amber-400'
                  }`}
                  style={{ width: `${Math.min(score, 100)}%` }}
                />
              </div>
              <div className="flex justify-between text-[10px] text-white/30 font-mono">
                <span>0 (High Risk)</span>
                <span>70 (Moderate)</span>
                <span>80 (Low Risk)</span>
                <span>100 (Prime)</span>
              </div>
            </div>
          </div>

          {/* Quick Breakdown Summary */}
          <div className="grid grid-cols-2 gap-2 text-xs">
            <div className="p-2.5 rounded-lg bg-white/[0.03] border border-white/5">
              <span className="text-white/40 text-[11px] block">Lafaa Qonnaa (Landholding)</span>
              <span className="text-white font-medium">
                {profile.scoreBreakdown.landholdingVerification.totalHectares} ha (
                {profile.scoreBreakdown.landholdingVerification.totalQadaa} Qadaa)
              </span>
              <span className="text-emerald-400 font-semibold block text-[11px] mt-0.5">
                {profile.scoreBreakdown.landholdingVerification.score}/
                {profile.scoreBreakdown.landholdingVerification.max} pts
              </span>
            </div>
            <div className="p-2.5 rounded-lg bg-white/[0.03] border border-white/5">
              <span className="text-white/40 text-[11px] block">Gamtaa (Cooperative)</span>
              <span className="text-white font-medium truncate block">
                {profile.scoreBreakdown.cooperativeMembership.cooperativeName}
              </span>
              <span className="text-emerald-400 font-semibold block text-[11px] mt-0.5">
                {profile.scoreBreakdown.cooperativeMembership.score}/
                {profile.scoreBreakdown.cooperativeMembership.max} pts
              </span>
            </div>
          </div>

          {/* Collapsible Detailed Breakdown */}
          {showDetails && (
            <div className="space-y-3 pt-2 border-t border-white/10 text-xs text-white/80">
              <h4 className="font-semibold text-white text-xs uppercase tracking-wider">
                Caasaa Qabxii (Score Breakdown):
              </h4>
              <div className="space-y-2">
                <div className="flex justify-between items-center bg-white/[0.02] p-2 rounded">
                  <div>
                    <p className="font-medium">1. Waraqaa Abbaa Qabeenyummaa Lafaa</p>
                    <p className="text-[11px] text-white/40">Verified cadastral land registry in Jimma Zone</p>
                  </div>
                  <span className="font-semibold text-emerald-400">
                    {profile.scoreBreakdown.landholdingVerification.score} / 25
                  </span>
                </div>

                <div className="flex justify-between items-center bg-white/[0.02] p-2 rounded">
                  <div>
                    <p className="font-medium">2. Tilmaama Oomishaa & Gosa Midhaanii</p>
                    <p className="text-[11px] text-white/40">
                      {profile.scoreBreakdown.cropCyclesAndYield.activePlots} active crop plots (
                      {profile.scoreBreakdown.cropCyclesAndYield.totalExpectedYieldKg.toLocaleString()} kg projected)
                    </p>
                  </div>
                  <span className="font-semibold text-emerald-400">
                    {profile.scoreBreakdown.cropCyclesAndYield.score} / 25
                  </span>
                </div>

                <div className="flex justify-between items-center bg-white/[0.02] p-2 rounded">
                  <div>
                    <p className="font-medium">3. Miseensummaa Gamtaa & Waldaa</p>
                    <p className="text-[11px] text-white/40">
                      Linked to recognized union/primary cooperative
                    </p>
                  </div>
                  <span className="font-semibold text-emerald-400">
                    {profile.scoreBreakdown.cooperativeMembership.score} / 20
                  </span>
                </div>

                <div className="flex justify-between items-center bg-white/[0.02] p-2 rounded">
                  <div>
                    <p className="font-medium">4. Galmee Gurgurtaa AgriLink</p>
                    <p className="text-[11px] text-white/40">
                      {profile.scoreBreakdown.verifiedSalesLedger.completedDeals} completed trades (
                      {profile.scoreBreakdown.verifiedSalesLedger.verifiedSalesETB.toLocaleString()} ETB)
                    </p>
                  </div>
                  <span className="font-semibold text-emerald-400">
                    {profile.scoreBreakdown.verifiedSalesLedger.score} / 20
                  </span>
                </div>

                <div className="flex justify-between items-center bg-white/[0.02] p-2 rounded">
                  <div>
                    <p className="font-medium">5. Mirkaneessa Eenyummaa</p>
                    <p className="text-[11px] text-white/40">Kebele ID & verified phone OTP</p>
                  </div>
                  <span className="font-semibold text-emerald-400">
                    {profile.scoreBreakdown.identityVerification.score} / 10
                  </span>
                </div>
              </div>

              {/* Partner Banks */}
              <div className="space-y-1.5 pt-2">
                <p className="font-semibold text-white text-xs uppercase tracking-wider">
                  Baankota Eeyyamaman (Partner Institutions):
                </p>
                <div className="space-y-1">
                  {profile.eligibleLenders.map((lender, i) => (
                    <div
                      key={i}
                      className="p-2 rounded bg-white/[0.04] border border-white/5 flex items-center justify-between"
                    >
                      <div>
                        <span className="font-medium text-white block">{lender.name}</span>
                        <span className="text-[10px] text-white/40">{lender.product}</span>
                      </div>
                      <span className="text-[10px] bg-white/10 text-white/80 px-2 py-0.5 rounded">
                        Available
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Action buttons */}
          <div className="flex gap-2 pt-1">
            <Button
              type="button"
              variant="secondary"
              onClick={() => setShowDetails(!showDetails)}
              className="text-xs flex-1"
            >
              {showDetails ? 'Cufi (Hide Details)' : 'Bal\'ina Ilaali (View Details)'}
            </Button>
            <Button
              type="button"
              onClick={() => setShowCertificate(true)}
              className="text-xs flex-1 bg-gradient-to-r from-emerald-600 to-green-600"
            >
              Waraqaa Mirkaneessaa (Certificate)
            </Button>
          </div>
        </div>
      </Card>

      {/* Digital Certificate Modal */}
      {showCertificate && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
          <div className="bg-[#1a2e22] border-2 border-agrilink-gold/50 rounded-2xl max-w-sm w-full p-6 text-white space-y-4 shadow-2xl relative">
            <button
              onClick={() => setShowCertificate(false)}
              className="absolute top-4 right-4 text-white/50 hover:text-white text-sm"
            >
              ✕
            </button>

            <div className="text-center space-y-1 border-b border-white/10 pb-3">
              <span className="text-3xl">🌿</span>
              <h3 className="font-bold text-base text-agrilink-gold">AgriLink Jimma Zone</h3>
              <p className="text-[11px] text-white/60">
                Digital Creditworthiness & Smallholder Registry Certificate
              </p>
            </div>

            <div className="space-y-2 text-xs">
              <div className="flex justify-between border-b border-white/5 pb-1">
                <span className="text-white/40">Farmer Name:</span>
                <span className="font-semibold">{profile.farmer.fullName}</span>
              </div>
              <div className="flex justify-between border-b border-white/5 pb-1">
                <span className="text-white/40">Zone / Woreda:</span>
                <span className="font-medium">{profile.farmer.location}</span>
              </div>
              <div className="flex justify-between border-b border-white/5 pb-1">
                <span className="text-white/40">Credit Score:</span>
                <span className="font-bold text-emerald-400">
                  {profile.creditScore}/100 ({profile.grade})
                </span>
              </div>
              <div className="flex justify-between border-b border-white/5 pb-1">
                <span className="text-white/40">Max Loan Limit:</span>
                <span className="font-bold text-agrilink-gold">
                  {profile.maxLoanEligibilityETB.toLocaleString()} ETB
                </span>
              </div>
              <div className="flex justify-between border-b border-white/5 pb-1">
                <span className="text-white/40">Risk Tier:</span>
                <span>{profile.riskTier}</span>
              </div>
              <div className="flex justify-between border-b border-white/5 pb-1">
                <span className="text-white/40">Verification Code:</span>
                <span className="font-mono text-agrilink-gold font-bold">
                  {profile.digitalVerificationCode}
                </span>
              </div>
            </div>

            {/* QR Simulation Box */}
            <div className="rounded-lg bg-white/5 p-3 text-center border border-dashed border-white/20">
              <div className="inline-block p-2 bg-white rounded">
                <div className="w-20 h-20 bg-slate-900 flex items-center justify-center text-[10px] text-white font-mono p-1">
                  [QR VALID: {profile.digitalVerificationCode.slice(-6)}]
                </div>
              </div>
              <p className="text-[10px] text-white/40 mt-1">
                Scannable by Sinqee, OCSSCO & Coopbank branch loan officers
              </p>
            </div>

            <Button
              type="button"
              variant="secondary"
              onClick={() => setShowCertificate(false)}
              className="w-full text-xs"
            >
              Cufi (Close)
            </Button>
          </div>
        </div>
      )}
    </>
  );
}
