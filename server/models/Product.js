import mongoose from "mongoose";

const productSchema = mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    description: {
        type: String,
        required: true,
    },
    price: {
        type: Number,
        required: true,
    },
    discountPrice: {
        type: Number,
    },
    countInStock: {
        type: Number,
        required: true,
        default: 0
    },
    sku: {
        type: String,
        unique: true,
        required: true,
    },
    category: {
        type: String,
        required: true,
    },
    brand: {
        type: String,

    },
    size: {
        type: [String],
        required: true,
    },
    colors: {
        type: [String],
        required: true,
    },
    collections: {
        type: String,
        required: true,
    },
    material: {
        type: String,
    },
    gender: {
        type: String,
        enum: ["Nam", "Nữ", "unisex"],
    },
    image: [{
        url: {
            type: String,
            required: true,
        },
        altText: {
            type: String,
        }
    }],
    isFeatured: {
        type: Boolean,
        default: false
    },
    isPublished: {
        type: Boolean,
        default: false
    },
    rating: {
        type: Number,
        default: 0
    },
    numReviews: {
        type: Number,
        default: 0
    },
    tag: [String],
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    metaTitle: {
        type: String,
    },
    metaDescription: {
        type: String,
    },
    metaKeywords: {
        type: String,
    },
    dimension: {
        length: Number,
        width: Number,
        height: Number
    },
    weight: Number
}, {timeStamps: true});

export default mongoose.model("Product", productSchema)