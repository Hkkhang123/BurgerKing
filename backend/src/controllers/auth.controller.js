import jwt from "jsonwebtoken";
import User from "../models/User.js";
import multer from 'multer';
import streamifier from 'streamifier';
import cloudinary from '../config/cloudinary.js';
import { OAuth2Client } from 'google-auth-library';
import admin from '../config/firebaseAdmin.js';
import Notification from "../models/Notification.js";
import { sendMail } from '../config/email.js';
import crypto from 'crypto';
import fetch from 'node-fetch';

const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    console.log('File nhận được:', file);
    const isImageMime = file.mimetype.startsWith('image/');
    const isImageExt = /\.(jpg|jpeg|png|gif|bmp|webp)$/i.test(file.originalname);
    if (isImageMime || (file.mimetype === 'application/octet-stream' && isImageExt)) {
      cb(null, true);
    } else {
      cb(new Error('Chỉ cho phép upload file hình ảnh!'), false);
    }
  }
});

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

function sanitizeUserImage(user) {
  if (!user.image || user.image === 'person.png' || !/^https?:\/\//.test(user.image)) {
    return '';
  }
  return user.image;
}

export const dangky = async (req, res) => {
  try {
    const { email, password, name } = req.body;
    const userExist = await User.findOne({ email });
    if (userExist) {
      return res.status(400).json({ message: "User đã tồn tại" });
    }
    const user = await User.create({ name, email, password });
    await user.save();
    const payload = {
      user: {
        id: user._id,
        role: user.role,
      },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      {
        expiresIn: "40h",
      },
      (err, token) => {
        if (err) {
          console.log(err);
        } else {
          res.status(201).json({
            user: {
              _id: user._id,
              name: user.name,
              email: user.email,
              role: user.role,
              image: sanitizeUserImage(user),
            },
            token,
          });
        }
      }
    );
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const dangNhap = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    
    if (!user) {
      return res.status(401).json({ 
        success: false,
        message: "Email hoặc mật khẩu không đúng" 
      });
    }
    
    if (!(await user.matchPassword(password))) {
      return res.status(401).json({ 
        success: false,
        message: "Email hoặc mật khẩu không đúng" 
      });
    }
    
    const payload = {
      user: {
        _id: user._id,
        role: user.role,
      },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      {
        expiresIn: "40h",
      },
      async (err, token) => {
        if (err) {
          console.log(err);
          return res.status(500).json({ 
            success: false,
            message: "Lỗi tạo token" 
          });
        } else {
          // Tạo notification đăng nhập thành công
          await Notification.create({
            user: user._id,
            title: "Đăng nhập thành công",
            message: "Chào mừng bạn quay trở lại!",
          });
          res.json({
            success: true,
            user: {
              _id: user._id,
              name: user.name,
              email: user.email,
              role: user.role,
              image: sanitizeUserImage(user),
            },
            token,
            message: "Đăng nhập thành công",
          });
        }
      }
    );
  } catch (error) {
    console.log('Login error:', error);
    res.status(500).json({ 
      success: false,
      message: "Lỗi đăng nhập: " + error.message 
    });
  }
};

export const getProfile = async (req, res) => {
  try {
    if (!req.user) {
      return res.status(404).json({ success: false, message: "Không tìm thấy user" });
    }
    // Lấy user từ database để đảm bảo luôn có thông tin mới nhất
    const user = await User.findById(req.user.id || req.user._id).select("-password");
    if (!user) {
      return res.status(404).json({ success: false, message: "Không tìm thấy user" });
    }
    return res.status(200).json({ success: true, data: user });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
}

export const uploadAvatar = [
  // Middleware upload single file
  upload.single('image'),
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({ message: 'No file uploaded' });
      }
      // Upload lên Cloudinary
      const streamUpload = (fileBuffer) => {
        return new Promise((resolve, reject) => {
          const stream = cloudinary.uploader.upload_stream(
            {
              folder: 'avatar',
              resource_type: 'auto',
            },
            (error, result) => {
              if (result) {
                resolve(result);
              } else {
                reject(error);
              }
            }
          );
          streamifier.createReadStream(req.file.buffer).pipe(stream);
        });
      };
      const result = await streamUpload(req.file.buffer);
      // Cập nhật user
      req.user.image = result.secure_url;
      await req.user.save();
      res.json({
        success: true,
        imageUrl: result.secure_url,
        message: 'Avatar updated successfully',
      });
    } catch (error) {
      res.status(500).json({ message: error.message });
    }
  },
];

