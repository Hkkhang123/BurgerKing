import React, { useState, useEffect } from 'react';
import { FaBars } from 'react-icons/fa';
import { useDispatch, useSelector } from 'react-redux';
import { useNotification } from '../../shared/hooks/useNotification';
import { getAllNotifications } from '../../redux/slices/notificationSlice';
import AdminSidebar from './AdminSidebar';
import { Outlet } from 'react-router-dom';

const AdminLayout = () => {
  const [isSideBar, setIsSideBar] = useState(false);
  const dispatch = useDispatch();
  const { showOrderNotification } = useNotification();
  const { notifications } = useSelector((state) => state.notification);

  const toggleSideBar = () => {
    setIsSideBar(!isSideBar);
  };

  // Lắng nghe thông báo mới
  useEffect(() => {
    // Lấy thông báo ban đầu
    dispatch(getAllNotifications());

    // Polling nhẹ để kiểm tra thông báo mới mỗi 30 giây (thay vì 10 giây)
    const interval = setInterval(() => {
      dispatch(getAllNotifications());
    }, 30000);

    return () => clearInterval(interval);
  }, [dispatch]);

  // Kiểm tra thông báo đơn hàng mới
  useEffect(() => {
    const orderNotifications = notifications.filter(
      notification => 
        notification.title.includes('Đơn hàng mới') && 
        !notification.isRead &&
        new Date(notification.createdAt) > new Date(Date.now() - 30000) // Chỉ xem thông báo trong 30 giây qua
    );

    orderNotifications.forEach(notification => {
      // Trích xuất thông tin từ message
      const message = notification.message;
      const orderCodeMatch = message.match(/#([A-Z0-9]+)/);
      const priceMatch = message.match(/với tổng tiền ([\d,]+)đ/);
      
      if (orderCodeMatch && priceMatch) {
        const orderCode = orderCodeMatch[1];
        const price = parseInt(priceMatch[1].replace(/,/g, ''));
        showOrderNotification(orderCode, price);
      }
    });
  }, [notifications, showOrderNotification]);

  return (
    <div className="min-h-screen flex flex-col md:flex-row relative bg-gray-100">
      {/* Mobile toggle button */}
      <div className="flex md:hidden p-4 bg-gray-900 text-white z-20 items-center">
        <button onClick={toggleSideBar}>
          <FaBars size={24} />
        </button>
        <h1 className="ml-4 text-xl font-medium">Admin Dashboard</h1>
      </div>

      {/* Overlay for mobile sidebar */}
      {isSideBar && (
        <div
          className="fixed inset-0 bg-black bg-opacity-40 z-10 md:hidden"
          onClick={toggleSideBar}
        />
      )}

      {/* Sidebar */}
      <div
        className={`bg-gray-900 w-64 min-h-screen text-white absolute md:relative transform
        ${isSideBar ? 'translate-x-0' : '-translate-x-full'}
        transition-transform duration-300 md:translate-x-0 md:static md:block z-20`}
      >
        <AdminSidebar />
      </div>

      {/* Main content */}
      <div className="flex-grow p-6 overflow-auto">
        <Outlet />
      </div>
    </div>
  );
};

export default AdminLayout;
