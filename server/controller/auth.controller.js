import jwt from "jsonwebtoken";
import User from "../models/User.js";
import multer from 'multer';
import streamifier from 'streamifier';
import cloudinary from '../config/cloudinary.js';

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
