import multer from 'multer'
import express from 'express'
import streamifier from 'streamifier'
import cloudinary from "../config/cloudinary.js";

const router = express.Router()
const storage = multer.memoryStorage()
const upload = multer({ storage })

router.post('/', upload.single('image'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({message: "No file uploaded"})
        }

        const streamUpload = (fileBuffer) => {
            return new Promise((resolve, reject) => {
                const stream = cloudinary.uploader.upload_stream((error, result) => {
                    if (result) {
                        resolve(result)
                    } else {
                        reject(error)
                    }
                })

                streamifier.createReadStream(fileBuffer).pipe(stream)
            })
        }
        const result = await streamUpload(req.file.buffer)
        res.json({imageUrl: result.secure_url})
    } catch (error) {
        res.status(500).json({message: error.message})
    }
})

export default router