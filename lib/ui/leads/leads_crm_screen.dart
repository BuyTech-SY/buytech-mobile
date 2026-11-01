import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/lead_model.dart';
import '../../data/services/api_service.dart';

class LeadsCrmScreen extends StatefulWidget {
  const LeadsCrmScreen({super.key});

  @override
  State<LeadsCrmScreen> createState() => _LeadsCrmScreenState();
}

class _LeadsCrmScreenState extends State<LeadsCrmScreen> {
  bool _isLoading = true;
  List<LeadModel> _leads = [];
  String _searchQuery = '';
  String? _selectedCardFilter;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLeads();
  }

  Future<void> _fetchLeads() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final leads = await ApiService.getLeads();
      if (!mounted) return;
      setState(() {
        _leads = leads;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل بيانات العملاء المحتملين';
      });
    }
  }

  List<LeadModel> get _filteredLeads {
    return _leads.where((l) {
      final matchesSearch = _searchQuery.isEmpty ||
          l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          l.phone.contains(_searchQuery) ||
          (l.company?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (l.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesCard = _selectedCardFilter == null || l.cardName == _selectedCardFilter;

      return matchesSearch && matchesCard;
    }).toList();
  }

  List<String> get _availableCards {
    final set = <String>{};
    for (final l in _leads) {
      if (l.cardName != null && l.cardName!.isNotEmpty) {
        set.add(l.cardName!);
      }
    }
    return set.toList();
  }

  Future<void> _launchWhatsApp(String phone, String name) async {
    // Clean phone number: remove non-digits except +
    var cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.startsWith('00')) {
      cleanPhone = '+${cleanPhone.substring(2)}';
    } else if (cleanPhone.startsWith('05')) {
      cleanPhone = '+966${cleanPhone.substring(1)}';
    } else if (cleanPhone.startsWith('09')) {
      cleanPhone = '+963${cleanPhone.substring(1)}';
    }

    final greeting = 'مرحباً $name، يسعدنا التواصل معك من طرف نظام البطاقات الذكية Access.';
    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(greeting)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح تطبيق واتساب')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إجراء المكالمة الهاتفية')),
        );
      }
    }
  }

  void _shareLead(LeadModel lead) {
    final text = '''
جهة اتصال جديدة من Access Smart Cards:
الاسم: ${lead.name}
الهاتف: ${lead.phone}
${lead.company != null ? 'الشركة: ${lead.company}\n' : ''}${lead.email != null ? 'البريد: ${lead.email}\n' : ''}${lead.notes != null ? 'ملاحظات: ${lead.notes}\n' : ''}البطاقة المصدر: ${lead.cardName ?? 'Access'}
''';
    Share.share(text, subject: 'بيانات العميل ${lead.name}');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final list = _filteredLeads;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المعارف والعملاء (Contacts)',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLeads,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: isDark ? AppColors.darkSurface : Colors.white,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم، الهاتف، الشركة، أو البريد...',
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
                if (_availableCards.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('الكل', style: TextStyle(fontSize: 12)),
                          selected: _selectedCardFilter == null,
                          onSelected: (val) => setState(() => _selectedCardFilter = null),
                          selectedColor: AppColors.primary.withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: _selectedCardFilter == null ? AppColors.primary : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ..._availableCards.map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(c, style: const TextStyle(fontSize: 12)),
                              selected: _selectedCardFilter == c,
                              onSelected: (val) => setState(() => _selectedCardFilter = val ? c : null),
                              selectedColor: AppColors.primary.withOpacity(0.15),
                              labelStyle: TextStyle(
                                color: _selectedCardFilter == c ? AppColors.primary : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // Content List
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
                            ElevatedButton(onPressed: _fetchLeads, child: const Text('إعادة المحاولة')),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchLeads,
                        color: AppColors.primary,
                        child: list.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                  Center(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 72,
                                          height: 72,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.people_outline, size: 36, color: AppColors.primary),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'لا يوجد عملاء حتى الآن',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'عندما يقوم أي زائر بتبادل جهات الاتصال عبر بطاقتك الذكية، سيظهر هنا فوراً.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  final lead = list[index];
                                  return _buildLeadCard(lead, isDark);
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(LeadModel lead, bool isDark) {
    final initials = lead.name.isNotEmpty
        ? lead.name.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join()
        : 'ع';

    final dateStr = lead.createdAt != null
        ? DateFormat('yyyy/MM/dd - hh:mm a').format(lead.createdAt!)
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showLeadDetailSheet(lead, isDark),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar, Name, Company, Card Tag
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  lead.name,
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                ),
                              ),
                              if (lead.cardName != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    lead.cardName!,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (lead.company != null && lead.company!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              lead.company!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            lead.phone,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (lead.notes != null && lead.notes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '💬 "${lead.notes}"',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Action Bar: WhatsApp, Call, Share, Copy
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (dateStr != null)
                      Text(
                        dateStr,
                        style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.grey),
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      children: [
                        // Copy phone
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          tooltip: 'نسخ رقم الهاتف',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: lead.phone));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم نسخ رقم الهاتف')),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        // Share
                        IconButton(
                          icon: const Icon(Icons.share, size: 16),
                          tooltip: 'مشاركة جهة الاتصال',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          onPressed: () => _shareLead(lead),
                        ),
                        const SizedBox(width: 6),
                        // Phone Call
                        IconButton(
                          icon: const Icon(Icons.phone, size: 17, color: AppColors.phoneEmerald),
                          tooltip: 'اتصال هاتفي',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                          onPressed: () => _makePhoneCall(lead.phone),
                        ),
                        const SizedBox(width: 8),
                        // Direct WhatsApp Button
                        ElevatedButton.icon(
                          icon: const Icon(Icons.chat, size: 14),
                          label: const Text('واتساب', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.whatsappGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: () => _launchWhatsApp(lead.phone, lead.name),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLeadDetailSheet(LeadModel lead, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    child: Text(
                      lead.name.isNotEmpty ? lead.name[0] : 'ع',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lead.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        if (lead.company != null)
                          Text(lead.company!, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(Icons.phone, 'رقم الهاتف', lead.phone, onTap: () => _makePhoneCall(lead.phone)),
              if (lead.email != null && lead.email!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.email, 'البريد الإلكتروني', lead.email!, onTap: () async {
                  final url = Uri.parse('mailto:${lead.email}');
                  if (await canLaunchUrl(url)) await launchUrl(url);
                }),
              ],
              if (lead.cardName != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.credit_card, 'البطاقة الذكية', lead.cardName!),
              ],
              if (lead.notes != null && lead.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.notes, 'ملاحظات العميل', lead.notes!),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.phone, color: AppColors.phoneEmerald),
                      label: const Text('اتصال'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _makePhoneCall(lead.phone),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text('محادثة واتساب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whatsappGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _launchWhatsApp(lead.phone, lead.name);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: onTap != null ? AppColors.primaryDark : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
