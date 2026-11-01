import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/smart_card_model.dart';
import 'nfc_writer_dialog.dart';
import 'qr_share_dialog.dart';

class CardPreviewDialog extends StatefulWidget {
  final SmartCardModel card;

  const CardPreviewDialog({super.key, required this.card});

  @override
  State<CardPreviewDialog> createState() => _CardPreviewDialogState();
}

class _CardPreviewDialogState extends State<CardPreviewDialog> {
  String _profileMode = 'retail'; // 'retail' or 'wholesale'

  Future<void> _launch(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.card;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator bar
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  // 1. Cover Banner & Top Utilities
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F766E), Color(0xFF0D9488), Color(0xFF06B6D4)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          image: c.coverImage != null
                              ? DecorationImage(
                                  image: NetworkImage(c.coverImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),

                      // Top Quick Buttons
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Row(
                          children: [
                            IconButton(
                              style: IconButton.styleFrom(backgroundColor: Colors.black38),
                              icon: const Icon(Icons.qr_code, color: Colors.white, size: 20),
                              onPressed: () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (_) => QrShareDialog(card: c),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              style: IconButton.styleFrom(backgroundColor: Colors.black38),
                              icon: const Icon(Icons.nfc, color: Colors.white, size: 20),
                              onPressed: () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (_) => NfcWriterDialog(card: c),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Circular Avatar with Verified Badge overlapping cover
                      Positioned(
                        bottom: -44,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.darkSurface : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 44,
                                backgroundColor: const Color(0xFFE2E8F0),
                                backgroundImage: c.avatar != null ? NetworkImage(c.avatar!) : null,
                                child: c.avatar == null
                                    ? Text(
                                        c.name.isNotEmpty ? c.name.substring(0, 1) : 'B',
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary),
                                      )
                                    : null,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              child: const Icon(Icons.check, size: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 52),

                  // 2. Identity info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          c.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        if (c.title != null && c.title!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            c.title!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          c.companyName,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
                        ),

                        // Dual Profile Switch (Retail vs Wholesale)
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _profileMode = 'retail'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _profileMode == 'retail' ? (isDark ? AppColors.darkSurface : Colors.white) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _profileMode == 'retail' ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                                  ),
                                  child: const Text('🏪 معرض وتجزئة', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _profileMode = 'wholesale'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _profileMode == 'wholesale' ? (isDark ? AppColors.darkSurface : Colors.white) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _profileMode == 'wholesale' ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                                  ),
                                  child: const Text('🏢 جملة وشركات', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Wholesale Banner
                        if (_profileMode == 'wholesale') ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: const Text(
                              '🏢 قسم مبيعات الجملة: عروض أسعار تفضيلية للموزعين والشركات والمشاريع مع فواتير وضمان رسمي.',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.4),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],

                        // Bio
                        if (c.bio != null && c.bio!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            c.bio!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : const Color(0xFF475569), height: 1.5),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Dual Primary CTAs (Blinq Signature)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.download_rounded, size: 18),
                                label: const Text('حفظ الرقم'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                                onPressed: () => _launch(c.vcardUrl),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.swap_horiz, size: 18, color: AppColors.primary),
                                label: const Text('تبادل الأرقام'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                ),
                                onPressed: () => _launch(c.publicUrl),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Contact List Rows
                        if (c.phone != null && c.phone!.isNotEmpty)
                          _buildContactTile(
                            icon: Icons.phone,
                            color: AppColors.phoneEmerald,
                            title: 'الهاتف المباشر',
                            value: c.phone!,
                            onTap: () => _launch('tel:${c.phone}'),
                          ),

                        if (c.whatsapp != null || c.phone != null)
                          _buildContactTile(
                            icon: Icons.chat_bubble,
                            color: AppColors.whatsappGreen,
                            title: 'واتساب مباشر',
                            value: c.whatsapp ?? c.phone!,
                            onTap: () {
                              final num = (c.whatsapp ?? c.phone!).replaceAll(RegExp(r'[^\d]'), '');
                              _launch('https://wa.me/$num');
                            },
                          ),

                        if (c.email != null && c.email!.isNotEmpty)
                          _buildContactTile(
                            icon: Icons.email,
                            color: AppColors.googleRed,
                            title: 'البريد الإلكتروني',
                            value: c.email!,
                            onTap: () => _launch('mailto:${c.email}'),
                          ),

                        _buildContactTile(
                          icon: Icons.storefront,
                          color: AppColors.primary,
                          title: 'المتجر الإلكتروني',
                          value: c.website ?? 'https://buytech.app',
                          onTap: () => _launch(c.website ?? 'https://buytech.app'),
                        ),

                        if (c.location != null && c.location!.isNotEmpty)
                          _buildContactTile(
                            icon: Icons.location_on,
                            color: AppColors.mapsRose,
                            title: 'المعرض / العنوان',
                            value: c.location!,
                            onTap: () {
                              if (c.googleMapsUrl != null && c.googleMapsUrl!.isNotEmpty) {
                                _launch(c.googleMapsUrl!);
                              }
                            },
                          ),
                      ],
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

  Widget _buildContactTile({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
