import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_child/features/pairing/presentation/screens/pairing_welcome_screen.dart';
import 'package:guardian_child/features/pairing/presentation/screens/qr_scanner_screen.dart';
import 'package:guardian_child/features/pairing/presentation/screens/enter_code_screen.dart';
import 'package:guardian_child/features/pairing/presentation/screens/permission_wizard_screen.dart';
import 'package:guardian_child/features/protection_status/presentation/screens/protection_home_screen.dart';
import 'package:guardian_child/features/screen_time/presentation/screens/screen_time_screen.dart';
import 'package:guardian_child/features/requests/presentation/screens/request_access_screen.dart';
import 'package:guardian_child/features/permission_health/presentation/screens/permission_health_screen.dart';
import 'package:guardian_child/features/help/presentation/screens/help_screen.dart';
import 'package:guardian_child/features/privacy/presentation/screens/privacy_screen.dart';

final childAppRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/pairing/welcome',
    routes: [
      GoRoute(
        path: '/pairing/welcome',
        name: 'pairing-welcome',
        builder: (context, state) => const PairingWelcomeScreen(),
      ),
      GoRoute(
        path: '/pairing/scan',
        name: 'pairing-scan',
        builder: (context, state) => const QRScannerScreen(),
      ),
      GoRoute(
        path: '/pairing/enter-code',
        name: 'pairing-enter-code',
        builder: (context, state) => const EnterCodeScreen(),
      ),
      GoRoute(
        path: '/pairing/permissions',
        name: 'pairing-permissions',
        builder: (context, state) => const PermissionWizardScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ChildMainLayout(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const ProtectionHomeScreen(),
          ),
          GoRoute(
            path: '/screen-time',
            name: 'screen-time',
            builder: (context, state) => const ScreenTimeScreen(),
          ),
          GoRoute(
            path: '/requests',
            name: 'requests',
            builder: (context, state) => const RequestAccessScreen(),
          ),
          GoRoute(
            path: '/permissions',
            name: 'permissions',
            builder: (context, state) => const PermissionHealthScreen(),
          ),
          GoRoute(
            path: '/help',
            name: 'help',
            builder: (context, state) => const HelpScreen(),
          ),
          GoRoute(
            path: '/privacy',
            name: 'privacy',
            builder: (context, state) => const PrivacyScreen(),
          ),
        ],
      ),
    ],
  );
});

class ChildMainLayout extends StatelessWidget {
  final Widget child;

  const ChildMainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (location.startsWith('/screen-time')) currentIndex = 1;
    else if (location.startsWith('/requests')) currentIndex = 2;
    else if (location.startsWith('/permissions')) currentIndex = 3;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0: context.go('/home'); break;
          case 1: context.go('/screen-time'); break;
          case 2: context.go('/requests'); break;
          case 3: context.go('/permissions'); break;
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.shield_outlined),
          selectedIcon: const Icon(Icons.shield),
          label: AppLocalizations.of(context).home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.schedule_outlined),
          selectedIcon: const Icon(Icons.schedule),
          label: AppLocalizations.of(context).screenTime,
        ),
        NavigationDestination(
          icon: const Icon(Icons.request_page_outlined),
          selectedIcon: const Icon(Icons.request_page),
          label: AppLocalizations.of(context).requests,
        ),
        NavigationDestination(
          icon: const Icon(Icons.security_outlined),
          selectedIcon: const Icon(Icons.security),
          label: AppLocalizations.of(context).permissions,
        ),
      ],
    );
  }
}