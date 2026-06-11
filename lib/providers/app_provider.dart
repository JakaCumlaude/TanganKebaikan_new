import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/preference_service.dart';

class AppProvider extends ChangeNotifier {
  final _dbHelper = DatabaseHelper();
  final _prefService = PreferenceService();

  List<Map<String, dynamic>> _donations = [];
  List<Map<String, dynamic>> _volunteers = [];
  Map<String, dynamic> _profile = {};

  List<Map<String, dynamic>> get donations => _donations;
  List<Map<String, dynamic>> get volunteers => _volunteers;
  Map<String, dynamic> get profile => _profile;

  bool get isDarkMode => _profile['is_dark_mode'] ?? false;

  Future<void> initApp() async {
    try {
      debugPrint("====== 🚀 MEMULAI INISIALISASI APP ======");
      await fetchProfile();
      await fetchDonations();
      await fetchVolunteers();
      debugPrint("====== ✅ INISIALISASI APP SELESAI ======");
    } catch (e) {
      debugPrint("❌ ERROR PADA initApp(): $e");
    }
  }

  Future<void> fetchProfile() async {
    try {
      _profile = await _prefService.getProfileData();
      notifyListeners();
    } catch (e) {
      debugPrint("❌ ERROR LUPA AMBIL PROFIL (SharedPrefs): $e");
    }
  }

  Future<void> updateProfile(
    String name,
    String email,
    String phone,
    bool darkMode,
  ) async {
    await _prefService.saveProfile(
      name: name,
      email: email,
      phone: phone,
      darkMode: darkMode,
    );
    await fetchProfile();
  }

  Future<void> fetchDonations() async {
    try {
      _donations = await _dbHelper.getDonations();
      debugPrint("📊 Data Donasi Berhasil Ditarik: ${_donations.length} item");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ ERROR SAAT MENGAMBIL DATA DONASI (SQLite): $e");
    }
  }

  Future<void> addDonation(Map<String, dynamic> data) async {
    try {
      await _dbHelper.insertDonation(data);
      await _prefService.incrementDonationCount();
      await fetchDonations();
      await fetchProfile();
      debugPrint("✅ Berhasil Menambah Donasi ke SQLite");
    } catch (e) {
      debugPrint("❌ ERROR SAAT INPUT DONASI (SQLite): $e");
    }
  }

  Future<void> removeDonation(int id) async {
    await _dbHelper.deleteDonation(id);
    await fetchDonations();
  }

  Future<void> fetchVolunteers() async {
    try {
      _volunteers = await _dbHelper.getVolunteers();
      debugPrint(
        "📊 Data Relawan Berhasil Ditarik: ${_volunteers.length} orang",
      );
      notifyListeners();
    } catch (e) {
      debugPrint("❌ ERROR SAAT MENGAMBIL DATA RELAWAN (SQLite): $e");
    }
  }

  Future<void> registerVolunteer(Map<String, dynamic> data) async {
    try {
      await _dbHelper.insertVolunteer(data);
      await fetchVolunteers();
      debugPrint("✅ Berhasil Mendaftarkan Relawan ke SQLite");
    } catch (e) {
      debugPrint("❌ ERROR SAAT DAFTAR RELAWAN (SQLite): $e");
    }
  }

  // TAMBAHAN: Operasi Update
  Future<void> editDonation(int id, Map<String, dynamic> data) async {
    try {
      await _dbHelper.updateDonation(id, data);
      await fetchDonations(); // Ambil data terbaru agar UI refresh otomatis
      debugPrint("✅ Berhasil Mengubah Data Donasi");
    } catch (e) {
      debugPrint("❌ ERROR EDIT DONASI: $e");
    }
  }

  Future<void> editVolunteer(int id, Map<String, dynamic> data) async {
    try {
      await _dbHelper.updateVolunteer(id, data);
      await fetchVolunteers(); // Ambil data terbaru agar UI refresh otomatis
      debugPrint("✅ Berhasil Mengubah Data Relawan");
    } catch (e) {
      debugPrint("❌ ERROR EDIT RELAWAN: $e");
    }
  }

  // TAMBAHAN: Operasi Delete
  Future<void> removeVolunteer(int id) async {
    try {
      await _dbHelper.deleteVolunteer(id);
      await fetchVolunteers(); // Ambil data terbaru agar UI refresh otomatis
      debugPrint("✅ Berhasil Menghapus Relawan");
    } catch (e) {
      debugPrint("❌ ERROR HAPUS RELAWAN: $e");
    }
  }
}
