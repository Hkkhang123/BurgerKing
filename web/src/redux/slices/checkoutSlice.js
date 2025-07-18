import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axiosInstance from "../../utils/axios";

export const createCheckout = createAsyncThunk(
  "checkout/createCheckout",
  async (checkoutData, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.post("/api/checkout", checkoutData);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

const checkoutSlice = createSlice({
    name: "checkout",
    initialState: {
        checkout: null,
        loading: false,
        error: null,
    },
    reducers: {},
    extraReducers: (builder) =>  {
        builder
        .addCase(createCheckout.pending, (state, action) => {
            state.loading = true;
            state.error = null;
        })
        .addCase(createCheckout.fulfilled, (state, action) => {
            state.loading = false;
            state.checkout = action.payload;
        })
        .addCase(createCheckout.rejected, (state, action) => {
            state.loading = false;
            state.error = action.payload.message;
        });
    },
})

export default checkoutSlice.reducer;
