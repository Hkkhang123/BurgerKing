import Product from "../models/Product.js";
import cloudinary from "../config/cloudinary.js";
import streamifier from "streamifier";
import User from "../models/User.js";

export const createProducts = async (req, res) => {
  try {
    const {
      name,
      description,
      price,
      discountPrice,
      category,
      material,
      sku,
      image,
      tag,
    } = req.body;

    let uploadedImages = [];

    // Xử lý image từ request body (URL)
    if (Array.isArray(image)) {
      for (const img of image) {
        if (img.url) {
          // Kiểm tra xem URL đã là Cloudinary URL chưa
          if (img.url.includes('cloudinary.com')) {
            // Nếu đã là Cloudinary URL, sử dụng trực tiếp
            uploadedImages.push({
              url: img.url,
              altText: img.altText || "",
            });
          } else {
            // Nếu là URL khác, upload lên Cloudinary
            try {
              const cloudinaryRes = await cloudinary.uploader.upload(img.url, {
                folder: "product",
              });
              uploadedImages.push({
                url: cloudinaryRes.secure_url,
                altText: img.altText || "",
              });
            } catch (uploadError) {
              console.error("Lỗi upload image:", uploadError);
              // Nếu upload thất bại, vẫn lưu URL gốc
              uploadedImages.push({
                url: img.url,
                altText: img.altText || "",
              });
            }
          }
        }
      }
    }

    // Xử lý file upload từ multer (nếu có)
    if (req.files && req.files.length > 0) {
      for (const file of req.files) {
        try {
          const streamUpload = (fileBuffer) => {
            return new Promise((resolve, reject) => {
              const stream = cloudinary.uploader.upload_stream(
                {
                  folder: "product",
                  resource_type: "auto"
                },
                (error, result) => {
                  if (result) {
                    resolve(result)
                  } else {
                    reject(error)
                  }
                }
              )
              streamifier.createReadStream(fileBuffer).pipe(stream)
            })
          }
          
          const cloudinaryRes = await streamUpload(file.buffer);
          uploadedImages.push({
            url: cloudinaryRes.secure_url,
            altText: file.originalname || "",
          });
        } catch (uploadError) {
          console.error("Lỗi upload file:", uploadError);
        }
      }
    }

    // Xử lý single file upload (nếu có)
    if (req.file) {
      try {
        const streamUpload = (fileBuffer) => {
          return new Promise((resolve, reject) => {
            const stream = cloudinary.uploader.upload_stream(
              {
                folder: "product",
                resource_type: "auto"
              },
              (error, result) => {
                if (result) {
                  resolve(result)
                } else {
                  reject(error)
                }
              }
            )
            streamifier.createReadStream(fileBuffer).pipe(stream)
          })
        }
        
        const cloudinaryRes = await streamUpload(req.file.buffer);
        uploadedImages.push({
          url: cloudinaryRes.secure_url,
          altText: req.file.originalname || "",
        });
      } catch (uploadError) {
        console.error("Lỗi upload single file:", uploadError);
      }
    }

    const product = new Product({
      name,
      description,
      price,
      discountPrice,
      category,
      material,
      sku,
      image: uploadedImages,
      tag,
      user: req.user._id,
    });
    const createdProduct = await product.save();
    res.status(201).json(createdProduct);
  } catch (error) {
    res.status(400).json({ message: "Loi tao san pham", error: error.message });
  }
};

export const updateProduct = async (req, res) => {
  try {
    const {
      name,
      description,
      price,
      discountPrice,
      category,
      material,
      sku,
      image,
      tag,
    } = req.body;

    const product = await Product.findById(req.params.id);
    if (product) {
      product.name = name || product.name;
      product.description = description || product.description;
      product.price = price || product.price;
      product.discountPrice = discountPrice || product.discountPrice;
      product.category = category || product.category;
      product.material = material || product.materials;
      product.sku = sku || product.sku;
      product.image = image || product.image;
      product.tag = tag || product.tag;

      const updatedProduct = await product.save();
      res.json(updatedProduct);
    } else {
      res.status(404).json({ message: "Product not found" });
    }
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const deleteProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (product) {
      await product.deleteOne();
      res.json({ message: "Product removed" });
    } else {
      res.status(404).json({ message: "Product not found" });
    }
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const getProducts = async (req, res) => {
  try {
    const {
      minPrice,
      maxPrice,
      sortBy,
      search,
      category,
      minRating,
      limit,
      page,
    } = req.query;

    let query = {};

    // Filter theo danh mục món ăn
    if (category && category.toLowerCase() !== "all") {
      query.category = category;
    }

    // Filter theo khoảng giá
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }

    // Filter theo đánh giá
    if (minRating) {
      query.rating = { $gte: Number(minRating) };
    }

    // Tìm kiếm theo tên hoặc mô tả
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: "i" } },
        { description: { $regex: search, $options: "i" } },
      ];
    }

    // Sắp xếp theo các tiêu chí
    let sort = {};
    if (sortBy) {
      switch (sortBy) {
        case "priceAsc":
          sort = { price: 1 }; // Giá tăng dần
          break;
        case "priceDesc":
          sort = { price: -1 }; // Giá giảm dần
          break;
        case "ratingDesc":
          sort = { rating: -1 }; // Đánh giá cao nhất
          break;
        case "ratingAsc":
          sort = { rating: 1 }; // Đánh giá thấp nhất
          break;
        case "newest":
          sort = { createdAt: -1 }; // Mới nhất
          break;
        case "oldest":
          sort = { createdAt: 1 }; // Cũ nhất
          break;
        case "popularity":
          sort = { purchaseCount: -1 }; // Phổ biến nhất
          break;
        default:
          sort = { createdAt: -1 }; // Mặc định sắp xếp theo thời gian tạo mới nhất
          break;
      }
    } else {
      // Mặc định sắp xếp theo thời gian tạo mới nhất
      sort = { createdAt: -1 };
    }

    // Pagination
    const pageNumber = Number(page) || 1;
    const limitNumber = Number(limit) || 10;
    const skip = (pageNumber - 1) * limitNumber;

    let products = await Product.find(query)
      .sort(sort)
      .skip(skip)
      .limit(limitNumber);
    
    res.json(products);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

