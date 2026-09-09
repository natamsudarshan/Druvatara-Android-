import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_parent/features/authentication/presentation/screens/login_screen.dart';
import 'package:guardian_parent/features/authentication/presentation/screens/register_screen.dart';
import 'package:guardian_parent/features/authentication/presentation/screens/onboarding_screen.dart';
import 'package:guardian_parent/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:guardian_parent/features/family/presentation/screens/family_setup_screen.dart';
import 'package:guardian_parent/features/child/presentation/screens/child_list_screen.dart';
import 'package:guardian_parent/features/child/presentation/screens/child_detail_screen.dart';
import 'package:guardian_parent/features/pairing/presentation/screens/pairing_screen.dart';
import 'package:guardian_parent/features/devices/presentation/screens/device_list_screen.dart';
import 'package:guardian_parent/features/devices/presentation/screens/device_detail_screen.dart';
import 'package:guardian_parent/features/screen_time/presentation/screens/screen_time_screen.dart';
import 'package:guardian_parent/features/applications/presentation/screens/applications_screen.dart';
import 'package:guardian_parent/features/schedules/presentation/screens/schedules_screen.dart';
import 'package:guardian_parent/features/web_safety/presentation/screens/web_safety_screen.dart';
import 'package:guardian_parent/features/location/presentation/screens/location_screen.dart';
import 'package:guardian_parent/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:guardian_parent/features/reports/presentation/screens/reports_screen.dart';
import 'package:guardian_parent/features/tara/presentation/screens/tara_screen.dart';
import 'package:guardian_parent/features/requests/presentation/screens/requests_screen.dart';
import 'package:guardian_parent/features/co_parent/presentation/screens/co_parent_screen.dart';
import 'package:guardian_parent/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:guardian_parent/features/account/presentation/screens/account_screen.dart';
import 'package:guardian_parent/features/privacy/presentation/screens/privacy_screen.dart';
import 'package:guardian_parent/features/support/presentation/screens/support_screen.dart';
import 'package:guardian_parent/features/settings/presentation/screens/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final isLoggedIn = authState.value?.isAuthenticated ?? false;
      final isOnboarding = state.matchedLocation.startsWith('/onboarding');
      final isAuthRoute = state.matchedLocation.startsWith('/login') || state.matchedLocation.startsWith('/register');

      if (!isLoggedIn && !isOnboarding && !isAuthRoute) {
        return '/onboarding';
      }

      if (isLoggedIn && (isOnboarding || isAuthRoute)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/family-setup',
        name: 'family-setup',
        builder: (context, state) => const FamilySetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/children',
            name: 'children',
            builder: (context, state) => const ChildListScreen(),
            routes: [
              GoRoute(
                path: ':childId',
                name: 'child-detail',
                builder: (context, state) => ChildDetailScreen(childId: state.pathParameters['childId']!),
              ),
            ],
          ),
          GoRoute(
            path: '/pairing/:childId',
            name: 'pairing',
            builder: (context, state) => PairingScreen(childId: state.pathParameters['childId']!),
          ),
          GoRoute(
            path: '/devices',
            name: 'devices',
            builder: (context, state) => const DeviceListScreen(),
            routes: [
              GoRoute(
                path: ':deviceId',
                name: 'device-detail',
                builder: (context, state) => DeviceDetailScreen(deviceId: state.pathParameters['deviceId']!),
              ),
            ],
          ),
          GoRoute(
            path: '/screen-time',
            name: 'screen-time',
            builder: (context, state) => const ScreenTimeScreen(),
          ),
          GoRoute(
            path: '/applications',
            name: 'applications',
            builder: (context, state) => const ApplicationsScreen(),
          ),
          GoRoute(
            path: '/schedules',
            name: 'schedules',
            builder: (context, state) => const SchedulesScreen(),
          ),
          GoRoute(
            path: '/web-safety',
            name: 'web-safety',
            builder: (context, state) => const WebSafetyScreen(),
          ),
          GoRoute(
            path: '/location',
            name: 'location',
            builder: (context, state) => const LocationScreen(),
          ),
          GoRoute(
            path: '/alerts',
            name: 'alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: '/tara',
            name: 'tara',
            builder: (context, state) => const TaraScreen(),
          ),
          GoRoute(
            path: '/requests',
            name: 'requests',
            builder: (context, state) => const RequestsScreen(),
          ),
          GoRoute(
            path: '/co-parent',
            name: 'co-parent',
            builder: (context, state) => const CoParentScreen(),
          ),
          GoRoute(
            path: '/subscription',
            name: 'subscription',
            builder: (context, state) => const SubscriptionScreen(),
          ),
          GoRoute(
            path: '/account',
            name: 'account',
            builder: (context, state) => const AccountScreen(),
          ),
          GoRoute(
            path: '/privacy',
            name: 'privacy',
            builder: (context, state) => const PrivacyScreen(),
          ),
          GoRoute(
            path: '/support',
            name: 'support',
            builder: (context, state) => const SupportScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(state.error?.toString() ?? 'Unknown error', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => context.go('/dashboard'), child: const Text('Go to Dashboard')),
          ],
        ),
      ),
    ),
  );
});

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

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
    if (location.startsWith('/children')) currentIndex = 1;
    else if (location.startsWith('/devices')) currentIndex = 2;
    else if (location.startsWith('/alerts')) currentIndex = 3;
    else if (location.startsWith('/tara')) currentIndex = 4;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        switch (index) {
          case 0: context.go('/dashboard'); break;
          case 1: context.go('/children'); break;
          case 2: context.go('/devices'); break;
          case 3: context.go('/alerts'); break;
          case 4: context.go('/tara'); break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.child_care_outlined),
          selectedIcon: Icon(Icons.child_care),
          label: 'Children',
        ),
        NavigationDestination(
          icon: Icon(Icons.devices_outlined),
          selectedIcon: Icon(Icons.devices),
          label: 'Devices',
        ),
        NavigationDestination(
          icon: Icon(Icons.warning_amber_outlined),
          selectedIcon: Icon(Icons.warning_amber),
          label: 'Alerts',
        ),
        NavigationDestination(
          icon: Icon(Icons.psychology_outlined),
          selectedIcon: Icon(Icons.psychology),
          label: 'TARA',
        ),
      ],
    );
  }
}