export const loginWithGoogle = async (req, res) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({ message: 'No idToken provided' });
    }
    // Xác thực idToken với Firebase
    let decoded;
    try {
      decoded = await admin.auth().verifyIdToken(idToken);
    } catch (err) {
      return res.status(401).json({ message: 'Invalid Firebase idToken' });
    }
    const { uid, email, name, picture } = decoded;
    // Tìm user theo uid hoặc email
    let user = await User.findOne({ $or: [ { googleId: uid }, { email } ] });
    if (!user) {
      user = await User.create({
        name: name || email,
        email,
        googleId: uid,
        image: picture,
        password: Math.random().toString(36).slice(-8)
      });
    } else if (!user.googleId) {
      user.googleId = uid;
      if (!user.image && picture) user.image = picture;
      await user.save();
    }
    // Tạo JWT
    const jwtPayload = {
      user: {
        id: user._id,
        role: user.role,
      },
    };
    jwt.sign(
      jwtPayload,
      process.env.JWT_SECRET,
      { expiresIn: '40h' },
      async (err, token) => {
        if (err) {
          return res.status(500).json({ message: 'JWT error' });
        }
        // Tạo notification đăng nhập Google thành công
        await Notification.create({
          user: user._id,
          title: "Đăng nhập thành công",
          message: "Chào mừng bạn quay trở lại!",
        });
        res.json({
          user: {
            _id: user._id,
            name: user.name,
            email: user.email,
            role: user.role,
            image: sanitizeUserImage(user),
          },
          token,
          message: 'Login with Google (Firebase) success',
        });
      }
    );
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const loginWithFacebook = async (req, res) => {
  const { access_token } = req.body;
  if (!access_token) return res.status(400).json({ message: 'No access token' });

  try {
    // Kiểm tra access token với Facebook
    const debugRes = await fetch(
      `https://graph.facebook.com/debug_token?input_token=${access_token}&access_token=${process.env.FACEBOOK_APP_ID}|${process.env.FACEBOOK_APP_SECRET}`
    );
    const debugData = await debugRes.json();
    if (!debugData.data || !debugData.data.is_valid) {
      return res.status(401).json({ message: 'Invalid Facebook token' });
    }

    // Lấy thông tin user từ Facebook
    const fbRes = await fetch(
      `https://graph.facebook.com/me?fields=id,name,email,picture&access_token=${access_token}`
    );
    const fbData = await fbRes.json();

    if (!fbData.id) return res.status(401).json({ message: 'Invalid Facebook user info' });

    let user = await User.findOne({ facebookId: fbData.id });
    if (!user) {
      user = await User.create({
        facebookId: fbData.id,
        name: fbData.name,
        email: fbData.email || `${fbData.id}@facebook.com`,
        image: fbData.picture?.data?.url,
        password: Math.random().toString(36).slice(-8)
      });
    }

    const payload = {
      user: {
        _id: user._id,
        role: user.role,
      },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      {
        expiresIn: "40h",
      },
      (err, token) => {
        if (err) {
          res.status(500).json({ message: 'JWT error', error: err.message });
        } else {
          res.status(200).json({
            user: {
              _id: user._id,
              name: user.name,
              email: user.email,
              role: user.role,
              image: user.image,
            },
            token,
          });
        }
      }
    );
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
};

export const updateProfile = [
  upload.single('avatar'),
  async (req, res) => {
    try {
      const userId = req.user._id || req.user.id;
      const { name, email} = req.body;
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
      if (name) user.name = name;
      if (email) user.email = email;
      // Xử lý upload avatar nếu có
      if (req.file) {
        // Dùng lại logic upload lên Cloudinary
        const streamUpload = (fileBuffer) => {
          return new Promise((resolve, reject) => {
            const stream = cloudinary.uploader.upload_stream(
              {
                folder: 'avatar',
                resource_type: 'auto',
              },
              (error, result) => {
                if (result) {
                  resolve(result);
                } else {
                  reject(error);
                }
              }
            );
            streamifier.createReadStream(fileBuffer).pipe(stream);
          });
        };
        const result = await streamUpload(req.file.buffer);
        user.image = result.secure_url;
      }
      await user.save();
      res.json({ user: { ...user.toObject(), image: sanitizeUserImage(user) } });
    } catch (e) {
      res.status(500).json({ message: "Server error", error: e.message });
    }
  }
];

// ==== ĐỊA CHỈ GIAO HÀNG ====

// Lấy danh sách địa chỉ giao hàng của user
export const getAddresses = async (req, res) => {
  try {
    const user = await User.findById(req.user._id || req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user.addresses || []);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Thêm địa chỉ giao hàng
export const addAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user._id || req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    // Nếu là địa chỉ mặc định, bỏ mặc định các địa chỉ khác
    if (req.body.isDefault) {
      user.addresses.forEach(addr => addr.isDefault = false);
    }
    user.addresses.push(req.body);
    await user.save();
    res.status(201).json(user.addresses);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Sửa địa chỉ giao hàng
export const updateAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user._id || req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    const { addressId } = req.params;
    const idx = user.addresses.findIndex(addr => addr._id.toString() === addressId);
    if (idx === -1) return res.status(404).json({ message: 'Address not found' });
    // Nếu là địa chỉ mặc định, bỏ mặc định các địa chỉ khác
    if (req.body.isDefault) {
      user.addresses.forEach(addr => addr.isDefault = false);
    }
    user.addresses[idx] = { ...user.addresses[idx]._doc, ...req.body };
    await user.save();
    res.json(user.addresses);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Xóa địa chỉ giao hàng
export const deleteAddress = async (req, res) => {
  try {
    const user = await User.findById(req.user._id || req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    const { addressId } = req.params;
    user.addresses = user.addresses.filter(addr => addr._id.toString() !== addressId);
    await user.save();
    res.json(user.addresses);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Gửi OTP về email để reset mật khẩu
export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng với email này' });
    }
    // Tạo OTP 6 số
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    user.resetPasswordOTP = otp;
    user.resetPasswordOTPExpires = Date.now() + 10 * 60 * 1000; // 10 phút
    await user.save();
    // Gửi email
    await sendMail({
      to: user.email,
      subject: 'Mã OTP đặt lại mật khẩu',
      text: `Mã OTP của bạn là: ${otp}`,
      html: `<p>Mã OTP đặt lại mật khẩu của bạn là: <b>${otp}</b></p><p>OTP có hiệu lực trong 10 phút.</p>`
    });
    res.json({ success: true, message: 'Đã gửi OTP về email!' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// Xác thực OTP và đặt lại mật khẩu
export const resetPassword = async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng với email này' });
    }
    if (!user.resetPasswordOTP || !user.resetPasswordOTPExpires) {
      return res.status(400).json({ success: false, message: 'Bạn chưa yêu cầu OTP hoặc OTP đã hết hạn' });
    }
    if (user.resetPasswordOTP !== otp) {
      return res.status(400).json({ success: false, message: 'OTP không đúng' });
    }
    if (user.resetPasswordOTPExpires < Date.now()) {
      return res.status(400).json({ success: false, message: 'OTP đã hết hạn' });
    }
    // Đặt lại mật khẩu
    user.password = newPassword;
    user.resetPasswordOTP = null;
    user.resetPasswordOTPExpires = null;
    await user.save();
    res.json({ success: true, message: 'Đặt lại mật khẩu thành công!' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ===== OTP AUTHENTICATION FUNCTIONS =====

// Gửi OTP cho đăng nhập
export const sendLoginOtp = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'Không tìm thấy người dùng với email này' 
      });
    }
    
    // Tạo OTP 6 số
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    user.resetPasswordOTP = otp; // Tạm thời dùng field này
    user.resetPasswordOTPExpires = Date.now() + 10 * 60 * 1000; // 10 phút
    await user.save();
    
    // Gửi email
    await sendMail({
      to: user.email,
      subject: 'Mã OTP đăng nhập',
      text: `Mã OTP đăng nhập của bạn là: ${otp}`,
      html: `<p>Mã OTP đăng nhập của bạn là: <b>${otp}</b></p><p>OTP có hiệu lực trong 10 phút.</p>`
    });
    
    res.json({ 
      success: true, 
      message: 'Đã gửi OTP về email!' 
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: error.message 
    });
  }
};

// Xác thực OTP đăng nhập
export const verifyLoginOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'Không tìm thấy người dùng với email này' 
      });
    }
    
    if (!user.resetPasswordOTP || !user.resetPasswordOTPExpires) {
      return res.status(400).json({ 
        success: false, 
        message: 'Bạn chưa yêu cầu OTP hoặc OTP đã hết hạn' 
      });
    }
    
    if (user.resetPasswordOTP !== otp) {
      return res.status(400).json({ 
        success: false, 
        message: 'OTP không đúng' 
      });
    }
    
    if (user.resetPasswordOTPExpires < Date.now()) {
      return res.status(400).json({ 
        success: false, 
        message: 'OTP đã hết hạn' 
      });
    }
    
    // Xóa OTP sau khi xác thực thành công
    user.resetPasswordOTP = null;
    user.resetPasswordOTPExpires = null;
    await user.save();
    
    // Tạo JWT token
    const payload = {
      user: {
        _id: user._id,
        role: user.role,
      },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      {
        expiresIn: "40h",
      },
      async (err, token) => {
        if (err) {
          return res.status(500).json({ 
            success: false, 
            message: 'Lỗi tạo token' 
          });
        }
        
        // Tạo notification đăng nhập thành công
        await Notification.create({
          user: user._id,
          title: "Đăng nhập thành công",
          message: "Chào mừng bạn quay trở lại!",
        });
        
        res.json({
          success: true,
          user: {
            _id: user._id,
            name: user.name,
            email: user.email,
            role: user.role,
            image: sanitizeUserImage(user),
          },
          token,
          message: "Đăng nhập thành công",
        });
      }
    );
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: error.message 
    });
  }
};

