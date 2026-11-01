import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_strings.dart';
import '../../core/state/app_settings.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isYearly = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.tr('subscription_plans'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ACCESS PRO',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ارتقِ بتجربة شبكة علاقاتك الذكية',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'بطاقات غير محدودة، تحليلات متقدمة، وهوية احترافية بدون قيود',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Billing Toggle (Monthly vs Yearly)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? AppColors.darkBorder : Colors.transparent),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isYearly = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isYearly
                              ? (isDark ? AppColors.darkCard : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: !_isYearly
                              ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]
                              : null,
                        ),
                        child: Text(
                          AppStrings.tr('monthly'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: !_isYearly
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isYearly = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isYearly
                              ? (isDark ? AppColors.darkCard : Colors.white)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _isYearly
                              ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.tr('yearly'),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isYearly
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Plan 1: Free Tier
            _buildPlanCard(
              title: 'الخطة المجانية (Starter)',
              price: '0\$',
              period: '/ دائماً',
              isCurrent: true,
              isPopular: false,
              features: [
                'بطاقة ذكية واحدة (1 Digital Card)',
                'رمز QR قياسي للمشاركة المباشرة',
                'برمجة شريحة NFC واحدة',
                'تخزين المعارف حتى 20 جهة اتصال',
              ],
              buttonText: 'خطتك الحالية',
              isDark: isDark,
              onTap: null,
            ),

            const SizedBox(height: 16),

            // Plan 2: Access Pro (Most Popular)
            _buildPlanCard(
              title: 'Access Pro (المحترف)',
              price: _isYearly ? '7.99\$' : '9.99\$',
              period: _isYearly ? '/ شهرياً (تدفع سنوياً 95\$)' : '/ شهرياً',
              isCurrent: false,
              isPopular: true,
              features: [
                'بطاقات ذكية غير محدودة (عمل، شخصي، فعاليات)',
                'لوغو Access وهوية مخصصة داخل رمز الـ QR',
                'تحليلات وإحصائيات تفصيلية للزيارات والتحميلات',
                'تصدير جهات الاتصال إلى ملفات Excel / CSV / vCard',
                'تخصيص كامل لألوان البطاقة والغلاف وإزالة شارة النظام',
                'برمجة غير محدودة لشرائح وكروت NFC',
                'أولوية الدعم الفني المباشر',
              ],
              buttonText: 'الترقية إلى Access Pro الآن',
              isDark: isDark,
              onTap: () {
                _showSuccessUpgrade('Access Pro');
              },
            ),

            const SizedBox(height: 16),

            // Plan 3: Access Teams
            _buildPlanCard(
              title: 'Access Business (الشركات والفرق)',
              price: _isYearly ? '24.99\$' : '29.99\$',
              period: _isYearly ? '/ شهرياً (تدفع سنوياً 280\$)' : '/ شهرياً',
              isCurrent: false,
              isPopular: false,
              features: [
                'كل مميزات باقة Pro بالكامل',
                'لوحة تحكم مركزية لإدارة بطاقات جميع الموظفين',
                'تثبيت هوية بصرية وشعار موحد لجميع بطاقات الفريق',
                'طلب كروت فيزيائية NFC مطبوعة بجودة عالية',
                'ربط تكاملي مع نظام CRM الشركة ومتابعة العملاء',
              ],
              buttonText: 'تفعيل باقة الشركات',
              isDark: isDark,
              onTap: () {
                _showSuccessUpgrade('Access Business');
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required bool isCurrent,
    required bool isPopular,
    required List<String> features,
    required String buttonText,
    required bool isDark,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPopular ? AppColors.primary.withOpacity(0.18) : Colors.black.withOpacity(0.04),
            blurRadius: isPopular ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isPopular ? AppColors.primary : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: const Text(
                    'الأكثر طلباً ⭐',
                    style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                period,
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Features List
          ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: isPopular ? AppColors.primary : const Color(0xFF10B981),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white80 : const Color(0xFF334155),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 16),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isPopular
                  ? AppColors.primary
                  : (isCurrent ? Colors.grey.withOpacity(0.2) : const Color(0xFF0F766E)),
              foregroundColor: isCurrent ? Colors.grey : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: isPopular ? 4 : 0,
            ),
            onPressed: onTap,
            child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showSuccessUpgrade(String planName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 8),
            Text('الترقية إلى $planName', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        content: Text(
          'تم تفعيل طلب الترقية إلى باقة $planName بنجاح على حسابك في Access! جميع المزايا الاحترافية أصبحت متاحة لبطاقاتك.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('حسناً، رائع!'),
          ),
        ],
      ),
    );
  }
}
