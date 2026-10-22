import { authRequest } from '../auth/api-client';
import type {
  AIChatResponse,
  AgriKnowledgeTopic,
  DiseaseScreeningResult,
} from './types';

const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3001/api/v1';

export const aiApi = {
  /**
   * Conversational Assistant chat query (Afaan Oromoo first, RAG grounded)
   */
  chat: (query: string, language: 'om' | 'am' | 'en' = 'om') =>
    authRequest<AIChatResponse>('/ai/chat', {
      method: 'POST',
      body: JSON.stringify({ query, language }),
    }),

  /**
   * Image and symptom-based plant disease screening (supports JSON or multipart FormData)
   */
  screenDisease: async (payload: {
    cropHint?: string;
    diseaseHint?: string;
    symptomDescription?: string;
    imageFile?: File;
  }): Promise<DiseaseScreeningResult> => {
    if (payload.imageFile) {
      const formData = new FormData();
      formData.append('image', payload.imageFile);
      if (payload.cropHint) formData.append('cropHint', payload.cropHint);
      if (payload.diseaseHint) formData.append('diseaseHint', payload.diseaseHint);
      if (payload.symptomDescription)
        formData.append('symptomDescription', payload.symptomDescription);

      const res = await fetch(`${API_BASE_URL}/ai/screen-disease`, {
        method: 'POST',
        body: formData,
      });

      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.message || 'Disease screening failed');
      }
      return (await res.json()) as DiseaseScreeningResult;
    }

    return authRequest<DiseaseScreeningResult>('/ai/screen-disease', {
      method: 'POST',
      body: JSON.stringify({
        cropHint: payload.cropHint,
        diseaseHint: payload.diseaseHint,
        symptomDescription: payload.symptomDescription,
      }),
    });
  },

  /**
   * List agronomic & pathology topics verified by JARC
   */
  listKnowledge: (category?: string, crop?: string) => {
    const params = new URLSearchParams();
    if (category) params.append('category', category);
    if (crop) params.append('crop', crop);
    const qs = params.toString() ? `?${params.toString()}` : '';
    return authRequest<{
      success: boolean;
      count: number;
      knowledgeBase: AgriKnowledgeTopic[];
    }>(`/ai/knowledge${qs}`);
  },

  /**
   * Get single knowledge topic details
   */
  getKnowledgeTopic: (topicId: string) =>
    authRequest<{ success: boolean; topic: AgriKnowledgeTopic }>(
      `/ai/knowledge/${encodeURIComponent(topicId)}`
    ),
};
