import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axiosInstance from "../../utils/axios";

export const fetchAllUsers = createAsyncThunk(
  "admin/fetchAllUsers",
  async () => {
    const response = await axiosInstance.get("/api/admin");
    return response.data;
  }
);

export const createUser = createAsyncThunk(
  "admin/createUser",
  async (userData, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.post("/api/admin", userData);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

export const updateUser = createAsyncThunk(
  "admin/updateUser",
  async ({ id, name, email, role }) => {
    const response = await axiosInstance.put(`/api/admin/${id}`, { name, email, role });
    return response.data.user;
  }
);

export const deleteUser = createAsyncThunk("admin/deleteUser", async (id) => {
  const response = await axiosInstance.delete(`/api/admin/${id}`);
  return id;
});

export const fetchAdminProducts = createAsyncThunk(
  "admin/fetchAdminProducts",
  async () => {
    const response = await axiosInstance.get("/api/admin/product");
    return response.data;
  }
);

export const createProduct = createAsyncThunk(
  "admin/createProduct",
  async (productData) => {
    const response = await axiosInstance.post("/api/products", productData);
    return response.data;
  }
);

export const updateProduct = createAsyncThunk(
  "admin/updateProduct",
  async ({ id, productData }) => {
    const response = await axiosInstance.put(`/api/products/${id}`, productData);
    return response.data;
  }
);

export const deleteProduct = createAsyncThunk(
  "admin/deleteProduct",
  async (id) => {
    await axiosInstance.delete(`/api/products/${id}`);
    return id;
  }
);

export const fetchAllOrder = createAsyncThunk(
  "admin/fetchAllOrder",
  async (_, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.get("/api/admin/order");
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

export const updateOrder = createAsyncThunk(
  "admin/updateOrder",
  async ({ id, status }, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.put(`/api/admin/order/${id}`, { status });
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

export const deleteOrder = createAsyncThunk(
  "admin/deleteOrder",
  async (id, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.delete(`/api/admin/order/${id}`);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

const adminSlice = createSlice({
  name: "admin",
  initialState: {
    orders: [],
    totalOrder: 0,
    totalSale: 0,
    products: [],
    users: [],
    loading: false,
    error: null,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchAllUsers.pending, (state, action) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchAllUsers.fulfilled, (state, action) => {
        state.loading = false;
        state.users = action.payload;
      })
      .addCase(fetchAllUsers.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload.message;
      })

      .addCase(updateUser.fulfilled, (state, action) => {
        const updatedUser = action.payload;
        const userIndex = state.users.findIndex(
          (user) => user._id === updatedUser._id
        );
        if (userIndex !== -1) {
          state.users[userIndex] = updatedUser;
        }
      })
      .addCase(deleteUser.fulfilled, (state, action) => {
        state.users = state.users.filter((user) => user._id !== action.payload);
      })

      .addCase(createUser.pending, (state, action) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(createUser.fulfilled, (state, action) => {
        state.loading = false;
        state.users.push(action.payload.user);
      })
      .addCase(createUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload.message;
      })

      .addCase(fetchAdminProducts.pending, (state, action) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchAdminProducts.fulfilled, (state, action) => {
        state.loading = false;
        state.products = action.payload;
      })
      .addCase(fetchAdminProducts.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload.message;
      })

      .addCase(createProduct.fulfilled, (state, action) => {
        state.products.push(action.payload);
      })
      .addCase(updateProduct.fulfilled, (state, action) => {
        const productIndex = state.products.findIndex(
          (product) => product._id === action.payload._id
        );
        if (productIndex !== -1) {
          state.products[productIndex] = action.payload;
        }
      })

      .addCase(deleteProduct.fulfilled, (state, action) => {
        state.products = state.products.filter(
          (product) => product._id !== action.payload._id
        );
      })

      .addCase(fetchAllOrder.pending, (state, action) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchAllOrder.fulfilled, (state, action) => {
        state.loading = false;
        state.orders = action.payload;
        state.totalOrder = action.payload.length;

        const totalSales = action.payload.reduce((total, order) => {
          return total + order.totalPrice;
        }, 0);
        state.totalSale = totalSales;
      })
      .addCase(fetchAllOrder.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload.message;
      })
      .addCase(updateOrder.fulfilled, (state, action) => {
        const updateOrder = action.payload;
        console.log(action.payload);

        const orderIndex = state.orders.findIndex(
          (order) => order._id === updateOrder._id
        );
        if (orderIndex !== -1) {
          state.orders[orderIndex] = updateOrder;
        }
      })
      .addCase(deleteOrder.fulfilled, (state, action) => {
        state.orders = state.orders.filter(
          (order) => order._id !== action.payload
        );
      });
  },
});

export default adminSlice.reducer;
