import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axiosInstance from "../../utils/axios";

// Lấy danh sách thông báo
export const getNotifications = createAsyncThunk(
  "notification/getNotifications",
  async (_, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.get("/api/notifications");
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data || { message: "Lỗi không xác định" });
    }
  }
);

// Lấy tất cả thông báo (cho admin)
export const getAllNotifications = createAsyncThunk(
  "notification/getAllNotifications",
  async (_, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.get("/api/notifications/all");
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data || { message: "Lỗi không xác định" });
    }
  }
);

// Đánh dấu tất cả thông báo là đã đọc
export const markAllAsRead = createAsyncThunk(
  "notification/markAllAsRead",
  async (_, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.put("/api/notifications/mark-read");
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data || { message: "Lỗi không xác định" });
    }
  }
);

// Xóa tất cả thông báo
export const deleteAllNotifications = createAsyncThunk(
  "notification/deleteAllNotifications",
  async (_, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.delete("/api/notifications");
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data || { message: "Lỗi không xác định" });
    }
  }
);

// Tạo notification mới
export const createNotification = createAsyncThunk(
  "notification/createNotification",
  async (notificationData, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.post("/api/notifications", notificationData);
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response?.data || { message: "Lỗi không xác định" });
    }
  }
);

const initialState = {
  notifications: [],
  loading: false,
  error: null,
};

const notificationSlice = createSlice({
  name: "notification",
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
    addNotification: (state, action) => {
      state.notifications.unshift(action.payload);
    },
  },
  extraReducers: (builder) => {
    builder
      // getNotifications
      .addCase(getNotifications.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getNotifications.fulfilled, (state, action) => {
        state.loading = false;
        state.notifications = action.payload;
      })
      .addCase(getNotifications.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload?.message || action.error?.message || 'Lỗi không xác định';
      })
      // getAllNotifications
      .addCase(getAllNotifications.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getAllNotifications.fulfilled, (state, action) => {
        state.loading = false;
        state.notifications = action.payload;
      })
      .addCase(getAllNotifications.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload?.message || action.error?.message || 'Lỗi không xác định';
      })
      // markAllAsRead
      .addCase(markAllAsRead.fulfilled, (state) => {
        state.notifications = state.notifications.map(notification => ({
          ...notification,
          isRead: true
        }));
      })
      // deleteAllNotifications
      .addCase(deleteAllNotifications.fulfilled, (state) => {
        state.notifications = [];
      })
      // createNotification
      .addCase(createNotification.fulfilled, (state, action) => {
        state.notifications.unshift(action.payload);
      });
  },
});

export const { clearError, addNotification } = notificationSlice.actions;
export default notificationSlice.reducer; 