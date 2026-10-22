import { AgriAIService } from '../services/agriAIService.js';
import { AgriKnowledgeBase } from '../models/AgriKnowledgeBase.js';

export class AgriAIController {
  /**
   * Conversational Assistant chat query with RAG and Jimma guardrails
   */
  static async chatQuery(req, res, next) {
    try {
      const { query, language } = req.body;
      const farmerId = req.user?.id || 'user_farmer_abebe';

      if (!query || typeof query !== 'string' || !query.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Query string is required.',
          messageAfaanOromoo: 'Gaaffiin barbaachisaadha.',
        });
      }

      const result = await AgriAIService.processFarmerQuery({
        query: query.trim(),
        language: language || undefined,
        farmerId,
      });

      return res.status(200).json({
        success: true,
        ...result,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Flagship Image-based or symptom-based plant disease screening
   */
  static async screenDisease(req, res, next) {
    try {
      const { cropHint, diseaseHint, symptomDescription } = req.body;
      let imageUrl = req.body.imageUrl;

      if (req.file) {
        // Construct relative URL for uploaded image
        imageUrl = `/uploads/images/${req.file.filename}`;
      }

      const diagnosis = await AgriAIService.screenPlantDisease({
        imageUrl,
        cropHint,
        diseaseHint,
        symptomDescription,
      });

      return res.status(200).json({
        success: true,
        imageUrl: imageUrl || null,
        ...diagnosis,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * List agronomic & pathology topics verified by JARC
   */
  static async listKnowledgeTopics(req, res, next) {
    try {
      const { category, crop } = req.query;
      const filter = {};
      if (category) filter.category = category;
      if (crop) filter.crop = new RegExp(crop, 'i');

      const topics = await AgriKnowledgeBase.find(filter).sort({ crop: 1, topicId: 1 });

      return res.status(200).json({
        success: true,
        count: topics.length,
        knowledgeBase: topics.map((t) => t.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get single knowledge topic detail by topicId
   */
  static async getKnowledgeTopic(req, res, next) {
    try {
      const { topicId } = req.params;
      const topic = await AgriKnowledgeBase.findOne({ topicId });

      if (!topic) {
        return res.status(404).json({
          success: false,
          message: `Knowledge topic '${topicId}' not found.`,
          messageAfaanOromoo: `Mata dureen qorannoo '${topicId}' hin argamne.`,
        });
      }

      return res.status(200).json({
        success: true,
        topic: topic.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }
}
