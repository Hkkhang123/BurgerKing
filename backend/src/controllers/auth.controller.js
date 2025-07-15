import jwt from "jsonwebtoken";
import User from "../models/User.js";
import multer from 'multer';
import streamifier from 'streamifier';
import cloudinary from '../config/cloudinary.js';
import { OAuth2Client } from 'google-auth-library';
import admin from '../config/firebaseAdmin.js';
import Notification from "../models/Notification.js";

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
    if (user && (await user.matchPassword(password))) {
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
          } else {
            // Tạo notification đăng nhập thành công
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
              message: "Success",
            });
          }
        }
      );
    }
  } catch (error) {
    res
      .status(500)
      .json({ message: "Lỗi đăng nhập controller", message: error.message });
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
