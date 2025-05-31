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
      brand,
      size,
      colors,
      collections,
      material,
      gender,
      sku,
      image,
      isFeatured,
      isPublished,
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
      brand,
      size,
      colors,
      collections,
      material,
      gender,
      sku,
      image: uploadedImages,
      isFeatured,
      isPublished,
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
      brand,
      size,
      colors,
      collections,
      material,
      gender,
      sku,
      image,
      isFeatured,
      isPublished,
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
      product.brand = brand || product.brand;
      product.size = size || product.size;
      product.colors = colors || product.colors; 
      product.collections = collections || product.collections;
      product.material = material || product.materials;
      product.gender = gender || product.gender;
      product.sku = sku || product.sku;
      product.image = image || product.image;
      product.isFeatured =
        isFeatured !== undefined ? isFeatured : product.isFeatured;
      product.isPublished =
        isPublished !== undefined ? isPublished : product.isPublished;
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
      collections,
      size,
      colors,
      gender,
      minPrice,
      maxPrice,
      sortBy,
      search,
      category,
      material,
      brand,
      limit,
    } = req.query;

    let query = {};

    if (collections && collections.toLowerCase() !== "all") {
      query.collections = collections;
    }

    if (category && category.toLowerCase() !== "all") {
      query.category = category;
    }

    if (size) {
      query.size = { $in: size.split(",") };
    }

    if (colors) {
      query.colors = { $in: [colors] };
    }

    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }

    if (gender) {
      query.gender = gender;
    }

    if (material) {
      query.material = { $in: material.split(",") };
    }

    if (brand) {
      query.brand = { $in: brand.split(",") };
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
      gender: product.gender,
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
