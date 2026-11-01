import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/smart_card_model.dart';
import '../../data/services/api_service.dart';
import 'card_preview_dialog.dart';
import 'nfc_writer_dialog.dart';
import 'qr_share_dialog.dart';

class SmartCardsScreen extends StatefulWidget {
  const SmartCardsScreen({super.key});

  @override
  State<SmartCardsScreen> createState() => _SmartCardsScreenState();
}

class _SmartCardsScreenState extends State<SmartCardsScreen> {
  bool _isLoading = true;
  List<SmartCardModel> _cards = [];
  Map<String, dynamic> _stats = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  Future<void> _fetchCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await ApiService.getSmartCards();

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _cards = res['cards'] as List<SmartCardModel>;
        _stats = res['stats'] as Map<String, dynamic>;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = res['message'] as String? ?? 'تعذر تحميل البطاقات';
      });
    }
  }

  Future<void> _toggleStatus(SmartCardModel card) async {
    final prev = card.isActive;
    setState(() => card.isActive = !prev);

    final ok = await ApiService.toggleCardStatus(card.id);
    if (!ok && mounted) {
      setState(() => card.isActive = prev);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تعديل حالة البطاقة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'بطاقات الأعمال الذكية',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCards,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _fetchCards, child: const Text('إعادة المحاولة')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchCards,
                  color: AppColors.primary,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      // 1. Blinq Enterprise Metrics Strip
                      _buildMetricsStrip(isDark),

                      const SizedBox(height: 20),

                      // Section Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'بطاقات فريق BuyTech (${_cards.length})',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Cards Grid/List
                      if (_cards.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: const Column(
                            children: [
                              Text('📇', style: TextStyle(fontSize: 40)),
                              SizedBox(height: 10),
                              Text('لا توجد بطاقات منشأة بعد', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      else
                        ..._cards.map((c) => _buildCardTile(c, isDark)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMetricsStrip(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem('البطاقات', '${_stats['total_cards'] ?? _cards.length}', 'نشطة', isDark),
          _buildDivider(isDark),
          _buildMetricItem('المشاهدات', '${_stats['total_views'] ?? 0}', 'مسح QR & NFC', isDark),
          _buildDivider(isDark),
          _buildMetricItem('الـ Leads', '${_stats['total_leads'] ?? 0}', 'عملاء مكتسبين', isDark),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String title, String count, String sub, bool isDark) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
        Text(sub, style: TextStyle(fontSize: 9, color: isDark ? Colors.white38 : Colors.grey)),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 36,
      width: 1,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }

  Widget _buildCardTile(SmartCardModel c, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Banner & Status Switch
          Stack(
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF06B6D4)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  image: c.coverImage != null
                      ? DecorationImage(image: NetworkImage(c.coverImage!), fit: BoxFit.cover)
                      : null,
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Switch(
                  value: c.isActive,
                  activeColor: AppColors.primary,
                  onChanged: (_) => _toggleStatus(c),
                ),
              ),
            ],
          ),

          // Card Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: c.avatar != null ? NetworkImage(c.avatar!) : null,
                  child: c.avatar == null
                      ? Text(
                          c.name.isNotEmpty ? c.name.substring(0, 1) : 'B',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 18),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                      Text(
                        c.title ?? c.companyName,
                        style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المشاهدات: ${c.viewsCount} • حفظ الرقم: ${c.vcardDownloadsCount}',
                        style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action Buttons: Preview, QR, and Native NFC Writer!
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                  label: const Text('معاينة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => CardPreviewDialog(card: c),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.qr_code_2, size: 16),
                  label: const Text('رمز QR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => QrShareDialog(card: c),
                    );
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.nfc, size: 16),
                  label: const Text('برمجة NFC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => NfcWriterDialog(card: c),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