// Gửi OTP cho đăng ký
export const sendSignupOtp = async (req, res) => {
  try {
    const { email, name, password } = req.body;
    
    // Kiểm tra email đã tồn tại chưa
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email đã được sử dụng' 
      });
    }
    
    // Tạo OTP 6 số
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Lưu OTP vào session hoặc cache (không tạo user)
    // Có thể sử dụng Redis, hoặc lưu tạm trong memory
    // Ở đây ta sẽ lưu vào một collection riêng hoặc sử dụng Map
    if (!global.signupOTPs) {
      global.signupOTPs = new Map();
    }
    
    global.signupOTPs.set(email, {
      otp,
      name,
      password,
      expires: Date.now() + 10 * 60 * 1000 // 10 phút
    });
    
    // Gửi email
    await sendMail({
      to: email,
      subject: 'Mã OTP đăng ký',
      text: `Mã OTP đăng ký của bạn là: ${otp}`,
      html: `<p>Mã OTP đăng ký của bạn là: <b>${otp}</b></p><p>OTP có hiệu lực trong 10 phút.</p>`
    });
    
    res.json({ 
      success: true, 
      message: 'Đã gửi OTP về email!' 
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: error.message 
    });
  }
};

// Đăng ký với OTP
export const registerWithOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;
    
    // Kiểm tra OTP từ cache
    if (!global.signupOTPs || !global.signupOTPs.has(email)) {
      return res.status(400).json({ 
        success: false, 
        message: 'OTP không tồn tại hoặc đã hết hạn' 
      });
    }
    
    const otpData = global.signupOTPs.get(email);
    
    // Kiểm tra OTP có đúng không
    if (otpData.otp !== otp) {
      return res.status(400).json({ 
        success: false, 
        message: 'OTP không đúng' 
      });
    }
    
    // Kiểm tra OTP có hết hạn không
    if (otpData.expires < Date.now()) {
      global.signupOTPs.delete(email);
      return res.status(400).json({ 
        success: false, 
        message: 'OTP đã hết hạn' 
      });
    }
    
    // Kiểm tra email đã tồn tại chưa
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ 
        success: false, 
        message: 'Email đã được sử dụng' 
      });
    }
    
    // Tạo user thật với thông tin từ cache
    const newUser = new User({
      email: email, // Sử dụng email từ request
      name: otpData.name,
      password: otpData.password
    });
    await newUser.save();
    
    // Xóa OTP khỏi cache
    global.signupOTPs.delete(email);
    
    // Tạo JWT token
    const payload = {
      user: {
        _id: newUser._id,
        role: newUser.role,
      },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      {
        expiresIn: "40h",
      },
      async (err, token) => {
        if (err) {
          return res.status(500).json({ 
            success: false, 
            message: 'Lỗi tạo token' 
          });
        }
        
        // Tạo notification đăng ký thành công
        await Notification.create({
          user: newUser._id,
          title: "Đăng ký thành công",
          message: "Chào mừng bạn đến với ứng dụng!",
        });
        
        res.status(201).json({
          success: true,
          user: {
            _id: newUser._id,
            name: newUser.name,
            email: newUser.email,
            role: newUser.role,
            image: sanitizeUserImage(newUser),
          },
          token,
          message: "Đăng ký thành công",
        });
      }
    );
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: error.message 
    });
  }
};

