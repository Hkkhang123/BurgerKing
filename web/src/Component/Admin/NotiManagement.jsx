import React, { useState } from "react";
import axios from "../../utils/axios";

const NotiManagement = () => {
  const [title, setTitle] = useState("");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);
  const [successMsg, setSuccessMsg] = useState("");
  const [errorMsg, setErrorMsg] = useState("");

  const handleSendNotification = async () => {
    if (!title.trim() || !message.trim()) {
      setErrorMsg("Vui lòng nhập tiêu đề và nội dung.");
      return;
    }
    setLoading(true);
    setSuccessMsg("");
    setErrorMsg("");

    try {
      await axios.post("api/notifications/send", { title, message });
      setSuccessMsg("Thông báo đã được gửi thành công!");
      setTitle("");
      setMessage("");
    } catch (err) {
      setErrorMsg("Không thể gửi thông báo.");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto bg-white shadow-lg rounded-lg p-6">
      <h2 className="text-2xl font-bold text-gray-800 mb-4">
        Quản lý thông báo
      </h2>

      {successMsg && (
        <div className="mb-4 text-green-700 bg-green-100 p-3 rounded-lg">
          {successMsg}
        </div>
      )}
      {errorMsg && (
        <div className="mb-4 text-red-700 bg-red-100 p-3 rounded-lg">
          {errorMsg}
        </div>
      )}

      <div className="mb-4">
        <label className="block text-gray-700 font-medium mb-2">Tiêu đề</label>
        <input
          type="text"
          className="w-full border border-gray-300 rounded-md p-2 focus:ring-2 focus:ring-blue-400 focus:outline-none"
          placeholder="Nhập tiêu đề thông báo"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
        />
      </div>

      <div className="mb-4">
        <label className="block text-gray-700 font-medium mb-2">
          Nội dung
        </label>
        <textarea
          className="w-full border border-gray-300 rounded-md p-2 focus:ring-2 focus:ring-blue-400 focus:outline-none"
          rows="4"
          placeholder="Nhập nội dung thông báo"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
        ></textarea>
      </div>

      <button
        onClick={handleSendNotification}
        disabled={loading}
        className={`w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 rounded-lg transition duration-200 ${
          loading ? "opacity-70 cursor-not-allowed" : ""
        }`}
      >
        {loading ? "Đang gửi..." : "Gửi thông báo"}
      </button>
    </div>
  );
};

export default NotiManagement;
