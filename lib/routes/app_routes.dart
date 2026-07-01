// routes/app_routes.dart
import 'package:flutter/material.dart';
import 'package:swiftly_mobile/screens/dashboard_screen.dart';
import 'package:swiftly_mobile/screens/rider_dashboard_screen.dart';
import 'package:swiftly_mobile/screens/store_owner_dashboard_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/store_owner/store_profile.dart';

class AppRoutes {
  // Customer routes
  static const String home = '/';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';

  // Rider routes
  static const String riderDashboard = '/rider-dashboard';
  static const String riderDeliveries = '/rider-deliveries';
  static const String riderProfile = '/rider-profile';

  // Store Owner routes
  static const String storeDashboard = '/store-dashboard';
  static const String storeProducts = '/store-products';
  static const String storeInventory = '/store-inventory';
  static const String storeProfile = '/store-profile';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Customer routes
      case home:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      // Rider routes
      case riderDashboard:
        return MaterialPageRoute(builder: (_) => const RiderDashboardScreen());
      case riderDeliveries:
        // return MaterialPageRoute(builder: (_) => const RiderDeliveriesScreen());
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Deliveries'),
        );
      case riderProfile:
        // return MaterialPageRoute(builder: (_) => const RiderProfileScreen());
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Profile'),
        );

      // Store Owner routes
      case storeDashboard:
        return MaterialPageRoute(
          builder: (_) => const StoreOwnerDashboardScreen(),
        );
      case storeProducts:
        // return MaterialPageRoute(builder: (_) => const StoreProductsScreen());
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Products'),
        );
      case storeInventory:
        // return MaterialPageRoute(builder: (_) => const StoreInventoryScreen());
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Inventory'),
        );
      case storeProfile:
        // return MaterialPageRoute(builder: (_) => const StoreProfileScreen());
        return MaterialPageRoute(builder: (_) => const StoreProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
    }
  }
}

// Temporary placeholder
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('$title - Coming Soon')));
  }
}
