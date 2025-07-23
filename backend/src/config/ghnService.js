import axios from "axios";

const GHN_BASE_URL = "https://dev-online-gateway.ghn.vn/shiip/public-api";
const TOKEN = process.env.GHN_TOKEN;
const SHOP_ID = process.env.GHN_SHOP_ID;

const ghnClient = axios.create({
  baseURL: GHN_BASE_URL,
  headers: {
    Token: TOKEN,
    ShopId: SHOP_ID,
    "Content-Type": "application/json",
  },
});

const ghnService = {
  // Lấy danh sách tỉnh
  getProvinces: async () => {
    const res = await ghnClient.post("/master-data/province");
    return res.data;
  },

  // Lấy danh sách quận theo tỉnh
  getDistricts: async (provinceId) => {
    try {
      const res = await ghnClient.post("/master-data/district", {
        province_id: Number(provinceId),
      });
      return res.data;
    } catch (error) {
      console.error("Lỗi getDistricts:", error.response?.data || error.message);
      throw error;
    }
  },

  // Lấy danh sách phường theo quận
  getWards: async (districtId) => {
    try {
      const res = await ghnClient.post("/master-data/ward", {
        district_id: Number(districtId),
      });
      return res.data;
    } catch (error) {
      console.error("Lỗi getWards:", error.response?.data || error.message);
      throw error;
    }
  },

  // Lấy dịch vụ vận chuyển
  getAvailableServices: async (fromDistrict, toDistrict) => {
    const res = await ghnClient.post("/v2/shipping-order/available-services", {
      shop_id: Number(SHOP_ID),
      from_district: Number(fromDistrict),
      to_district: Number(toDistrict),
    });
    return res.data;
  },

  // Tính phí vận chuyển
 async calculateFee(data) {
  try {
    const { data: res } = await axios.post(
      "http://localhost:5000/api/shipping/calculate-fee",
      data,
      { headers: { "Content-Type": "application/json" } }
    );

    if (res.code === 200) {
      return res.data.total;
    } else {
      throw new Error(res.message || "Failed to calculate fee");
    }
  } catch (err) {
    console.error("[GHN Fee] Request Error:", err.response?.data || err.message);
    throw err;
  }
}




};

export default ghnService;
