import mongoose from "mongoose";
import bcrypt from "bcryptjs";

const userSchema = mongoose.Schema({
    name: {
        type: String,
        required: true,
        trim: true
    },
    email: {
        type: String,
        required: true,
        trim: true,
        unique: true,
        match: [/.+\@.+\..+/, "Vui lòng nhập email hợp lệ"]
    },
    password: {
        type: String,
        required: true,
        minLength: 6,
    },
    role: {
        type: String,
        enum: ["customer", "admin"],
        default: "customer"
    },

}, {timestamps: true});

userSchema.pre("save", async function (next) {
    if (!this.isModified("password")) return next()
    try {
        const salt = await bcrypt.genSalt(10)
        this.password = await bcrypt.hash(this.password, salt)
        next()
    } catch (error) {
        next(error)        
    }
})
userSchema.methods.matchPassword = async function (password) {
    return await bcrypt.compare(password, this.password);
}

export default mongoose.model("User", userSchema)

