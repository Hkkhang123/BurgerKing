import React from 'react'
import { IoLogoInstagram } from 'react-icons/io'
import { RiTwitterXLine } from 'react-icons/ri'
import { TbBrandFacebook } from 'react-icons/tb'
import { FiPhoneCall } from 'react-icons/fi'
import { Link } from 'react-router-dom'

const Footer = () => {
  return (
    <footer className='border-t py-12'>
        <div className="container mx-auto grid grid-cols-1 md:grid-cols-4 gap-8 px-4 lg:px-0">
            <div>
                <h3 className="text-lg text-gray-800 mb-4">Thông tin mới nhất</h3>
                <p className="text-gray-500 mb-4">Trở thành người đầu tiên biết về những sản phẩm mới, sự kiện và đề xuất online</p>
                <p className="font-medium text-sm text-gray-600 mb-6">Đăng nhập và nhận giảm giá 10% với đơn đầu tiên.</p>

                {/* form nhập email */}
                <form className='flex'>
                    <input 
                        type="email"
                        placeholder='Nhập email của bạn'
                        className='p-3 w-full text-sm border-t border-l border-b border-gray-300
                        rounded-l-md focus:outline-none focus:ring-2 focus:ring-gray-500 transition-all'
                        required 
                        />
                    <button type='submit' className='bg-black text-white px-6 py-3 text-sm 
                    rounded-r-md hover:bg-gray-800 transition-all'
                    >
                        Đăng ký
                    </button>
                </form>
            </div>
            {/* Shop link */}
            <div className="">
                <h3 className="text-lg text-gray-800 mb-4">
                    Cửa hàng
                </h3>
                <ul>
                    <li>
                        <Link to="#" className=' hover:text-gray-600 transition-colors'>Áo Nam</Link>
                    </li>

                    <li>
                        <Link to="#" className=' hover:text-gray-600 transition-colors'>Áo Nữ</Link>
                    </li>

                    <li>
                        <Link to="#" className=' hover:text-gray-600 transition-colors'>Quần Nam</Link>
                    </li>

                    <li>
                        <Link to="#" className=' hover:text-gray-600 transition-colors'>Quần nữ</Link>
                    </li>
                </ul>
            </div>

            <div className="">
                <h3 className="text-lg text-gray-800 mb-4">
                    Hỗ trợ chúng tôi
                </h3>
                <ul>
                    <li>
                        <Link to="#" className=' hover:text-gray-600 transition-colors'>Liên lạc</Link>
                    </li>

                    <li>
                        <Link to="#" className=' hover:text-gray-600 transition-colors'>Về chúng tôi</Link>
                    </li>

                    <li>
                        <Link to="#" className=' hover:text-gray-600 transition-colors'>FAQs</Link>
                    </li>

                    <li>
                        <Link to="#" className=' hover:text-gray-600 transition-colors'>Features</Link>
                    </li>
                </ul>
            </div>

            {/* Follow */}
            <div className="">
                <h3 className="text-lg text-gray-800 mb-4">Theo dõi chúng tôi</h3>
                <div className="flex items-center space-x-4 mb-6">
                    <a 
                        href="https://www.facebook.com/" 
                        className="hover:text-gray-500"
                        target='_blank'
                        rel='noopener noreferrer'
                    >
                        <TbBrandFacebook className='size-5' />
                    </a>

                    <a 
                        href="https://www.facebook.com/" 
                        className="hover:text-gray-500"
                        target='_blank'
                        rel='noopener noreferrer'
                    >
                        <IoLogoInstagram className='size-5' />
                    </a>

                    <a 
                        href="https://www.facebook.com/" 
                        className="hover:text-gray-500"
                        target='_blank'
                        rel='noopener noreferrer'
                    >
                        <RiTwitterXLine className='size-4' />
                    </a>
                </div>
                <p className="text-gray-500">Liên hệ chúng tôi</p>
                <p>
                    <FiPhoneCall className='inline-block mr-2' />
                    123-456-789
                </p>
            </div>
        </div>

        <div className="container mx-auto mt-12 px-4 lg:px-0 border-t border-gray-200 pt-6">
            <p className='text-gray-500 text-sm tracking-tighter text-center'>
                2025. All Right Reverse
            </p>
        </div>
    </footer>
  )
}

export default Footer