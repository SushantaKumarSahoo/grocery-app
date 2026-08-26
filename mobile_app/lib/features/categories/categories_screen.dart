import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../data/models/category.dart';
import '../home/widgets/category_tile.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(title: const Text('Categories')),
      body: ScreenBackdrop(
        themed: true,
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: staticCategories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, i) {
            final c = staticCategories[i];
            return CategoryTile(
                  category: c,
                  onTap: () =>
                      context.push('/category/${Uri.encodeComponent(c.name)}'),
                )
                .animate()
                .fadeIn(delay: (30 * i).ms, duration: 280.ms)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  delay: (30 * i).ms,
                  duration: 280.ms,
                  curve: Curves.easeOutBack,
                );
          },
        ),
      ),
    );
  }
}