export const getProductById = async (req, res) => {
  try {
    const products = await Product.findById(req.params.id);
    if (products) {
      res.json(products);
    } else {
      res.status(404).json({ message: "Product not found" });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getSimilarProducts = async (req, res) => {
  const { id } = req.params;
  try {
    const product = await Product.findById(id);

    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }

    const getSimilarProducts = await Product.find({
      _id: { $ne: id },
      category: product.category,
    }).limit(4);

    res.json(getSimilarProducts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getBestSellerProducts = async (req, res) => {
  try {
    const bestSellers = await Product.find({ purchaseCount: { $gt: 20 } })
      .sort({ purchaseCount: -1 });
    if (bestSellers && bestSellers.length > 0) {
      res.json(bestSellers);
    } else {
      res.status(404).json({ message: "No best seller products found" });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

export const getNewArrivalProducts = async (req, res) => {
  try {
    const newArrival = await Product.find().sort({ createdAt: -1 }).limit(8);
    res.json(newArrival);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Toggle sản phẩm yêu thích cho user hiện tại
export const toggleFavoriteProduct = async (req, res) => {
  try {
    const userId = req.user._id;
    const { productId } = req.params;
    
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    
    // Convert productId to string for comparison
    const productIdStr = productId.toString();
    const index = user.favorites.findIndex(
      (id) => id.toString() === productIdStr
    );
    
    let action = '';
    if (index > -1) {
      // Đã có, xóa khỏi favorites
      user.favorites.splice(index, 1);
      action = 'removed';
    } else {
      // Chưa có, thêm vào favorites
      user.favorites.push(productId);
      action = 'added';
    }
    
    await user.save();
    
    // Convert ObjectIds to strings for response
    const favoritesStrings = user.favorites.map(id => id.toString());
    
    res.json({ 
      message: `Favorite ${action} successfully`, 
      favorites: favoritesStrings,
      action: action
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Lấy danh sách đánh giá của sản phẩm
export const getProductReviews = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id).select('reviews');
    if (!product) return res.status(404).json({ message: 'Product not found' });
    res.json(product.reviews);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Thêm đánh giá mới cho sản phẩm
export const addProductReview = async (req, res) => {
  try {
    const { rating, comment } = req.body;
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ message: 'Product not found' });

    // Kiểm tra nếu user đã đánh giá
    const alreadyReviewed = product.reviews.find(
      (r) => r.user.toString() === req.user._id.toString()
    );
    if (alreadyReviewed) {
      return res.status(400).json({ message: 'Bạn đã đánh giá sản phẩm này rồi' });
    }

    const review = {
      user: req.user._id,
      name: req.user.name,
      rating: Number(rating),
      comment,
    };
    product.reviews.push(review);
    product.numReviews = product.reviews.length;
    product.rating =
      product.reviews.reduce((acc, item) => item.rating + acc, 0) /
      product.reviews.length;
    await product.save();
    res.status(201).json({ message: 'Đã thêm đánh giá' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Lấy nhiều sản phẩm theo danh sách ID
export const getProductsByIds = async (req, res) => {
  try {
    const { ids } = req.body; // ids là mảng ID
    if (!Array.isArray(ids) || ids.length === 0) {
      return res.status(400).json({ message: "Danh sách ID không hợp lệ" });
    }
    const products = await Product.find({ _id: { $in: ids } });
    res.json({ success: true, products });
  } catch (error) {
    res.status(500).json({ message: "Lỗi server", error: error.message });
  }
};
