import { createSlice, createAsyncThunk } from "@reduxjs/toolkit";
import axiosInstance from "../../utils/axios";

export const fetchProductsByFilter = createAsyncThunk(
  "product/fetchProductsByFilter",
  async ({
    collection,
    size,
    color,
    gender,
    minPrice, 
    maxPrice,
    sortBy,
    search,
    category,
    material,
    brand,
    limit,
  }) => {
    const query = new URLSearchParams();
    if (collection) query.append("collection", collection);
    if (size) query.append("size", size);
    if (color) query.append("color", color);
    if (gender) query.append("gender", gender);
    if (minPrice) query.append("minPrice", minPrice);
    if (maxPrice) query.append("maxPrice", maxPrice);
    if (sortBy) query.append("sortBy", sortBy);
    if (search) query.append("search", search);
    if (category) query.append("category", category);
    if (material) query.append("material", material);
    if (brand) query.append("brand", brand);
    if (limit) query.append("limit", limit);

    const response = await axiosInstance.get(`/api/products?${query}`);
    return response.data;
  }
);

export const fetchProductsByDetails = createAsyncThunk(
  "products/fetchProductsByDetails",
  async (id) => {
    const response = await axiosInstance.get(`/api/products/${id}`);
    return response.data;
  }
);

export const updateProduct = createAsyncThunk(
  "products/updateProduct",
  async ({ id, productData }) => {
    const response = await axiosInstance.put(`/api/products/${id}`, productData);
    return response.data;
  }
);

export const fetchSimilarProducts = createAsyncThunk(
  "product/fetchSimilarProducts",
  async ({ id }) => {
    const response = await axiosInstance.get(`/api/products/similar/${id}`);
    return response.data;
  }
);

const productSlice = createSlice({
  name: "products",
  initialState: {
    products: [],
    selectedProduct: null,
    similarProducts: [],
    loading: false,
    error: null,
    filters: {
      category: "",
      size: "",
      color: "",
      gender: "",
      brand: "",
      minPrice: "",
      maxPrice: "",
      sortBy: "",
      search: "",
      material: "",
      collection: "",
    },
  },
  reducers: {
    setFilters: (state, action) => {
      state.filters = { ...state.filters, ...action.payload };
    },
    clearFilters: (state) => {
      state.filters = {
        category: "",
        size: "",
        color: "",
        gender: "",
        brand: "",
        minPrice: "",
        maxPrice: "",
        sortBy: "",
        search: "",
        material: "",
        collection: "",
      };
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchProductsByFilter.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchProductsByFilter.fulfilled, (state, action) => {
        state.loading = false;
        state.products = Array.isArray(action.payload) ? action.payload : [];
      })
      .addCase(fetchProductsByFilter.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload.message;
      })

      //Details

      .addCase(fetchProductsByDetails.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchProductsByDetails.fulfilled, (state, action) => {
        state.loading = false;
        state.selectedProduct = action.payload;
      })
      .addCase(fetchProductsByDetails.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload.message;
      })

      //update

      .addCase(updateProduct.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(updateProduct.fulfilled, (state, action) => {
        state.loading = false;
        state.updateProduct = action.payload;
        const index = state.products.findIndex(
          (product) => product._id === updateProduct._id
        );

        if (index !== -1) {
          state.products[index] = updateProduct;
        }
      })
      .addCase(updateProduct.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload.message;
      })

      //similar

      .addCase(fetchSimilarProducts.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchSimilarProducts.fulfilled, (state, action) => {
        state.loading = false;
        state.similarProducts = action.payload;
      })
      .addCase(fetchSimilarProducts.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload.message;
      });
  },
});

export const { setFilters, clearFilters } = productSlice.actions;
export default productSlice.reducer;
