import React from "react";
import { Link, NavLink, useNavigate } from "react-router-dom";
import { FaBoxOpen, FaClipboardList, FaSign, FaSignOutAlt, FaStore, FaUser } from "react-icons/fa"
import { useDispatch } from "react-redux";
import { logout } from "../../redux/slices/authSlices";
import { clearCart } from "../../redux/slices/cartSlice";
const AdminSidebar = () => {
  const navigate = useNavigate()
  const dispatch = useDispatch()

  const handleLogout = () => {
    dispatch(logout())
    dispatch(clearCart())
    navigate("/login")
  }
  return (
    <div className="p-6">
      <div className="mb-6">
        <Link to="/admin" className="text-2xl font-semibold">
          E-commerce
        </Link>
      </div>
      <h2 className="text-2xl font-medium mb-6 text-center">Admin Dashboard</h2>

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
<NavLink //  <Link to="/admin/notifications">Quản lý thông báo</Link>
          to="/admin/notifications"
          className={({ isActive }) =>
            isActive
              ? "bg-gray-700 text-white py-3 px-4 rounded flex items-center space-x-2"
              : "text-gray-300 hover:text-white py-3 px-4 rounded flex items-center space-x-2"
          }
        >
          <FaClipboardList />
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
