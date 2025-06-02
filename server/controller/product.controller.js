import Product from "../models/Product.js";
import cloudinary from "../config/cloudinary.js";
export const createProducts = async (req, res) => {
  try {
    const {
      name,
      description,
      price,
      discountPrice,
      countInStock,
      category,
      material,
      sku,
      image,
      tag,
      dimension,
      weight,
    } = req.body;

    let uploadedImages = [];

    if (Array.isArray(image)) {
      for (const img of image) {
        if (img.url) {
          const cloudinaryRes = await cloudinary.uploader.upload(img.url, {
            folder: "product",
          });
          uploadedImages.push({
            url: cloudinaryRes.secure_url,
            altText: img.altText || "", // Giữ altText nếu có
          });
        }
      }
    }

    const product = new Product({
      name,
      description,
      price,
      discountPrice,
      countInStock,
      category,
      material,
      sku,
      image: uploadedImages,
      tag,
      dimension,
      weight,
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
      countInStock,
      category,
      material,
      sku,
      image,
      tag,
      dimension,
      weight,
    } = req.body;

    const product = await Product.findById(req.params.id);
    if (product) {
      product.name = name || product.name;
      product.description = description || product.description;
      product.price = price || product.price;
      product.discountPrice = discountPrice || product.discountPrice;
      product.countInStock = countInStock || product.countInStock;
      product.category = category || product.category;
      product.material = material || product.materials;
      product.sku = sku || product.sku;
      product.image = image || product.image;
      product.tag = tag || product.tag;
      product.dimension = dimension || product.dimension;
      product.weight = weight || product.weight;

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
      limit,
    } = req.query;

    let query = {};

    if (category && category.toLowerCase() !== "all") {
      query.category = category;
    }

    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: "i" } },
        { description: { $regex: search, $options: "i" } },
      ];
    }
    let sort = {};
    if (sortBy) {
      switch (sortBy) {
        case "priceAsc":
          sort = { price: 1 };
          break;
        case "priceDesc":
          sort = { price: -1 };
          break;
        case "popularity":
          sort = { rating: -1 };
          break;
        default:
          break;
      }
    }

    let products = await Product.find(query)
      .sort(sort)
      .limit(Number(limit) || 0);
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
    const bestSeller = await Product.findOne().sort({ rating: -1 });
    if (bestSeller) {
      res.json(bestSeller);
    } else {
      res.status(404).json({ message: "Product not found" });
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
