import express from 'express';

const router = express.Router();

// Benchmark commodity markets strictly within Jimma Zone, Oromia
const marketData = [
  {
    id: 'MKT_JIMMA',
    name: 'Jimma Central Market',
    nameAfaanOromoo: 'Gabaa Guddaa Jimmaa',
    location: 'Jimma Town',
    zone: 'Jimma Zone',
    region: 'Oromia',
    updatedAt: new Date().toISOString(),
    prices: [
      { cropName: 'Coffee (Jimma Washed Grade 1)', pricePerUnit: 440.0, unit: 'kg', trend: '+2.5%' },
      { cropName: 'Teff (White Magna)', pricePerUnit: 95.0, unit: 'kg', trend: '+1.5%' },
      { cropName: 'Maize (White)', pricePerUnit: 40.0, unit: 'kg', trend: '0.0%' },
      { cropName: 'Potato', pricePerUnit: 25.0, unit: 'kg', trend: '+1.0%' },
      { cropName: 'Wheat (Durum)', pricePerUnit: 62.0, unit: 'kg', trend: '-1.0%' },
      { cropName: 'Tomato', pricePerUnit: 45.0, unit: 'kg', trend: '+5.0%' },
      { cropName: 'Carrot', pricePerUnit: 38.0, unit: 'kg', trend: '+0.5%' },
    ],
  },
  {
    id: 'MKT_AGARO',
    name: 'Agaro Commodity Market',
    nameAfaanOromoo: 'Gabaa Aagaaroo',
    location: 'Gomma Woreda, Agaro',
    zone: 'Jimma Zone',
    region: 'Oromia',
    updatedAt: new Date().toISOString(),
    prices: [
      { cropName: 'Coffee (Agaro Washed Specialty)', pricePerUnit: 450.0, unit: 'kg', trend: '+3.0%' },
      { cropName: 'Teff (Mixed)', pricePerUnit: 96.0, unit: 'kg', trend: '+1.0%' },
      { cropName: 'Maize', pricePerUnit: 41.5, unit: 'kg', trend: '+0.5%' },
      { cropName: 'Potato', pricePerUnit: 25.5, unit: 'kg', trend: '+1.5%' },
      { cropName: 'Wheat', pricePerUnit: 63.5, unit: 'kg', trend: '0.0%' },
      { cropName: 'Tomato', pricePerUnit: 48.0, unit: 'kg', trend: '+2.0%' },
    ],
  },
  {
    id: 'MKT_LIMMU',
    name: 'Limmu Genet Agricultural Hub',
    nameAfaanOromoo: 'Gabaa Limmuu Jannat',
    location: 'Limmu Kosa Woreda',
    zone: 'Jimma Zone',
    region: 'Oromia',
    updatedAt: new Date().toISOString(),
    prices: [
      { cropName: 'Coffee (Limmu Grade 1 Organic)', pricePerUnit: 465.0, unit: 'kg', trend: '+4.0%' },
      { cropName: 'Maize (Highland White)', pricePerUnit: 42.0, unit: 'kg', trend: '+1.2%' },
      { cropName: 'Potato', pricePerUnit: 27.0, unit: 'kg', trend: '+2.0%' },
      { cropName: 'Wheat', pricePerUnit: 64.0, unit: 'kg', trend: '+0.5%' },
    ],
  },
  {
    id: 'MKT_SEKA',
    name: 'Seka Chekorsa Market',
    nameAfaanOromoo: 'Gabaa Saqqaa Coqorsaa',
    location: 'Seka Chekorsa Woreda',
    zone: 'Jimma Zone',
    region: 'Oromia',
    updatedAt: new Date().toISOString(),
    prices: [
      { cropName: 'Teff (Seka Red & White)', pricePerUnit: 94.0, unit: 'kg', trend: '+1.0%' },
      { cropName: 'Maize', pricePerUnit: 39.5, unit: 'kg', trend: '-0.5%' },
      { cropName: 'Wheat', pricePerUnit: 61.0, unit: 'kg', trend: '0.0%' },
      { cropName: 'Potato', pricePerUnit: 24.5, unit: 'kg', trend: '+1.0%' },
    ],
  },
];

router.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    zone: 'Jimma Zone',
    count: marketData.length,
    markets: marketData,
  });
});

router.get('/:id/prices', (req, res) => {
  const market = marketData.find((m) => m.id.toLowerCase() === req.params.id.toLowerCase());
  if (!market) {
    return res.status(404).json({ success: false, error: 'Market not found in Jimma Zone' });
  }
  res.status(200).json({
    success: true,
    marketId: market.id,
    marketName: market.name,
    marketNameAfaanOromoo: market.nameAfaanOromoo,
    zone: market.zone,
    prices: market.prices,
  });
});

router.get('/prices/history', (req, res) => {
  const crop = req.query.crop || 'Coffee';
  res.status(200).json({
    success: true,
    zone: 'Jimma Zone',
    crop,
    history: [
      { month: 'May', price: 410.0 },
      { month: 'Jun', price: 420.0 },
      { month: 'Jul', price: 430.0 },
      { month: 'Aug', price: 445.0 },
      { month: 'Sep', price: 455.0 },
      { month: 'Oct', price: 465.0 },
    ],
  });
});

export default router;
