import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../data/services/api_service.dart';
import 'quote_cart_sheet.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _isLoading = true;
  List<ProductModel> _products = [];
  String _searchQuery = '';
  String? _selectedCategory;
  String? _errorMessage;

  // Cart: Product -> Quantity
  final Map<ProductModel, int> _cart = {};

  final List<String> _categories = [
    'الكل',
    'أجهزة الكاشير POS',
    'طابعات الفواتير',
    'قارئات الباركود',
    'موازين إلكترونية',
    'أدراج النقدية',
    'ملحقات واستهلاكيات',
  ];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await ApiService.getProducts();
      if (!mounted) return;
      setState(() {
        _products = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل المنتجات من الخادم';
      });
    }
  }

  List<ProductModel> get _filteredProducts {
    return _products.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.sku?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (p.customProductId?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesCategory = _selectedCategory == null ||
          _selectedCategory == 'الكل' ||
          (p.category != null && p.category!.contains(_selectedCategory!));

      return matchesSearch && matchesCategory;
    }).toList();
  }

  int get _totalCartCount {
    int total = 0;
    _cart.forEach((_, qty) => total += qty);
    return total;
  }

  double get _totalCartPrice {
    double total = 0;
    _cart.forEach((p, qty) => total += p.price * qty);
    return total;
  }

  void _addToCart(ProductModel product) {
    setState(() {
      _cart[product] = (_cart[product] ?? 0) + 1;
    });
  }

  void _updateQuantity(ProductModel product, int qty) {
    setState(() {
      if (qty <= 0) {
        _cart.remove(product);
      } else {
        _cart[product] = qty;
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
    Navigator.pop(context);
  }

  void _openQuoteCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuoteCartSheet(
        cart: _cart,
        onClearCart: _clearCart,
        onUpdateQuantity: (p, q) {
          _updateQuantity(p, q);
          // Force modal state refresh
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final list = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'كتالوج المنتجات وعروض الأسعار',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProducts,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Bar & Category Filter
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                color: isDark ? AppColors.darkSurface : Colors.white,
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن جهاز، طابعة، قارئ، أو كود SKU...',
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = (_selectedCategory == null && cat == 'الكل') ||
                              _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(cat, style: const TextStyle(fontSize: 12)),
                              selected: isSelected,
                              onSelected: (val) {
                                setState(() {
                                  _selectedCategory = cat == 'الكل' ? null : cat;
                                });
                              },
                              selectedColor: AppColors.primary.withOpacity(0.15),
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.primary : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Products List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_errorMessage!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                ElevatedButton(onPressed: _fetchProducts, child: const Text('إعادة المحاولة')),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchProducts,
                            color: AppColors.primary,
                            child: list.isEmpty
                                ? const Center(child: Text('لا توجد منتجات مطابقة'))
                                : ListView.builder(
                                    padding: EdgeInsets.fromLTRB(16, 16, 16, _cart.isNotEmpty ? 90 : 16),
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      final product = list[index];
                                      final inCart = _cart[product] ?? 0;
                                      return _buildProductCard(product, inCart, isDark);
                                    },
                                  ),
                          ),
              ),
            ],
          ),

          // Floating Quote Bottom Bar when cart has items
          if (_cart.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: _openQuoteCartSheet,
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.shopping_bag, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$_totalCartCount منتج في سلة التسعيرة',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${_totalCartPrice.toStringAsFixed(2)} ر.س تقديراً',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'إرسال واتساب',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primaryDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, int inCart, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: inCart > 0
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: inCart > 0 ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image or Icon
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              image: product.image != null
                  ? DecorationImage(
                      image: NetworkImage(product.image!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product.image == null
                ? const Icon(Icons.devices, color: AppColors.primary, size: 30)
                : null,
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.category != null)
                  Text(
                    product.category!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    if (product.sku != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'SKU: ${product.sku}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Action: Add / Counter
          if (inCart == 0)
            ElevatedButton(
              onPressed: () => _addToCart(product),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySurface,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primaryLight, width: 0.8),
                ),
              ),
              child: const Text(
                '+ تسعير',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    onPressed: () => _updateQuantity(product, inCart - 1),
                  ),
                  Text(
                    '$inCart',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    onPressed: () => _updateQuantity(product, inCart + 1),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
