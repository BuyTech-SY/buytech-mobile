import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_strings.dart';
import '../../data/models/smart_card_model.dart';
import '../../data/services/api_service.dart';

class CardFormDialog extends StatefulWidget {
  final SmartCardModel? initialCard;

  const CardFormDialog({super.key, this.initialCard});

  static Future<SmartCardModel?> show(BuildContext context, {SmartCardModel? card}) {
    return showGeneralDialog<SmartCardModel?>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.70),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: CardFormDialog(initialCard: card),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<CardFormDialog> createState() => _CardFormDialogState();
}

class _CardFormDialogState extends State<CardFormDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;
  late TextEditingController _websiteController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  late TextEditingController _avatarUrlController;
  late TextEditingController _coverUrlController;

  // Social Controllers
  late TextEditingController _linkedinController;
  late TextEditingController _instagramController;
  late TextEditingController _telegramController;

  String? _selectedAvatarPreset;
  String? _selectedCoverPreset;

  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _avatarPresets = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&h=200&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop&crop=faces',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=faces',
  ];

  final List<String> _coverPresets = [
    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600&h=300&fit=crop',
    'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=600&h=300&fit=crop',
    'https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=600&h=300&fit=crop',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&h=300&fit=crop',
    'https://images.unsplash.com/photo-1518770660439-4636190af475?w=600&h=300&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.initialCard;

    _nameController = TextEditingController(text: c?.name ?? '');
    _titleController = TextEditingController(text: c?.title ?? '');
    _companyController = TextEditingController(text: c?.companyName ?? 'Access');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _whatsappController = TextEditingController(text: c?.whatsapp ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _websiteController = TextEditingController(text: c?.website ?? '');
    _locationController = TextEditingController(text: c?.location ?? '');
    _bioController = TextEditingController(text: c?.bio ?? '');
    _avatarUrlController = TextEditingController(text: c?.avatar ?? '');
    _coverUrlController = TextEditingController(text: c?.coverImage ?? '');

    final socials = c?.socialLinks ?? {};
    _linkedinController = TextEditingController(text: socials['linkedin'] ?? '');
    _instagramController = TextEditingController(text: socials['instagram'] ?? '');
    _telegramController = TextEditingController(text: socials['telegram'] ?? '');

    _selectedAvatarPreset = c?.avatar;
    _selectedCoverPreset = c?.coverImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
    _coverUrlController.dispose();
    _linkedinController.dispose();
    _instagramController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final avatarVal = _avatarUrlController.text.trim().isNotEmpty
        ? _avatarUrlController.text.trim()
        : _selectedAvatarPreset;

    final coverVal = _coverUrlController.text.trim().isNotEmpty
        ? _coverUrlController.text.trim()
        : _selectedCoverPreset;

    final socialLinks = <String, String>{};
    if (_linkedinController.text.trim().isNotEmpty) socialLinks['linkedin'] = _linkedinController.text.trim();
    if (_instagramController.text.trim().isNotEmpty) socialLinks['instagram'] = _instagramController.text.trim();
    if (_telegramController.text.trim().isNotEmpty) socialLinks['telegram'] = _telegramController.text.trim();

    final payload = <String, dynamic>{
      'name': _nameController.text.trim(),
      'title': _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : null,
      'company_name': _companyController.text.trim().isNotEmpty ? _companyController.text.trim() : 'Access',
      'phone': _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      'whatsapp': _whatsappController.text.trim().isNotEmpty ? _whatsappController.text.trim() : null,
      'email': _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      'website': _websiteController.text.trim().isNotEmpty ? _websiteController.text.trim() : null,
      'location': _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
      'bio': _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
      'avatar_url': avatarVal,
      'cover_url': coverVal,
      'social_links': socialLinks,
    };

    final isEdit = widget.initialCard != null;
    final Map<String, dynamic> res;

    if (isEdit) {
      res = await ApiService.updateSmartCard(widget.initialCard!.id, payload);
    } else {
      res = await ApiService.createSmartCard(payload);
    }

    if (!mounted) return;

    if (res['success'] == true && res['card'] != null) {
      Navigator.of(context).pop(res['card'] as SmartCardModel);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = res['message'] as String? ?? (isEdit ? 'فشل تحديث البطاقة' : 'فشل إنشاء البطاقة');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.initialCard != null;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface.withOpacity(0.96) : Colors.white.withOpacity(0.98),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark ? AppColors.primary.withOpacity(0.35) : AppColors.primary.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 40,
              spreadRadius: 4,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(isEdit ? Icons.edit_note_rounded : Icons.credit_card_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? AppStrings.tr('edit_card') : AppStrings.tr('new_card'),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Access Smart Digital Card',
                          style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: isDark ? Colors.white60 : Colors.black45),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 1. Avatar Selection Section
              _buildSectionLabel(AppStrings.tr('avatar_style'), isDark),
              const SizedBox(height: 8),
              SizedBox(
                height: 54,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatarPresets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final url = _avatarPresets[idx];
                    final isSelected = _selectedAvatarPreset == url;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatarPreset = url;
                          _avatarUrlController.text = url;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(url),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _avatarUrlController,
                label: 'أو رابط صورة شخصية مخصص',
                hint: 'https://example.com/avatar.jpg',
                icon: Icons.image_outlined,
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              // 2. Cover Banner Selection Section
              _buildSectionLabel(AppStrings.tr('cover_style'), isDark),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _coverPresets.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final url = _coverPresets[idx];
                    final isSelected = _selectedCoverPreset == url;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCoverPreset = url;
                          _coverUrlController.text = url;
                        });
                      },
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2.5,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(url),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _coverUrlController,
                label: 'أو رابط غلاف مخصص',
                hint: 'https://example.com/cover.jpg',
                icon: Icons.panorama_outlined,
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              // 3. Basic Info Fields
              _buildSectionLabel('البيانات الشخصية والمهنية', isDark),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                label: AppStrings.tr('full_name'),
                hint: 'أحمد العلي',
                icon: Icons.person_outline_rounded,
                isDark: isDark,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'يرجى إدخال الاسم';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _titleController,
                label: AppStrings.tr('job_title'),
                hint: 'المدير التنفيذي / مهندس تقني',
                icon: Icons.badge_outlined,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _companyController,
                label: AppStrings.tr('company'),
                hint: 'Access',
                icon: Icons.business_outlined,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _bioController,
                label: AppStrings.tr('bio'),
                hint: 'عبارة تعريفية قصيرة تظهر على واجهة بطاقتك...',
                icon: Icons.edit_note_rounded,
                maxLines: 2,
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              // 4. Contact Methods
              _buildSectionLabel('طرق التواصل المباشر', isDark),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneController,
                label: AppStrings.tr('phone'),
                hint: '+963 9XX XXX XXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _whatsappController,
                label: AppStrings.tr('whatsapp'),
                hint: '+963 9XX XXX XXX',
                icon: Icons.chat_bubble_outline_rounded,
                keyboardType: TextInputType.phone,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _emailController,
                label: AppStrings.tr('email'),
                hint: 'name@company.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _websiteController,
                label: AppStrings.tr('website'),
                hint: 'https://mywebsite.com',
                icon: Icons.language_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _locationController,
                label: AppStrings.tr('location'),
                hint: 'دمشق، سورية',
                icon: Icons.location_on_outlined,
                isDark: isDark,
              ),

              const SizedBox(height: 16),

              // 5. Social Links
              _buildSectionLabel(AppStrings.tr('social_links'), isDark),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _linkedinController,
                label: 'LinkedIn (رابط أو اسم المستخدم)',
                hint: 'https://linkedin.com/in/username',
                icon: Icons.link_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _instagramController,
                label: 'Instagram (حساب إنستغرام)',
                hint: '@username',
                icon: Icons.camera_alt_outlined,
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _telegramController,
                label: 'Telegram (معرف تلغرام)',
                hint: '@username',
                icon: Icons.send_rounded,
                isDark: isDark,
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
                      ),
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: Text(AppStrings.tr('cancel'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(isEdit ? Icons.save_rounded : Icons.check_circle_outline_rounded, size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  isEdit ? AppStrings.tr('save') : AppStrings.tr('create_now'),
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.white30 : Colors.black38),
            prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
            filled: true,
            fillColor: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
