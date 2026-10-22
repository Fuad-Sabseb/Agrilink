import { Produce } from '../models/Produce.js';

export class ProduceController {
  /**
   * Create a new produce listing (Farmer)
   */
  static async createProduce(req, res, next) {
    try {
      const {
        cropName,
        cropType,
        quantity,
        unit,
        pricePerUnit,
        currency,
        description,
        location,
        woreda,
        qualityGrade,
        harvestDate,
        images,
      } = req.body;

      if (!cropName || !cropType || !quantity || !pricePerUnit) {
        return res.status(400).json({
          success: false,
          error: 'cropName, cropType, quantity, and pricePerUnit are required',
        });
      }

      const produce = await Produce.create({
        farmerId: req.user.id,
        farmerName: req.user.fullName,
        cropName,
        cropType,
        quantity,
        unit: unit || 'kg',
        pricePerUnit,
        currency: currency || 'ETB',
        description: description || '',
        location: location || req.user.location,
        woreda: woreda || req.user.woreda,
        qualityGrade: qualityGrade || 'Grade 1',
        harvestDate: harvestDate || new Date(),
        images: images || [],
        status: 'available',
      });

      return res.status(201).json({
        success: true,
        message: 'Produce listed successfully',
        produce: produce.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * List produce with multi-criteria search and filters
   */
  static async listProduce(req, res, next) {
    try {
      const { search, cropType, location, woreda, minPrice, maxPrice, qualityGrade, farmerId, status } = req.query;

      const query = { status: status || 'available' };

      if (farmerId) {
        query.farmerId = farmerId;
      }

      if (cropType) {
        query.cropType = new RegExp(cropType, 'i');
      }

      if (location) {
        query.location = new RegExp(location, 'i');
      }

      if (woreda) {
        query.woreda = new RegExp(woreda, 'i');
      }

      if (qualityGrade) {
        query.qualityGrade = qualityGrade;
      }

      if (minPrice || maxPrice) {
        query.pricePerUnit = {};
        if (minPrice) query.pricePerUnit.$gte = parseFloat(minPrice);
        if (maxPrice) query.pricePerUnit.$lte = parseFloat(maxPrice);
      }

      if (search) {
        query.$or = [
          { cropName: new RegExp(search, 'i') },
          { cropType: new RegExp(search, 'i') },
          { description: new RegExp(search, 'i') },
          { location: new RegExp(search, 'i') },
        ];
      }

      const produceList = await Produce.find(query).sort({ createdAt: -1 });

      return res.status(200).json({
        success: true,
        count: produceList.length,
        produce: produceList.map((p) => p.toJSON()),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Get single produce by ID
   */
  static async getProduceById(req, res, next) {
    try {
      const produce = await Produce.findById(req.params.id);
      if (!produce) {
        return res.status(404).json({
          success: false,
          error: 'Produce listing not found',
        });
      }

      return res.status(200).json({
        success: true,
        produce: produce.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Update produce listing
   */
  static async updateProduce(req, res, next) {
    try {
      const produce = await Produce.findById(req.params.id);
      if (!produce) {
        return res.status(404).json({
          success: false,
          error: 'Produce listing not found',
        });
      }

      // Check ownership
      if (produce.farmerId !== req.user.id && req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          error: 'You are not authorized to update this listing',
        });
      }

      Object.assign(produce, req.body);
      await produce.save();

      return res.status(200).json({
        success: true,
        message: 'Produce listing updated successfully',
        produce: produce.toJSON(),
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * Delete produce listing
   */
  static async deleteProduce(req, res, next) {
    try {
      const produce = await Produce.findById(req.params.id);
      if (!produce) {
        return res.status(404).json({
          success: false,
          error: 'Produce listing not found',
        });
      }

      if (produce.farmerId !== req.user.id && req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          error: 'You are not authorized to delete this listing',
        });
      }

      await Produce.deleteOne({ _id: produce._id });

      return res.status(200).json({
        success: true,
        message: 'Produce listing removed successfully',
      });
    } catch (error) {
      next(error);
    }
  }
}
