import mongoose from "mongoose";

const orderItemSchema = mongoose.Schema({
    productId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Product",
        required: true,
    },
    name: {
        type: String,
        required: true,
    },
    image: {
        type: String,
        required: true,
    },
    price: {
        type: Number,
        required: true,
    },
    size: String,
    colors: String,
    quantity: {
        type: Number,
        required: true,
    },
}, {_id: false});


const orderSchema = mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true,
    },
    orderItems: [orderItemSchema],
    shippingAddress: {
        address: {
            type: String,
            required: true,
        },
        city: {
            type: String,
            required: true,
        },
        postalCode: {
            type: String,
            required: true,
        },
        district: {
            type: String,
            required: true,
        },
    },
    paymentMethod: {
        type: String,
        required: true,
    },
    totalPrice: {
        type: Number,
        required: true,
    },
    isPaid: {
        type: Boolean,
        default: false,
    },
    paidAt: {
        type: Date,
    },
    isDelivered: {
        type: Boolean,
        default: false,
    },
    deliveredAt: {
        type: Date,
    },
    paymentStatus: {
        type: String,
        default: "Đang xử lý"
    },
    status: {
        type: String,
        enum: ["Đang xử lý", "Đã gửi đi", "Đã giao hàng", "Đã hủy"],
        default: "Đang xử lý"
    }
}, {timestamps: true});

export default mongoose.model("Order", orderSchema);