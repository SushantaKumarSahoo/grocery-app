import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_ext.dart';
import '../../providers/cart_provider.dart';
import 'home_screen.dart';
import '../categories/categories_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/floating_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _docked = false;

  final _pages = const [
    HomeScreen(),
    CategoriesScreen(),
    CartScreen(embedded: true),
    OrdersScreen(),
    ProfileScreen(),
  ];

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    final direction = notification.metrics.axis == Axis.vertical
        ? (notification is UserScrollNotification ? notification.direction : null)
        : null;
    if (direction == null) return false;

    final shouldDock = direction == ScrollDirection.reverse;
    final shouldFloat = direction == ScrollDirection.forward ||
        notification.metrics.pixels <= notification.metrics.minScrollExtent;

    if (shouldDock && !_docked) {
      setState(() => _docked = true);
    } else if (shouldFloat && _docked) {
      setState(() => _docked = false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().itemCount;

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _index,
        docked: _docked,
        onTap: (i) => setState(() {
          _index = i;
          _docked = false;
        }),
        items: [
          const NavItemData(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
          ),
          const NavItemData(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: 'Categories',
          ),
          NavItemData(
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag_rounded,
            label: 'Cart',
            badgeCount: cartCount,
          ),
          const NavItemData(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: 'Orders',
          ),
          const NavItemData(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
