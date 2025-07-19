// Script test để tạo thông báo
const axios = require('axios');

async function testNotification() {
  try {
    console.log('Đang test tạo thông báo...');
    
    // Test endpoint
    const response = await axios.post('https://burgerking-j92p.onrender.com/api/notifications/test', {}, {
      headers: {
        'Content-Type': 'application/json',
        // Thêm token admin nếu cần
      }
    });
    
    console.log('Kết quả:', response.data);
  } catch (error) {
    console.log('Lỗi:', error.response?.data || error.message);
  }
}

testNotification(); 