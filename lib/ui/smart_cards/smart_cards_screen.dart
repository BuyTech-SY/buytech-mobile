import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_strings.dart';
import '../../core/state/app_settings.dart';
import '../../data/models/smart_card_model.dart';
import '../../data/services/api_service.dart';
import 'card_form_dialog.dart';
import 'fullscreen_qr_dialog.dart';
import 'card_preview_dialog.dart';
import 'nfc_writer_dialog.dart';
import '../subscription/subscription_screen.dart';

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

  final PageController _pageController = PageController(viewportFraction: 0.90);
  int _activeCardIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchCards();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        if (_activeCardIndex >= _cards.length) {
          _activeCardIndex = (_cards.length - 1).clamp(0, _cards.length);
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = res['message'] as String? ?? 'تعذر تحميل البطاقات';
      });
    }
  }

  Future<void> _openCreateCard() async {
    final newCard = await CardFormDialog.show(context);
    if (newCard != null && mounted) {
      setState(() {
        _cards.insert(0, newCard);
        _activeCardIndex = 0;
      });
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إنشاء بطاقة "${newCard.name}" بنجاح!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _openEditCard(SmartCardModel card) async {
    final updatedCard = await CardFormDialog.show(context, card: card);
    if (updatedCard != null && mounted) {
      setState(() {
        final idx = _cards.indexWhere((c) => c.id == updatedCard.id);
        if (idx != -1) {
          _cards[idx] = updatedCard;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث بيانات بطاقة "${updatedCard.name}" بنجاح!'),
          backgroundColor: AppColors.primary,
        ),
      );
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
    final activeCard = _cards.isNotEmpty && _activeCardIndex < _cards.length
        ? _cards[_activeCardIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Official Access Logo Asset
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(5),
              child: Image.asset(
                'assets/images/logo-white.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Center(
                  child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.tr('my_cards'),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
                const Text(
                  'Access Digital Cards',
                  style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Theme Switcher (Dark / Light)
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'التحويل للوضع الليلي',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? Colors.amberAccent : AppColors.primaryDark,
              size: 22,
            ),
            onPressed: () => AppSettings.toggleTheme(),
          ),

          // Language Switcher (AR / EN)
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(36, 36),
            ),
            onPressed: () => AppSettings.toggleLanguage(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                AppSettings.isArabic ? 'EN' : 'عربي',
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11),
              ),
            ),
          ),

          // Add New Card Button
          IconButton(
            tooltip: AppStrings.tr('new_card'),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
            ),
            onPressed: _openCreateCard,
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
              : _cards.isEmpty
                  ? _buildEmptyState(isDark)
                  : RefreshIndicator(
                      onRefresh: _fetchCards,
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            // Access Pro Upgrade Ribbon
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: _buildProSubscriptionRibbon(isDark),
                            ),

                            const SizedBox(height: 14),

                            // 1. Blinq Card Carousel
                            SizedBox(
                              height: 220,
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: _cards.length,
                                onPageChanged: (index) {
                                  setState(() => _activeCardIndex = index);
                                },
                                itemBuilder: (context, index) {
                                  final card = _cards[index];
                                  final isSelected = index == _activeCardIndex;
                                  return _buildCarouselCard(card, isSelected, isDark);
                                },
                              ),
                            ),

                            // Carousel Dots Indicator
                            if (_cards.length > 1) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(_cards.length, (i) {
                                  final isCurrent = i == _activeCardIndex;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    width: isCurrent ? 24 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isCurrent ? AppColors.primary : Colors.grey.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                }),
                              ),
                            ],

                            const SizedBox(height: 18),

                            // 2. Active Card Live QR Code Section (Blinq Hero Presentation)
                            if (activeCard != null) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: _buildQrPresentationBox(activeCard, isDark),
                              ),

                              const SizedBox(height: 20),

                              // 3. Quick Action Buttons Grid (Edit, Share, NFC, Copy, View)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: _buildActionGrid(activeCard, isDark),
                              ),

                              const SizedBox(height: 18),

                              // 4. Quick Metrics Strip
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: _buildMetricsStrip(activeCard, isDark),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildProSubscriptionRibbon(bool isDark) {
    return GestureDetector(
      onTap: () => SubscriptionScreen.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('upgrade_pro'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  const Text(
                    'بطاقات غير محدودة، تحليلات متقدمة، وهوية بدون قيود',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'الخطط',
                style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w900, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.credit_card_off_rounded, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.tr('empty_cards'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.tr('empty_cards_sub'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(AppStrings.tr('new_card'), style: const TextStyle(fontWeight: FontWeight.w900)),
              onPressed: _openCreateCard,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselCard(SmartCardModel card, bool isSelected, bool isDark) {
    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.94,
      duration: const Duration(milliseconds: 250),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: card.coverImage == null
              ? LinearGradient(
                  colors: isSelected
                      ? [const Color(0xFF0F766E), const Color(0xFF0D9488), const Color(0xFF14B8A6)]
                      : [const Color(0xFF1E293B), const Color(0xFF334155)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          image: card.coverImage != null
              ? DecorationImage(
                  image: NetworkImage(card.coverImage!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.primary.withOpacity(0.35) : Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Company Badge + Status Switch + Edit Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            card.companyName.isNotEmpty ? card.companyName : 'Access',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            // Quick Edit Icon
                            InkWell(
                              onTap: () => _openEditCard(card),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.35),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Toggle Status
                            InkWell(
                              onTap: () => _toggleStatus(card),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: card.isActive
                                      ? const Color(0xFF10B981).withOpacity(0.45)
                                      : Colors.red.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: card.isActive ? const Color(0xFF34D399) : Colors.redAccent,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      card.isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      card.isActive ? AppStrings.tr('active') : AppStrings.tr('inactive'),
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Avatar + Name + Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            backgroundImage: card.avatar != null && card.avatar!.isNotEmpty
                                ? NetworkImage(card.avatar!)
                                : null,
                            child: (card.avatar == null || card.avatar!.isEmpty)
                                ? Text(
                                    card.name.isNotEmpty ? card.name[0] : 'A',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (card.title != null && card.title!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  card.title!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrPresentationBox(SmartCardModel card, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.qr_code_2_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'رمز الـ QR المباشر للبطاقة',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              InkWell(
                onTap: () => FullscreenQrDialog.show(context, card),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fullscreen_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.tr('fullscreen_qr'),
                        style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // QR Code Tap to Expand
          GestureDetector(
            onTap: () => FullscreenQrDialog.show(context, card),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: QrImageView(
                data: card.publicUrl,
                version: QrVersions.auto,
                size: 190,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF0F172A),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'اضغط على الرمز لتكبيره بملء الشاشة مع سطوع عالي للعرض السريع',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(SmartCardModel card, bool isDark) {
    return Row(
      children: [
        // 1. Edit Card Button
        Expanded(
          child: _buildActionButton(
            label: AppStrings.tr('edit_card'),
            icon: Icons.edit_note_rounded,
            color: const Color(0xFFF59E0B),
            isDark: isDark,
            onTap: () => _openEditCard(card),
          ),
        ),
        const SizedBox(width: 8),

        // 2. Share Button
        Expanded(
          child: _buildActionButton(
            label: AppStrings.tr('share'),
            icon: Icons.share_rounded,
            color: AppColors.primary,
            isDark: isDark,
            onTap: () {
              Share.share(
                'بطاقة ${card.name} الذكية على Access:\n${card.publicUrl}',
                subject: 'Access Smart Card',
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // 3. NFC Write Button
        Expanded(
          child: _buildActionButton(
            label: AppStrings.tr('write_nfc'),
            icon: Icons.nfc_rounded,
            color: const Color(0xFF0EA5E9),
            isDark: isDark,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => NfcWriterDialog(card: card),
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // 4. Copy Link Button
        Expanded(
          child: _buildActionButton(
            label: AppStrings.tr('copy_link'),
            icon: Icons.copy_rounded,
            color: const Color(0xFF8B5CF6),
            isDark: isDark,
            onTap: () {
              Clipboard.setData(ClipboardData(text: card.publicUrl));
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.tr('link_copied'))),
              );
            },
          ),
        ),
        const SizedBox(width: 8),

        // 5. Preview Button
        Expanded(
          child: _buildActionButton(
            label: AppStrings.tr('preview'),
            icon: Icons.visibility_rounded,
            color: const Color(0xFF10B981),
            isDark: isDark,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CardPreviewDialog(card: card),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : const Color(0xFF334155),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsStrip(SmartCardModel card, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetricItem(AppStrings.tr('views'), '${card.viewsCount}', Icons.remove_red_eye_outlined, AppColors.primary),
          Container(width: 1, height: 28, color: isDark ? Colors.white12 : Colors.black12),
          _buildMetricItem(AppStrings.tr('vcard_downloads'), '${card.vcardDownloadsCount}', Icons.contact_page_outlined, const Color(0xFF0EA5E9)),
          Container(width: 1, height: 28, color: isDark ? Colors.white12 : Colors.black12),
          _buildMetricItem(AppStrings.tr('leads'), '${card.leadsCount}', Icons.people_outline, const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String title, String count, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              count,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