// ===== TWO-FACTOR AUTHENTICATION =====

// Bước 1: Đăng nhập bằng password và gửi OTP
export const loginWithPasswordAndSendOtp = async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'Không tìm thấy người dùng với email này' 
      });
    }

    // Kiểm tra password
    if (!(await user.matchPassword(password))) {
      return res.status(401).json({ 
        success: false, 
        message: 'Mật khẩu không đúng' 
      });
    }

    // Tạo OTP 6 số
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    user.resetPasswordOTP = otp; // Tạm thời dùng field này cho 2FA
    user.resetPasswordOTPExpires = Date.now() + 10 * 60 * 1000; // 10 phút
    await user.save();
    
    // Gửi email OTP
    await sendMail({
      to: user.email,
      subject: 'Mã xác thực hai yếu tố',
      text: `Mã xác thực hai yếu tố của bạn là: ${otp}`,
      html: `<p>Mã xác thực hai yếu tố của bạn là: <b>${otp}</b></p><p>OTP có hiệu lực trong 10 phút.</p>`
    });
    
    res.json({ 
      success: true, 
      message: 'Đã gửi mã xác thực hai yếu tố về email!',
      userId: user._id // Trả về userId để frontend sử dụng
    });
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: error.message 
    });
  }
};

// Bước 2: Xác thực OTP và hoàn tất đăng nhập
export const verifyTwoFactorAuth = async (req, res) => {
  try {
    const { userId, otp } = req.body;
    const user = await User.findById(userId);
    
    if (!user) {
      return res.status(404).json({ 
        success: false, 
        message: 'Không tìm thấy người dùng' 
      });
    }
    
    if (!user.resetPasswordOTP || !user.resetPasswordOTPExpires) {
      return res.status(400).json({ 
        success: false, 
        message: 'Bạn chưa yêu cầu OTP hoặc OTP đã hết hạn' 
      });
    }
    
    if (user.resetPasswordOTP !== otp) {
      return res.status(400).json({ 
        success: false, 
        message: 'Mã xác thực không đúng' 
      });
    }
    
    if (user.resetPasswordOTPExpires < Date.now()) {
      return res.status(400).json({ 
        success: false, 
        message: 'Mã xác thực đã hết hạn' 
      });
    }
    
    // Xóa OTP sau khi xác thực thành công
    user.resetPasswordOTP = null;
    user.resetPasswordOTPExpires = null;
    await user.save();
    
    // Tạo JWT token
    const payload = {
      user: {
        _id: user._id,
        role: user.role,
      },
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      {
        expiresIn: "40h",
      },
      async (err, token) => {
        if (err) {
          return res.status(500).json({ 
            success: false, 
            message: 'Lỗi tạo token' 
          });
        }
        
        // Tạo notification đăng nhập thành công
        await Notification.create({
          user: user._id,
          title: "Đăng nhập thành công",
          message: "Xác thực hai yếu tố thành công!",
        });
        
        res.json({
          success: true,
          user: {
            _id: user._id,
            name: user.name,
            email: user.email,
            role: user.role,
            image: sanitizeUserImage(user),
          },
          token,
          message: "Đăng nhập thành công",
        });
      }
    );
  } catch (error) {
    res.status(500).json({ 
      success: false, 
      message: error.message 
    });
  }
};
