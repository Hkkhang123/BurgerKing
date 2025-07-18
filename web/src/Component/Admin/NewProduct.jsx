import React, { useState } from "react";
import { useNavigate } from "react-router-dom";

const category = [
  "Hamburger", "Khoai tây chiên", "Pizza", "Đồ uống"
];

const NewProduct = () => {
  const navigate = useNavigate();
  const [productData, setProductData] = useState({
    name: "",
    description: "",
    price: 0,
    discountPrice: 0,
    sku: "",
    category: "",
    material: "",
    image: [], // sẽ chỉ dùng để preview
  });
  const [selectedFiles, setSelectedFiles] = useState([]); // lưu file ảnh thực tế
  const [errors, setErrors] = useState({});

  // Validate
  const validate = () => {
    const newErrors = {};
    if (!productData.name) newErrors.name = "Tên sản phẩm là bắt buộc";
    if (!productData.description) newErrors.description = "Mô tả là bắt buộc";
    if (!productData.price || productData.price <= 0) newErrors.price = "Giá phải lớn hơn 0";
    if (!productData.sku) newErrors.sku = "SKU là bắt buộc";
    if (!productData.category) newErrors.category = "Loại sản phẩm là bắt buộc";
    if (productData.image.length === 0) newErrors.image = "Cần ít nhất 1 hình ảnh";
    return newErrors;
  };

  // Khi chọn file, lưu file vào state và tạo preview
  const handleImageChange = (e) => {
    const files = Array.from(e.target.files);
    setSelectedFiles(files);
    setProductData((prevData) => ({
      ...prevData,
      image: files.map((file) => ({ url: URL.createObjectURL(file) })),
    }));
  };

  const handleRemoveImage = (idx) => {
    setSelectedFiles((prev) => prev.filter((_, i) => i !== idx));
    setProductData((prevData) => ({
      ...prevData,
      image: prevData.image.filter((_, i) => i !== idx),
    }));
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setProductData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  // Sửa lại handleSubmit: gửi FormData lên /api/with-image
  const handleSubmit = async (e) => {
    e.preventDefault();
    const newErrors = validate();
    setErrors(newErrors);
    if (Object.keys(newErrors).length > 0) return;
    const formData = new FormData();
    formData.append("name", productData.name);
    formData.append("description", productData.description);
    formData.append("price", productData.price);
    formData.append("discountPrice", productData.discountPrice);
    formData.append("sku", productData.sku);
    formData.append("category", productData.category);
    formData.append("material", productData.material);
    if (selectedFiles[0]) formData.append("image", selectedFiles[0]); // chỉ gửi 1 ảnh, nếu backend hỗ trợ nhiều thì dùng forEach
    await fetch(`${import.meta.env.VITE_BACKEND_URL}/api/products/with-image`, {
      method: "POST",
      body: formData,
      headers: {
        // Không set Content-Type, browser sẽ tự set
        Authorization: `Bearer ${localStorage.getItem("userToken")}`,
      },
    });
    navigate("/admin/product");
  };

  return (
    <div className="max-w-5xl mx-auto p-6 shadow-md">
      <h2 className="text-3xl font-bold mb-6">Thêm sản phẩm</h2>
      <form onSubmit={handleSubmit}>
        {/* Tên sản phẩm */}
        <div className="mb-6">
          <label className="block font-semibold mb-2">Tên sản phẩm</label>
          <input
            type="text"
            name="name"
            value={productData.name}
            onChange={handleChange}
            className="w-full p-2 border rounded-md border-gray-300"
          />
          {errors.name && <p className="text-red-500 text-sm">{errors.name}</p>}
        </div>
        {/* Mô tả */}
        <div className="mb-6">
          <label className="block font-semibold mb-2">Mô tả</label>
          <textarea
            name="description"
            value={productData.description}
            onChange={handleChange}
            className="w-full p-2 border rounded-md border-gray-300"
            rows={4}
          />
          {errors.description && <p className="text-red-500 text-sm">{errors.description}</p>}
        </div>
        {/* Giá */}
        <div className="mb-6">
          <label className="block font-semibold mb-2">Giá</label>
          <input
            type="number"
            name="price"
            min={0}
            value={productData.price}
            className="w-full border border-gray-300 rounded-md p-2"
            onChange={handleChange}
          />
          {errors.price && <p className="text-red-500 text-sm">{errors.price}</p>}
        </div>
        {/* Giá khuyến mãi */}
        <div className="mb-6">
          <label className="block font-semibold mb-2">Giá khuyến mãi</label>
          <input
            type="number"
            name="discountPrice"
            min={0}
            value={productData.discountPrice}
            className="w-full border border-gray-300 rounded-md p-2"
            onChange={handleChange}
          />
        </div>
        {/* SKU */}
        <div className="mb-6">
          <label className="block font-semibold mb-2">SKU</label>
          <input
            type="text"
            name="sku"
            value={productData.sku}
            className="w-full border border-gray-300 rounded-md p-2"
            onChange={handleChange}
          />
          {errors.sku && <p className="text-red-500 text-sm">{errors.sku}</p>}
        </div>
        {/* Loại sản phẩm */}
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
          {errors.category && <p className="text-red-500 text-sm">{errors.category}</p>}
        </div>
        {/* Nguyên liệu */}
        <div className="mb-6">
          <label className="block font-semibold mb-2">Nguyên liệu</label>
          <input
            type="text"
            name="material"
            value={productData.material}
            className="w-full border border-gray-300 rounded-md p-2"
            onChange={handleChange}
          />
        </div>
        {/* Hình ảnh */}
        <div className="mb-6">
          <label className="block font-semibold mb-2">Hình ảnh</label>
          <input type="file" multiple onChange={handleImageChange} />
          {errors.image && <p className="text-red-500 text-sm">{errors.image}</p>}
          <div className="flex gap-4 mt-4 flex-wrap">
            {productData.image.map((img, idx) => (
              <div key={idx} className="relative">
                <img src={img.url} alt="Ảnh sản phẩm" className="size-20 object-cover rounded-md shadow-md" />
                <button type="button" onClick={() => handleRemoveImage(idx)} className="absolute top-0 right-0 bg-red-500 text-white rounded-full px-2 py-1 text-xs">X</button>
              </div>
            ))}
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
