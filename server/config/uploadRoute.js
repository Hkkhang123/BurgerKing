import multer from 'multer'
import express from 'express'
import streamifier from 'streamifier'
import cloudinary from "../config/cloudinary.js";

const router = express.Router()
const storage = multer.memoryStorage()
const upload = multer({ 
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    // Chỉ cho phép image files
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Chỉ cho phép upload file hình ảnh!'), false);
    }
  }
})

// Upload single file
router.post('/single', upload.single('image'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({message: "No file uploaded"})
        }

        const streamUpload = (fileBuffer) => {
            return new Promise((resolve, reject) => {
                const stream = cloudinary.uploader.upload_stream(
                    {
                        folder: "product",
                        resource_type: "auto"
                    },
                    (error, result) => {
                        if (result) {
                            resolve(result)
                        } else {
                            reject(error)
                        }
                    }
                )

                streamifier.createReadStream(fileBuffer).pipe(stream)
            })
        }
        const result = await streamUpload(req.file.buffer)
        res.json({
            success: true,
            imageUrl: result.secure_url,
            publicId: result.public_id
        })
    } catch (error) {
        res.status(500).json({message: error.message})
    }
})

// Upload multiple files
router.post('/multiple', upload.array('images', 10), async (req, res) => {
    try {
        if (!req.files || req.files.length === 0) {
            return res.status(400).json({message: "No files uploaded"})
        }

        const streamUpload = (fileBuffer) => {
            return new Promise((resolve, reject) => {
                const stream = cloudinary.uploader.upload_stream(
                    {
                        folder: "product",
                        resource_type: "auto"
                    },
                    (error, result) => {
                        if (result) {
                            resolve(result)
                        } else {
                            reject(error)
                        }
                    }
                )

                streamifier.createReadStream(fileBuffer).pipe(stream)
            })
        }

        const uploadPromises = req.files.map(file => streamUpload(file.buffer))
        const results = await Promise.all(uploadPromises)
        
        const uploadedImages = results.map(result => ({
            url: result.secure_url,
            publicId: result.public_id,
            altText: result.original_filename || ""
        }))

        res.json({
            success: true,
            images: uploadedImages
        })
    } catch (error) {
        res.status(500).json({message: error.message})
    }
})

// Upload từ URL
router.post('/url', async (req, res) => {
    try {
        const { imageUrl, altText } = req.body
        
        if (!imageUrl) {
            return res.status(400).json({message: "Image URL is required"})
        }

        const result = await cloudinary.uploader.upload(imageUrl, {
            folder: "product",
            resource_type: "auto"
        })

        res.json({
            success: true,
            imageUrl: result.secure_url,
            publicId: result.public_id,
            altText: altText || result.original_filename || ""
        })
    } catch (error) {
        res.status(500).json({message: error.message})
    }
})

export default router