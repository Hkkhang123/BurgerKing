import express from "express";
import { NewSubcriber } from "../controller/subcriber.controller.js";

const router = express.Router();

router.post("/subcribe", NewSubcriber)

export default router;