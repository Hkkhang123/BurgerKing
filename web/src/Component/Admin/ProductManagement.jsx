import React, { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link } from "react-router-dom";
import { deleteProduct, fetchAdminProducts } from "../../redux/slices/adminSlice";

const ProductManagement = () => {
  const dispatch = useDispatch();
  const {products, loading, error} = useSelector(state => state.admin)

  useEffect(() => {
    dispatch(fetchAdminProducts())
  },[dispatch])

  const handleDelete = (id) => {
    if (window.confirm("Bạn có chắc muốn xóa sản phẩm này không ?")) {
      dispatch(deleteProduct(id));
    }
  };

  if(loading) {
    return <p>Đang tải...</p>
  }

  if(error) {
    return <p className="text-red-500">Lỗi: {error}</p>
  }
  return (
    <div className="max-w-7xl mx-auto p-6">
      <h2 className="text-2xl font-bold mb-6">Quản lý sản phẩm</h2>
      <div className="overflow-x-auto shadow-md sm:rounded-lg">
        <table className="min-w-full text-left text-gray-500">
          <thead className="bg-gray-100 text-xs uppercase text-gray-700">
            <tr>
              <th className="py-3 px-4">Tên</th>
              <th className="py-3 px-4">Giá</th>
              <th className="py-3 px-4">SKU</th>
              <th className="py-3 px-4">Hàng động</th>
            </tr>
          </thead>

          <tbody>
            {products.length > 0 ? (
              products.map((product) => (
                <tr
                  key={product._id}
                  className="border-b hover: bg-gray-50 cursor-pointer"
                >
                  <td className="p-4 font-medium text-gray-900 whitespace-nowrap">
                    {product.name}
                  </td>
                  <td className="p-4">
                    {product.price.toLocaleString("vi-VN")} VND
                  </td>
                  <td className="p-4">{product.sku}</td>
                  <td className="p-4">
                    <Link
                      to={`/admin/product/${product._id}/edit`}
                      className="bg-yellow-500 text-white px-2 py-1 rounded mr-2 hover:bg-yellow-600"
                    >
                      Edit
                    </Link>
                    <button
                      onClick={() => handleDelete(product._id)}
                      className="bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600"
                    >
                      Xóa
                    </button>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={4} className="p-4 text-center text-gray-500">
                  {" "}
                  Không tìm thấy sản phẩm.
                </td>
              </tr>
            )}
          </tbody>
        </table>
        
      </div>
      <Link
          to="/admin/product/new"
          className="bg-blue-500 text-white px-4 py-2 rounded mt-4 inline-block hover:bg-blue-600"
        >
          Thêm sản phẩm
        </Link>
    </div>
  );
};

export default ProductManagement;
