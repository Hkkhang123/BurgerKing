const product = [
  // ===== BURGER =====
  {
    name: "Burger Bò Phô Mai",
    description: "Burger bò thơm ngon với phô mai tan chảy, rau xanh tươi và sốt đặc biệt",
    price: 85000,
    discountPrice: 75000,
    sku: "BURGER-001",
    category: "burger",
    material: "Bò, phô mai, rau xanh, bánh mì",
    image: [
      {
        url: "https://images.pexels.com/photos/1639557/pexels-photo-1639557.jpeg?w=500",
        altText: "Burger bò phô mai"
      }
    ],
    rating: 4.5,
    numReviews: 128,
    tag: ["burger", "bò", "phô mai", "đồ ăn"],
    metaTitle: "Burger Bò Phô Mai - Hương vị đặc biệt",
    metaDescription: "Thưởng thức burger bò với phô mai tan chảy thơm ngon",
    purchaseCount: 17,
    isFavorite: false
  },
  {
    name: "Burger Gà Rán",
    description: "Burger gà rán giòn với sốt mayonnaise và rau củ tươi ngon",
    price: 75000,
    discountPrice: 65000,
    sku: "BURGER-002",
    category: "burger",
    material: "Gà rán, mayonnaise, rau củ, bánh mì",
    image: [
      {
        url: "https://images.pexels.com/photos/1633578/pexels-photo-1633578.jpeg?w=500",
        altText: "Burger gà rán"
      }
    ],
    rating: 4.3,
    numReviews: 95,
    tag: ["burger", "gà", "rán", "đồ ăn"],
    metaTitle: "Burger Gà Rán - Giòn tan hương vị",
    metaDescription: "Burger gà rán giòn với sốt mayonnaise đặc biệt",
    purchaseCount: 23,
    isFavorite: false
  },

  // ===== PIZZA =====
  {
    name: "Pizza Margherita",
    description: "Pizza truyền thống với sốt cà chua, phô mai mozzarella và lá húng quế",
    price: 120000,
    discountPrice: 100000,
    sku: "PIZZA-001",
    category: "pizza",
    material: "Bột pizza, sốt cà chua, phô mai mozzarella, húng quế",
    image: [
      {
        url: "https://images.pexels.com/photos/825661/pexels-photo-825661.jpeg?w=500",
        altText: "Pizza Margherita"
      }
    ],
    rating: 4.6,
    numReviews: 203,
    tag: ["pizza", "margherita", "phô mai", "đồ ăn"],
    metaTitle: "Pizza Margherita - Hương vị truyền thống",
    metaDescription: "Pizza Margherita với phô mai mozzarella thơm ngon",
    purchaseCount: 14,
    isFavorite: false
  },
  {
    name: "Pizza Pepperoni",
    description: "Pizza với pepperoni cay nồng và phô mai tan chảy",
    price: 140000,
    discountPrice: 120000,
    sku: "PIZZA-002",
    category: "pizza",
    material: "Bột pizza, sốt cà chua, pepperoni, phô mai",
    image: [
      {
        url: "https://images.pexels.com/photos/825661/pexels-photo-825661.jpeg?w=500",
        altText: "Pizza Pepperoni"
      }
    ],
    rating: 4.4,
    numReviews: 167,
    tag: ["pizza", "pepperoni", "cay", "đồ ăn"],
    metaTitle: "Pizza Pepperoni - Cay nồng",
    metaDescription: "Pizza Pepperoni với hương vị cay nồng đặc trưng",
    purchaseCount: 25,
    isFavorite: false
  },

  // ===== SUSHI =====
  {
    name: "Sushi California Roll",
    description: "Sushi cuộn với cua, bơ và dưa leo, phủ trứng cá",
    price: 85000,
    discountPrice: 75000,
    sku: "SUSHI-001",
    category: "sushi",
    material: "Cơm sushi, cua, bơ, dưa leo, trứng cá",
    image: [
      {
        url: "https://images.pexels.com/photos/2097090/pexels-photo-2097090.jpeg?w=500",
        altText: "Sushi California Roll"
      }
    ],
    rating: 4.5,
    numReviews: 89,
    tag: ["sushi", "california roll", "cua", "đồ ăn"],
    metaTitle: "Sushi California Roll - Tươi ngon",
    metaDescription: "Sushi California Roll với cua và bơ",
    purchaseCount: 19,
    isFavorite: false
  },

  // ===== MÓN VIỆT =====
  {
    name: "Phở Bò",
    description: "Phở bò truyền thống với nước dùng đậm đà, bánh phở mềm",
    price: 65000,
    discountPrice: 55000,
    sku: "VIETNAMESE-001",
    category: "vietnamese",
    material: "Bánh phở, thịt bò, nước dùng, rau thơm",
    image: [
      {
        url: "https://images.pexels.com/photos/1907244/pexels-photo-1907244.jpeg?w=500",
        altText: "Phở bò"
      }
    ],
    rating: 4.7,
    numReviews: 189,
    tag: ["phở", "bò", "truyền thống", "món việt"],
    metaTitle: "Phở Bò - Truyền thống",
    metaDescription: "Phở bò với nước dùng đậm đà truyền thống",
    purchaseCount: 32,
    isFavorite: false
  },

  // ===== THỨC UỐNG =====
  {
    name: "Coca Cola",
    description: "Nước ngọt Coca Cola mát lạnh, hương vị đặc trưng",
    price: 25000,
    discountPrice: 20000,
    sku: "DRINK-001",
    category: "drink",
    material: "Nước có ga, đường, hương liệu",
    image: [
      {
        url: "https://images.pexels.com/photos/2789328/pexels-photo-2789328.jpeg?w=500",
        altText: "Coca Cola"
      }
    ],
    rating: 4.2,
    numReviews: 234,
    tag: ["nước ngọt", "coca cola", "có ga", "thức uống"],
    metaTitle: "Coca Cola - Hương vị đặc trưng",
    metaDescription: "Nước ngọt Coca Cola mát lạnh",
    purchaseCount: 28,
    isFavorite: false
  },

  // ===== TRÁNG MIỆNG =====
  {
    name: "Kem Chocolate",
    description: "Kem chocolate đậm đà với hạt dẻ giòn",
    price: 35000,
    discountPrice: 30000,
    sku: "DESSERT-001",
    category: "dessert",
    material: "Kem, chocolate, hạt dẻ",
    image: [
      {
        url: "https://images.pexels.com/photos/1352281/pexels-photo-1352281.jpeg?w=500",
        altText: "Kem chocolate"
      }
    ],
    rating: 4.4,
    numReviews: 98,
    tag: ["kem", "chocolate", "ngọt", "tráng miệng"],
    metaTitle: "Kem Chocolate - Đậm đà",
    metaDescription: "Kem chocolate với hạt dẻ giòn",
    purchaseCount: 15,
    isFavorite: false
  }
];

export default product; 