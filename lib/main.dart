import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'router.dart';
import 'providers/user_provider.dart';
import 'providers/auth_provider.dart';
import 'core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // System UI style — match Midnight Neon dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF141420), // warmWhite (dark)
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize local storage
  await LocalStorage.init();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TrySomethingApp(),
    ),
  );
}

class TrySomethingApp extends ConsumerStatefulWidget {
  const TrySomethingApp({super.key});

  @override
  ConsumerState<TrySomethingApp> createState() => _TrySomethingAppState();
}

class _TrySomethingAppState extends ConsumerState<TrySomethingApp> {
  @override
  void initState() {
    super.initState();
    // Attempt to restore auth session from stored tokens
    Future.microtask(() {
      ref.read(authProvider.notifier).tryRestoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TrySomething',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
