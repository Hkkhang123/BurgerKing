import React, { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { fetchAllOrder, updateOrder } from "../../redux/slices/adminSlice";

const OrderManagement = () => {
  const dispatch = useDispatch();

  const { orders, loading, error } = useSelector((state) => state.admin);

  // State loading cho từng order
  const [orderLoading, setOrderLoading] = useState({});
  const [message, setMessage] = useState("");

  // XÓA useEffect kiểm tra quyền user và điều hướng về '/'
  useEffect(() => {
    dispatch(fetchAllOrder());
  }, [dispatch]);

  const handleStatusChange = async (orderId, newStatus) => {
    setOrderLoading((prev) => ({ ...prev, [orderId]: true }));
    setMessage("");
    try {
      const result = await dispatch(updateOrder({ id: orderId, status: newStatus }));
      if (result.meta && result.meta.requestStatus === "fulfilled") {
        setMessage("Cập nhật trạng thái thành công!");
        dispatch(fetchAllOrder());
      } else {
        setMessage(result.payload?.message || "Cập nhật thất bại!");
      }
    } catch {
      setMessage("Có lỗi xảy ra khi cập nhật!");
    } finally {
      setOrderLoading((prev) => ({ ...prev, [orderId]: false }));
    }
  };

  if (loading) {
    return <p>Đang tải...</p>;
  }
  if (error) {
    return <p className="text-red-500">Lỗi: {error}</p>;
  }
  return (
    <div className="max-w-7xl mx-auto p-6">
      <h2 className="text-2xl font-bold mb-6">Quản lý đơn hàng</h2>
      {message && (
        <div className="mb-4 text-green-600 font-semibold">{message}</div>
      )}
      <div className="overflow-x-auto shadow-md sm:rounded-lg">
        <table className="min-w-full text-left text-gray-500">
          <thead className="bg-gray-100 text-xs uppercase text-gray-700">
            <tr>
              <th className="py-3 px-4">ID đơn hàng</th>
              <th className="py-3 px-4">Khách hàng</th>
              <th className="py-3 px-4">Tổng tiền</th>
              <th className="py-3 px-4">Trạng thái</th>
              <th className="py-3 px-4">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {orders.length > 0 ? (
              orders.map((order) => (
                <tr
                  key={order._id}
                  className="border-b cursor-pointer hover:bg-gray-50"
                >
                  <td className="py-4 px-4 font-medium text-gray-500 whitespace-nowrap">
                    #{order._id}
                  </td>

                  <td className="p-4">{order.user.name}</td>
                  <td className="p-4">
                    {order.totalPrice.toLocaleString("vi-VN")} VND
                  </td>
                  <td className="p-4">
                    <select
                      value={order.status}
                      onChange={(e) => handleStatusChange(order._id, e.target.value)}
                      disabled={orderLoading[order._id]}
                      className="bg-gray-50 border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2.5"
                    >
                      <option value="Chờ xử lý">Chờ xử lý</option>
                      <option value="Đã hoàn thành">Đã hoàn thành</option>
                      <option value="Đã hủy">Đã hủy</option>
                    </select>
                  </td>
                  <td className="p-4">
                    <button
                      onClick={() => handleStatusChange(order._id, "Đã hoàn thành")}
                      className="bg-green-500 text-white py-2 px-4 rounded hover:bg-green-600"
                      disabled={orderLoading[order._id]}
                    >
                      {orderLoading[order._id] ? "Đang cập nhật..." : "Đánh dấu là đã hoàn thành"}
                    </button>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan={5} className="p-4 text-center text-gray-500">
                  Không tim thấy đơn hàng
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default OrderManagement;
