import '../../core/config/supabase_config.dart';
import '../models/product.dart';

class ProductRepository {
  Future<List<Product>> fetchProducts({String? categoryName}) async {
    var query = supabase.from('products').select().eq('status', 'active');
    if (categoryName != null && categoryName.isNotEmpty) {
      query = query.ilike('category_name', categoryName);
    }
    final data = await query.order('created_at', ascending: false);
    return (data as List)
        .map((e) => Product.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<Product>> fetchFeaturedProducts({int limit = 10}) async {
    final data = await supabase
        .from('products')
        .select()
        .eq('status', 'active')
        .gt('stock', 0)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List)
        .map((e) => Product.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Product?> fetchProductById(String id) async {
    final data =
        await supabase.from('products').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return Product.fromMap(Map<String, dynamic>.from(data));
  }

  Future<List<Product>> searchProducts(String query) async {
    final data = await supabase
        .from('products')
        .select()
        .eq('status', 'active')
        .ilike('name', '%$query%')
        .order('name');
    return (data as List)
        .map((e) => Product.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
