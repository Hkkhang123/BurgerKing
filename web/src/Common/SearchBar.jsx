import React, { useState } from 'react'
import { HiMagnifyingGlass } from 'react-icons/hi2'
import { useDispatch } from 'react-redux'
import { useNavigate } from 'react-router-dom'
import { fetchProductsByFilter, setFilters } from '../../redux/slices/productSlice'

const SearchBar = () => {
    const [searchTerm, setSearchTerm] = useState('')
    const [isOpened, setIsOpened] = useState(false)
    const dispatch = useDispatch()

    const navigate = useNavigate()
    const handleSearchToggle = () => {
        setIsOpened(!isOpened)
    }

    const handleSearch = (e) => {
        e.preventDefault()
        dispatch(setFilters({ search: searchTerm }))
        dispatch(fetchProductsByFilter({ search: searchTerm }))
        navigate(`/collection/all/?search=${searchTerm}`)   
        setIsOpened(false)
    }
  return (
    <div className={`flex items-center justify-center w-full transition-all duration-300 ${isOpened ? 
    'absolute top-0 left-0 w-full bg-white h-24 z-50' : 'w-auto'} `}>
        {isOpened ? (
            <form
                onSubmit={handleSearch} 
                className='relative flex items-center justify-center w-full'>
                <div className="relative w-1/2">
                    <input 
                        type="text" 
                        placeholder='Tìm kiếm' 
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className='bg-gray-100 px-4 py-2 pl-2 pr-12 rounded-lg focus:ouline-none w-full placeholder:text-gray-700'
                        value={searchTerm} />
                    
                    <button className='absolute right-2 top-1/2 transform -translate-y-1/2
                    text-gray-600 hover:text-gray-800' type='submit'>
                        <HiMagnifyingGlass className='size-6'/>
                    </button>
                </div>

            </form>
        ) : (
            <button onClick={handleSearchToggle}>
                <HiMagnifyingGlass className='size-6' />
            </button>
        )}
    </div>
  )
}

export default SearchBar