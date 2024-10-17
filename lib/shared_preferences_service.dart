import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<void> saveFavorites(List<String> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteProducts', products);
  }

  Future<List<String>?> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('favoriteProducts');
  }
}
