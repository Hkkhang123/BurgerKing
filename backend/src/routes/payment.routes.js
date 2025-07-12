import express from 'express';
import momoController from '../controllers/payment.controller.js';
import dotenv from 'dotenv';
dotenv.config();


const router = express.Router();

// Route nhận IPN MoMo
router.post('/momo/ipn', momoController.momoIpn);
// Route test MoMo
router.post('/momo/test', momoController.momoTest);


export default router;