import { Inspection } from '../models/Inspection.js';

export class InspectionController {
  /**
   * List inspections (filtered by woreda, status, or targetType)
   */
  static async listInspections(req, res, next) {
    try {
      const { woreda, status, targetType, officerId } = req.query;
      const query = {};

      if (woreda) query.woredaName = new RegExp(woreda, 'i');
      if (status) query.status = status;
      if (targetType) query.targetType = targetType;
      if (officerId) query.officerId = officerId;

      const inspections = await Inspection.find(query).sort({ checkInTime: -1 });

      return res.status(200).json({
        success: true,
        count: inspections.length,
        inspections: inspections.map((i) => i.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Create new inspection
   */
  static async createInspection(req, res, next) {
    try {
      const {
        woredaName,
        targetType,
        cooperativeName,
        farmName,
        type,
        notes,
      } = req.body;

      if (!woredaName || !targetType) {
        return res.status(400).json({
          success: false,
          error: 'woredaName and targetType are required',
        });
      }

      const inspection = await Inspection.create({
        officerId: req.user.id,
        officerName: req.user.fullName,
        woredaName,
        targetType,
        cooperativeName: targetType === 'cooperative' ? cooperativeName : null,
        farmName: targetType === 'farm' ? farmName : null,
        type: type || 'routine',
        status: 'in_progress',
        checkInTime: new Date(),
        notes: notes || '',
        findings: [],
        issueCount: 0,
      });

      return res.status(201).json({
        success: true,
        message: 'Inspection initiated successfully',
        inspection: inspection.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get inspection details
   */
  static async getInspectionById(req, res, next) {
    try {
      const inspection = await Inspection.findById(req.params.id);
      if (!inspection) {
        return res.status(404).json({
          success: false,
          error: 'Inspection not found',
        });
      }

      return res.status(200).json({
        success: true,
        inspection: inspection.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Add finding to inspection
   */
  static async addFinding(req, res, next) {
    try {
      const { title, severity, description, photoUrl } = req.body;
      const inspection = await Inspection.findById(req.params.id);

      if (!inspection) {
        return res.status(404).json({
          success: false,
          error: 'Inspection not found',
        });
      }

      if (!title) {
        return res.status(400).json({
          success: false,
          error: 'Finding title is required',
        });
      }

      const newFinding = {
        title,
        severity: severity || 'low',
        description: description || '',
        photoUrl: photoUrl || null,
        recordedAt: new Date(),
      };

      inspection.findings.push(newFinding);
      if (['high', 'critical'].includes(severity)) {
        inspection.issueCount += 1;
        inspection.status = 'flagged';
      }
      await inspection.save();

      return res.status(200).json({
        success: true,
        message: 'Finding recorded successfully',
        inspection: inspection.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Submit digital signature and complete inspection
   */
  static async submitSignature(req, res, next) {
    try {
      const { signatureUrl } = req.body;
      const inspection = await Inspection.findById(req.params.id);

      if (!inspection) {
        return res.status(404).json({
          success: false,
          error: 'Inspection not found',
        });
      }

      if (!signatureUrl) {
        return res.status(400).json({
          success: false,
          error: 'signatureUrl is required',
        });
      }

      inspection.signatureUrl = signatureUrl;
      inspection.checkOutTime = new Date();
      if (inspection.status !== 'flagged') {
        inspection.status = 'completed';
      }
      await inspection.save();

      return res.status(200).json({
        success: true,
        message: 'Inspection completed and signed',
        inspection: inspection.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }
}
