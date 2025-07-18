import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axiosInstance from "../../utils/axios";

const loadCartFromStorage = () => {
  const storedCart = localStorage.getItem("cart");
  return storedCart ? JSON.parse(storedCart) : {products: []};
};

const saveCartToStorage = (cart) => {
  localStorage.setItem("cart", JSON.stringify(cart));
};

export const fetchCartItems = createAsyncThunk(
  "cart/fetchCart",
  async ({ userId, guestId }, { rejectWithValue }) => {
    try {
      const response = await axiosInstance.get("/api/cart", {
        params: {
          userId,
          guestId,
        },
      });
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

export const addToCart = createAsyncThunk(
  "cart/addToCart",
  async (
    { productId, quantity, size, color, guestId, userId },
    { rejectWithValue } 
  ) => {
    try {
      const response = await axiosInstance.post("/api/cart", { productId, quantity, size, color, guestId, userId });
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

export const updateCartQuantity = createAsyncThunk(
  "cart/updateCartQuantity",
  async ({ productId, quantity, size, color, userId, guestId }) => {
    try {
      const response = await axiosInstance.put("/api/cart", { productId, quantity, size, color, userId, guestId });
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

export const removeFromCart = createAsyncThunk(
  "cart/removeFromCart",
  async ({ productId, size, color, userId, guestId }) => {
    try {
      const response = await axiosInstance.delete("/api/cart", {
        data: { productId, size, color, userId, guestId },
      });
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

export const mergeCart = createAsyncThunk(
  "cart/mergeCart",
  async ({ user, guestId }) => {
    try {
      const response = await axiosInstance.post("/api/cart/merge", { user, guestId });
      return response.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);

const cartSlice = createSlice({
    name: "cart",
    initialState: {
        cartItems: loadCartFromStorage(),
        loading: false,
        error: null,
    },
    reducers: {
        clearCart: (state) => {
            state.cart = {products: []}
            localStorage.removeItem("cart");
        },
    },
    extraReducers: (builder) => {
        builder
        .addCase(fetchCartItems.pending, (state) => {
            state.loading = true;
            state.error = null;
        })
        .addCase(fetchCartItems.fulfilled, (state, action) => {
            state.loading = false
            state.cart = action.payload;
            saveCartToStorage(action.payload);
        })
        .addCase(fetchCartItems.rejected, (state, action) => {
            state.loading = false;
            state.error = action.error || "Failed to fetch cart";
        })

        //add to cart
        
        .addCase(addToCart.pending, (state) => {
            state.loading = true;
            state.error = null;
        })
        .addCase(addToCart.fulfilled, (state, action) => {
            state.loading = false
            state.cart = action.payload;
            saveCartToStorage(action.payload);
        })
        .addCase(addToCart.rejected, (state, action) => {
            state.loading = false;
            state.error = action.payload?.message || "Failed to add to cart";
        })

        //update cart quantity

        .addCase(updateCartQuantity.pending, (state) => {
            state.loading = true;
            state.error = null;
        })
        .addCase(updateCartQuantity.fulfilled, (state, action) => {
            state.loading = false
            state.cart = action.payload;
            saveCartToStorage(action.payload);
        })
        .addCase(updateCartQuantity.rejected, (state, action) => {
            state.loading = false;
            state.error = action.payload?.message || "Failed to update quantity";
        })

        //remove from cart

        .addCase(removeFromCart.pending, (state) => {
            state.loading = true;
            state.error = null;
        })
        .addCase(removeFromCart.fulfilled, (state, action) => {
            state.loading = false
            state.cart = action.payload;
            saveCartToStorage(action.payload);
        })
        .addCase(removeFromCart.rejected, (state, action) => {
            state.loading = false;
            state.error = action.payload?.message || "Failed to remove from cart";
        })
    }
})

export const { clearCart } = cartSlice.actions;
export default cartSlice.reducer;
