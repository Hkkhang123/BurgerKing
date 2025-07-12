import express from 'express';
import momoController from '../controllers/payment.controller.js';
import { momoStatus } from '../controllers/payment.controller.js';
import dotenv from 'dotenv';
dotenv.config();


const router = express.Router();

// Route nhận IPN MoMo
router.post('/momo/ipn', momoController.momoIpn);
// Route test MoMo
router.post('/momo/test', momoController.momoTest);
// Route kiểm tra trạng thái thanh toán MoMo
router.post('/momo/status', momoStatus);


export default router;