import jwt from "jsonwebtoken";
import User from "../models/User.js";

export const dangky = async (req, res) => {
  try {
    const { email, password, name } = req.body;
    const userExist = await User.findOne({ email });
    if (userExist) {
      return res.status(400).json({ message: "User đã tồn tại" });
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
