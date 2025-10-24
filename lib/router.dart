import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'screens/auth/landing_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/admin/appointments/appointment_management_screen.dart';
import 'screens/admin/services/service_management_screen.dart';
import 'screens/admin/reports/reports_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
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
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomeScreen(),
        routes: [
          GoRoute(
            path: 'appointments',
            builder: (context, state) =>
                const AppointmentManagementScreen(),
          ),
          GoRoute(
            path: 'services',
            builder: (context, state) => const ServiceManagementScreen(),
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
        ]),
  ],
  redirect: (context, state) async {
    final user = FirebaseAuth.instance.currentUser;
    final isGoingToAdmin = state.matchedLocation.startsWith('/admin');

    // If user is not logged in and tries to access a protected route
    if (user == null && isGoingToAdmin) {
      return '/login'; // Redirect to login
    }

    // If user is logged in and tries to access admin route
    if (user != null && isGoingToAdmin) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final role = userDoc.data()?['role'];

      if (role != 'admin') {
        return '/home'; // Not an admin, redirect to user home
      }
    }

    return null; // No redirection needed
  },
);
