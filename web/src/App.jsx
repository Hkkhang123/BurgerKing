import { Provider } from "react-redux";
import { BrowserRouter, Route, Routes, Navigate } from "react-router-dom";
import { PersistGate } from 'redux-persist/integration/react'
import ProtectedRoute from "./Common/ProtectedRoute";
import AdminLayout from "./Component/Admin/AdminLayout";
import Login from "./pages/Login";
import AdminHomePage from "./pages/AdminHomePage";
import UserManagement from "./Component/Admin/UserManagement";
import ProductManagement from "./Component/Admin/ProductManagement";
import EditProduct from "./Component/Admin/EditProduct";
import NewProduct from "./Component/Admin/NewProduct";
import OrderManagement from "./Component/Admin/OrderManagement";
import NotificationManagement from "./Component/Admin/NotificationManagement";
import { NotificationProvider } from "./shared/contexts/NotificationProvider";
import store, { persistor } from "./redux/store";


function App() {
  return (
    <Provider store={store}>
      <PersistGate loading={null} persistor={persistor}>
        <NotificationProvider>
          <BrowserRouter>
            <Routes>
              <Route path="/login" element={<Login />} />
              {/* Route mặc định chuyển về login */}
              <Route path="/" element={<Navigate to="/login" replace />} />
              <Route
                path="/admin"
                element={
                  <ProtectedRoute>
                    <AdminLayout />
                  </ProtectedRoute>
                }
              >
                <Route path="notification-management" element={<NotificationManagement />} />
                <Route index element={<AdminHomePage />} />
                <Route path="user" element={<UserManagement />} />
                <Route path="product" element={<ProductManagement />} />
                <Route path="product/:id/edit" element={<EditProduct />} />
                <Route path="product/new" element={<NewProduct />} />
                <Route path="order" element={<OrderManagement />} />
              </Route>
            </Routes>
          </BrowserRouter>
        </NotificationProvider>
      </PersistGate>
    </Provider>
  );
}

export default App;
