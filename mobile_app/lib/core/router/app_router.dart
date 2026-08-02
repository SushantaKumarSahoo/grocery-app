import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/phone_login_screen.dart';
import '../../features/auth/otp_screen.dart';
import '../../features/auth/complete_profile_screen.dart';
import '../../features/home/main_shell.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/categories/category_products_screen.dart';
import '../../features/product/product_details_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/event/event_details_screen.dart';
import '../../features/event/order_summary_screen.dart';
import '../../features/quotation/quotation_screen.dart';
import '../../features/orders/order_detail_screen.dart';
import '../../features/profile/addresses_screen.dart';
import '../../features/support/support_screen.dart';
import '../../features/support/support_ticket_screen.dart';
import '../../data/models/product.dart';

class AppRouter {
  static GoRouter build(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final status = authProvider.status;
        final loc = state.matchedLocation;

        if (status == AuthStatus.unknown) {
          return loc == '/splash' ? null : '/splash';
        }
        if (status == AuthStatus.onboarding) {
          return loc == '/onboarding' ? null : '/onboarding';
        }
        final authRoutes = ['/login', '/register', '/phone-login', '/otp'];
        if (status == AuthStatus.unauthenticated || status == AuthStatus.awaitingOtp) {
          return authRoutes.contains(loc) ? null : '/login';
        }
        if (status == AuthStatus.needsProfile) {
          return loc == '/complete-profile' ? null : '/complete-profile';
        }
        if (status == AuthStatus.authenticated) {
          if (loc == '/splash' ||
              loc == '/onboarding' ||
              loc == '/complete-profile' ||
              authRoutes.contains(loc)) {
            return '/home';
          }
        }
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
        GoRoute(
            path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
        GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
        GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
        GoRoute(
            path: '/phone-login',
            builder: (c, s) => const PhoneLoginScreen()),
        GoRoute(
          path: '/otp',
          builder: (c, s) => OtpScreen(phone: s.extra as String? ?? ''),
        ),
        GoRoute(
            path: '/complete-profile',
            builder: (c, s) => const CompleteProfileScreen()),
        GoRoute(path: '/home', builder: (c, s) => const MainShell()),
        GoRoute(path: '/browse', builder: (c, s) => const CategoriesScreen()),
        GoRoute(
          path: '/category/:id',
          builder: (c, s) => CategoryProductsScreen(
            categoryId: s.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/product/:id',
          builder: (c, s) => ProductDetailsScreen(
            product: s.extra as Product,
          ),
        ),
        GoRoute(path: '/cart', builder: (c, s) => const CartScreen()),
        GoRoute(path: '/addresses', builder: (c, s) => const AddressesScreen()),
        GoRoute(path: '/support', builder: (c, s) => const SupportScreen()),
        GoRoute(
          path: '/support/:ticketId',
          builder: (c, s) => SupportTicketScreen(
            ticketId: s.pathParameters['ticketId']!,
            subject: s.extra as String?,
          ),
        ),
        GoRoute(
            path: '/event-details',
            builder: (c, s) => const EventDetailsScreen()),
        GoRoute(
            path: '/order-summary',
            builder: (c, s) => const OrderSummaryScreen()),
        GoRoute(
          path: '/quotation/:orderId',
          builder: (c, s) => QuotationScreen(
            orderId: s.pathParameters['orderId']!,
          ),
        ),
        GoRoute(
          path: '/order/:orderId',
          builder: (c, s) => OrderDetailScreen(
            orderId: s.pathParameters['orderId']!,
          ),
        ),
      ],
    );
  }
}
