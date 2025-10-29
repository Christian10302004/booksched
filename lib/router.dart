import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/screens/admin/manage_services_screen.dart';
import 'package:myapp/screens/admin/reports_screen.dart';
import 'package:myapp/screens/user/book_appointment_screen.dart';
import 'package:myapp/screens/user/edit_profile_screen.dart';
import 'package:myapp/screens/user/profile_screen.dart';
import 'package:myapp/screens/user/user_home_screen.dart';
import 'package:myapp/screens/user/view_appointments_screen.dart';
import 'package:myapp/widgets/scaffold_with_nav_bar.dart';
import 'services/auth/auth_service.dart'; // Import AuthService
import 'screens/auth/landing_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/appointment_management_screen.dart';

// Private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthService authService) {
  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authService, // Listen for auth changes
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LandingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/user',
            builder: (context, state) => const UserHomeScreen(),
            routes: [
              GoRoute(
                path: 'edit_profile',
                builder: (context, state) => const EditProfileScreen(),
              ),
            ]
          ),
          GoRoute(
            path: '/user/book',
            builder: (context, state) => const BookAppointmentScreen(),
          ),
          GoRoute(
            path: '/user/appointments',
            builder: (context, state) => const ViewAppointmentsScreen(),
          ),
          GoRoute(
            path: '/user/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomeScreen(),
        routes: [
          GoRoute(
            path: 'appointments',
            builder: (context, state) => const AppointmentManagementScreen(),
          ),
          GoRoute(
            path: 'services',
            builder: (context, state) => const ManageServicesScreen(),
          ),
          GoRoute(path: 'reports', builder: (context, state) => const ReportsScreen()),
        ],
      ),
    ],
    redirect: (context, state) async {
      final user = authService.user;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/';

      if (user == null) {
        return isAuthRoute ? null : '/';
      }

      if (isAuthRoute) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final role = userDoc.data()?['role'];
        return role == 'admin' ? '/admin' : '/user';
      }

      final isGoingToAdmin = state.matchedLocation.startsWith('/admin');
      if (isGoingToAdmin) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final role = userDoc.data()?['role'];
        if (role != 'admin') {
          return '/user'; // Not an admin, redirect to user home
        }
      }

      return null; // No redirection needed
    },
  );
}
