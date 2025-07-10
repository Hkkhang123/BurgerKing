import express from 'express';
import {
  createMomoPayment,
  createVNPayUrl,
  momoNotify,
  vnpayReturn
} from '../controllers/payment.controller.js';

const router = express.Router();

router.post('/momo', createMomoPayment);
router.post('/vnpay', createVNPayUrl);
router.post('/momo/notify', momoNotify);
router.get('/vnpay/return', vnpayReturn);

export default router;