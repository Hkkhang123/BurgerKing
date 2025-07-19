import React, { useState, useCallback } from 'react';
import { NotificationContext } from './NotificationContext.js';
import NotificationToast from '../widgets/NotificationToast';

export const NotificationProvider = ({ children }) => {
  const [notifications, setNotifications] = useState([]);

  const removeNotification = useCallback((id) => {
    setNotifications(prev => prev.filter(notification => notification.id !== id));
  }, []);

  const showNotification = useCallback((message, type = 'info', duration = 5000) => {
    const id = Date.now() + Math.random();
    const newNotification = {
      id,
      message,
      type,
      duration
    };

    setNotifications(prev => [...prev, newNotification]);

    // Tự động xóa sau khi hết thời gian
    setTimeout(() => {
      removeNotification(id);
    }, duration);
  }, [removeNotification]);

  const showOrderNotification = useCallback((orderCode, totalPrice) => {
    showNotification(
      `🛒 Đơn hàng mới #${orderCode} - ${totalPrice.toLocaleString('vi-VN')}đ`,
      'success',
      8000
    );
  }, [showNotification]);

  const value = {
    showNotification,
    showOrderNotification,
    removeNotification
  };

  return (
    <NotificationContext.Provider value={value}>
      {children}
      {/* Render tất cả notifications */}
      {notifications.map((notification, index) => (
        <div
          key={notification.id}
          style={{
            position: 'fixed',
            top: `${20 + (index * 80)}px`,
            right: '20px',
            zIndex: 1000 - index,
            maxWidth: '400px',
            width: '100%'
          }}
        >
          <NotificationToast
            message={notification.message}
            type={notification.type}
            duration={notification.duration}
            onClose={() => removeNotification(notification.id)}
          />
        </div>
      ))}
    </NotificationContext.Provider>
  );
}; 