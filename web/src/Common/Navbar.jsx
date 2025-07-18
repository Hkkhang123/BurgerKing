import React, { useState } from "react";
import { Link } from "react-router-dom";
import {
  HiOutlineUser,
  HiOutlineShoppingBag,
  HiBars3BottomRight,
} from "react-icons/hi2";
import SearchBar from "./SearchBar";
import CartDrawer from "../Layout/CartDrawer";
import { IoMdClose } from "react-icons/io";
import { useSelector } from "react-redux";
const Navbar = () => {
  const [CartOpen, setCartOpen] = useState(false);
  const [navDrawerOpen, setNavDrawerOpen] = useState(false);
  const { cart } = useSelector((state) => state.cart);
  const { user } = useSelector((state) => state.auth);
  const cartItem =
    cart?.products?.reduce((acc, item) => acc + item.quantity, 0) || 0;

  const toggleCart = () => {
    setCartOpen(!CartOpen);
  };

  const toggleNavDrawer = () => {
    setNavDrawerOpen(!navDrawerOpen);
  };
  return (
    <>
      <nav className="container mx-auto flex items-center justify-between py-4 px-6">
        {/*Logo - Left*/}
        <div>
          <Link to="/" className="text-2xl font-medium">
            E-commerce
          </Link>
        </div>
        {/*Center - Navigation*/}
        <div className="hidden md:flex space-x-6">
          <Link
            to="/collection/all/?gender=Nam"
            className="text-gray-700 hover:text-black font-medium uppercase"
          >
            Nam
          </Link>
          <Link
            to="/collection/all/?gender=Nữ"
            className="text-gray-700 hover:text-black font-medium uppercase"
          >
            Nữ
          </Link>
          <Link
            to="/collection/all/?category=Áo"
            className="text-gray-700 hover:text-black font-medium uppercase"
          >
            Áo
          </Link>
          <Link
            to="/collection/all/?category=Quần"
            className="text-gray-700 hover:text-black font-medium uppercase"
          >
            Quần
          </Link>
        </div>
        {/*Right - Icons*/}
        <div className="flex items-center space-x-4">
          {user && user.role === "admin" && (
            <Link
              to="/admin"
              className="block bg-black px-2 rounded text-sm text-white"
            >
              Admin
            </Link>
          )}
          <Link to="/profile" className="hover:text-black">
            <HiOutlineUser className="size-6 text-gray-700" />
          </Link>
          <button onClick={toggleCart} className="relative hover:text-black">
            <HiOutlineShoppingBag className="size-6 text-gray-700" />
            {cartItem > 0 && (
              <span className="absolute bg-rabbit-red text-white text-xs rounded-full -top-1 px-2 py-0.5">
                {cartItem}
              </span>
            )}
          </button>

          {/*Search*/}
          <SearchBar />

          <button className="md:hidden" onClick={toggleNavDrawer}>
            <HiBars3BottomRight className="size-6 text-gray-700" />
          </button>
        </div>
      </nav>
      <CartDrawer CartOpen={CartOpen} toggleCart={toggleCart} />

      {/* Mobile Navigation */}
      <div
        className={`fixed top-0 left-0 w-3/4 md:w-1/3 sm:w-1/2 h-full bg-white shadow-lg 
    transform transition-transform duration-300 z-50 ${
      navDrawerOpen ? "-translate-x-0" : "-translate-x-full"
    }`}
      >
        <div className="flex justify-end p-4">
          <button onClick={toggleNavDrawer}>
            <IoMdClose className="size-6 text-gray-600" />
          </button>
        </div>
        <div className="p-4">
          <h2 className="text-xl font-semibold mb-4">Menu</h2>
          <nav className="space-y-4">
            <Link
              onClick={toggleNavDrawer}
              to="/collection/all/?gender=Nam"
              className="block py-2 text-gray-600 hover:text-black"
            >
              Nam
            </Link>

            <Link
              onClick={toggleNavDrawer}
              to="/collection/all/?gender=Nữ"
              className="block py-2 text-gray-600 hover:text-black"
            >
              Nữ
            </Link>

            <Link
              onClick={toggleNavDrawer}
              to="/collection/all/?category=Quần"
              className="block py-2 text-gray-600 hover:text-black"
            >
              Quần
            </Link>

            <Link
              onClick={toggleNavDrawer}
              to="/collection/all/?category=Áo"
              className="block py-2 text-gray-600 hover:text-black"
            >
              Áo
            </Link>
          </nav>
        </div>
      </div>
    </>
  );
};

export default Navbar;
