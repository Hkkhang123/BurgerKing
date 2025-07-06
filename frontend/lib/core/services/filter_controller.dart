import 'package:get/get.dart';
import 'package:client/core/utils/api_service.dart';

class FilterController extends GetxController {
  // Filter state
  var minPrice = 0.obs;
  var maxPrice = 500000.obs;
  var selectedCategory = 'all'.obs;
  var selectedRating = 0.0.obs;
  var selectedSortBy = 'newest'.obs;
  var searchQuery = ''.obs;
  
  // Products state
  var products = [].obs;
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  
  // Pagination
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  var limit = 10.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // Apply filter and reload products
  void applyFilter(Map<String, dynamic> filterParams) {
    minPrice.value = filterParams['minPrice'] ?? 0;
    maxPrice.value = filterParams['maxPrice'] ?? 500000;
    selectedCategory.value = filterParams['category'] ?? 'all';
    selectedRating.value = filterParams['minRating'] ?? 0.0;
    selectedSortBy.value = filterParams['sortBy'] ?? 'newest';
    
    // Reset pagination
    currentPage.value = 1;
    hasMoreData.value = true;
    
    // Reload products with new filter
    loadProducts();
  }

  // Search products
  void searchProducts(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    hasMoreData.value = true;
    loadProducts();
  }

  // Load products with current filter
  Future<void> loadProducts({bool loadMore = false}) async {
    if (isLoading.value) return;
    
    if (loadMore) {
      currentPage.value++;
    } else {
      currentPage.value = 1;
      products.clear();
    }
    
    isLoading.value = true;
    hasError.value = false;
    
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'page': currentPage.value,
        'limit': limit.value,
      };
      
      // Add filter parameters
      if (minPrice.value > 0) queryParams['minPrice'] = minPrice.value;
      if (maxPrice.value < 500000) queryParams['maxPrice'] = maxPrice.value;
      if (selectedCategory.value != 'all') queryParams['category'] = selectedCategory.value;
      if (selectedRating.value > 0) queryParams['minRating'] = selectedRating.value;
      if (selectedSortBy.value.isNotEmpty) queryParams['sortBy'] = selectedSortBy.value;
      if (searchQuery.value.isNotEmpty) queryParams['search'] = searchQuery.value;
      
      final response = await ApiService.get('/api/products', queryParams: queryParams);
      
      if (response['success']) {
        // Backend returns array directly, not wrapped in 'data'
        final newProducts = response['data'] as List;
        
        if (loadMore) {
          products.addAll(newProducts);
        } else {
          products.value = newProducts;
        }
        
        // Check if there's more data
        hasMoreData.value = newProducts.length >= limit.value;
      } else {
        hasError.value = true;
        errorMessage.value = response['error'] ?? 'Không thể tải sản phẩm';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Lỗi kết nối: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Load more products (for pagination)
  Future<void> loadMoreProducts() async {
    if (hasMoreData.value && !isLoading.value) {
      await loadProducts(loadMore: true);
    }
  }

  // Reset all filters
  void resetFilters() {
    minPrice.value = 0;
    maxPrice.value = 500000;
    selectedCategory.value = 'all';
    selectedRating.value = 0.0;
    selectedSortBy.value = 'newest';
    searchQuery.value = '';
    currentPage.value = 1;
    hasMoreData.value = true;
    loadProducts();
  }

  // Get current filter summary
  String getFilterSummary() {
    final filters = <String>[];
    
    if (selectedCategory.value != 'all') {
      filters.add(_getCategoryName(selectedCategory.value));
    }
    
    if (minPrice.value > 0 || maxPrice.value < 500000) {
      filters.add('${(minPrice.value / 1000).round()}k - ${(maxPrice.value / 1000).round()}k');
    }
    
    if (selectedRating.value > 0) {
      filters.add('${selectedRating.value.toInt()}+ sao');
    }
    
    if (searchQuery.value.isNotEmpty) {
      filters.add('"${searchQuery.value}"');
    }
    
    return filters.isEmpty ? 'Tất cả sản phẩm' : filters.join(', ');
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'pizza': return 'Pizza';
      case 'burger': return 'Burger';
      case 'sushi': return 'Sushi';
      case 'vietnamese': return 'Món Việt';
      case 'asian': return 'Món Á';
      case 'western': return 'Món Âu';
      case 'dessert': return 'Tráng miệng';
      case 'drink': return 'Đồ uống';
      default: return category;
    }
  }

  // Check if any filter is active
  bool get hasActiveFilters {
    return selectedCategory.value != 'all' ||
           minPrice.value > 0 ||
           maxPrice.value < 500000 ||
           selectedRating.value > 0 ||
           searchQuery.value.isNotEmpty;
  }
} 