import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/appointment_model.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/appointments/appointment_management_screen.dart';
import '../../screens/admin/services/service_management_screen.dart';
import '../../screens/auth/landing_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/user/user_home_screen.dart';
import '../../screens/user/book_appointment_screen.dart';
import '../../screens/user/user_appointments_screen.dart';
import '../../screens/user/edit_appointment_screen.dart';
import '../../screens/user/profile_screen.dart';
import '../auth/auth_service.dart';
import '../../widgets/scaffold_with_nav_bar.dart';

class RouterService {
  final AuthService authService;
  late final GoRouter router;

  RouterService(this.authService) {
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final shellNavigatorKey = GlobalKey<NavigatorState>();

    router = GoRouter(
      refreshListenable: authService,
      initialLocation: '/',
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LandingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
          routes: [
            GoRoute(
              path: 'services',
              builder: (context, state) => const ServiceManagementScreen(),
            ),
            GoRoute(
              path: 'appointments',
              builder: (context, state) => const AppointmentManagementScreen(),
            ),
          ],
        ),
        ShellRoute(
          navigatorKey: shellNavigatorKey,
          builder: (context, state, child) {
            return ScaffoldWithNavBar(child: child);
          },
          routes: [
            GoRoute(
              path: '/user',
              builder: (context, state) => const UserHomeScreen(),
            ),
            GoRoute(
              path: '/user/book',
              builder: (context, state) => const BookAppointmentScreen(),
            ),
            GoRoute(
              path: '/user/appointments',
              builder: (context, state) => const UserAppointmentsScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => EditAppointmentScreen(
                    appointment: state.extra as Appointment,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: '/user/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final loggedIn = authService.user != null;
        final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register' || state.matchedLocation == '/';

        if (!loggedIn) {
          return loggingIn ? null : '/';
        }

        if (loggingIn) {
          return authService.isAdmin ? '/admin' : '/user';
        }

        return null;
      },
    );
  }
}
