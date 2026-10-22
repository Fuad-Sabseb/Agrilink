'use client';

import { useState, useEffect, useRef } from 'react';
import Link from 'next/link';
import { RequireAuth } from '../../../components/auth/RequireAuth';
import { Card } from '../../../components/ui/Card';
import { Button } from '../../../components/ui/Button';
import { Alert } from '../../../components/ui/Alert';
import { aiApi } from '../../../lib/ai/api-client';
import type {
  ChatMessage,
  DiseaseScreeningResult,
  AgriKnowledgeTopic,
} from '../../../lib/ai/types';

const QUICK_PROMPTS = [
  {
    label: '☕ Gatii Bunaa Jimmaa',
    prompt: 'Buna Jimmaatti meeqaan gurgurama? Gabaa kamtu caala?',
    category: 'market',
  },
  {
    label: '🚚 Geejjiba Jimma–Aggaaroo',
    prompt: 'Baasii geejjibaa fi kellaa Jimmaa irraa gara Aggaaroo meeqa?',
    category: 'logistics',
  },
  {
    label: '🛒 Bittoota Boqqolloo',
    prompt: 'Boqqolloo eenyutu bitaa jira Jimma keessatti?',
    category: 'buyer',
  },
  {
    label: '🌱 Fayyaa Biyyee Kotichaa',
    prompt: 'Fayyaa biyyee kotichaa fi diimaa akkamitti eegna?',
    category: 'soil',
  },
  {
    label: '🍂 Dhukkuba Waaqoo Bunaa',
    prompt: 'Dhukkuba waaqoo bunaa akkamitti ittisuu danda\'ama?',
    category: 'pathology',
  },
];

