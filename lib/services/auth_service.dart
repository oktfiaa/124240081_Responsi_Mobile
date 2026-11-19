import 'package:shared_preferences/shared_preferences.dart';

// Service autentikasi untuk mengelola sesi login dengan SharedPreferences
class AuthService {
  // Kredensial akun: Username (NIM) dan Password
  static const String validUsername = '124240081';
  static const String validPassword = '123';

  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUsername = 'username';

  // Menyimpan sesi login ke SharedPreferences
  static Future<bool> login(String inputUsername, String inputPassword) async {
    final username = inputUsername.trim();
    final password = inputPassword.trim();

    // Validasi kredensial: username harus NIM '124240081' dan password '123'
    if (username == validUsername && password == validPassword) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyIsLoggedIn, true);
      await prefs.setString(keyUsername, username);
      return true;
    }

    return false;
  }

  // Memeriksa status login saat aplikasi pertama kali dibuka
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  // Mengambil username yang tersimpan untuk ditampilkan di Profile Page
  static Future<String> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUsername) ?? validUsername;
  }

  // Menghapus data sesi saat user logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyIsLoggedIn);
    await prefs.remove(keyUsername);
  }
}
