import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axiosInstance from "../../utils/axios";

const userFromStorage = localStorage.getItem("userInfo")
  ? JSON.parse(localStorage.getItem("userInfo"))
  : null;

const tokenFromStorage = localStorage.getItem("userToken") || null;

const initialGuest =
  localStorage.getItem("guestId") || `guest_${new Date().getTime()}`;
localStorage.setItem("guestId", initialGuest);

const initialState = {
  user: userFromStorage,
  token: tokenFromStorage,
  guestId: initialGuest,
  loading: false,
  error: null,
  isAdminAuthenticated: !!userFromStorage && userFromStorage.role === 'admin',
};

export const loginUser = createAsyncThunk(
  "auth/loginUser",
  async (userData, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.post("/api/auth/dangnhap", userData);
      localStorage.setItem("userInfo", JSON.stringify(response.data.user));
      localStorage.setItem("userToken", response.data.token);
      return { user: response.data.user, token: response.data.token };
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

export const registerUser = createAsyncThunk(
  "auth/registerUser",
  async (userData, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.post("/api/auth/dangky", userData);
      localStorage.setItem("userInfo", JSON.stringify(response.data.user));
      localStorage.setItem("userToken", response.data.token);
      return { user: response.data.user, token: response.data.token };
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

export const loginAdmin = createAsyncThunk(
  "auth/loginAdmin",
  async (adminData, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.post("/api/auth/dangnhap", adminData);
      if (response.data.user.role !== "admin") {
        return rejectWithValue({ message: "Tài khoản không phải admin!" });
      }
      localStorage.setItem("userInfo", JSON.stringify(response.data.user));
      localStorage.setItem("userToken", response.data.token);
      return { user: response.data.user, token: response.data.token };
    } catch (error) {
      return rejectWithValue(error.response?.data || { message: "Lỗi không xác định" });
    }
  }
);

const authSlice = createSlice({
  name: "auth",
  initialState,
  reducers: {
    logout: (state) => {
      state.user = null;
      state.token = null;
      state.isAdminAuthenticated = false; // Đảm bảo luôn false khi logout
      state.guestId = `guest_${new Date().getTime()}`;
      localStorage.removeItem("userInfo");
      localStorage.removeItem("userToken");
      localStorage.setItem("guestId", state.guestId);
    },

    generateGuestId: (state) => {
      state.guestId = `guest_${new Date().getTime()}`;
      localStorage.setItem("guestId", state.guestId);
    },
  },

  extraReducers: (builder) => {
    builder
    .addCase(loginUser.pending, (state) => {
      state.loading = true;
      state.error = null;
    })
    .addCase(loginUser.fulfilled, (state, action) => {
        state.loading = false;
        state.user = action.payload.user;
        state.token = action.payload.token;
    })
    .addCase(loginUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload?.message || action.error?.message || 'Lỗi không xác định';
    })
    .addCase(registerUser.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(registerUser.fulfilled, (state, action) => {
          state.loading = false;
          state.user = action.payload.user;
          state.token = action.payload.token;
      })
      .addCase(registerUser.rejected, (state, action) => {
          state.loading = false;
          state.error = action.payload?.message || action.error?.message || 'Lỗi không xác định';
      })
    .addCase(loginAdmin.pending, (state) => {
      state.loading = true;
      state.error = null;
    })
    .addCase(loginAdmin.fulfilled, (state, action) => {
      state.loading = false;
      state.user = action.payload.user;
      state.token = action.payload.token;
      state.isAdminAuthenticated = true;
    })
    .addCase(loginAdmin.rejected, (state, action) => {
      state.loading = false;
      state.error = action.payload?.message || action.error?.message || 'Lỗi không xác định';
      state.isAdminAuthenticated = false; // Đảm bảo luôn false khi login fail
    })
  },
});

export const { logout, generateGuestId } = authSlice.actions;
export default authSlice.reducer;
