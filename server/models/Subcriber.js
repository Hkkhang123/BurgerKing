import mongoose from "mongoose";

const subcriberSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true
    },
    subcribedAt: {
        type: Date,
        default: Date.now
    }
})

export default mongoose.model("Subcriber", subcriberSchema)