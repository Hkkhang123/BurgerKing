
import Coupon from '../models/Coupon.js';

export const getAllCoupons = async (req, res) => {
  try {
    const coupons = await Coupon.find();
    res.json(coupons);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server khi lấy danh sách mã giảm giá' });
  }
};

export const getCouponByCode = async (req, res) => {
  const { code } = req.params;
  const total = parseInt(req.query.total, 10);

  try {
    const coupon = await Coupon.findOne({ code });

    if (!coupon) {
      return res.status(404).json({ message: 'Không tìm thấy mã giảm giá này' });
    }

    if (!coupon.isActive) {
      return res.status(400).json({ message: 'Mã giảm giá đã bị vô hiệu hóa' });
    }

    const now = new Date();
    const startDate = new Date(coupon.startDate);
    const endDate = new Date(coupon.endDate);

    if (now < startDate) {
      return res.status(400).json({
        message: `Mã giảm giá chỉ áp dụng từ ngày ${startDate.toLocaleDateString()}`,
      });
    }

    if (now > endDate) {
      return res.status(400).json({
        message: 'Mã giảm giá đã hết hạn sử dụng',
      });
    }

    if (total < coupon.minOrderValue) {
      const difference = coupon.minOrderValue - total;
      return res.status(400).json({
        message: `Đơn hàng của bạn cần thêm ${difference.toLocaleString()} đ để dùng mã này`,
      });
    }

    return res.json(coupon);
  } catch (error) {
    console.error('Lỗi khi lấy mã giảm giá:', error);
    res.status(500).json({ message: 'Lỗi server khi xử lý mã giảm giá' });
  }
};

export const createCoupon = async (req, res) => {
  try {
    const newCoupon = new Coupon(req.body);
    await newCoupon.save();
    res.status(201).json(newCoupon);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server khi tạo mã giảm giá' });
  }
};

export const updateCoupon = async (req, res) => {
  try {
    const updatedCoupon = await Coupon.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
    });
    res.json(updatedCoupon);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server khi cập nhật mã giảm giá' });
  }
};

export const deleteCoupon = async (req, res) => {
  try {
    await Coupon.findByIdAndDelete(req.params.id);
    res.json({ message: 'Xóa mã giảm giá thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server khi xóa mã giảm giá' });
  }
};""
