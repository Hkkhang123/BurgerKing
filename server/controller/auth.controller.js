import jwt from "jsonwebtoken";
import User from "../models/User.js";
import multer from 'multer';
import streamifier from 'streamifier';
import cloudinary from '../config/cloudinary.js';
import { OAuth2Client } from 'google-auth-library';
import admin from '../config/firebaseAdmin.js';

const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Chỉ cho phép upload file hình ảnh!'), false);
    }
  }
});

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

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
              image: user.image || null,
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
        (err, token) => {
          if (err) {
            console.log(err);
          } else {
            res.json({
              user: {
                _id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
                image: user.image || null,
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
    res.json(req.user)
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
      (err, token) => {
        if (err) {
          return res.status(500).json({ message: 'JWT error' });
        }
        res.json({
          user: {
            _id: user._id,
            name: user.name,
            email: user.email,
            role: user.role,
            image: user.image || null,
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
