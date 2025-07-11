import express from 'express';
import {
  createMomoPayment,
  momoNotify,
} from '../controllers/payment.controller.js';

const router = express.Router();
const axios = require('axios');

// PayPal credentials
const paypalClientId = 'AaCon4otj5OlvQ3oM1jMCtwD_ASY3KUOkSy0XqkZSuXZr-d85CllgKALdNK5nbo2p5VDPhcAck8PnIWC';
const paypalSecret = 'EOki27cTpRUAYLlx82G1wxPG3SP8tszvCpcAZasDcHGndL3aByX4lx1qhIiUAvXc4vomhnOFKxyUWLsw';
const paypalBase = 'https://api-m.sandbox.paypal.com'; // Sandbox for testing

// Get PayPal access token
async function getPaypalAccessToken() {
  const response = await axios({
    url: paypalBase + '/v1/oauth2/token',
    method: 'post',
    headers: {
      'Accept': 'application/json',
      'Accept-Language': 'en_US',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    auth: {
      username: paypalClientId,
      password: paypalSecret,
    },
    data: 'grant_type=client_credentials',
  });
  return response.data.access_token;
}

// POST /api/payment/paypal
router.post('/paypal', async (req, res) => {
  try {
    const { amount, currency, returnUrl, cancelUrl } = req.body;
    const accessToken = await getPaypalAccessToken();
    const order = await axios({
      url: paypalBase + '/v2/checkout/orders',
      method: 'post',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`,
      },
      data: {
        intent: 'CAPTURE',
        purchase_units: [{
          amount: {
            currency_code: currency || 'USD',
            value: amount || '1.00',
          },
        }],
        application_context: {
          return_url: returnUrl || 'https://your-app.com/paypal/return',
          cancel_url: cancelUrl || 'https://your-app.com/paypal/cancel',
        },
      },
    });
    const approve = order.data.links.find(link => link.rel === 'approve');
    res.json({ payUrl: approve.href });
  } catch (err) {
    res.status(500).json({ error: err.toString() });
  }
});

router.post('/momo', createMomoPayment);
//router.post('/vnpay', createVNPayUrl);
router.post('/momo/notify', momoNotify);
//router.get('/vnpay/return', vnpayReturn);

export default router;