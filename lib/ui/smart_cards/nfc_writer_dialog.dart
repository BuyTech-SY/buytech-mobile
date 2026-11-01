import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/smart_card_model.dart';
import '../../data/services/nfc_service.dart';

class NfcWriterDialog extends StatefulWidget {
  final SmartCardModel card;

  const NfcWriterDialog({super.key, required this.card});

  @override
  State<NfcWriterDialog> createState() => _NfcWriterDialogState();
}

class _NfcWriterDialogState extends State<NfcWriterDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _isWriting = true;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _startNfcWrite();
  }

  @override
  void dispose() {
    _animController.dispose();
    NfcService.stopSession();
    super.dispose();
  }

  Future<void> _startNfcWrite() async {
    setState(() {
      _isWriting = true;
      _isSuccess = false;
      _errorMessage = null;
    });

    await NfcService.writeCardUri(
      uri: widget.card.ndefUri,
      onSuccess: () {
        if (!mounted) return;
        setState(() {
          _isWriting = false;
          _isSuccess = true;
        });
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _isWriting = false;
          _errorMessage = err;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header icon with animations
            if (_isWriting)
              ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.15).animate(
                  CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
                ),
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.nfc, size: 48, color: AppColors.primary),
                  ),
                ),
              )
            else if (_isSuccess)
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withOpacity(0.15),
                ),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded, size: 54, color: AppColors.success),
                ),
              )
            else
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withOpacity(0.15),
                ),
                child: const Center(
                  child: Icon(Icons.error_outline_rounded, size: 54, color: AppColors.error),
                ),
              ),

            const SizedBox(height: 20),

            // Title
            Text(
              _isWriting
                  ? 'قرّب بطاقة NFC من ظهر الهاتف'
                  : (_isSuccess ? 'تمت برمجة الشريحة بنجاح! 🎉' : 'تعذر إتمام البرمجة'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              _isWriting
                  ? 'قم بملامسة البطاقة أو الميدالية الذكية في المنطقة العلوية لظهر الهاتف حتى تسمع رنة التثبيت.'
                  : (_isSuccess
                      ? 'أصبحت الشريحة الآن مربوطة ببطاقة (${widget.card.name}) وستفتح تلقائياً عند لمسها لأي هاتف.'
                      : (_errorMessage ?? 'حدث خطأ، يرجى المحاولة مجدداً.')),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            // NDEF URL preview box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.card.ndefUri,
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                      textDirection: TextDirection.ltr,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (_isWriting)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء الجلسة', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              )
            else if (_isSuccess)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('تم بنجاح ✔', style: TextStyle(fontWeight: FontWeight.w800)),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('إغلاق'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startNfcWrite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
