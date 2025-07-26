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
    purchaseCount: 25,
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
    purchaseCount: 30,
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
    purchaseCount: 22,
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
    purchaseCount: 28,
    isFavorite: false
  },

  // ===== KHOAI TÂY CHIÊN =====
  {
    name: "Khoai tây chiên",
    description: "Khoai tây chiên giòn rụm với muối và gia vị đặc biệt",
    price: 45000,
    discountPrice: 35000,
    sku: "FRIES-001",
    category: "fries",
    material: "Khoai tây, dầu ăn, muối, gia vị",
    image: [
      {
        url: "https://images.pexels.com/photos/1583884/pexels-photo-1583884.jpeg?w=500",
        altText: "Khoai tây chiên"
      }
    ],
    rating: 4.3,
    numReviews: 156,
    tag: ["khoai tây", "chiên", "giòn", "đồ ăn"],
    metaTitle: "Khoai tây chiên - Giòn rụm",
    metaDescription: "Khoai tây chiên giòn rụm với gia vị đặc biệt",
    purchaseCount: 35,
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
    purchaseCount: 40,
    isFavorite: false
  }
];

export default product; 