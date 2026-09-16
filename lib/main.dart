import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/learning_repository.dart';
import 'models/app_models.dart';
import 'presentation/app_state.dart';
import 'views/admin/admin_shell.dart';
import 'views/auth/auth_page.dart';
import 'views/customer/customer_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final config = AppConfig.fromEnvironment(dotenv.env);
  if (!config.isSupabaseConfigured) {
    runApp(
      const _StartupErrorApp(message: 'Konfigurasi Supabase belum lengkap.'),
    );
    return;
  }
  try {
    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabaseKey,
    );
  } catch (error) {
    runApp(
      _StartupErrorApp(message: 'Supabase tidak dapat dihubungkan: $error'),
    );
    return;
  }
  runApp(
    LunaVerseApp(
      authRepository: SupabaseAuthRepository(),
      learningRepository: SupabaseLearningRepository(),
    ),
  );
}

class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    ),
  );
}

class LunaVerseApp extends StatelessWidget {
  const LunaVerseApp({super.key, this.authRepository, this.learningRepository});
  final AuthRepository? authRepository;
  final LearningRepository? learningRepository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(
        authRepository ?? const UnavailableAuthRepository(),
        learningRepository ?? DemoLearningRepository(),
      )..restoreSession(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nova Language Learning',
        theme: AppTheme.light,
        home: const _AppRouter(),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.currentUser == null) return const AuthPage();
    return state.currentUser!.role == UserRole.admin
        ? const AdminShell()
        : const CustomerShell();
  }
}
