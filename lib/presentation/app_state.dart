import 'package:flutter/foundation.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/learning_repository.dart';
import '../models/app_models.dart';

class AppState extends ChangeNotifier {
  AppState(this.authRepository, this.learningRepository);
  final AuthRepository authRepository;
  final LearningRepository learningRepository;
  AppUser? currentUser;
  bool isLoading = true;
  String? errorMessage;
  String? registrationMessage;
  UserStreak streak = const UserStreak(count: 0, lastActivityDate: null);
  Future<void> restoreSession() async {
    currentUser = await authRepository.restoreSession();
    if (currentUser != null) {
      streak = await learningRepository.getStreak(currentUser!.id);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async => _run(() async {
    currentUser = await authRepository.signIn(email, password);
    streak = await learningRepository.getStreak(currentUser!.id);
  });
  Future<bool> register(String name, String email, String password) async {
    registrationMessage = null;
    var canEnterDashboard = false;
    final completed = await _run(() async {
      final result = await authRepository.register(name, email, password);
      if (result.needsEmailConfirmation) {
        registrationMessage =
            'Akun berhasil dibuat. Cek email untuk konfirmasi, lalu login.';
        return;
      }
      currentUser = result.user;
      streak = await learningRepository.getStreak(currentUser!.id);
      canEnterDashboard = true;
    });
    return completed && canEnterDashboard;
  }

  Future<void> signOut() async {
    await authRepository.signOut();
    currentUser = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    currentUser = await authRepository.restoreSession();
    notifyListeners();
  }

  Future<void> recordLearningActivity() async {
    final user = currentUser;
    if (user == null) return;
    final today = _dateOnly(DateTime.now());
    final last = streak.lastActivityDate == null
        ? null
        : _dateOnly(streak.lastActivityDate!);
    if (last == today) return;
    final yesterday = today.subtract(const Duration(days: 1));
    final nextCount = last == null || last == yesterday
        ? (last == null ? 1 : streak.count + 1)
        : streak.count;
    streak = await learningRepository.saveStreak(
      user.id,
      UserStreak(count: nextCount, lastActivityDate: today),
    );
    notifyListeners();
  }

  bool get streakActive {
    final last = streak.lastActivityDate;
    if (last == null) return false;
    return _dateOnly(last) == _dateOnly(DateTime.now());
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  Future<bool> _run(Future<void> Function() action) async {
    errorMessage = null;
    try {
      await action();
      notifyListeners();
      return true;
    } catch (error) {
      errorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
