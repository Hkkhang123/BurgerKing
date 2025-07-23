import express from "express";
import axios from "axios";

import ghnService from "../config/ghnService.js";

const router = express.Router();

// Lấy danh sách tỉnh
router.get("/provinces", async (req, res) => {
  try {
    const data = await ghnService.getProvinces();
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lấy danh sách quận theo provinceId
router.get("/districts/:provinceId", async (req, res) => {
  try {
    const data = await ghnService.getDistricts(req.params.provinceId);
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lấy danh sách phường theo districtId
router.get("/wards/:districtId", async (req, res) => {
  try {
    const data = await ghnService.getWards(req.params.districtId);
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Lấy danh sách dịch vụ vận chuyển
router.post("/available-services", async (req, res) => {
  const { from_district, to_district } = req.body;
  try {
    const data = await ghnService.getAvailableServices(from_district, to_district);
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/calculate-fee', async (req, res) => {
  try {
    const response = await axios.post(
      'https://dev-online-gateway.ghn.vn/shiip/public-api/v2/shipping-order/fee',
      req.body, // Chứa dữ liệu như bạn đưa ra
      {
        headers: {
          'Content-Type': 'application/json',
          'Token': process.env.GHN_TOKEN,
          'ShopId': process.env.GHN_SHOP_ID
        }
      }
    );

    // Chuẩn hóa phản hồi
    res.json({
      code: 200,
      message: "Success",
      data: response.data.data // dữ liệu gồm total, service_fee...
    });
  } catch (error) {
    console.error('[Calculate Fee] Error:', error.response?.data || error.message);
    res.status(500).json({
      code: 500,
      message: error.response?.data?.message || 'Internal Server Error'
    });
  }
});


export default router;
