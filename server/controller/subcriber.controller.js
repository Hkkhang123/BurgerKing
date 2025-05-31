import Subcriber from "../models/Subcriber.js";

export const NewSubcriber = async (req, res) => {
    const { email } = req.body

    if (!email) {
        return res.status(400).json({message: "Email is required"});
    }

    try {
        let subcriber = await Subcriber.findOne({email})

        if (subcriber) {
            return res.status(400).json({message: "email already exists"});
        }

        subcriber = new Subcriber({
            email
        })

        await subcriber.save()

        res.status(201).json({message: "Subcriber subcribed to the new letter"})
    } catch (error) {
        res.status(500).json({message: error.message})
    }
}