import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'pages/home_page.dart';
import 'pages/volunteer_page.dart';
import 'pages/account_page.dart';

void main() async {
  // Memastikan inisialisasi binding Flutter selesai sebelum app jalan (penting untuk SQLite/SharedPrefs)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const TanganKebaikanApp());
}

class TanganKebaikanApp extends StatelessWidget {
  const TanganKebaikanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // KUNCINYA DI SINI: Menggunakan cascade operator (..initApp())
      // Aplikasi akan langsung terbuka instan, sementara database dimuat di background tanpa memblokir layar HP.
      create: (_) => AppProvider()..initApp(),
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'Tangan Kebaikan',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              colorSchemeSeed: const Color(0xFF11998e),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              colorSchemeSeed: const Color(0xFF11998e),
            ),
            themeMode: appProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const MainNavigation(),
          );
        },
      ),
    );
  }
}

// Komponen untuk Bottom Navigation Bar agar mempermudah perpindahan halaman
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    VolunteerPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Donasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_ind_outlined),
            selectedIcon: Icon(Icons.assignment_ind),
            label: 'Relawan',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
