import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_strings.dart';
import '../smart_cards/smart_cards_screen.dart';
import '../scanner/qr_scanner_screen.dart';
import '../leads/leads_crm_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    SmartCardsScreen(),
    QrScannerScreen(),
    LeadsCrmScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppColors.primary.withOpacity(0.15),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.credit_card_outlined),
                selectedIcon: const Icon(Icons.credit_card_rounded, color: AppColors.primary),
                label: AppStrings.tr('my_cards'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.qr_code_scanner_outlined),
                selectedIcon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
                label: AppStrings.tr('qr_scanner'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.contacts_outlined),
                selectedIcon: const Icon(Icons.contacts_rounded, color: AppColors.primary),
                label: AppStrings.tr('contacts'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primary),
                label: AppStrings.tr('settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
