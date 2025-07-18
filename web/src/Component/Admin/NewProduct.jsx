import React, { useState } from "react";
import { useDispatch } from "react-redux";
import { useNavigate } from "react-router-dom";
import { createProduct } from "../../redux/slices/adminSlice";

const category = [
  "Quần", "Áo"
]

const material = [
  "Vải Cotton",
  "Len",
  "Vải Polyeste",
  "Lụa",
  "Vải Vicose",
  "Vải Fleece",
];
const gender = ["Nam", "Nữ"];

const NewProduct = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const [productData, setProductData] = useState({
    name: "",
    description: "",
    price: 0,
    countInStock: 0,
    sku: "",
    category: "",
    brand: "",
    size: [],
    colors: [],
    collections: "",
    material: "",
    gender: "",
    image: [],
  });
  const [uploading, setUploading] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setProductData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  const handleImageUpload = async (e) => {
    const file = e.target.files[0];
    const formData = new FormData();
    formData.append("image", file);
    try {
      setUploading(true);
      const { data } = await axios.post(
        `${import.meta.env.VITE_BACKEND_URL}/api/upload`,
        formData,
        {
          headers: {
            "Content-Type": "multipart/form-data",
          },
        }
      );
      setProductData((prevData) => ({
        ...prevData,
        image: [...prevData.image, { url: data.imageUrl, altText: "" }],
      }));
      setUploading(false);
    } catch (error) {
      console.error(error);
      setUploading(false);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    dispatch(createProduct(productData));
    navigate("/admin/product");
  };
  return (
    <div className="max-w-5xl mx-auto p-6 shadow-md">
      <h2 className="text-3xl font-bold mb-6">Thêm sản phẩm</h2>
      <form onSubmit={handleSubmit}>
        <div className="mb-6">
          <label className="block font-semibold mb-2">Tên sản phẩm</label>
          <input
            type="text"
            name="name"
            value={productData.name}
            onChange={handleChange}
            className="w-full p-2 border rounded-md border-gray-300"
          />
        </div>

        <div className="mb-6">
          <label className="block font-semibold mb-2">Mô tả</label>
          <textarea
            name="description"
            value={productData.description}
            onChange={handleChange}
            className="w-full p-2 border rounded-md border-gray-300"
            rows={4}
          />
        </div>

        <div className="mb-6">
          <label className="block font-semibold mb-2">Giá</label>
          <input
            type="number"
            name="price"
            step={100000}
            min={0}
            value={productData.price}
            className="w-full border border-gray-300 rounded-md p-2"
            onChange={handleChange}
          />
        </div>

        <div className="mb-6">
          <label className="block font-semibold mb-2">Loại sản phẩm</label>
          <select
            id="category"
            name="category"
            value={productData.category}
            onChange={handleChange}
            className="w-full border border-gray-300 rounded-md p-2"
          >
            <option value="">Loại sản phẩm</option>
            {category.map((item) => (
              <option key={item} value={item}>
                {item}
              </option>
            ))}
          </select>
        </div>

        <div className="mb-6">
          <label className="block font-semibold mb-2">Số lượng tồn kho</label>
          <input
            type="number"
            name="countInStock"
            max={100}
            value={productData.countInStock}
            className="w-full border border-gray-300 rounded-md p-2"
            onChange={handleChange}
          />
        </div>

        <div className="mb-6">
          <label className="block font-semibold mb-2">SKU</label>
          <input
            type="text"
            name="sku"
            value={productData.sku}
            className="w-full border border-gray-300 rounded-md p-2"
            onChange={handleChange}
          />
        </div>

        <div className="mb-6">
          <label className="block font-semibold mb-2">Giới tính</label>
          <select
            id="gender"
            name="gender"
            value={productData.gender}
            onChange={handleChange}
            className="w-full border border-gray-300 rounded-md p-2"
          >
            <option value="">Giới tính</option>
            {gender.map((item) => (
              <option key={item} value={item}>
                {item}
              </option>
            ))}
          </select>
        </div>

        <div className="mb-6">
          <label className="block font-semibold mb-2">Kich cỡ</label>
          <input
            type="text"
            name="size"
            value={productData.size.join(", ")}
            className="w-full border border-gray-300 rounded-md p-2"
            onChange={(e) =>
              setProductData({
                ...productData,
                size: e.target.value.split(",").map((item) => item.trim()),
              })
            }
          />
        </div>

        <div className="mb-6">
          <label className="block font-semibold mb-2">Thương hiệu</label>
          <input
            type="text"
            name="brand"
            value={productData.brand}
            className="w-full border border-gray-300 rounded-md p-2"
            onChange={handleChange}
          />
        </div>

        <div className="mb-6">
          <label className="block font-semibold mb-2">Màu sắc</label>
          <input
            type="text"
            name="color"
            value={productData.colors.join(", ")}
            className="w-full border border-gray-300 rounded-md p-2"
            onChange={(e) =>
              setProductData({
                ...productData,
                colors: e.target.value.split(",").map((item) => item.trim()),
              })
            }
          />
        </div>

        <div className="mb-6">
          <label className="block font-semibold mb-2">Nguyên liệu</label>
          <select
            id="material"
            name="material"
            value={productData.material}
            onChange={handleChange}
            className="w-full border border-gray-300 rounded-md p-2"
          >
            <option value="">Nguyên liệu</option>
            {material.map((item) => (
              <option key={item} value={item}>
                {item}
              </option>
            ))}
          </select>
        </div>

        <div className="mb-6">
          <label className="block font-semibold mb-2">Bộ sưu tập</label>
          <input
            type="text"
            name="collections"
            value={productData.collections}
            className="w-full border border-gray-300 rounded-md p-2"
            onChange={handleChange}
          />
        </div>

        {/* Image */}
        <div className="mb-6">
          <label className="block font-semibold mb-2">Hình ảnh</label>
          <input type="file" onChange={handleImageUpload} value={productData.image} />
          {uploading && <p>Đang tải hình ảnh...</p>}
          <div className="flex gap-4 mt-4">
                {productData.image && (
                    <span className="ml-3 text-sm font-medium text-gray-400">{uploading}</span>
                )}
          </div>
        </div>

        <button
          type="submit"
          className="w-full bg-green-500 text-white py-2 rounded-md hover:bg-green-600 transition-colors"
        >
          Thêm
        </button>
      </form>
    </div>
  );
};

export default NewProduct;
