import React, { useState, useEffect } from 'react';
import { FaBell, FaTimes, FaCheckCircle, FaExclamationTriangle, FaInfoCircle } from 'react-icons/fa';

const NotificationToast = ({ 
  message, 
  type = 'info', 
  duration = 5000, 
  onClose 
}) => {
  const [isVisible, setIsVisible] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => {
      setIsVisible(false);
      setTimeout(() => {
        onClose && onClose();
      }, 300); // Đợi animation fade out
    }, duration);

    return () => clearTimeout(timer);
  }, [duration, onClose]);

  const getIcon = () => {
    switch (type) {
      case 'success':
        return <FaCheckCircle className="text-green-500" size={20} />;
      case 'error':
        return <FaExclamationTriangle className="text-red-500" size={20} />;
      case 'warning':
        return <FaExclamationTriangle className="text-yellow-500" size={20} />;
      default:
        return <FaInfoCircle className="text-blue-500" size={20} />;
    }
  };

  const getBgColor = () => {
    switch (type) {
      case 'success':
        return 'bg-white border-green-200 shadow-lg';
      case 'error':
        return 'bg-white border-red-200 shadow-lg';
      case 'warning':
        return 'bg-white border-yellow-200 shadow-lg';
      default:
        return 'bg-white border-blue-200 shadow-lg';
    }
  };

  if (!isVisible) return null;

  return (
    <div className={`
      ${getBgColor()}
      border rounded-lg p-4 max-w-sm
      transform transition-all duration-300 ease-in-out
      ${isVisible ? 'translate-x-0 opacity-100' : 'translate-x-full opacity-0'}
    `}>
      <div className="flex items-start space-x-3">
        <div className="flex-shrink-0">
          {getIcon()}
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-sm font-medium text-gray-900 leading-5">
            {message}
          </p>
        </div>
        <div className="flex-shrink-0">
          <button
            onClick={() => {
              setIsVisible(false);
              setTimeout(() => onClose && onClose(), 300);
            }}
            className="text-gray-400 hover:text-gray-600 transition-colors p-1"
          >
            <FaTimes size={14} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default NotificationToast; 