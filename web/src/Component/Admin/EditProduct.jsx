import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useNavigate, useParams } from "react-router-dom";
import { fetchProductsByDetails } from "../../redux/slices/productSlice";
import axiosInstance from "../../utils/axios";
import { updateProduct } from "../../redux/slices/adminSlice";

const EditProduct = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const {id} = useParams();
  const {selectedProduct, loading, error} = useSelector(state => state.products)
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
    collection: "",
    material: "",
    gender: "",
    image: [],
  });

  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    if(id) {
      dispatch(fetchProductsByDetails(id))
    }
  },[id, dispatch])

useEffect(() => {
  if(selectedProduct) {
    setProductData(selectedProduct)
  }
}, [selectedProduct])

  const handleChange = (e) => {
    const { name, value } = e.target;
    setProductData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  };

  const handleImageUpload = async(e) => {
    const file = e.target.files[0];
    const formData = new FormData();
    formData.append("image", file);
    try {
      setUploading(true);
      const {data} = await axiosInstance.post("/api/upload", formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        }
      });
      setProductData((prevData) => ({
        ...prevData,
        image: [...prevData.image, {url: data.imageUrl, altText: ""}],
      }))
      setUploading(false);
    } catch (error) {
      console.error(error);
      setUploading(false);
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    dispatch(updateProduct({id, productData}));
    navigate("/admin/product");
  };

  if(loading) {
    return <p>Đang tải...</p>
  }

  if(error) {
    return <p className="text-red-500">Lỗi: {error}</p>
  }
  return (
    <div className="max-w-5xl mx-auto p-6 shadow-md">
      <h2 className="text-3xl font-bold mb-6">Chỉnh sửa sản phẩm</h2>
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
            value={productData.price}
            className="w-full border border-gray-300 rounded-md p-2"
            onChange={handleChange}
          />
        </div>

        <div className="mb-6">
          <label className="block font-semibold mb-2">Số lượng tồn kho</label>
          <input
            type="number"
            name="countInStock"
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

        {/* Image */}
        <div className="mb-6">
          <label className="block font-semibold mb-2">Hình ảnh</label>
          <input type="file" onChange={handleImageUpload} />
          {uploading && <p>Đang tải hình ảnh...</p>}
          <div className="flex gap-4 mt-4">
            {productData.image.map((image, index) => (
              <div key={index}>
                <img
                  src={image.url}
                  alt={image.altText || "ảnh sản phẩm"}
                  className="size-20 object-cover rounded-md shadow-md"
                />
              </div>
            ))}
          </div>
        </div>

        <button
          type="submit"
          className="w-full bg-green-500 text-white py-2 rounded-md hover:bg-green-600 transition-colors"
        >
          Cập nhật
        </button>
      </form>
    </div>
  );
};

export default EditProduct;
