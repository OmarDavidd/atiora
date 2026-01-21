import 'package:atiora/core/storage/hive_service.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/di.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  SharedPreferences.setMockInitialValues({});

  await HiveService.instance.init();

  // 🧪 PROBAR HIVE AHORA
  final hive = HiveService.instance;
  final now = DateTime.now();

  final testBook = BookModel(
    id: 'test-123',
    userId: 'test-user',
    title: 'El Quijote - Prueba Hive',
    author: 'Cervantes',
    genre: ['ficción', 'clásico'],
    totalPages: 500,
    currentPage: 150,
    status: 'leyendo',
    rating: 4.5,
    coverUrl: 'https://example.com/quijote.jpg',
    createdAt: now,
    updatedAt: now,
  );

  // GUARDAR
  await hive.saveBook(testBook);

  // LEER
  final savedBook = hive.getBook('test-123');
  print('🎉 HIVE FUNCIONA: ${savedBook?.title ?? "ERROR"}');
  print('📚 Géneros: ${savedBook?.genre.join(", ")}');

  await configureDependencies();

  runApp(const AtioraApp());
}

class AtioraApp extends StatefulWidget {
  const AtioraApp({super.key});

  @override
  State<AtioraApp> createState() => _AtioraAppState();
}

class _AtioraAppState extends State<AtioraApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await AppTheme.loadThemeMode();
    if (mounted) {
      setState(() {
        _themeMode = mode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atiora',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.getTheme(context, ThemeMode.light),
      darkTheme: AppTheme.getTheme(context, ThemeMode.dark),
      home: Scaffold(
        appBar: AppBar(title: const Text('Atiora'), centerTitle: true),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text(
                '🎉 Core + Theme + DI Listo!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Próximo: Base de datos',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newMode = _themeMode == ThemeMode.light
                ? ThemeMode.dark
                : ThemeMode.light;
            await AppTheme.saveThemeMode(newMode);
            if (mounted) {
              setState(() {
                _themeMode = newMode;
              });
            }
          },
          child: Icon(
            _themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
