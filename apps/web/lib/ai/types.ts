export interface AIChatCitation {
  source: string;
  label: string;
}

export interface AIChatResponse {
  success: boolean;
  response: string;
  language: 'om' | 'am' | 'en';
  intent: string;
  citations: AIChatCitation[];
  audioScript?: string;
}

export interface TreatmentInstruction {
  en: string;
  om: string;
}

export interface DiseaseDiagnosis {
  diseaseName: string;
  diseaseNameAfaanOromoo: string;
  scientificName: string;
  crop: string;
  severity: string;
  prevalenceInJimma: string;
}

export interface DiseaseTreatmentProtocol {
  cultural: TreatmentInstruction;
  organic: TreatmentInstruction;
  chemicalApproved: TreatmentInstruction;
}

export interface DiseaseScreeningResult {
  success: boolean;
  screeningId: string;
  timestamp: string;
  imageUrl?: string | null;
  confidencePercentage: number;
  diagnosis: DiseaseDiagnosis;
  symptoms: TreatmentInstruction;
  treatmentProtocol: DiseaseTreatmentProtocol;
  recommendedResistantVarieties: {
    institute: string;
    cultivars: string;
  };
  audioReadout: {
    afaanOromoo: string;
    english: string;
  };
}

export interface AgriKnowledgeTopic {
  id: string;
  topicId: string;
  crop: string;
  cropAfaanOromoo: string;
  category: 'plant_pathology' | 'soil_and_agronomy' | 'seasonal_calendar' | 'market_and_credit';
  title: string;
  titleAfaanOromoo: string;
  scientificName?: string;
  keywords: string[];
  symptoms?: {
    en: string;
    om: string;
  };
  prevalenceInJimma: string;
  recommendedVarieties: string;
  treatmentProtocol?: {
    culturalEn?: string;
    culturalOm?: string;
    organicEn?: string;
    organicOm?: string;
    chemicalApprovedEn?: string;
    chemicalApprovedOm?: string;
  };
  prevention?: {
    en: string;
    om: string;
  };
  confidenceBaseline: number;
  isVerifiedByJARC: boolean;
}

export interface ChatMessage {
  id: string;
  sender: 'user' | 'assistant';
  text: string;
  timestamp: string;
  language?: 'om' | 'am' | 'en';
  intent?: string;
  citations?: AIChatCitation[];
  audioScript?: string;
  screeningResult?: DiseaseScreeningResult;
}
