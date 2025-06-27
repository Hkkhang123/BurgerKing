const product = [
  // ===== ĐỒ ĂN =====
  {
    name: "Burger Bò Phô Mai",
    description: "Burger bò thơm ngon với phô mai tan chảy, rau xanh tươi và sốt đặc biệt",
    price: 85000,
    discountPrice: 75000,
    sku: "BURGER-001",
    category: "Đồ ăn",
    material: "Bò, phô mai, rau xanh, bánh mì",
    image: [
      {
        url: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500",
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
    category: "Đồ ăn",
    material: "Gà rán, mayonnaise, rau củ, bánh mì",
    image: [
      {
        url: "https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=500",
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
  {
    name: "Burger Bacon",
    description: "Burger với bacon nướng thơm, phô mai và sốt BBQ đậm đà",
    price: 90000,
    discountPrice: 80000,
    sku: "BURGER-003",
    category: "Đồ ăn",
    material: "Bacon, phô mai, sốt BBQ, bánh mì",
    image: [
      {
        url: "https://images.unsplash.com/photo-1553979459-d2229ba7433b?w=500",
        altText: "Burger bacon"
      }
    ],
    rating: 4.7,
    numReviews: 156,
    tag: ["burger", "bacon", "BBQ", "đồ ăn"],
    metaTitle: "Burger Bacon - Hương vị đậm đà",
    metaDescription: "Burger bacon với sốt BBQ đặc biệt thơm ngon",
    purchaseCount: 29,
    isFavorite: false
  },
  {
    name: "Gà Rán Giòn",
    description: "Gà rán giòn rụm với lớp vỏ vàng ươm, thịt mềm ngọt",
    price: 120000,
    discountPrice: 100000,
    sku: "CHICKEN-001",
    category: "Đồ ăn",
    material: "Gà tươi, bột chiên, gia vị",
    image: [
      {
        url: "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500",
        altText: "Gà rán giòn"
      }
    ],
    rating: 4.6,
    numReviews: 203,
    tag: ["gà", "rán", "giòn", "đồ ăn"],
    metaTitle: "Gà Rán Giòn - Giòn tan hương vị",
    metaDescription: "Gà rán giòn với lớp vỏ vàng ươm thơm ngon",
    purchaseCount: 14,
    isFavorite: false
  },
  {
    name: "Khoai Tây Chiên",
    description: "Khoai tây chiên giòn với muối và gia vị đặc biệt",
    price: 35000,
    discountPrice: 30000,
    sku: "FRIES-001",
    category: "Đồ ăn",
    material: "Khoai tây, dầu ăn, muối, gia vị",
    image: [
      {
        url: "https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500",
        altText: "Khoai tây chiên"
      }
    ],
    rating: 4.4,
    numReviews: 167,
    tag: ["khoai tây", "chiên", "snack", "đồ ăn"],
    metaTitle: "Khoai Tây Chiên - Giòn tan",
    metaDescription: "Khoai tây chiên giòn với gia vị đặc biệt",
    purchaseCount: 25,
    isFavorite: false
  },
  {
    name: "Cánh Gà Nướng",
    description: "Cánh gà nướng mật ong với sốt BBQ đậm đà",
    price: 85000,
    discountPrice: 75000,
    sku: "WINGS-001",
    category: "Đồ ăn",
    material: "Cánh gà, mật ong, sốt BBQ",
    image: [
      {
        url: "https://images.unsplash.com/photo-1567620832904-9d843b3c8b10?w=500",
        altText: "Cánh gà nướng"
      }
    ],
    rating: 4.5,
    numReviews: 89,
    tag: ["cánh gà", "nướng", "BBQ", "đồ ăn"],
    metaTitle: "Cánh Gà Nướng - Hương vị đặc biệt",
    metaDescription: "Cánh gà nướng mật ong với sốt BBQ",
    purchaseCount: 19,
    isFavorite: false
  },

  // ===== THỨC UỐNG =====
  {
    name: "Coca Cola",
    description: "Nước ngọt Coca Cola mát lạnh, hương vị đặc trưng",
    price: 25000,
    discountPrice: 20000,
    sku: "DRINK-001",
    category: "Thức uống",
    material: "Nước có ga, đường, hương liệu",
    image: [
      {
        url: "https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=500",
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
  {
    name: "Pepsi",
    description: "Nước ngọt Pepsi với hương vị độc đáo",
    price: 25000,
    discountPrice: 20000,
    sku: "DRINK-002",
    category: "Thức uống",
    material: "Nước có ga, đường, hương liệu",
    image: [
      {
        url: "https://images.unsplash.com/photo-1629203851122-3726ecdf080e?w=500",
        altText: "Pepsi"
      }
    ],
    rating: 4.1,
    numReviews: 187,
    tag: ["nước ngọt", "pepsi", "có ga", "thức uống"],
    metaTitle: "Pepsi - Hương vị độc đáo",
    metaDescription: "Nước ngọt Pepsi mát lạnh",
    purchaseCount: 12,
    isFavorite: false
  },
  {
    name: "Sinh Tố Dâu",
    description: "Sinh tố dâu tây tươi ngon với sữa và đá",
    price: 45000,
    discountPrice: 40000,
    sku: "DRINK-003",
    category: "Thức uống",
    material: "Dâu tây, sữa, đường, đá",
    image: [
      {
        url: "https://images.unsplash.com/photo-1505252585461-04db1eb84625?w=500",
        altText: "Sinh tố dâu"
      }
    ],
    rating: 4.6,
    numReviews: 76,
    tag: ["sinh tố", "dâu", "tươi", "thức uống"],
    metaTitle: "Sinh Tố Dâu - Tươi ngon",
    metaDescription: "Sinh tố dâu tây tươi với sữa",
    purchaseCount: 21,
    isFavorite: false
  },
  {
    name: "Sinh Tố Xoài",
    description: "Sinh tố xoài chín ngọt với sữa đặc",
    price: 40000,
    discountPrice: 35000,
    sku: "DRINK-004",
    category: "Thức uống",
    material: "Xoài chín, sữa đặc, đường, đá",
    image: [
      {
        url: "https://images.unsplash.com/photo-1505252585461-04db1eb84625?w=500",
        altText: "Sinh tố xoài"
      }
    ],
    rating: 4.4,
    numReviews: 92,
    tag: ["sinh tố", "xoài", "ngọt", "thức uống"],
    metaTitle: "Sinh Tố Xoài - Ngọt ngào",
    metaDescription: "Sinh tố xoài chín với sữa đặc",
    purchaseCount: 16,
    isFavorite: false
  },
  {
    name: "Cà Phê Sữa Đá",
    description: "Cà phê đậm đà với sữa đặc và đá lạnh",
    price: 35000,
    discountPrice: 30000,
    sku: "DRINK-005",
    category: "Thức uống",
    material: "Cà phê, sữa đặc, đường, đá",
    image: [
      {
        url: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=500",
        altText: "Cà phê sữa đá"
      }
    ],
    rating: 4.3,
    numReviews: 145,
    tag: ["cà phê", "sữa đá", "đậm đà", "thức uống"],
    metaTitle: "Cà Phê Sữa Đá - Đậm đà",
    metaDescription: "Cà phê đậm đà với sữa đặc",
    purchaseCount: 27,
    isFavorite: false
  },
  {
    name: "Trà Sữa Trân Châu",
    description: "Trà sữa thơm ngon với trân châu đen",
    price: 50000,
    discountPrice: 45000,
    sku: "DRINK-006",
    category: "Thức uống",
    material: "Trà, sữa, trân châu, đường",
    image: [
      {
        url: "https://images.unsplash.com/photo-1558857563-b371033873b8?w=500",
        altText: "Trà sữa trân châu"
      }
    ],
    rating: 4.5,
    numReviews: 178,
    tag: ["trà sữa", "trân châu", "ngọt", "thức uống"],
    metaTitle: "Trà Sữa Trân Châu - Thơm ngon",
    metaDescription: "Trà sữa với trân châu đen",
    purchaseCount: 13,
    isFavorite: false
  },

  // ===== ĐỒ ĂN VẶT =====
  {
    name: "Bánh Donut",
    description: "Bánh donut mềm mại với lớp kem ngọt ngào",
    price: 30000,
    discountPrice: 25000,
    sku: "SNACK-001",
    category: "Đồ ăn vặt",
    material: "Bột mì, đường, kem, hương liệu",
    image: [
      {
        url: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500",
        altText: "Bánh donut"
      }
    ],
    rating: 4.4,
    numReviews: 89,
    tag: ["bánh", "donut", "kem", "đồ ăn vặt"],
    metaTitle: "Bánh Donut - Ngọt ngào",
    metaDescription: "Bánh donut mềm với kem ngọt",
    purchaseCount: 22,
    isFavorite: false
  },
  {
    name: "Kem Vanilla",
    description: "Kem vanilla mát lạnh với hương vị thơm ngon",
    price: 35000,
    discountPrice: 30000,
    sku: "SNACK-002",
    category: "Đồ ăn vặt",
    material: "Sữa, kem, vanilla, đường",
    image: [
      {
        url: "https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500",
        altText: "Kem vanilla"
      }
    ],
    rating: 4.6,
    numReviews: 112,
    tag: ["kem", "vanilla", "mát lạnh", "đồ ăn vặt"],
    metaTitle: "Kem Vanilla - Mát lạnh",
    metaDescription: "Kem vanilla thơm ngon mát lạnh",
    purchaseCount: 30,
    isFavorite: false
  },
  {
    name: "Kem Chocolate",
    description: "Kem chocolate đậm đà với hạt cacao",
    price: 40000,
    discountPrice: 35000,
    sku: "SNACK-003",
    category: "Đồ ăn vặt",
    material: "Sữa, kem, chocolate, hạt cacao",
    image: [
      {
        url: "https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=500",
        altText: "Kem chocolate"
      }
    ],
    rating: 4.7,
    numReviews: 98,
    tag: ["kem", "chocolate", "đậm đà", "đồ ăn vặt"],
    metaTitle: "Kem Chocolate - Đậm đà",
    metaDescription: "Kem chocolate với hạt cacao",
    purchaseCount: 11,
    isFavorite: false
  },
  {
    name: "Bánh Muffin",
    description: "Bánh muffin mềm mại với hương vị đặc biệt",
    price: 25000,
    discountPrice: 20000,
    sku: "SNACK-004",
    category: "Đồ ăn vặt",
    material: "Bột mì, trứng, sữa, hương liệu",
    image: [
      {
        url: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=500",
        altText: "Bánh muffin"
      }
    ],
    rating: 4.3,
    numReviews: 67,
    tag: ["bánh", "muffin", "mềm", "đồ ăn vặt"],
    metaTitle: "Bánh Muffin - Mềm mại",
    metaDescription: "Bánh muffin mềm với hương vị đặc biệt",
    purchaseCount: 18,
    isFavorite: false
  },
  {
    name: "Snack Khoai Tây",
    description: "Snack khoai tây giòn với hương vị đặc biệt",
    price: 20000,
    discountPrice: 15000,
    sku: "SNACK-005",
    category: "Đồ ăn vặt",
    material: "Khoai tây, dầu ăn, gia vị",
    image: [
      {
        url: "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500",
        altText: "Snack khoai tây"
      }
    ],
    rating: 4.2,
    numReviews: 156,
    tag: ["snack", "khoai tây", "giòn", "đồ ăn vặt"],
    metaTitle: "Snack Khoai Tây - Giòn tan",
    metaDescription: "Snack khoai tây giòn với gia vị đặc biệt",
    purchaseCount: 24,
    isFavorite: false
  },
  {
    name: "Bánh Cookie",
    description: "Bánh cookie giòn với chocolate chip",
    price: 18000,
    discountPrice: 15000,
    sku: "SNACK-006",
    category: "Đồ ăn vặt",
    material: "Bột mì, chocolate chip, bơ, đường",
    image: [
      {
        url: "https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=500",
        altText: "Bánh cookie"
      }
    ],
    rating: 4.5,
    numReviews: 134,
    tag: ["bánh", "cookie", "chocolate", "đồ ăn vặt"],
    metaTitle: "Bánh Cookie - Giòn ngọt",
    metaDescription: "Bánh cookie giòn với chocolate chip",
    purchaseCount: 15,
    isFavorite: false
  }
];

export default product;