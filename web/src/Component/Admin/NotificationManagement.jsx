import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { FaBell, FaCheck, FaTrash, FaEye } from 'react-icons/fa';
import { getAllNotifications, markAllAsRead, deleteAllNotifications } from '../../redux/slices/notificationSlice';
import { useNotification } from '../../shared/hooks/useNotification';

const NotificationManagement = () => {
  const dispatch = useDispatch();
  const { notifications, loading } = useSelector((state) => state.notification);
  const [selectedNotification, setSelectedNotification] = useState(null);
  const { showNotification } = useNotification();

  useEffect(() => {
    dispatch(getAllNotifications());
  }, [dispatch]);

  const handleMarkAllAsRead = async () => {
    try {
      await dispatch(markAllAsRead()).unwrap();
      showNotification('Đã đánh dấu tất cả thông báo là đã đọc!', 'success');
    } catch (error) {
      showNotification('Lỗi khi đánh dấu thông báo: ' + error.message, 'error');
    }
  };

  const handleDeleteAll = async () => {
    if (window.confirm('Bạn có chắc muốn xóa tất cả thông báo?')) {
      try {
        await dispatch(deleteAllNotifications()).unwrap();
        showNotification('Đã xóa tất cả thông báo!', 'success');
      } catch (error) {
        showNotification('Lỗi khi xóa thông báo: ' + error.message, 'error');
      }
    }
  };

  const unreadCount = notifications.filter(notification => !notification.isRead).length;

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleString('vi-VN');
  };

  const getNotificationIcon = (title) => {
    if (title.includes('Đơn hàng mới')) {
      return <FaBell className="text-green-500" />;
    } else if (title.includes('Thanh toán')) {
      return <FaCheck className="text-blue-500" />;
    }
    return <FaBell className="text-gray-500" />;
  };

  return (
    <div className="p-6">
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-800 mb-2">Quản lý thông báo</h1>
        <p className="text-gray-600">Quản lý tất cả thông báo trong hệ thống</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <div className="bg-white p-4 rounded-lg shadow">
          <div className="flex items-center">
            <FaBell className="text-blue-500 text-2xl mr-3" />
            <div>
              <p className="text-sm text-gray-600">Tổng thông báo</p>
              <p className="text-2xl font-bold text-gray-800">{notifications.length}</p>
            </div>
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow">
          <div className="flex items-center">
            <FaEye className="text-green-500 text-2xl mr-3" />
            <div>
              <p className="text-sm text-gray-600">Chưa đọc</p>
              <p className="text-2xl font-bold text-red-500">{unreadCount}</p>
            </div>
          </div>
        </div>
        <div className="bg-white p-4 rounded-lg shadow">
          <div className="flex items-center">
            <FaCheck className="text-gray-500 text-2xl mr-3" />
            <div>
              <p className="text-sm text-gray-600">Đã đọc</p>
              <p className="text-2xl font-bold text-gray-800">{notifications.length - unreadCount}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Actions */}
      <div className="flex flex-wrap gap-4 mb-6">
        <button
          onClick={handleMarkAllAsRead}
          disabled={unreadCount === 0}
          className="bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed flex items-center"
        >
          <FaCheck className="mr-2" />
          Đánh dấu tất cả đã đọc
        </button>
        <button
          onClick={handleDeleteAll}
          disabled={notifications.length === 0}
          className="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 disabled:bg-gray-300 disabled:cursor-not-allowed flex items-center"
        >
          <FaTrash className="mr-2" />
          Xóa tất cả
        </button>
      </div>

      {/* Notifications List */}
      <div className="bg-white rounded-lg shadow">
        <div className="p-4 border-b">
          <h2 className="text-xl font-semibold text-gray-800">Danh sách thông báo</h2>
        </div>
        
        {loading ? (
          <div className="p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500 mx-auto"></div>
            <p className="mt-2 text-gray-600">Đang tải thông báo...</p>
          </div>
        ) : notifications.length === 0 ? (
          <div className="p-8 text-center">
            <FaBell className="text-gray-400 text-4xl mx-auto mb-4" />
            <p className="text-gray-500">Không có thông báo nào</p>
            <p className="text-sm text-gray-400 mt-2">Hãy thử tạo thông báo test hoặc tạo đơn hàng mới</p>
          </div>
        ) : (
          <div className="divide-y">
            {notifications.map((notification) => (
              <div
                key={notification._id}
                className={`p-4 hover:bg-gray-50 cursor-pointer transition-colors ${
                  !notification.isRead ? 'bg-blue-50' : ''
                }`}
                onClick={() => setSelectedNotification(notification)}
              >
                <div className="flex items-start justify-between">
                  <div className="flex items-start space-x-3 flex-1">
                    <div className="mt-1">
                      {getNotificationIcon(notification.title)}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center space-x-2">
                        <h3 className="font-medium text-gray-800">
                          {notification.title}
                        </h3>
                        {!notification.isRead && (
                          <span className="bg-blue-500 text-white text-xs px-2 py-1 rounded-full">
                            Mới
                          </span>
                        )}
                      </div>
                      <p className="text-gray-600 mt-1">{notification.message}</p>
                      <div className="flex items-center space-x-4 mt-2 text-sm text-gray-500">
                        <span>Người nhận: {notification.user?.name || notification.user || 'N/A'}</span>
                        <span>{formatDate(notification.createdAt)}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Notification Detail Modal */}
      {selectedNotification && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-800">Chi tiết thông báo</h3>
              <button
                onClick={() => setSelectedNotification(null)}
                className="text-gray-500 hover:text-gray-700"
              >
                ✕
              </button>
            </div>
            <div className="space-y-3">
              <div>
                <label className="block text-sm font-medium text-gray-700">Tiêu đề:</label>
                <p className="mt-1 text-gray-800">{selectedNotification.title}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Nội dung:</label>
                <p className="mt-1 text-gray-800">{selectedNotification.message}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Người nhận:</label>
                <p className="mt-1 text-gray-800">{selectedNotification.user?.name || selectedNotification.user || 'N/A'}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Thời gian:</label>
                <p className="mt-1 text-gray-800">{formatDate(selectedNotification.createdAt)}</p>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700">Trạng thái:</label>
                <p className="mt-1">
                  <span className={`px-2 py-1 rounded-full text-xs ${
                    selectedNotification.isRead 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-blue-100 text-blue-800'
                  }`}>
                    {selectedNotification.isRead ? 'Đã đọc' : 'Chưa đọc'}
                  </span>
                </p>
              </div>
            </div>
            <div className="mt-6 flex justify-end">
              <button
                onClick={() => setSelectedNotification(null)}
                className="bg-gray-500 text-white px-4 py-2 rounded-lg hover:bg-gray-600"
              >
                Đóng
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default NotificationManagement; 