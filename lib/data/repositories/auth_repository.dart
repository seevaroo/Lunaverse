import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/app_models.dart';

abstract class AuthRepository {
  Future<AppUser?> restoreSession();
  Future<AppUser> signIn(String email, String password);
  Future<RegistrationResult> register(String name, String email, String password);
  Future<void> signOut();
  Future<void> updateName(String name);
  Future<void> updatePassword(String currentPassword, String newPassword);
}

class RegistrationResult {
  const RegistrationResult({required this.user, required this.needsEmailConfirmation});
  final AppUser user;
  final bool needsEmailConfirmation;
}

class SupabaseAuthRepository implements AuthRepository {
  final _client = Supabase.instance.client;

  AppUser _map(User user) => AppUser(
        id: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['name'] as String? ?? 'Learner',
        role: user.userMetadata?['role'] == 'admin' ? UserRole.admin : UserRole.user,
      );

  @override
  Future<AppUser?> restoreSession() async {
    final user = _client.auth.currentUser;
    return user == null ? null : _map(user);
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(email: email, password: password);
    return _map(response.user!);
  }

  @override
  Future<RegistrationResult> register(String name, String email, String password) async {
    if (password.length < 6) {
      throw const AuthException('Password Supabase minimal 6 karakter.');
    }
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': 'user'},
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Registrasi belum selesai.');
    }
    return RegistrationResult(
      user: _map(user),
      needsEmailConfirmation: response.session == null,
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> updateName(String name) async {
    await _client.auth.updateUser(
      UserAttributes(data: {'name': name}),
    );
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('User tidak ditemukan.');
    }
    
    // Verify current password by signing in again
    await _client.auth.signInWithPassword(
      email: user.email!,
      password: currentPassword,
    );
    
    // Update password
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}

class UnavailableAuthRepository implements AuthRepository {
  const UnavailableAuthRepository();

  @override
  Future<AppUser?> restoreSession() async => null;

  @override
  Future<AppUser> signIn(String email, String password) async {
    throw const AuthException('Supabase belum terhubung.');
  }

  @override
  Future<RegistrationResult> register(String name, String email, String password) async {
    throw const AuthException('Supabase belum terhubung.');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updateName(String name) async {
    throw const AuthException('Supabase belum terhubung.');
  }

  @override
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    throw const AuthException('Supabase belum terhubung.');
  }
}