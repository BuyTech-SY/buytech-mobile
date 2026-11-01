import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/product_model.dart';

class QuoteCartSheet extends StatefulWidget {
  final Map<ProductModel, int> cart;
  final VoidCallback onClearCart;
  final Function(ProductModel, int) onUpdateQuantity;

  const QuoteCartSheet({
    super.key,
    required this.cart,
    required this.onClearCart,
    required this.onUpdateQuantity,
  });

  @override
  State<QuoteCartSheet> createState() => _QuoteCartSheetState();
}

class _QuoteCartSheetState extends State<QuoteCartSheet> {
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice {
    double sum = 0;
    widget.cart.forEach((product, qty) {
      sum += product.price * qty;
    });
    return sum;
  }

  Future<void> _sendQuoteViaWhatsApp() async {
    if (widget.cart.isEmpty) return;

    final customerName = _customerNameController.text.trim();
    final customerPhone = _customerPhoneController.text.trim();
    final notes = _notesController.text.trim();

    final buffer = StringBuffer();
    buffer.writeln('📋 *عرض سعر رسمي - BuyTech للحلول التقنية وأنظمة POS*');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    if (customerName.isNotEmpty) {
      buffer.writeln('👤 *السيد/ة:* $customerName');
    }
    if (customerPhone.isNotEmpty) {
      buffer.writeln('📱 *رقم العميل:* $customerPhone');
    }
    buffer.writeln('📅 *التاريخ:* ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📦 *قائمة المنتجات والبنود:*');

    int index = 1;
    widget.cart.forEach((product, qty) {
      final lineTotal = (product.price * qty).toStringAsFixed(2);
      buffer.writeln('$index. *${product.name}*');
      buffer.writeln('   الكمية: $qty × ${product.price.toStringAsFixed(2)} = $lineTotal ر.س');
      index++;
    });

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('💰 *الإجمالي الكلي:* ${_totalPrice.toStringAsFixed(2)} ر.س');
    buffer.writeln('*(الأسعار شاملة الدعم الفني والضمان)*');

    if (notes.isNotEmpty) {
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('📝 *ملاحظات إضافية:*');
      buffer.writeln(notes);
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('✨ شركة BuyTech - حلول نقاط البيع والشبكات والأنظمة السحابية');
    buffer.writeln('🌐 https://op-system.buytech.app');

    final text = buffer.toString();

    // Determine target phone: if customerPhone provided, use it, else send to general WhatsApp
    String targetPhone = '';
    if (customerPhone.isNotEmpty) {
      var p = customerPhone.replaceAll(RegExp(r'[^\d+]'), '');
      if (p.startsWith('00')) p = '+${p.substring(2)}';
      else if (p.startsWith('05')) p = '+966${p.substring(1)}';
      else if (p.startsWith('09')) p = '+963${p.substring(1)}';
      targetPhone = p;
    }

    final url = targetPhone.isNotEmpty
        ? Uri.parse('https://wa.me/$targetPhone?text=${Uri.encodeComponent(text)}')
        : Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح واتساب')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = widget.cart.entries.toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'سلة عرض السعر (${entries.length})',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: widget.onClearCart,
                  child: const Text('تفريغ السلة', style: TextStyle(color: AppColors.error, fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Cart Items List & Customer Details
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('السلة فارغة، أضف منتجات لتسعيرها'))
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      ...entries.map((entry) {
                        final product = entry.key;
                        final qty = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product.price.toStringAsFixed(2)} ر.س',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 22, color: Colors.grey),
                                    onPressed: () => widget.onUpdateQuantity(product, qty - 1),
                                  ),
                                  Text(
                                    '$qty',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.primary),
                                    onPressed: () => widget.onUpdateQuantity(product, qty + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 16),
                      Text(
                        'بيانات العميل المستهدف (اختياري)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _customerNameController,
                        decoration: InputDecoration(
                          hintText: 'اسم العميل أو المؤسسة...',
                          prefixIcon: const Icon(Icons.person_outline, size: 18),
                          filled: true,
                          fillColor: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _customerPhoneController,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          hintText: 'رقم واتساب العميل (مثال: 05xxxxxxxx)',
                          prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                          filled: true,
                          fillColor: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'ملاحظات العرض (شروط الضمان، طريقة الدفع)...',
                          prefixIcon: const Icon(Icons.edit_note, size: 18),
                          filled: true,
                          fillColor: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ],
                  ),
          ),

          // Bottom Checkout Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الإجمالي التقديري:',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_totalPrice.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send_rounded, size: 20),
                      label: const Text(
                        'تصدير وإرسال عبر واتساب',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whatsappGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: entries.isEmpty ? null : _sendQuoteViaWhatsApp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
