import React, { useState, useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { useNavigate } from "react-router-dom";
import { loginAdmin } from "../redux/slices/authSlices";

function Login() {
  const dispatch = useDispatch();
  const navigate = useNavigate();
  const { loading, error, isAdminAuthenticated } = useSelector((state) => state.auth);

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  useEffect(() => {
    if (isAdminAuthenticated) {
      navigate("/admin");
    }
  }, [isAdminAuthenticated, navigate]);

  const handleSubmit = (e) => {
    e.preventDefault();
    dispatch(loginAdmin({ email, password }));
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-indigo-100 to-slate-100">
      <form
        onSubmit={handleSubmit}
        className="w-full max-w-md bg-white p-8 rounded-2xl shadow-xl flex flex-col gap-6"
      >
        <h2 className="text-3xl font-bold text-center text-slate-800 mb-2">Admin Login</h2>
        {error && (
          <div className="text-red-500 text-center">{error}</div>
        )}
        <div>
          <label className="block mb-2 text-slate-700 font-semibold">Email</label>
          <input
            type="email"
            className="w-full p-3 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-400"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            autoFocus
          />
        </div>
        <div>
          <label className="block mb-2 text-slate-700 font-semibold">Password</label>
          <input
            type="password"
            className="w-full p-3 border border-slate-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-400"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </div>
        <button
          type="submit"
          className="w-full bg-indigo-600 hover:bg-indigo-700 text-white py-3 rounded-lg font-bold text-lg transition"
          disabled={loading}
        >
          {loading ? "Đang đăng nhập..." : "Đăng nhập"}
        </button>
      </form>
    </div>
  );
}

export default Login;