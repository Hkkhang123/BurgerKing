import express from 'express';
import momoController from '../controllers/payment.controller.js';
import dotenv from 'dotenv';
dotenv.config();


const router = express.Router();

// Route test MoMo
router.post('/momo/test', momoController.momoTest);
// Route nhận IPN MoMo
router.post('/momo/ipn', momoController.momoIpn);

export default router;