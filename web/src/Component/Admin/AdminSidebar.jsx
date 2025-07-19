import React, { useState, useEffect } from "react";
import { Link, NavLink, useNavigate } from "react-router-dom";
import { FaBoxOpen, FaClipboardList, FaSign, FaSignOutAlt, FaStore, FaUser, FaBell } from "react-icons/fa"
import { useDispatch, useSelector } from "react-redux";
import { logout } from "../../redux/slices/authSlices";
import { clearCart } from "../../redux/slices/cartSlice";
import { getAllNotifications } from "../../redux/slices/notificationSlice";

const AdminSidebar = () => {
  const navigate = useNavigate()
  const dispatch = useDispatch()
  const [showNotifications, setShowNotifications] = useState(false);
  const { notifications, loading } = useSelector((state) => state.notification);

  // Tính toán unreadCount trước khi sử dụng
  const unreadCount = notifications.filter(notification => !notification.isRead).length;

  useEffect(() => {
    // Lấy tất cả thông báo cho admin
    dispatch(getAllNotifications());
  }, [dispatch]);

  // Debug logging
  useEffect(() => {
    console.log('🔔 [AdminSidebar] Notifications state:', {
      count: notifications.length,
      unread: unreadCount,
      loading
    });
  }, [notifications, unreadCount, loading]);

  const handleLogout = () => {
    dispatch(logout())
    dispatch(clearCart())
    navigate("/login")
  }

  const toggleNotifications = () => {
    setShowNotifications(!showNotifications);
  };

  return (
    <div className="p-6 relative">
      <div className="mb-6">
        <Link to="/admin" className="text-2xl font-semibold">
          E-commerce
        </Link>
      </div>
      <h2 className="text-2xl font-medium mb-6 text-center">Admin Dashboard</h2>

      {/* Notification Bell */}
      <div className="mb-6 flex justify-center">
        <div className="relative">
          <button 
            onClick={toggleNotifications} 
            className="relative p-3 hover:bg-gray-700 rounded-full transition-colors"
          >
            <FaBell size={20} className="text-gray-300" />
            {unreadCount > 0 && (
              <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full h-5 w-5 flex items-center justify-center">
                {unreadCount}
              </span>
            )}
          </button>
        </div>
      </div>

      {/* Notification Dropdown */}
      {showNotifications && (
        <div className="absolute top-32 left-6 right-6 bg-white shadow-lg rounded-lg border max-h-64 overflow-y-auto z-50">
          <div className="p-3 border-b">
            <h3 className="font-semibold text-gray-800 text-sm">Thông báo</h3>
          </div>
          <div className="p-2">
            {loading ? (
              <div className="text-center py-4 text-gray-500 text-sm">Đang tải...</div>
            ) : notifications.length === 0 ? (
              <div className="text-center py-4 text-gray-500 text-sm">Không có thông báo</div>
            ) : (
              notifications.slice(0, 8).map((notification) => (
                <div
                  key={notification._id}
                  className={`p-2 border-b last:border-b-0 hover:bg-gray-50 cursor-pointer ${
                    !notification.isRead ? 'bg-blue-50' : ''
                  }`}
                >
                  <div className="font-medium text-xs text-gray-800">
                    {notification.title}
                  </div>
                  <div className="text-xs text-gray-600 mt-1 line-clamp-2">
                    {notification.message}
                  </div>
                  <div className="text-xs text-gray-400 mt-1">
                    {new Date(notification.createdAt).toLocaleString('vi-VN')}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      )}

      <nav className="flex flex-col space-y-2">
        <NavLink
          to="/admin/user"
          className={({ isActive }) =>
            isActive
              ? "bg-gray-700 text-white py-3 px-4 rounded flex items-center space-x-2"
              : "text-gray-300 hover:text-white py-3 px-4 rounded flex items-center space-x-2"
          }
        >
          <FaUser />
          <span>User</span>
        </NavLink>

        <NavLink
          to="/admin/product"
          className={({ isActive }) =>
            isActive
              ? "bg-gray-700 text-white py-3 px-4 rounded flex items-center space-x-2"
              : "text-gray-300 hover:text-white py-3 px-4 rounded flex items-center space-x-2"
          }
        >
          <FaBoxOpen />
          <span>Product</span>
        </NavLink>

        <NavLink
          to="/admin/order"
          className={({ isActive }) =>
            isActive
              ? "bg-gray-700 text-white py-3 px-4 rounded flex items-center space-x-2"
              : "text-gray-300 hover:text-white py-3 px-4 rounded flex items-center space-x-2"
          }
        >
          <FaClipboardList />
          <span>Đơn hàng</span>
        </NavLink>

        <NavLink
          to="/admin/notification-management"
          className={({ isActive }) =>
            isActive
              ? "bg-gray-700 text-white py-3 px-4 rounded flex items-center space-x-2"
              : "text-gray-300 hover:text-white py-3 px-4 rounded flex items-center space-x-2"
          }
        >
          <FaBell />
          <span>Quản lý thông báo</span>
        </NavLink>

        <NavLink
          to="/"
          className={({ isActive }) =>
            isActive
              ? "bg-gray-700 text-white py-3 px-4 rounded flex items-center space-x-2"
              : "text-gray-300 hover:text-white py-3 px-4 rounded flex items-center space-x-2"
          }
        >
          <FaStore />
          <span>Về trang chủ</span>
        </NavLink>
        
      </nav>
      <div className="mb-6">
        <button onClick={handleLogout} className="w-full bg-red-500 hover:bg-red-600 text-white py-2 px-4 rounded flex items-center justify-center space-x-2">
          <FaSignOutAlt />
          <span>Đăng xuất</span>
        </button>
      </div>
    </div>
  );
};

export default AdminSidebar;
