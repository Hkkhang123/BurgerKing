import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axiosInstance from "../../utils/axios";

export const fetchUserOrders = createAsyncThunk(
    "order/fetchUserOrders",
    async (_, { rejectWithValue }) => {
        try {
            const response = await axiosInstance.get("/api/order/my-order");
            return response.data;
        } catch (error) {
            return rejectWithValue(error.response.data);
        }
    }
);

export const fetchOrderDetails = createAsyncThunk(
    "order/fetchOrderDetails",
    async (orderId, { rejectWithValue }) => {
        try {
            const response = await axiosInstance.get(`/api/order/${orderId}`);
            return response.data;
        } catch (error) {
            return rejectWithValue(error.response.data);
        }
    }   
);

const orderSlice = createSlice({
    name: "orders",
    initialState: {
        orders: [],
        totalOrder: 0,
        orderDetail: null,
        loading: false,
        error: null,
    },
    reducers: {},
    extraReducers: (builder) => {
        builder
        .addCase(fetchUserOrders.pending, (state, action) => {
            state.loading = true;
            state.error = null;
        })
        .addCase(fetchUserOrders.fulfilled, (state, action) => {
            state.loading = false;
            state.orders = action.payload;
        })
        .addCase(fetchUserOrders.rejected, (state, action) => {
            state.loading = false;
            state.error = action.payload.message;
        })

        //order detail
        .addCase(fetchOrderDetails.pending, (state, action) => {
            state.loading = true;
            state.error = null;
        })
        .addCase(fetchOrderDetails.fulfilled, (state, action) => {
            state.loading = false;
            state.orderDetail = action.payload;
        })
        .addCase(fetchOrderDetails.rejected, (state, action) => {
            state.loading = false;
            state.error = action.payload.message;
        })
    }
})

export default orderSlice.reducer;