export default function AgriAIAssistantPage() {
  const [activeTab, setActiveTab] = useState<'chat' | 'screen' | 'knowledge'>('chat');
  const [language, setLanguage] = useState<'om' | 'am' | 'en'>('om');

  // Chat State
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: 'welcome_1',
      sender: 'assistant',
      text: "Nagaa! Ani gargaaraa teeknoolojii AgriAI ti. Waa'ee gatii gabaa Godina Jimmaa, baasii geejjibaa fi kellaa, fayyaa biyyee, fi dhukkuboota biqilaa qorannoo JARC irratti hundaayeen isin gargaara.",
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      language: 'om',
      audioScript: "Nagaa! Ani gargaaraa AgriAI ti. Waa'ee qonnaa Godina Jimmaa akkamittin isin gargaaru?",
      citations: [
        { source: 'platform_scope', label: 'Strictly Jimma Zone, Oromia Bounded' },
        { source: 'JARC_EIAR', label: 'Jimma Agricultural Research Center Verified' },
      ],
    },
  ]);
  const [inputQuery, setInputQuery] = useState('');
  const [isSending, setIsSending] = useState(false);
  const [chatError, setChatError] = useState<string | null>(null);

  // Audio Playback State
  const [activeAudioId, setActiveAudioId] = useState<string | null>(null);

  // Plant Disease Screening State
  const [selectedCropHint, setSelectedCropHint] = useState('Coffee');
  const [selectedDiseaseHint, setSelectedDiseaseHint] = useState('');
  const [symptomDescription, setSymptomDescription] = useState('');
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [screeningResult, setScreeningResult] = useState<DiseaseScreeningResult | null>(null);
  const [isScreening, setIsScreening] = useState(false);
  const [screenError, setScreenError] = useState<string | null>(null);

  // Knowledge Base State
  const [knowledgeList, setKnowledgeList] = useState<AgriKnowledgeTopic[]>([]);
  const [loadingKnowledge, setLoadingKnowledge] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');

  const chatBottomRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    chatBottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Load Knowledge base on tab change
  useEffect(() => {
    if (activeTab === 'knowledge' && knowledgeList.length === 0) {
      setLoadingKnowledge(true);
      aiApi
        .listKnowledge()
        .then((res) => {
          setKnowledgeList(res.knowledgeBase);
        })
        .catch(() => {})
        .finally(() => setLoadingKnowledge(false));
    }
  }, [activeTab, knowledgeList.length]);

  // Handle Audio Readout via Web Speech API
  const handlePlayAudio = (id: string, textToSpeak?: string) => {
    if (typeof window === 'undefined' || !('speechSynthesis' in window)) {
      alert('Audio playback is not supported on your browser.');
      return;
    }

    if (activeAudioId === id) {
      window.speechSynthesis.cancel();
      setActiveAudioId(null);
      return;
    }

    window.speechSynthesis.cancel();
    if (!textToSpeak) return;

    const utterance = new SpeechSynthesisUtterance(textToSpeak);
    utterance.lang = language === 'om' ? 'om-ET' : language === 'am' ? 'am-ET' : 'en-US';
    utterance.rate = 0.95;

    utterance.onend = () => setActiveAudioId(null);
    utterance.onerror = () => setActiveAudioId(null);

    setActiveAudioId(id);
    window.speechSynthesis.speak(utterance);
  };

  // Submit Chat Query
  const handleSendChat = async (queryText?: string) => {
    const q = (queryText || inputQuery).trim();
    if (!q || isSending) return;

    const userMsg: ChatMessage = {
      id: `usr_${Date.now()}`,
      sender: 'user',
      text: q,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    };

    setMessages((prev) => [...prev, userMsg]);
    setInputQuery('');
    setChatError(null);
    setIsSending(true);

    try {
      const res = await aiApi.chat(q, language);
      const aiMsg: ChatMessage = {
        id: `ai_${Date.now()}`,
        sender: 'assistant',
        text: res.response,
        timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        language: res.language,
        intent: res.intent,
        citations: res.citations,
        audioScript: res.audioScript,
      };
      setMessages((prev) => [...prev, aiMsg]);
    } catch (err: unknown) {
      setChatError((err as Error).message || 'Failed to receive AI advisory.');
    } finally {
      setIsSending(false);
    }
  };

  // Handle Image Selection for Screening
  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setImageFile(file);
      setImagePreview(URL.createObjectURL(file));
      setScreenError(null);
    }
  };

  // Submit Disease Screening
  const handleScreenDisease = async () => {
    setIsScreening(true);
    setScreenError(null);
    setScreeningResult(null);

    try {
      const result = await aiApi.screenDisease({
        cropHint: selectedCropHint,
        diseaseHint: selectedDiseaseHint,
        symptomDescription,
        imageFile: imageFile || undefined,
      });
      setScreeningResult(result);
    } catch (err: unknown) {
      setScreenError((err as Error).message || 'Error occurred while screening disease.');
    } finally {
      setIsScreening(false);
    }
  };

  const filteredKnowledge =
    selectedCategory === 'all'
      ? knowledgeList
      : knowledgeList.filter((k) => k.category === selectedCategory);

  return (
    <RequireAuth>
      <div className="min-h-screen bg-stone-950 text-stone-100 flex flex-col">
        {/* Navigation Header */}
        <header className="border-b border-stone-800 bg-stone-900/90 backdrop-blur sticky top-0 z-30 px-4 py-3">
          <div className="max-w-4xl mx-auto flex items-center justify-between">
            <div className="flex items-center gap-3">
              <Link
                href="/app"
                className="text-stone-400 hover:text-stone-200 text-sm flex items-center gap-1 transition"
              >
                <span>←</span>
                <span className="hidden sm:inline">Dashboard</span>
              </Link>
              <div className="h-4 w-px bg-stone-700" />
              <div>
                <h1 className="font-bold text-white text-base sm:text-lg flex items-center gap-2">
                  <span>🤖</span>
                  <span>AgriAI Jimma</span>
                  <span className="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 rounded-full bg-emerald-900/50 text-emerald-400 border border-emerald-700/50">
                    Grounded RAG
                  </span>
                </h1>
                <p className="text-xs text-stone-400 hidden sm:block">
                  Afaan Oromoo • JARC Verified • Exclusively Jimma Zone
                </p>
              </div>
            </div>

            {/* Language Switcher */}
            <div className="flex items-center gap-1 bg-stone-800 p-1 rounded-lg border border-stone-700 text-xs font-medium">
              <button
                onClick={() => setLanguage('om')}
                className={`px-2.5 py-1 rounded transition ${
                  language === 'om'
                    ? 'bg-amber-600 text-white font-bold'
                    : 'text-stone-400 hover:text-stone-200'
                }`}
              >
                Oromoo
              </button>
              <button
                onClick={() => setLanguage('am')}
                className={`px-2.5 py-1 rounded transition ${
                  language === 'am'
                    ? 'bg-amber-600 text-white font-bold'
                    : 'text-stone-400 hover:text-stone-200'
                }`}
              >
                አማርኛ
              </button>
              <button
                onClick={() => setLanguage('en')}
                className={`px-2.5 py-1 rounded transition ${
                  language === 'en'
                    ? 'bg-amber-600 text-white font-bold'
                    : 'text-stone-400 hover:text-stone-200'
                }`}
              >
                English
              </button>
            </div>
          </div>

          {/* Module Tab Switcher */}
          <div className="max-w-4xl mx-auto mt-3 flex items-center gap-2 border-t border-stone-800/80 pt-2">
            <button
              onClick={() => setActiveTab('chat')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition ${
                activeTab === 'chat'
                  ? 'bg-amber-500/20 text-amber-300 border border-amber-500/40'
                  : 'text-stone-400 hover:text-stone-200 hover:bg-stone-800/60'
              }`}
            >
              <span>💬</span>
              <span>Gaaffii & Deebii (AI Chat)</span>
            </button>
            <button
              onClick={() => setActiveTab('screen')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition ${
                activeTab === 'screen'
                  ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/40'
                  : 'text-stone-400 hover:text-stone-200 hover:bg-stone-800/60'
              }`}
            >
              <span>🔬</span>
              <span>Qorannoo Dhukkubaa (Leaf Screen)</span>
            </button>
            <button
              onClick={() => setActiveTab('knowledge')}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition ${
                activeTab === 'knowledge'
                  ? 'bg-cyan-500/20 text-cyan-300 border border-cyan-500/40'
                  : 'text-stone-400 hover:text-stone-200 hover:bg-stone-800/60'
              }`}
            >
              <span>📚</span>
              <span>Beekumsa JARC (Agronomy)</span>
            </button>
          </div>
        </header>

        {/* Main Content Area */}
        <main className="flex-1 max-w-4xl w-full mx-auto p-4 flex flex-col">
          {/* TAB 1: Conversational AI Chat */}
          {activeTab === 'chat' && (
            <div className="flex-1 flex flex-col justify-between h-[calc(100vh-175px)]">
              {/* Strict Jimma Zone Shield Notification */}
              <div className="bg-amber-950/30 border border-amber-800/50 rounded-xl px-3 py-2 mb-3 flex items-center justify-between text-xs text-amber-300">
                <div className="flex items-center gap-2">
                  <span className="text-base">🛡️</span>
                  <span>
                    <strong>Eegumsa Dhugaa:</strong> AgriAI gabaa fi qonna Godina Jimmaa qofa irratti hundaaye odeeffannoo dhugaa kenna.
                  </span>
                </div>
                <span className="text-[10px] text-amber-400/80 bg-amber-900/60 px-2 py-0.5 rounded font-mono">
                  Jimma Zone Only
                </span>
              </div>

              {/* Chat Messages Stream */}
              <div className="flex-1 overflow-y-auto space-y-4 pr-1 pb-4">
                {messages.map((msg) => (
                  <div
                    key={msg.id}
                    className={`flex flex-col ${
                      msg.sender === 'user' ? 'items-end' : 'items-start'
                    }`}
                  >
                    <div
                      className={`max-w-[88%] sm:max-w-[80%] rounded-2xl px-4 py-3 shadow-md ${
                        msg.sender === 'user'
                          ? 'bg-amber-600 text-white rounded-br-none'
                          : 'bg-stone-900 border border-stone-800 text-stone-100 rounded-bl-none'
                      }`}
                    >
                      {/* Assistant Header & Audio Button */}
                      {msg.sender === 'assistant' && (
                        <div className="flex items-center justify-between border-b border-stone-800 pb-2 mb-2 text-xs text-stone-400">
                          <span className="flex items-center gap-1.5 font-semibold text-emerald-400">
                            <span>🌱</span> AgriAI Assistant
                          </span>
                          <button
                            onClick={() =>
                              handlePlayAudio(msg.id, msg.audioScript || msg.text)
                            }
                            title="Sagalee dhaggeeffadhaa (Listen)"
                            className={`flex items-center gap-1 px-2 py-0.5 rounded transition ${
                              activeAudioId === msg.id
                                ? 'bg-amber-500 text-stone-950 font-bold animate-pulse'
                                : 'bg-stone-800 hover:bg-stone-700 text-stone-300'
                            }`}
                          >
                            <span>{activeAudioId === msg.id ? '🔊 Tapha...' : '🔈 Sagalee'}</span>
                          </button>
                        </div>
                      )}

                      {/* Message Content */}
                      <div className="text-sm whitespace-pre-wrap leading-relaxed">
                        {msg.text}
                      </div>

                      {/* Verified Citation Chips */}
                      {msg.citations && msg.citations.length > 0 && (
                        <div className="mt-3 pt-2 border-t border-stone-800/80 flex flex-wrap gap-1.5 items-center">
                          <span className="text-[10px] text-stone-400 font-bold">Madaa (Sources):</span>
                          {msg.citations.map((c, idx) => (
                            <span
                              key={idx}
                              className="text-[10px] bg-stone-800 border border-stone-700 text-stone-300 px-2 py-0.5 rounded-full flex items-center gap-1"
                            >
                              <span className="h-1.5 w-1.5 rounded-full bg-emerald-400" />
                              <span>{c.label}</span>
                            </span>
                          ))}
                        </div>
                      )}

                      <div
                        className={`text-[10px] mt-1.5 text-right ${
                          msg.sender === 'user' ? 'text-amber-200' : 'text-stone-400'
                        }`}
                      >
                        {msg.timestamp}
                      </div>
                    </div>
                  </div>
                ))}

                {isSending && (
                  <div className="flex items-center gap-2 text-stone-400 text-xs p-2">
                    <span className="h-4 w-4 border-2 border-amber-400/40 border-t-amber-400 rounded-full animate-spin" />
                    <span>AgriAI deebii qopheessaa jira...</span>
                  </div>
                )}

                <div ref={chatBottomRef} />
              </div>

              {/* Quick Prompts Pills */}
              <div className="py-2 flex items-center gap-2 overflow-x-auto text-xs no-scrollbar">
                <span className="text-[10px] uppercase font-bold text-stone-400 shrink-0">
                  Gaaffilee:
                </span>
                {QUICK_PROMPTS.map((qp, idx) => (
                  <button
                    key={idx}
                    onClick={() => handleSendChat(qp.prompt)}
                    className="shrink-0 bg-stone-900 hover:bg-stone-800 border border-stone-800 text-stone-300 px-3 py-1 rounded-full transition"
                  >
                    {qp.label}
                  </button>
                ))}
              </div>

              {/* Chat Input Bar */}
              <div className="mt-2 bg-stone-900 border border-stone-800 rounded-xl p-2 flex items-center gap-2">
                <input
                  type="text"
                  value={inputQuery}
                  onChange={(e) => setInputQuery(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSendChat()}
                  placeholder={
                    language === 'om'
                      ? 'Gaaffii keessan asitti barreessaa (fkn: Buna, Geejjiba, Biyyee)...'
                      : 'Ask AgriAI about Jimma prices, transport tariffs, disease...'
                  }
                  className="flex-1 bg-transparent px-3 py-2 text-sm text-stone-100 placeholder-stone-400 focus:outline-none"
                />
                <Button
                  onClick={() => handleSendChat()}
                  disabled={!inputQuery.trim() || isSending}
                  className="bg-amber-600 hover:bg-amber-500 text-white text-xs px-4 py-2 rounded-lg font-semibold flex items-center gap-1.5"
                >
                  <span>Ergi</span>
                  <span>→</span>
                </Button>
              </div>

              {chatError && (
                <div className="mt-2">
                  <Alert variant="error">{chatError}</Alert>
                </div>
              )}
            </div>
          )}

          {/* TAB 2: Image-based Plant Disease Screening */}
          {activeTab === 'screen' && (
            <div className="space-y-6">
              <Card className="bg-stone-900 border-stone-800 p-5">
                <div className="flex items-start justify-between">
                  <div>
                    <h2 className="text-lg font-bold text-white flex items-center gap-2">
                      <span>🔬</span>
                      <span>Qorannoo Dhukkuba Biqilaa (Plant Leaf Screening)</span>
                    </h2>
                    <p className="text-xs text-stone-400 mt-1">
                      Suuraa baala biqilaa fe&apos;uun dhukkuboota akka Waaqoo Bunaa (Coffee Leaf Rust), Koolii (CBD), fi Abalbaluu (Late Blight) adda baasaa.
                    </p>
                  </div>
                  <span className="text-xs px-2.5 py-1 rounded-full bg-emerald-950 border border-emerald-800 text-emerald-400 font-semibold">
                    JARC Pathology Engine
                  </span>
                </div>

                <div className="mt-5 grid grid-cols-1 md:grid-cols-2 gap-4">
                  {/* Image Upload Area */}
                  <div className="flex flex-col">
                    <label className="text-xs font-semibold text-stone-300 mb-2">
                      1. Suuraa Baalaa Fe&apos;aa (Upload Leaf Photo)
                    </label>
                    <div className="border-2 border-dashed border-stone-700 hover:border-emerald-600 rounded-xl p-4 flex flex-col items-center justify-center text-center bg-stone-950/50 min-h-[180px] transition cursor-pointer relative">
                      {imagePreview ? (
                        <div className="relative w-full h-44 rounded-lg overflow-hidden flex items-center justify-center bg-black">
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img
                            src={imagePreview}
                            alt="Leaf Preview"
                            className="max-h-full max-w-full object-contain"
                          />
                          <button
                            onClick={() => {
                              setImageFile(null);
                              setImagePreview(null);
                            }}
                            className="absolute top-2 right-2 bg-red-600/80 hover:bg-red-600 text-white text-xs px-2 py-1 rounded-md"
                          >
                            Haqi (Remove)
                          </button>
                        </div>
                      ) : (
                        <label className="cursor-pointer flex flex-col items-center">
                          <span className="text-3xl mb-2">📸</span>
                          <span className="text-xs font-semibold text-stone-200">
                            Suuraa filadhaa ykn kaasaa
                          </span>
                          <span className="text-[10px] text-stone-400 mt-1">
                            JPG, PNG, WEBP (Max 5MB)
                          </span>
                          <input
                            type="file"
                            accept="image/*"
                            onChange={handleImageChange}
                            className="hidden"
                          />
                        </label>
                      )}
                    </div>
                  </div>

                  {/* Metadata & Symptoms Form */}
                  <div className="space-y-3">
                    <div>
                      <label className="text-xs font-semibold text-stone-300 block mb-1">
                        2. Gosa Midhaanii (Select Crop)
                      </label>
                      <select
                        value={selectedCropHint}
                        onChange={(e) => setSelectedCropHint(e.target.value)}
                        className="w-full bg-stone-950 border border-stone-700 rounded-lg px-3 py-2 text-xs text-stone-100 focus:outline-none focus:border-emerald-500"
                      >
                        <option value="Coffee">Buna (Coffee)</option>
                        <option value="Maize">Boqqolloo (Maize)</option>
                        <option value="Potato">Dinnicha (Potato)</option>
                        <option value="Tomato">Timaatima (Tomato)</option>
                        <option value="Teff">Xaafii (Teff)</option>
                        <option value="Wheat">Qamadii (Wheat)</option>
                      </select>
                    </div>

                    <div>
                      <label className="text-xs font-semibold text-stone-300 block mb-1">
                        3. Dhukkuba Shakkamu (Suspected Condition)
                      </label>
                      <select
                        value={selectedDiseaseHint}
                        onChange={(e) => setSelectedDiseaseHint(e.target.value)}
                        className="w-full bg-stone-950 border border-stone-700 rounded-lg px-3 py-2 text-xs text-stone-100 focus:outline-none focus:border-emerald-500"
                      >
                        <option value="">Waliigala Sakatta&apos;aa (Auto-Detect)</option>
                        <option value="rust">Waaqoo Baala Bunaa (Coffee Leaf Rust)</option>
                        <option value="cbd">Dhukkuba Firii Bunaa (Coffee Berry Disease)</option>
                        <option value="mln">Dhukkuba Baala Boqqolloo (Maize Lethal Necrosis)</option>
                        <option value="late blight">Abalbaluu Dinnichaa/Timaatimaa (Late Blight)</option>
                        <option value="healthy">Biqilaa Fayyaa Qabu (Healthy Crop)</option>
                      </select>
                    </div>

                    <div>
                      <label className="text-xs font-semibold text-stone-300 block mb-1">
                        4. Ibsa Mallattoolee (Observed Symptoms)
                      </label>
                      <textarea
                        value={symptomDescription}
                        onChange={(e) => setSymptomDescription(e.target.value)}
                        placeholder="Fkn: Baala jalatti buqqee keelloo-diimaa daakuu fakkaatu..."
                        rows={2}
                        className="w-full bg-stone-950 border border-stone-700 rounded-lg px-3 py-2 text-xs text-stone-100 focus:outline-none focus:border-emerald-500"
                      />
                    </div>

                    <Button
                      onClick={handleScreenDisease}
                      disabled={isScreening}
                      className="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-xs py-2.5 rounded-lg flex items-center justify-center gap-2"
                    >
                      {isScreening ? (
                        <>
                          <span className="h-4 w-4 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                          <span>Qorannoon gaggeeffamaa jira...</span>
                        </>
                      ) : (
                        <>
                          <span>🔍</span>
                          <span>Qorannoo Jalqabi (Screen Disease Now)</span>
                        </>
                      )}
                    </Button>
                  </div>
                </div>

                {screenError && (
                  <div className="mt-4">
                    <Alert variant="error">{screenError}</Alert>
                  </div>
                )}
              </Card>

              {/* Screening Output Card */}
              {screeningResult && (
                <Card className="bg-stone-900 border-emerald-700/60 p-6 space-y-6">
                  {/* Diagnosis Header */}
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-stone-800 pb-4">
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="text-2xl">🌿</span>
                        <h3 className="text-xl font-bold text-white">
                          {screeningResult.diagnosis.diseaseNameAfaanOromoo}
                        </h3>
                        <span className="text-xs text-stone-400">
                          ({screeningResult.diagnosis.diseaseName})
                        </span>
                      </div>
                      <p className="text-xs text-stone-400 italic mt-0.5 font-mono">
                        Scientific Name: {screeningResult.diagnosis.scientificName}
                      </p>
                    </div>

                    <div className="flex items-center gap-3">
                      <div className="text-right">
                        <div className="text-[10px] text-stone-400 uppercase font-semibold">
                          Qabxii Amanamummaa
                        </div>
                        <div className="text-2xl font-black text-emerald-400">
                          {screeningResult.confidencePercentage}%
                        </div>
                      </div>
                      <button
                        onClick={() =>
                          handlePlayAudio(
                            'diag_readout',
                            language === 'om'
                              ? screeningResult.audioReadout.afaanOromoo
                              : screeningResult.audioReadout.english
                          )
                        }
                        className="bg-emerald-600/20 hover:bg-emerald-600/30 text-emerald-300 border border-emerald-600/50 p-2.5 rounded-xl flex items-center gap-1.5 text-xs font-semibold"
                      >
                        <span>🔊</span>
                        <span>{activeAudioId === 'diag_readout' ? 'Dhaabi' : 'Dhaggeeffadhaa'}</span>
                      </button>
                    </div>
                  </div>

                  {/* Symptoms & Prevalence */}
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
                    <div className="bg-stone-950 p-3.5 rounded-xl border border-stone-800">
                      <div className="text-stone-400 font-semibold mb-1 flex items-center gap-1.5">
                        <span>🔍</span>
                        <span>Mallattoolee Adda Bahan (Identified Symptoms):</span>
                      </div>
                      <p className="text-stone-200 leading-relaxed">
                        {language === 'om'
                          ? screeningResult.symptoms.om
                          : screeningResult.symptoms.en}
                      </p>
                    </div>
                    <div className="bg-stone-950 p-3.5 rounded-xl border border-stone-800">
                      <div className="text-stone-400 font-semibold mb-1 flex items-center gap-1.5">
                        <span>📍</span>
                        <span>Facaatii Godina Jimmaa (Prevalence in Jimma):</span>
                      </div>
                      <p className="text-stone-200 leading-relaxed">
                        {screeningResult.diagnosis.prevalenceInJimma}
                      </p>
                    </div>
                  </div>

                  {/* Comprehensive Treatment Protocols */}
                  <div className="space-y-3">
                    <h4 className="text-sm font-bold text-white flex items-center gap-2">
                      <span>🩺</span>
                      <span>Tarkaanfii Yaalaa fi Ittisaa (Treatment Protocols)</span>
                    </h4>

                    <div className="grid grid-cols-1 md:grid-cols-3 gap-3 text-xs">
                      {/* Cultural */}
                      <div className="bg-stone-950 p-4 rounded-xl border border-stone-800 flex flex-col justify-between">
                        <div>
                          <div className="font-bold text-amber-400 mb-1 flex items-center gap-1.5">
                            <span>✂️</span>
                            <span>1. Ogummaa Aadaa (Cultural)</span>
                          </div>
                          <p className="text-stone-300 leading-relaxed mt-1">
                            {language === 'om'
                              ? screeningResult.treatmentProtocol.cultural.om
                              : screeningResult.treatmentProtocol.cultural.en}
                          </p>
                        </div>
                        <span className="text-[10px] text-stone-400 mt-2 font-mono">
                          Zero-cost agronomy
                        </span>
                      </div>

                      {/* Organic */}
                      <div className="bg-stone-950 p-4 rounded-xl border border-stone-800 flex flex-col justify-between">
                        <div>
                          <div className="font-bold text-emerald-400 mb-1 flex items-center gap-1.5">
                            <span>🍃</span>
                            <span>2. Qoricha Uumamaa (Organic)</span>
                          </div>
                          <p className="text-stone-300 leading-relaxed mt-1">
                            {language === 'om'
                              ? screeningResult.treatmentProtocol.organic.om
                              : screeningResult.treatmentProtocol.organic.en}
                          </p>
                        </div>
                        <span className="text-[10px] text-stone-400 mt-2 font-mono">
                          Bio-fungicide & ash
                        </span>
                      </div>

                      {/* Approved Chemical */}
                      <div className="bg-stone-950 p-4 rounded-xl border border-stone-800 flex flex-col justify-between">
                        <div>
                          <div className="font-bold text-cyan-400 mb-1 flex items-center gap-1.5">
                            <span>🧪</span>
                            <span>3. Keemikaala Hayyamame (MoA Approved)</span>
                          </div>
                          <p className="text-stone-300 leading-relaxed mt-1">
                            {language === 'om'
                              ? screeningResult.treatmentProtocol.chemicalApproved.om
                              : screeningResult.treatmentProtocol.chemicalApproved.en}
                          </p>
                        </div>
                        <span className="text-[10px] text-stone-400 mt-2 font-mono">
                          Registered fungicides
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Recommended JARC Resistant Varieties */}
                  <div className="bg-emerald-950/40 border border-emerald-800/80 rounded-xl p-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 text-xs">
                    <div>
                      <div className="text-emerald-300 font-bold flex items-center gap-1.5">
                        <span>🏛️</span>
                        <span>{screeningResult.recommendedResistantVarieties.institute}</span>
                      </div>
                      <p className="text-stone-300 mt-1">
                        Sanyii Filatamaa Dhibee Kan Ittisan:{' '}
                        <strong className="text-white">
                          {screeningResult.recommendedResistantVarieties.cultivars}
                        </strong>
                      </p>
                    </div>
                    <span className="text-[10px] px-2.5 py-1 rounded bg-emerald-900/60 border border-emerald-700/60 text-emerald-200 font-mono">
                      EIAR Certified
                    </span>
                  </div>
                </Card>
              )}
            </div>
          )}

          {/* TAB 3: JARC Agronomic Knowledge Base */}
          {activeTab === 'knowledge' && (
            <div className="space-y-6">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <h2 className="text-lg font-bold text-white flex items-center gap-2">
                    <span>📚</span>
                    <span>Qorannoo Qonnaa Godina Jimmaa (JARC Knowledge Base)</span>
                  </h2>
                  <p className="text-xs text-stone-400 mt-0.5">
                    Odeeffannoo qorannoo Wiirtuu Qorannoo Qonnaa Jimmaa (EIAR / JARC) mirkanaa&apos;e.
                  </p>
                </div>

                {/* Category Filter */}
                <div className="flex items-center gap-1.5 bg-stone-900 p-1 rounded-lg border border-stone-800 text-xs">
                  <button
                    onClick={() => setSelectedCategory('all')}
                    className={`px-2.5 py-1 rounded transition ${
                      selectedCategory === 'all'
                        ? 'bg-amber-600 text-white font-bold'
                        : 'text-stone-400 hover:text-stone-200'
                    }`}
                  >
                    Hunda (All)
                  </button>
                  <button
                    onClick={() => setSelectedCategory('plant_pathology')}
                    className={`px-2.5 py-1 rounded transition ${
                      selectedCategory === 'plant_pathology'
                        ? 'bg-amber-600 text-white font-bold'
                        : 'text-stone-400 hover:text-stone-200'
                    }`}
                  >
                    Dhukkuboota (Diseases)
                  </button>
                  <button
                    onClick={() => setSelectedCategory('soil_and_agronomy')}
                    className={`px-2.5 py-1 rounded transition ${
                      selectedCategory === 'soil_and_agronomy'
                        ? 'bg-amber-600 text-white font-bold'
                        : 'text-stone-400 hover:text-stone-200'
                    }`}
                  >
                    Biyyee & Qonna (Soil)
                  </button>
                </div>
              </div>

              {loadingKnowledge ? (
                <div className="flex justify-center py-12">
                  <span className="h-8 w-8 rounded-full border-2 border-stone-700 border-t-amber-400 animate-spin" />
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {filteredKnowledge.map((kb) => (
                    <Card
                      key={kb.id}
                      className="bg-stone-900 border-stone-800 p-4 space-y-3 flex flex-col justify-between"
                    >
                      <div>
                        <div className="flex items-start justify-between">
                          <div>
                            <span className="text-[10px] uppercase font-bold text-amber-400 tracking-wider">
                              {kb.cropAfaanOromoo} ({kb.crop})
                            </span>
                            <h3 className="text-base font-bold text-white mt-0.5">
                              {kb.titleAfaanOromoo}
                            </h3>
                            <p className="text-xs text-stone-400 font-mono">
                              {kb.scientificName || kb.title}
                            </p>
                          </div>
                          <span className="text-[10px] bg-emerald-950 border border-emerald-800 text-emerald-400 px-2 py-0.5 rounded-full font-semibold">
                            JARC Verified
                          </span>
                        </div>

                        <div className="mt-3 text-xs text-stone-300 space-y-1.5">
                          <div>
                            <strong className="text-stone-400">Mallattoo (Symptoms): </strong>
                            <span>{kb.symptoms?.om || kb.symptoms?.en}</span>
                          </div>
                          <div>
                            <strong className="text-stone-400">Facaatii (Location): </strong>
                            <span>{kb.prevalenceInJimma}</span>
                          </div>
                          <div>
                            <strong className="text-stone-400">Sanyii Filatamaa: </strong>
                            <span className="text-emerald-300">{kb.recommendedVarieties}</span>
                          </div>
                        </div>
                      </div>

                      <div className="pt-2 border-t border-stone-800/80 flex items-center justify-between text-xs">
                        <span className="text-[10px] text-stone-400">
                          Baseline: {Math.round(kb.confidenceBaseline * 100)}%
                        </span>
                        <button
                          onClick={() => {
                            setActiveTab('chat');
                            handleSendChat(`Waa'ee ${kb.titleAfaanOromoo} bal'inaan naaf ibsi.`);
                          }}
                          className="text-amber-400 hover:text-amber-300 font-medium flex items-center gap-1"
                        >
                          <span>AI Gaafadhaa</span>
                          <span>→</span>
                        </button>
                      </div>
                    </Card>
                  ))}
                </div>
              )}
            </div>
          )}
        </main>
      </div>
    </RequireAuth>
  );
}
