import express from 'express';
import { AgriAIController } from '../controllers/agriAIController.js';
import { optionalAuthenticate } from '../middleware/auth.js';
import { uploadImage } from '../middleware/upload.js';

const router = express.Router();

// 1. Conversational AI Assistant query (Afaan Oromoo first, strict RAG & guardrails)
router.post('/chat', optionalAuthenticate, AgriAIController.chatQuery);

// 2. Plant leaf disease screening (image upload or metadata cues)
router.post('/screen-disease', uploadImage.single('image'), optionalAuthenticate, AgriAIController.screenDisease);

// 3. Agronomic Knowledge Base (JARC / EIAR certified agronomy & pathology)
router.get('/knowledge', AgriAIController.listKnowledgeTopics);
router.get('/knowledge/:topicId', AgriAIController.getKnowledgeTopic);

export default router;
