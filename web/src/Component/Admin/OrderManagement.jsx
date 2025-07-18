import React, { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import { fetchAllOrder, updateOrder } from "../../redux/slices/adminSlice";

const OrderManagement = () => {
  const dispatch = useDispatch();
  const navigate = useNavigate();

  const { user } = useSelector((state) => state.auth);
  const { orders, loading, error } = useSelector((state) => state.admin);

  useEffect(() => {
    if (!user || user.role !== "admin") {
      navigate("/");
    } else {
      dispatch(fetchAllOrder());
    }
  }, [dispatch, navigate, user]);

  const handleStatusChange = (orderId, newStatus) => {
    dispatch(updateOrder({ id: orderId, status: newStatus }));
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
                      onChange={(e) =>
                        handleStatusChange(order._id, e.target.value)
                      }
                      className="bg-gray-50 border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block p-2.5"
                    >
                      <option value="Đang xử lý">Đang xử lý</option>
                      <option value="Đã gửi đi">Đã gửi đi</option>
                      <option value="Đã giao hàng">Đã giao hàng</option>
                      <option value="Đã hủy">Đã hủy</option>
                    </select>
                  </td>
                  <td className="p-4">
                    <button
                      onClick={() =>
                        handleStatusChange(order._id, "Đã giao hàng")
                      }
                      className="bg-green-500 text-white py-2 px-4 rounded hover:bg-green-600"
                    >
                      Đánh dấu là đã giao hàng
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
