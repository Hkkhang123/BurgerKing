import jwt from "jsonwebtoken";
import User from "../models/User.js";

export const protectRoutes = async (req, res, next) => {
    let token
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            token = req.headers.authorization.split(' ')[1]
            const decoded = jwt.verify(token, process.env.JWT_SECRET)

            const userId = decoded.user.id || decoded.user._id;
            req.user = await User.findById(userId).select('-password')
            next()
        } catch (error) {
            res.status(401).json({ message: 'Unauthorized - Invalid token' })
        }
    } else {
        res.status(401).json({ message: 'Unauthorized - No token provided' })
    }
}

export const isAdmin = (req, res, next) => {
    if (req.user && req.user.role === 'admin') {
        next()
    } else {
        res.status(403).json({ message: 'Forbidden - User is not an admin' })
    }
}
