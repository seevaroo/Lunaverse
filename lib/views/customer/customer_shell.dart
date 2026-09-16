import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/learning_repository.dart';
import '../../models/app_models.dart';
import '../../presentation/app_state.dart';

const _indigo = Color(0xffa855f7);
const _indigoBright = Color(0xffc084fc);
const _pageBackground = Color(0xff0d0721);
const _panel = Color(0xff160d33);
const _panelSoft = Color(0xff1f1242);
const _border = Color(0xff351662);
const _muted = Color(0xffa69ab8);

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell>
    with SingleTickerProviderStateMixin {
  String activeMenu = 'Dashboard';
  final progress = <int>[80, 42, 64, 25];
  bool isRecording = false;
  Language? selectedLanguage;
  Language? selectedVocabLanguage;
  late final AnimationController waveController;
  Timer? recordingTimer;

  @override
  void initState() {
    super.initState();
    waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    recordingTimer?.cancel();
    waveController.dispose();
    super.dispose();
  }

  void toggleRecording() {
    setState(() => isRecording = !isRecording);
    if (isRecording) {
      waveController.repeat();
      recordingTimer = Timer(const Duration(seconds: 8), () {
        if (mounted) setState(() => isRecording = false);
        waveController.stop();
      });
    } else {
      recordingTimer?.cancel();
      waveController.stop();
    }
  }

  void saveRecording(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recording saved to your speaking practice.'),
      ),
    );
  }

  void openExerciseSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: .85,
        child: _ExercisePanel(
          isRecording: isRecording,
          waveAnimation: waveController,
          onRecording: toggleRecording,
          onSave: () => saveRecording(context),
        ),
      ),
    );
  }

  void chooseMenu(String menu) {
    setState(() => activeMenu = menu);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 1000;
    final state = context.watch<AppState>();
    final center = _CenterContent(
      activeMenu: activeMenu,
      streakCount: state.streak.count,
      streakActive: state.streakActive,
      progress: progress,
      onProgressTap: (index) =>
          setState(() => progress[index] = (progress[index] + 8).clamp(0, 100)),
      onSelectLanguage: (language) => setState(() {
        selectedLanguage = language;
        activeMenu = 'Languages';
      }),
      onOpenLanguages: () => setState(() => activeMenu = 'Languages'),
      onOpenDashboard: () => setState(() => activeMenu = 'Dashboard'),
      selectedLanguage: selectedLanguage,
      selectedVocabLanguage: selectedVocabLanguage,
      onSelectVocabLanguage: (language) => setState(() => selectedVocabLanguage = language),
    );

    if (isDesktop) {
      return Scaffold(
        backgroundColor: _pageBackground,
        body: Row(
          children: [
            _NavigationSidebar(
              activeMenu: activeMenu,
              userName: state.currentUser?.name ?? 'Learner',
              streakCount: state.streak.count,
              streakActive: state.streakActive,
              onSelect: chooseMenu,
              onSignOut: state.signOut,
            ),
            Expanded(
              child: Column(
                children: [
                  const _DashboardTopBar(),
                  Expanded(child: center),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: _pageBackground,
      drawer: Drawer(
        child: _NavigationSidebar(
          activeMenu: activeMenu,
          userName: state.currentUser?.name ?? 'Learner',
          streakCount: state.streak.count,
          streakActive: state.streakActive,
          onSelect: (menu) {
            Navigator.pop(context);
            chooseMenu(menu);
          },
          onSignOut: state.signOut,
        ),
      ),
      appBar: AppBar(
        backgroundColor: _pageBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const _BrandMark(),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ),
      ),
      body: center,
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _indigo,
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Text(
          'L',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(width: 9),
      const Text(
        'LinguaNova',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    ],
  );
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar();

  @override
  Widget build(BuildContext context) => Container(
    height: 70,
    padding: const EdgeInsets.symmetric(horizontal: 28),
    decoration: const BoxDecoration(
      color: _pageBackground,
      border: Border(bottom: BorderSide(color: Color(0xff211039))),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 400,
          height: 40,
          child: TextField(
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search courses, vocabulary...',
              hintStyle: const TextStyle(color: _muted),
              prefixIcon: const Icon(Icons.search, color: _muted, size: 19),
              filled: true,
              fillColor: _panel,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: _border),
              ),
            ),
          ),
        ),
        const Spacer(),
        _topIcon(Icons.notifications_none_rounded),
        const SizedBox(width: 10),
        _topIcon(Icons.person_outline_rounded),
      ],
    ),
  );

  Widget _topIcon(IconData icon) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: _panel,
      shape: BoxShape.circle,
      border: Border.all(color: _border),
    ),
    child: Icon(icon, color: _indigoBright, size: 19),
  );
}

class _NavigationSidebar extends StatelessWidget {
  const _NavigationSidebar({
    required this.activeMenu,
    required this.userName,
    required this.streakCount,
    required this.streakActive,
    required this.onSelect,
    required this.onSignOut,
  });
  final String activeMenu;
  final String userName;
  final int streakCount;
  final bool streakActive;
  final ValueChanged<String> onSelect;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) => Container(
    width: 252,
    color: const Color(0xff120827),
    padding: const EdgeInsets.fromLTRB(18, 28, 18, 20),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 42),
            child: _BrandMark(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
            child: _SidebarProfile(
              userName: userName,
              streakCount: streakCount,
              streakActive: streakActive,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 12, bottom: 10),
            child: Text(
              'GENERAL',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                color: _muted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _item(context, 'Dashboard', Icons.grid_view_rounded),
          _item(context, 'Languages', Icons.translate_rounded),
          _item(context, 'Vocabulary', Icons.psychology_outlined),
          _item(context, 'Achievements', Icons.emoji_events_outlined),
          _item(context, 'Progress', Icons.track_changes_outlined),
          _item(context, 'Calendar', Icons.calendar_month_outlined),
          _item(context, 'Settings', Icons.settings_outlined),
          ListTile(
            onTap: onSignOut,
            leading: const Icon(
              Icons.logout,
              size: 20,
              color: Color(0xfff87171),
            ),
            title: const Text(
              'Logout',
              style: TextStyle(color: Color(0xfff87171)),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff32135c), Color(0xff6d28a9)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xff743bc0)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✣  Go Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Unlock unlimited AI tutoring.',
                  style: TextStyle(color: Color(0xffdec4f5), fontSize: 10),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xffc084fc),
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: Center(
                      child: Text(
                        'Upgrade Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _item(BuildContext context, String label, IconData icon) {
    final active = label == activeMenu;
    return ListTile(
      onTap: () => onSelect(label),
      selected: active,
      selectedTileColor: const Color(0xff35145b),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Icon(icon, size: 20, color: active ? _indigoBright : _muted),
      title: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : _muted,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _SidebarProfile extends StatelessWidget {
  const _SidebarProfile({
    required this.userName,
    required this.streakCount,
    required this.streakActive,
  });
  final String userName;
  final int streakCount;
  final bool streakActive;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xff291149),
              border: Border.all(color: _indigo, width: 1.5),
            ),
            child: const Icon(Icons.person_outline, color: _indigoBright),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Level 1 • 0 XP',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: const LinearProgressIndicator(
          value: .35,
          minHeight: 7,
          backgroundColor: Color(0xff2b1647),
          color: _indigo,
        ),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '🔥 $streakCount Day Streak',
            style: TextStyle(
              color: streakActive ? Color(0xfff59e0b) : _muted,
              fontSize: 11,
            ),
          ),
          Text('◉ 0', style: TextStyle(color: Color(0xfffbbf24), fontSize: 11)),
        ],
      ),
    ],
  );
}

class _CenterContent extends StatelessWidget {
  const _CenterContent({
    required this.activeMenu,
    required this.streakCount,
    required this.streakActive,
    required this.progress,
    required this.onProgressTap,
    required this.onSelectLanguage,
    required this.onOpenLanguages,
    required this.onOpenDashboard,
    required this.selectedLanguage,
    required this.selectedVocabLanguage,
    required this.onSelectVocabLanguage,
  });
  final String activeMenu;
  final int streakCount;
  final bool streakActive;
  final List<int> progress;
  final ValueChanged<int> onProgressTap;
  final ValueChanged<Language?> onSelectLanguage;
  final VoidCallback onOpenLanguages;
  final VoidCallback onOpenDashboard;
  final Language? selectedLanguage;
  final Language? selectedVocabLanguage;
  final ValueChanged<Language?> onSelectVocabLanguage;

  @override
  Widget build(BuildContext context) {
    if (activeMenu == 'Languages') {
      if (selectedLanguage != null) {
        return LessonPage(
          language: selectedLanguage!,
          onBack: () => onSelectLanguage(null),
        );
      }
      return _LanguagesPage(
        onOpenDashboard: onOpenDashboard,
        onSelectLanguage: onSelectLanguage,
      );
    }
    if (activeMenu == 'Vocabulary') {
      return _LettersPage(
        selectedLanguage: selectedVocabLanguage,
        onSelectLanguage: onSelectVocabLanguage,
      );
    }
    if (activeMenu == 'Progress') {
      return _ProgressPage(progress: progress, streakCount: streakCount);
    }
    if (activeMenu == 'Achievements') {
      return _AchievementsPage(progress: progress, streakCount: streakCount);
    }
    if (activeMenu == 'Settings') {
      return _SettingsPage(
        onBack: onOpenDashboard,
      );
    }
    return _ReferenceDashboard(
      streakCount: streakCount,
      streakActive: streakActive,
      progress: progress,
      onProgressTap: onProgressTap,
      onSelectLanguage: onSelectLanguage,
      onOpenLanguages: onOpenLanguages,
    );
  }
}

class _ReferenceDashboard extends StatelessWidget {
  const _ReferenceDashboard({
    required this.streakCount,
    required this.streakActive,
    required this.progress,
    required this.onProgressTap,
    required this.onSelectLanguage,
    required this.onOpenLanguages,
  });

  final int streakCount;
  final bool streakActive;
  final List<int> progress;
  final ValueChanged<int> onProgressTap;
  final ValueChanged<Language> onSelectLanguage;
  final VoidCallback onOpenLanguages;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return FutureBuilder<List<Language>>(
      future: state.learningRepository.getLanguages(),
      builder: (context, snapshot) {
        final languages = snapshot.data ?? DemoLearningRepository.languages;
        return LayoutBuilder(
          builder: (context, constraints) => ListView(
            padding: const EdgeInsets.fromLTRB(38, 28, 38, 36),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      color: _indigoBright,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _DashboardStreak(count: streakCount, active: streakActive),
                ],
              ),
              const SizedBox(height: 20),
              _WelcomeHero(
                userName: state.currentUser?.name ?? 'Learner',
                onStart: onOpenLanguages,
              ),
              const SizedBox(height: 28),
              const SizedBox(height: 28),
              const Text(
                'My Languages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: languages.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) => _LanguageTile(
                    language: languages[index],
                    onTap: () => onSelectLanguage(languages[index]),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              _StatCard(
                icon: Icons.track_changes,
                label: 'Completed Lessons',
                value:
                    '${progress.where((value) => value >= 100).length} Lessons',
                color: const Color(0xff60a5fa),
                width: constraints.maxWidth,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardStreak extends StatelessWidget {
  const _DashboardStreak({required this.count, required this.active});
  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.local_fire_department,
        color: active ? const Color(0xffffa62b) : _muted,
        size: 18,
      ),
      const SizedBox(width: 5),
      Text(
        '$count days',
        style: TextStyle(
          color: active ? const Color(0xffffc05c) : _muted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _LanguagesPage extends StatelessWidget {
  const _LanguagesPage({
    required this.onOpenDashboard,
    required this.onSelectLanguage,
  });
  final VoidCallback onOpenDashboard;
  final ValueChanged<Language> onSelectLanguage;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return FutureBuilder<List<Language>>(
      future: state.learningRepository.getLanguages(),
      builder: (context, snapshot) {
        final languages = snapshot.data ?? DemoLearningRepository.languages;
        return LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1050
                ? 3
                : constraints.maxWidth >= 650
                ? 2
                : 1;
            final gap = 20.0;
            final cardWidth =
                (constraints.maxWidth - (columns - 1) * gap) / columns;
            return ListView(
              padding: const EdgeInsets.fromLTRB(38, 28, 38, 36),
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onOpenDashboard,
                      child: const Text(
                        'Dashboard',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.chevron_right, color: _muted, size: 16),
                    ),
                    const Text(
                      'Languages',
                      style: TextStyle(
                        color: _indigoBright,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'Languages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose a language and continue your learning journey.',
                  style: TextStyle(color: _muted, fontSize: 14),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: languages
                      .map(
                        (language) => _LanguageProgressCard(
                          language: language,
                          width: cardWidth,
                          onStart: () => onSelectLanguage(language),
                        ),
                      )
                      .toList(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _LanguageProgressCard extends StatelessWidget {
  const _LanguageProgressCard({
    required this.language,
    required this.width,
    required this.onStart,
  });

  final Language language;
  final double width;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
    decoration: BoxDecoration(
      color: const Color(0xff19052a),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              language.id.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  language.nativeName,
                  style: const TextStyle(color: _indigoBright, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _LanguageMetric(
                icon: Icons.track_changes,
                label: 'Level',
                value: 'Not started',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LanguageMetric(
                icon: Icons.local_fire_department_outlined,
                label: 'XP',
                value: '0',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Start learning',
              style: TextStyle(color: _muted, fontSize: 12),
            ),
            Text(
              '0%',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const LinearProgressIndicator(
            value: 0,
            minHeight: 9,
            backgroundColor: Color(0xff351b48),
            color: _indigo,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 34,
          child: ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: _indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
              elevation: 0,
              shadowColor: const Color(0x664c1d95),
            ),
            child: const Text('Start Learning'),
          ),
        ),
      ],
    ),
  );
}

class _LanguageMetric extends StatelessWidget {
  const _LanguageMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: _panelSoft,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xff48215f)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _indigoBright, size: 14),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.userName, required this.onStart});
  final String userName;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      return Container(
        height: isMobile ? 252 : 190,
        padding: EdgeInsets.fromLTRB(
          isMobile ? 20 : 28,
          22,
          isMobile ? 20 : 28,
          18,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff241044), Color(0xff6932a4)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xff5b278d)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $userName!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 23 : 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Expanded(
                  child: Text(
                    'Start your learning journey today! Complete your first lesson to begin tracking your progress.',
                    style: TextStyle(
                      color: Color(0xffe9d5ff),
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _indigo,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: const [
                        BoxShadow(color: Color(0x664c1d95), blurRadius: 16),
                      ],
                    ),
                    child: const Text(
                      '▶  Start',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.width,
  }) : muted = false;
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double width;
  final bool muted;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: muted ? _muted : color),
          ),
          const SizedBox(width: 13),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: muted ? _muted : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.language, required this.onTap});
  final Language language;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Text(language.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                language.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${language.lessons} lessons',
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.language,
    required this.onTap,
    required this.width,
  });
  final Language language;
  final VoidCallback onTap;
  final double width;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      width: width,
      height: 90,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xff19052a),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            language.id.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            language.name,
            style: const TextStyle(color: _muted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome({
    required this.streakCount,
    required this.streakActive,
    required this.progress,
    required this.onProgressTap,
    required this.onSelectLanguage,
  });
  final int streakCount;
  final bool streakActive;
  final List<int> progress;
  final ValueChanged<int> onProgressTap;
  final ValueChanged<Language> onSelectLanguage;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final progressItems = [
      (
        'Daily Speaking Practice',
        'Build confidence through real conversations',
        Icons.mic_none_rounded,
      ),
      (
        'Real World Vocabulary',
        'Learn words you actually use daily',
        Icons.language_rounded,
      ),
      (
        'Daily Conversations',
        'Practice phrases and expressions',
        Icons.forum_outlined,
      ),
      (
        'Listening Essentials',
        'Train your ears for natural speech',
        Icons.headphones_outlined,
      ),
    ];
    return FutureBuilder<List<Language>>(
      future: state.learningRepository.getLanguages(),
      builder: (context, snapshot) {
        final languages = snapshot.data ?? DemoLearningRepository.languages;
        return ListView(
          padding: const EdgeInsets.fromLTRB(38, 28, 38, 100),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${state.currentUser?.name ?? 'Learner'}!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Learn faster with your AI-powered language platform',
                      style: const TextStyle(color: _muted),
                    ),
                  ],
                ),
                _StreakLabel(count: streakCount, active: streakActive),
              ],
            ),
            const SizedBox(height: 22),
            _StreakBanner(count: streakCount, active: streakActive),
            const SizedBox(height: 28),
            Text(
              'My progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            ...progressItems.asMap().entries.map(
              (entry) => _ProgressCard(
                item: entry.value,
                value: progress[entry.key],
                onTap: () => onProgressTap(entry.key),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Explore lessons',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Showing the most popular lessons.'),
                    ),
                  ),
                  child: const Text(
                    'Popular lessons',
                    style: TextStyle(color: _indigoBright),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 155,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: languages.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => _LanguageCard(
                  language: languages[index],
                  onTap: () => onSelectLanguage(languages[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StreakLabel extends StatelessWidget {
  const _StreakLabel({required this.count, required this.active});
  final int count;
  final bool active;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        Icons.local_fire_department,
        color: active ? const Color(0xffec9d25) : Colors.grey,
        size: 18,
      ),
      const SizedBox(width: 5),
      Text('$count days', style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.count, required this.active});
  final int count;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: _panel,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              active
                  ? 'Daily streak active. Keep it up!'
                  : 'Complete a lesson to relight your streak.',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text('$count days', style: const TextStyle(color: _muted)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(7, (index) {
            final dayActive = active && index >= 7 - count.clamp(0, 7);
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 32,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: dayActive ? _indigo : _panelSoft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  dayActive
                      ? Icons.local_fire_department
                      : Icons.circle_outlined,
                  size: 17,
                  color: dayActive ? Colors.white : _muted,
                ),
              ),
            );
          }),
        ),
      ],
    ),
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.item,
    required this.value,
    required this.onTap,
  });
  final (String, String, IconData) item;
  final int value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    color: _panel,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: _border),
    ),
    margin: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _panelSoft,
              child: Icon(item.$3, color: _indigo, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$2,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                  const SizedBox(height: 9),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: value / 100),
                    duration: const Duration(milliseconds: 450),
                    builder: (_, animated, _) => LinearProgressIndicator(
                      value: animated,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(8),
                      color: _indigo,
                      backgroundColor: _panelSoft,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$value%',
              style: const TextStyle(
                color: _indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.language, required this.onTap});
  final Language language;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 175,
    child: Card(
      color: _panel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(language.icon, style: const TextStyle(fontSize: 28)),
              Text(
                language.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${language.lessons} lessons',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ExercisePanel extends StatefulWidget {
  const _ExercisePanel({
    required this.isRecording,
    required this.waveAnimation,
    required this.onRecording,
    required this.onSave,
  });
  final bool isRecording;
  final Animation<double> waveAnimation;
  final VoidCallback onRecording;
  final VoidCallback onSave;
  @override
  State<_ExercisePanel> createState() => _ExercisePanelState();
}

class _ExercisePanelState extends State<_ExercisePanel> {
  late final TapGestureRecognizer weatheredRecognizer;
  late final TapGestureRecognizer surfacesRecognizer;
  @override
  void initState() {
    super.initState();
    weatheredRecognizer = TapGestureRecognizer()
      ..onTap = () => _showDefinition(
        'weathered',
        'marked by time, use, or exposure to the elements',
      );
    surfacesRecognizer = TapGestureRecognizer()
      ..onTap = () =>
          _showDefinition('surfaces', 'the outside or top layer of something');
  }

  @override
  void dispose() {
    weatheredRecognizer.dispose();
    surfacesRecognizer.dispose();
    super.dispose();
  }

  void _showDefinition(String word, String definition) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(word),
        content: Text(definition),
        actions: [
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.volume_up_outlined),
            label: const Text('Dengarkan AI'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(
      color: Color(0xff536174),
      fontSize: 15,
      height: 1.75,
    );
    final highlightedStyle = const TextStyle(
      color: Color(0xffd94c62),
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );
    return Material(
      color: _panel,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercise / Speaking',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _panelSoft,
                    border: Border.all(color: _border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SingleChildScrollView(
                    child: RichText(
                      text: TextSpan(
                        style: textStyle,
                        children: [
                          const TextSpan(text: 'To the hurried eye, the '),
                          TextSpan(
                            text: 'surfaces',
                            style: highlightedStyle,
                            recognizer: surfacesRecognizer,
                          ),
                          const TextSpan(text: ' may appear imperfect '),
                          TextSpan(
                            text: 'weathered',
                            style: highlightedStyle,
                            recognizer: weatheredRecognizer,
                          ),
                          const TextSpan(
                            text:
                                ' stone, softened edges, and walls marked by time. Yet to the mindful observer, every mark tells a story.\n\nRead the paragraph aloud and practice your pronunciation. Your AI coach will help you notice rhythm and clarity.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _indigo,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onRecording,
                      color: Colors.white,
                      icon: Icon(
                        widget.isRecording
                            ? Icons.stop_rounded
                            : Icons.mic_rounded,
                      ),
                    ),
                    Expanded(
                      child: _Waveform(
                        animation: widget.waveAnimation,
                        active: widget.isRecording,
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onSave,
                      child: const Text(
                        'Save recording',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform({required this.animation, required this.active});
  final Animation<double> animation;
  final bool active;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, _) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(18, (index) {
        final factor = active
            ? .25 + (((index + animation.value * 10) % 5) / 5)
            : .25;
        return Container(
          width: 3,
          height: 28 * factor,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: active ? .95 : .45),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    ),
  );
}

class _LettersPage extends StatefulWidget {
  const _LettersPage({
    required this.selectedLanguage,
    required this.onSelectLanguage,
  });
  final Language? selectedLanguage;
  final ValueChanged<Language?> onSelectLanguage;

  @override
  State<_LettersPage> createState() => _LettersPageState();
}

class _LettersPageState extends State<_LettersPage> {
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _initTts();
  }

  Future<void> _initTts() async {
    // setSharedInstance is not available on web
    try {
      await flutterTts.setSharedInstance(true);
    } catch (e) {
      // Ignore on web
    }
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    
    // Get available languages
    try {
      final languages = await flutterTts.getLanguages;
      print('Available TTS languages: $languages');
    } catch (e) {
      print('Could not get languages: $e');
    }
  }

  Future<void> _speak(String word, String pronunciation, String languageId) async {
    final Map<String, List<String>> languageCodes = {
      'ja': ['ja-JP', 'ja-JP', 'jpn-JPN'],
      'zh': ['zh-CN', 'zh-Hans-CN', 'cmn-Hans-CN', 'zh-Hans'],
      'ko': ['ko-KR', 'kor-KOR'],
      'en': ['en-US', 'en-GB'],
      'es': ['es-ES', 'es-MX'],
    };
    
    final codes = languageCodes[languageId] ?? ['en-US'];
    bool success = false;
    
    // Try to speak the native word in the target language
    for (final code in codes) {
      try {
        await flutterTts.setLanguage(code);
        await flutterTts.speak(word);
        success = true;
        break;
      } catch (e) {
        print('Failed to set language $code: $e');
        continue;
      }
    }
    
    // If target language TTS fails, fallback to phonetic pronunciation in English
    if (!success) {
      try {
        await flutterTts.setLanguage('en-US');
        await flutterTts.speak(pronunciation);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playing phonetic pronunciation'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        print('Failed to speak pronunciation: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('TTS not available'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return FutureBuilder<List<Language>>(
      future: state.learningRepository.getLanguages(),
      builder: (context, snapshot) {
        final languages = snapshot.data ?? DemoLearningRepository.languages;
        return ListView(
          padding: const EdgeInsets.all(28),
          children: [
            const Text(
              'Vocabulary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a language to view vocabulary words.',
              style: TextStyle(color: _muted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: languages.map((lang) {
                final isSelected = widget.selectedLanguage?.id == lang.id;
                return GestureDetector(
                  onTap: () => widget.onSelectLanguage(lang),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? _indigo : _panel,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _indigo : _border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lang.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lang.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : _muted,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            if (widget.selectedLanguage != null) ...[
              Row(
                children: [
                  Text(
                    'Recent Words',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${widget.selectedLanguage!.name})',
                    style: const TextStyle(
                      color: _indigoBright,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...VocabularyData.allVocabulary[widget.selectedLanguage!.id]!.map(
                (vocab) => Card(
                  color: _panel,
                  surfaceTintColor: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _panelSoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border),
                      ),
                      child: Center(
                        child: Text(
                          vocab['word']!.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: _indigoBright,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      vocab['word']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vocab['meaning']!,
                          style: const TextStyle(color: _muted, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vocab['pronunciation']!,
                          style: const TextStyle(
                            color: _indigoBright,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.volume_up, color: _indigoBright, size: 20),
                      onPressed: () {
                        _speak(vocab['word']!, vocab['pronunciation']!, widget.selectedLanguage!.id);
                      },
                    ),
                  ),
                ),
              ),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.translate, color: _muted, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Select a language above to view vocabulary',
                        style: TextStyle(color: _muted, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SettingsPage extends StatefulWidget {
  const _SettingsPage({required this.onBack});

  final VoidCallback onBack;

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  // Account fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Learning & Notifications
  bool _dailyReminder = false;
  String _learningTarget = '15 menit';

  // Preferences
  bool _darkMode = true;
  final bool _soundEffects = true;
  String _selectedLanguage = 'Indonesia';

  // Modal state
  String? _activeModal;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final state = context.read<AppState>();
    final user = await state.authRepository.restoreSession();
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width > 800;
    
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Stack(
        children: [
          // Main content
          LayoutBuilder(
            builder: (context, constraints) {
              if (isDesktop) {
                // Desktop: Sidebar layout
                return Row(
                  children: [
                    // Sidebar (main navigation)
                    Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: _panel,
                        border: Border(
                          right: BorderSide(color: _border, width: 1),
                        ),
                      ),
                      child: _buildMainSidebar(),
                    ),
                    // Settings content
                    Expanded(
                      child: _buildSettingsContent(),
                    ),
                  ],
                );
              } else {
                // Mobile: Full column with hamburger
                return Column(
                  children: [
                    _buildMobileHeader(),
                    Expanded(
                      child: _buildSettingsContent(),
                    ),
                  ],
                );
              }
            },
          ),
          // Modal overlay
          if (_activeModal != null)
            _buildModalOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainSidebar() {
    return Column(
      children: [
        const SizedBox(height: 24),
        // Logo/Brand
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _indigo.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.language,
            color: _indigoBright,
            size: 28,
          ),
        ),
        const SizedBox(height: 32),
        // Navigation items
        _buildMainSidebarItem(
          icon: Icons.home,
          label: 'Home',
          onTap: widget.onBack,
        ),
        _buildMainSidebarItem(
          icon: Icons.book,
          label: 'Lessons',
          onTap: () {},
        ),
        _buildMainSidebarItem(
          icon: Icons.emoji_events,
          label: 'Progress',
          onTap: () {},
        ),
        const Spacer(),
        _buildMainSidebarItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {},
          isSelected: true,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMainSidebarItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? _indigo.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isSelected ? _indigoBright : _muted,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        border: Border(
          bottom: BorderSide(color: _border, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back, color: _indigoBright),
          ),
          const SizedBox(width: 12),
          const Text(
            'Pengaturan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: _indigoBright),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width > 800 ? 48 : 16,
        vertical: 24,
      ),
      child: Column(
        children: [
          // Profile Header Card
          _buildProfileHeader(),
          const SizedBox(height: 24),
          
          // Container 1: Akun & Keamanan
          _buildSettingsContainer(
            title: 'Akun & Keamanan',
            icon: Icons.security,
            items: [
              _buildMenuItem(
                icon: Icons.person,
                label: 'Detail Profil',
                onTap: () => setState(() => _activeModal = 'profile'),
              ),
              _buildMenuItem(
                icon: Icons.lock,
                label: 'Kata Sandi',
                onTap: () => setState(() => _activeModal = 'password'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Container 2: Preferensi & Aplikasi
          _buildSettingsContainer(
            title: 'Preferensi & Aplikasi',
            icon: Icons.tune,
            items: [
              _buildMenuItem(
                icon: Icons.notifications,
                label: 'Belajar & Notifikasi',
                onTap: () => setState(() => _activeModal = 'notifications'),
              ),
              _buildMenuItem(
                icon: Icons.language,
                label: 'Bahasa / Language',
                onTap: () => setState(() => _activeModal = 'language'),
              ),
              _buildToggleMenuItem(
                icon: Icons.dark_mode,
                label: 'Mode Gelap',
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Container 3: Bantuan
          _buildSettingsContainer(
            title: 'Bantuan',
            icon: Icons.help,
            items: [
              _buildMenuItem(
                icon: Icons.support_agent,
                label: 'Dukungan / Support',
                onTap: () {},
              ),
              _buildMenuItem(
                icon: Icons.info,
                label: 'Tentang LinguaNova',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      color: _panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Profile Photo
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_indigo, _indigoBright],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(width: 20),
            // Profile Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameController.text.isNotEmpty ? _nameController.text : 'Loading...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _indigo.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Level 12',
                          style: TextStyle(
                            color: _indigoBright,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '2,450 XP',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Edit Button
            IconButton(
              onPressed: () => setState(() => _activeModal = 'profile'),
              icon: const Icon(Icons.edit, color: _indigoBright),
              style: IconButton.styleFrom(
                backgroundColor: _panelSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContainer({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Card(
      color: _panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(icon, color: _indigoBright, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: _border),
          // Container Items
          ...items,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: _muted, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: _muted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleMenuItem({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: _muted, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: _indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Card(
      color: _panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _border, width: 1),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red.shade400, size: 22),
              const SizedBox(width: 16),
              const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _activeModal = null),
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: _buildModalContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildModalContent() {
    return Container(
      width: MediaQuery.sizeOf(context).width > 600 ? 500 : MediaQuery.sizeOf(context).width * 0.9,
      constraints: const BoxConstraints(maxHeight: 600),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1),
      ),
      child: Column(
        children: [
          // Modal Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _activeModal = null),
                  icon: const Icon(Icons.close, color: _muted),
                ),
                const SizedBox(width: 12),
                Text(
                  _getModalTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: _border),
          // Modal Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildModalBody(),
            ),
          ),
        ],
      ),
    );
  }

  String _getModalTitle() {
    switch (_activeModal) {
      case 'profile':
        return 'Detail Profil';
      case 'password':
        return 'Kata Sandi';
      case 'notifications':
        return 'Belajar & Notifikasi';
      case 'language':
        return 'Bahasa / Language';
      default:
        return '';
    }
  }

  Widget _buildModalBody() {
    switch (_activeModal) {
      case 'profile':
        return _buildProfileForm();
      case 'password':
        return _buildPasswordForm();
      case 'notifications':
        return _buildNotificationsForm();
      case 'language':
        return _buildLanguageForm();
      default:
        return const SizedBox();
    }
  }

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama',
          style: TextStyle(color: _muted, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: _pageBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _indigo, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Email',
          style: TextStyle(color: _muted, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          enabled: false,
          style: const TextStyle(color: _muted),
          decoration: InputDecoration(
            filled: true,
            fillColor: _pageBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              try {
                final state = context.read<AppState>();
                await state.authRepository.updateName(_nameController.text);
                await state.refreshUser();
                await _loadUserData();
                setState(() => _activeModal = null);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nama berhasil diubah'),
                    backgroundColor: _indigo,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal mengubah nama: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordForm() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kata Sandi Saat Ini',
          style: TextStyle(color: _muted, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: currentPasswordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: _pageBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _indigo, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Kata Sandi Baru',
          style: TextStyle(color: _muted, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: newPasswordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: _pageBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _indigo, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Konfirmasi Kata Sandi Baru',
          style: TextStyle(color: _muted, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: confirmPasswordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: _pageBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _indigo, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              final currentPassword = currentPasswordController.text;
              final newPassword = newPasswordController.text;
              final confirmPassword = confirmPasswordController.text;

              if (newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password minimal 6 karakter'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Konfirmasi password tidak cocok'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final state = context.read<AppState>();
                await state.authRepository.updatePassword(currentPassword, newPassword);
                setState(() => _activeModal = null);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kata sandi berhasil diubah'),
                    backgroundColor: _indigo,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal mengubah kata sandi: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ubah Kata Sandi'),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsForm() {
    return Column(
      children: [
        SwitchListTile(
          value: _dailyReminder,
          onChanged: (value) => setState(() => _dailyReminder = value),
          title: const Text(
            'Pengingat Harian',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          subtitle: const Text(
            'Terima pengingat belajar setiap hari',
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          activeThumbColor: _indigo,
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(color: _border),
        const SizedBox(height: 16),
        const Text(
          'Target Waktu Belajar',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _learningTarget,
          decoration: InputDecoration(
            filled: true,
            fillColor: _pageBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _indigo, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          dropdownColor: _panel,
          style: const TextStyle(color: Colors.white),
          items: const [
            DropdownMenuItem(value: '5 menit', child: Text('5 menit')),
            DropdownMenuItem(value: '15 menit', child: Text('15 menit')),
            DropdownMenuItem(value: '30 menit', child: Text('30 menit')),
          ],
          onChanged: (value) => setState(() => _learningTarget = value ?? '15 menit'),
        ),
      ],
    );
  }

  Widget _buildLanguageForm() {
    return Column(
      children: [
        const Text(
          'Pilih Bahasa',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 16),
        ...['Indonesia', 'English', '日本語', '中文', '한국어', 'Español'].map(
          (lang) => RadioListTile<String>(
            value: lang,
            groupValue: _selectedLanguage,
            onChanged: (value) => setState(() => _selectedLanguage = value!),
            title: Text(
              lang,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            activeColor: _indigo,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}


class _ProgressPage extends StatelessWidget {
  const _ProgressPage({required this.progress, required this.streakCount});
  final List<int> progress;
  final int streakCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text('This Week  ˅', style: TextStyle(color: _muted, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _panel,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'XP Earned',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
              const SizedBox(height: 5),
              const Text(
                '0 XP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: _WeeklyLineChart(values: [35, 20, 42, 30, 78, 48, 68]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.menu_book_outlined,
                  label: 'Lessons',
                  value: '${progress.where((value) => value > 0).length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.bolt,
                  label: 'Words Learned',
                  value: '0',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '$streakCount Days',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyLineChart extends StatelessWidget {
  const _WeeklyLineChart({required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: CustomPaint(
          painter: _LineChartPainter(values),
          child: const SizedBox.expand(),
        ),
      ),
      const SizedBox(height: 6),
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Mon', style: TextStyle(color: _muted, fontSize: 10)),
          Text('Tue', style: TextStyle(color: _muted, fontSize: 10)),
          Text('Wed', style: TextStyle(color: _muted, fontSize: 10)),
          Text('Thu', style: TextStyle(color: _muted, fontSize: 10)),
          Text('Fri', style: TextStyle(color: _muted, fontSize: 10)),
          Text('Sat', style: TextStyle(color: _muted, fontSize: 10)),
          Text('Sun', style: TextStyle(color: _muted, fontSize: 10)),
        ],
      ),
    ],
  );
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final points = <Offset>[];
    final step = size.width / (values.length - 1);
    for (var index = 0; index < values.length; index++) {
      points.add(Offset(step * index, size.height - values[index]));
    }
    final area = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      area.lineTo(point.dx, point.dy);
    }
    area.lineTo(points.last.dx, size.height);
    area.close();
    canvas.drawPath(area, Paint()..color = _indigo.withValues(alpha: .14));
    final line = Paint()
      ..color = _indigo
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      final midpoint = (previous.dx + current.dx) / 2;
      path.cubicTo(
        midpoint,
        previous.dy,
        midpoint,
        current.dy,
        current.dx,
        current.dy,
      );
    }
    canvas.drawPath(path, line);
    final dot = Paint()..color = _indigo;
    for (final point in points) {
      canvas.drawCircle(point, 4, dot);
      canvas.drawCircle(point, 2, Paint()..color = _panel);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _panel,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _border),
    ),
    child: Row(
      children: [
        Icon(icon, color: _indigoBright, size: 20),
        const SizedBox(width: 9),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _AchievementsPage extends StatelessWidget {
  const _AchievementsPage({required this.progress, required this.streakCount});
  final List<int> progress;
  final int streakCount;

  @override
  Widget build(BuildContext context) {
    final achievements = [
      ('🔥', '7 Days Streak', streakCount >= 7),
      ('💜', '100 Words Learner', progress.any((value) => value >= 100)),
      ('⭐', 'First Lesson Complete', progress.any((value) => value > 0)),
      ('🏆', 'Week Goal Achiever', streakCount >= 7),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Achievements',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'View All',
              style: TextStyle(color: _indigoBright, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 190,
            mainAxisExtent: 170,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final item = achievements[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: item.$3 ? _indigo : _border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: item.$3
                            ? const [Color(0xffa855f7), Color(0xff4f46e5)]
                            : const [Color(0xff33283d), Color(0xff21182b)],
                      ),
                      border: Border.all(
                        color: item.$3 ? _indigoBright : _border,
                        width: 2,
                      ),
                      boxShadow: item.$3
                          ? const [
                              BoxShadow(
                                color: Color(0x668a2be2),
                                blurRadius: 14,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      item.$1,
                      style: TextStyle(
                        fontSize: 34,
                        color: item.$3 ? Colors.white : _muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.$3 ? 'Unlocked' : 'Locked',
                    style: TextStyle(
                      color: item.$3 ? _indigoBright : _muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class LessonPage extends StatelessWidget {
  const LessonPage({required this.language, required this.onBack, super.key});
  final Language language;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<AppState>().learningRepository;
    return FutureBuilder<List<Lesson>>(
      future: repository.getLessons(language.id),
      builder: (context, snapshot) {
        final lessons = snapshot.data ?? const <Lesson>[];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back, color: _indigoBright),
                    style: IconButton.styleFrom(
                      backgroundColor: _panel,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '${language.icon}  ${language.name}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: const Text(
                'Choose a lesson and keep moving forward.',
                style: TextStyle(color: _muted),
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                children: [
                  ...lessons.map(
                    (lesson) => Card(
                      color: _panel,
                      surfaceTintColor: Colors.transparent,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          lesson.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          lesson.summary,
                          style: const TextStyle(color: _muted),
                        ),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                await context
                                    .read<AppState>()
                                    .recordLearningActivity();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Materi selesai. Streak diperbarui.',
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _indigoBright,
                                side: const BorderSide(color: _indigo),
                              ),
                              child: const Text('Selesai'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizPage(language: language),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _indigo,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Practice'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({required this.language, super.key});
  final Language language;
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int questionIndex = 0;
  int correct = 0;
  int? answer;
  Future<void> next(List<QuizQuestion> questions) async {
    if (answer == null) return;
    if (answer == questions[questionIndex].answerIndex) correct++;
    if (questionIndex < questions.length - 1) {
      setState(() {
        questionIndex++;
        answer = null;
      });
      return;
    }
    final score = (correct / questions.length * 100).round();
    if (score >= 70) {
      await context.read<AppState>().learningRepository.saveAttempt(
        context.read<AppState>().currentUser!.id,
        QuizAttempt(
          language: widget.language.name,
          score: score,
          date: DateTime.now(),
        ),
      );
    }
    await context.read<AppState>().recordLearningActivity();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Achievement unlocked!'),
        content: Text('Your score is $score/100.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<AppState>().learningRepository;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.language.name} practice'),
        backgroundColor: _pageBackground,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<QuizQuestion>>(
        future: repository.getQuiz(widget.language.id),
        builder: (context, snapshot) {
          final questions = snapshot.data ?? const <QuizQuestion>[];
          if (questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final question = questions[questionIndex];
          return ListView(
            padding: const EdgeInsets.all(28),
            children: [
              LinearProgressIndicator(
                value: (questionIndex + 1) / questions.length,
              ),
              const SizedBox(height: 28),
              Text(
                question.question,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              ...question.options.asMap().entries.map(
                (entry) => RadioListTile<int>(
                  value: entry.key,
                  groupValue: answer,
                  onChanged: (value) => setState(() => answer = value),
                  title: Text(entry.value),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: answer == null ? null : () => next(questions),
                child: Text(
                  questionIndex == questions.length - 1 ? 'Finish' : 'Continue',
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    return FutureBuilder<List<QuizAttempt>>(
      future: state.learningRepository.getAttempts(state.currentUser!.id),
      builder: (context, snapshot) {
        final attempts = snapshot.data ?? const <QuizAttempt>[];
        return ListView(
          padding: const EdgeInsets.all(28),
          children: [
            Text(
              'Your profile',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(state.currentUser!.email),
            const SizedBox(height: 28),
            Text(
              'Score history',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            ...attempts.map(
              (attempt) => ListTile(
                leading: const Icon(Icons.emoji_events_outlined),
                title: Text(attempt.language),
                trailing: Text('${attempt.score}/100'),
              ),
            ),
            if (attempts.isEmpty) const Text('No quiz attempts yet.'),
          ],
        );
      },
    );
  }
}

class VocabularyData {
  static const Map<String, List<Map<String, String>>> allVocabulary = {
    'ja': [
      {'word': 'こんにちは', 'meaning': 'Hello', 'pronunciation': 'kon-ni-chi-wa'},
      {'word': 'ありがとう', 'meaning': 'Thank you', 'pronunciation': 'a-ri-ga-tou'},
      {'word': 'さようなら', 'meaning': 'Goodbye', 'pronunciation': 'sa-you-na-ra'},
      {'word': 'はい', 'meaning': 'Yes', 'pronunciation': 'hai'},
      {'word': 'いいえ', 'meaning': 'No', 'pronunciation': 'i-i-e'},
      {'word': 'おはよう', 'meaning': 'Good morning', 'pronunciation': 'o-ha-you'},
      {'word': 'こんばんは', 'meaning': 'Good evening', 'pronunciation': 'kon-ban-wa'},
      {'word': 'すみません', 'meaning': 'Excuse me', 'pronunciation': 'su-mi-ma-sen'},
      {'word': 'お願いします', 'meaning': 'Please', 'pronunciation': 'o-ne-gai-shi-ma-su'},
      {'word': 'どういたしまして', 'meaning': 'You\'re welcome', 'pronunciation': 'dou-i-ta-shi-ma-shi-te'},
      {'word': '名前', 'meaning': 'Name', 'pronunciation': 'na-ma-e'},
      {'word': '年齢', 'meaning': 'Age', 'pronunciation': 'nen-rei'},
      {'word': '国', 'meaning': 'Country', 'pronunciation': 'ku-ni'},
      {'word': '言語', 'meaning': 'Language', 'pronunciation': 'gen-go'},
      {'word': '友達', 'meaning': 'Friend', 'pronunciation': 'to-mo-da-chi'},
      {'word': '家族', 'meaning': 'Family', 'pronunciation': 'ka-zo-ku'},
      {'word': '先生', 'meaning': 'Teacher', 'pronunciation': 'sen-sei'},
      {'word': '学生', 'meaning': 'Student', 'pronunciation': 'ga-ku-sei'},
      {'word': '仕事', 'meaning': 'Work', 'pronunciation': 'shi-go-to'},
      {'word': '学校', 'meaning': 'School', 'pronunciation': 'ga-kkou'},
      {'word': '食べ物', 'meaning': 'Food', 'pronunciation': 'ta-be-mo-no'},
      {'word': '水', 'meaning': 'Water', 'pronunciation': 'mi-zu'},
      {'word': '茶', 'meaning': 'Tea', 'pronunciation': 'o-cha'},
      {'word': 'コーヒー', 'meaning': 'Coffee', 'pronunciation': 'kou-hii'},
      {'word': 'パン', 'meaning': 'Bread', 'pronunciation': 'pan'},
      {'word': '肉', 'meaning': 'Meat', 'pronunciation': 'ni-ku'},
      {'word': '魚', 'meaning': 'Fish', 'pronunciation': 'sa-ka-na'},
      {'word': '野菜', 'meaning': 'Vegetable', 'pronunciation': 'ya-sai'},
      {'word': '果物', 'meaning': 'Fruit', 'pronunciation': 'ku-da-mo-no'},
      {'word': '家', 'meaning': 'House', 'pronunciation': 'i-e'},
      {'word': '部屋', 'meaning': 'Room', 'pronunciation': 'he-ya'},
      {'word': '窓', 'meaning': 'Window', 'pronunciation': 'ma-do'},
      {'word': 'ドア', 'meaning': 'Door', 'pronunciation': 'do-a'},
      {'word': '机', 'meaning': 'Desk', 'pronunciation': 'tsu-ku-e'},
      {'word': '椅子', 'meaning': 'Chair', 'pronunciation': 'i-su'},
      {'word': '本', 'meaning': 'Book', 'pronunciation': 'hon'},
      {'word': 'ペン', 'meaning': 'Pen', 'pronunciation': 'pen'},
      {'word': '紙', 'meaning': 'Paper', 'pronunciation': 'ka-mi'},
      {'word': '電話', 'meaning': 'Phone', 'pronunciation': 'den-wa'},
      {'word': 'コンピューター', 'meaning': 'Computer', 'pronunciation': 'kon-pyu-taa'},
      {'word': '車', 'meaning': 'Car', 'pronunciation': 'ku-ru-ma'},
      {'word': 'バス', 'meaning': 'Bus', 'pronunciation': 'ba-su'},
      {'word': '電車', 'meaning': 'Train', 'pronunciation': 'den-sha'},
      {'word': '飛行機', 'meaning': 'Airplane', 'pronunciation': 'hi-kou-ki'},
      {'word': '船', 'meaning': 'Ship', 'pronunciation': 'fu-ne'},
      {'word': '自転車', 'meaning': 'Bicycle', 'pronunciation': 'ji-ten-sha'},
      {'word': '時間', 'meaning': 'Time', 'pronunciation': 'ji-kan'},
      {'word': '日', 'meaning': 'Day', 'pronunciation': 'hi'},
      {'word': '週', 'meaning': 'Week', 'pronunciation': 'shuu'},
      {'word': '月', 'meaning': 'Month', 'pronunciation': 'tsu-ki'},
      {'word': '年', 'meaning': 'Year', 'pronunciation': 'to-shi'},
      {'word': '春', 'meaning': 'Spring', 'pronunciation': 'ha-ru'},
      {'word': '夏', 'meaning': 'Summer', 'pronunciation': 'na-tsu'},
      {'word': '秋', 'meaning': 'Autumn', 'pronunciation': 'a-ki'},
      {'word': '冬', 'meaning': 'Winter', 'pronunciation': 'fu-yu'},
      {'word': '天気', 'meaning': 'Weather', 'pronunciation': 'ten-ki'},
      {'word': '雨', 'meaning': 'Rain', 'pronunciation': 'a-me'},
      {'word': '雪', 'meaning': 'Snow', 'pronunciation': 'yu-ki'},
      {'word': '風', 'meaning': 'Wind', 'pronunciation': 'ka-ze'},
      {'word': '太陽', 'meaning': 'Sun', 'pronunciation': 'tai-you'},
      {'word': '月', 'meaning': 'Moon', 'pronunciation': 'tsu-ki'},
      {'word': '星', 'meaning': 'Star', 'pronunciation': 'ho-shi'},
      {'word': '空', 'meaning': 'Sky', 'pronunciation': 'so-ra'},
      {'word': '海', 'meaning': 'Sea', 'pronunciation': 'u-mi'},
      {'word': '山', 'meaning': 'Mountain', 'pronunciation': 'ya-ma'},
      {'word': '川', 'meaning': 'River', 'pronunciation': 'ka-wa'},
      {'word': '森', 'meaning': 'Forest', 'pronunciation': 'mo-ri'},
      {'word': '花', 'meaning': 'Flower', 'pronunciation': 'ha-na'},
      {'word': '木', 'meaning': 'Tree', 'pronunciation': 'ki'},
      {'word': '草', 'meaning': 'Grass', 'pronunciation': 'ku-sa'},
      {'word': '鳥', 'meaning': 'Bird', 'pronunciation': 'to-ri'},
      {'word': '犬', 'meaning': 'Dog', 'pronunciation': 'i-nu'},
      {'word': '猫', 'meaning': 'Cat', 'pronunciation': 'ne-ko'},
      {'word': '馬', 'meaning': 'Horse', 'pronunciation': 'u-ma'},
      {'word': '牛', 'meaning': 'Cow', 'pronunciation': 'u-shi'},
      {'word': '豚', 'meaning': 'Pig', 'pronunciation': 'bu-ta'},
      {'word': '羊', 'meaning': 'Sheep', 'pronunciation': 'hi-tsu-ji'},
      {'word': '鶏', 'meaning': 'Chicken', 'pronunciation': 'ni-wa-to-ri'},
      {'word': '赤', 'meaning': 'Red', 'pronunciation': 'a-ka'},
      {'word': '青', 'meaning': 'Blue', 'pronunciation': 'a-o'},
      {'word': '黄色', 'meaning': 'Yellow', 'pronunciation': 'ki-i-ro'},
      {'word': '緑', 'meaning': 'Green', 'pronunciation': 'mi-do-ri'},
      {'word': '白', 'meaning': 'White', 'pronunciation': 'shi-ro'},
      {'word': '黒', 'meaning': 'Black', 'pronunciation': 'ku-ro'},
      {'word': '大きい', 'meaning': 'Big', 'pronunciation': 'oo-ki-i'},
      {'word': '小さい', 'meaning': 'Small', 'pronunciation': 'chi-i-sa-i'},
      {'word': '新しい', 'meaning': 'New', 'pronunciation': 'a-ta-ra-shi-i'},
      {'word': '古い', 'meaning': 'Old', 'pronunciation': 'fu-ru-i'},
      {'word': '良い', 'meaning': 'Good', 'pronunciation': 'yo-i'},
      {'word': '悪い', 'meaning': 'Bad', 'pronunciation': 'wa-ru-i'},
      {'word': '高い', 'meaning': 'High/Expensive', 'pronunciation': 'ta-ka-i'},
      {'word': '安い', 'meaning': 'Low/Cheap', 'pronunciation': 'ya-su-i'},
      {'word': '速い', 'meaning': 'Fast', 'pronunciation': 'ha-ya-i'},
      {'word': '遅い', 'meaning': 'Slow', 'pronunciation': 'o-so-i'},
      {'word': '難しい', 'meaning': 'Difficult', 'pronunciation': 'mu-zu-ka-shi-i'},
      {'word': '易しい', 'meaning': 'Easy', 'pronunciation': 'ya-sa-shi-i'},
      {'word': '美しい', 'meaning': 'Beautiful', 'pronunciation': 'u-tsu-ku-shi-i'},
      {'word': '汚い', 'meaning': 'Dirty', 'pronunciation': 'ki-ta-na-i'},
      {'word': '楽しい', 'meaning': 'Fun', 'pronunciation': 'ta-no-shi-i'},
      {'word': '悲しい', 'meaning': 'Sad', 'pronunciation': 'ka-na-shi-i'},
      {'word': '嬉しい', 'meaning': 'Happy', 'pronunciation': 'u-re-shi-i'},
      {'word': '怒る', 'meaning': 'Angry', 'pronunciation': 'o-ko-ru'},
      {'word': '怖い', 'meaning': 'Scary', 'pronunciation': 'ko-wa-i'},
      {'word': '疲れる', 'meaning': 'Tired', 'pronunciation': 'tsu-ka-re-ru'},
      {'word': '病気', 'meaning': 'Sick', 'pronunciation': 'byou-ki'},
      {'word': '健康', 'meaning': 'Healthy', 'pronunciation': 'ken-kou'},
      {'word': '強い', 'meaning': 'Strong', 'pronunciation': 'tsu-yo-i'},
      {'word': '弱い', 'meaning': 'Weak', 'pronunciation': 'yo-wa-i'},
      {'word': '若い', 'meaning': 'Young', 'pronunciation': 'wa-ka-i'},
      {'word': '年寄り', 'meaning': 'Old person', 'pronunciation': 'to-shi-yo-ri'},
    ],
    'zh': [
      {'word': '你好', 'meaning': 'Hello', 'pronunciation': 'nee-how'},
      {'word': '谢谢', 'meaning': 'Thank you', 'pronunciation': 'shye-shye'},
      {'word': '再见', 'meaning': 'Goodbye', 'pronunciation': 'dzai-jyen'},
      {'word': '是', 'meaning': 'Yes', 'pronunciation': 'shuh'},
      {'word': '不', 'meaning': 'No', 'pronunciation': 'boo'},
      {'word': '早上好', 'meaning': 'Good morning', 'pronunciation': 'dzao-shang-how'},
      {'word': '晚上好', 'meaning': 'Good evening', 'pronunciation': 'wan-shang-how'},
      {'word': '对不起', 'meaning': 'Sorry', 'pronunciation': 'due-boo-chee'},
      {'word': '请', 'meaning': 'Please', 'pronunciation': 'cheeng'},
      {'word': '不客气', 'meaning': 'You\'re welcome', 'pronunciation': 'boo-kuh-chee'},
      {'word': '名字', 'meaning': 'Name', 'pronunciation': 'ming-dzuh'},
      {'word': '年龄', 'meaning': 'Age', 'pronunciation': 'nyeen-ling'},
      {'word': '国家', 'meaning': 'Country', 'pronunciation': 'gwuh-jya'},
      {'word': '语言', 'meaning': 'Language', 'pronunciation': 'yoo-yen'},
      {'word': '朋友', 'meaning': 'Friend', 'pronunciation': 'peng-yoh'},
      {'word': '家庭', 'meaning': 'Family', 'pronunciation': 'jya-ting'},
      {'word': '老师', 'meaning': 'Teacher', 'pronunciation': 'lao-shuh'},
      {'word': '学生', 'meaning': 'Student', 'pronunciation': 'shwe-sheng'},
      {'word': '工作', 'meaning': 'Work', 'pronunciation': 'gong-dzwuh'},
      {'word': '学校', 'meaning': 'School', 'pronunciation': 'shwe-shyaw'},
      {'word': '食物', 'meaning': 'Food', 'pronunciation': 'shih-wuh'},
      {'word': '水', 'meaning': 'Water', 'pronunciation': 'shway'},
      {'word': '茶', 'meaning': 'Tea', 'pronunciation': 'cha'},
      {'word': '咖啡', 'meaning': 'Coffee', 'pronunciation': 'ka-fay'},
      {'word': '面包', 'meaning': 'Bread', 'pronunciation': 'myeen-bao'},
      {'word': '肉', 'meaning': 'Meat', 'pronunciation': 'row'},
      {'word': '鱼', 'meaning': 'Fish', 'pronunciation': 'yoo'},
      {'word': '蔬菜', 'meaning': 'Vegetable', 'pronunciation': 'shoo-tsai'},
      {'word': '水果', 'meaning': 'Fruit', 'pronunciation': 'shway-gwuh'},
      {'word': '房子', 'meaning': 'House', 'pronunciation': 'fang-dzuh'},
      {'word': '房间', 'meaning': 'Room', 'pronunciation': 'fang-jyen'},
      {'word': '窗户', 'meaning': 'Window', 'pronunciation': 'chwang-hoo'},
      {'word': '门', 'meaning': 'Door', 'pronunciation': 'men'},
      {'word': '桌子', 'meaning': 'Desk', 'pronunciation': 'jwuh-dzuh'},
      {'word': '椅子', 'meaning': 'Chair', 'pronunciation': 'ee-dzuh'},
      {'word': '书', 'meaning': 'Book', 'pronunciation': 'shoo'},
      {'word': '笔', 'meaning': 'Pen', 'pronunciation': 'bee'},
      {'word': '纸', 'meaning': 'Paper', 'pronunciation': 'jir'},
      {'word': '电话', 'meaning': 'Phone', 'pronunciation': 'dyen-hwa'},
      {'word': '电脑', 'meaning': 'Computer', 'pronunciation': 'dyen-nau'},
      {'word': '汽车', 'meaning': 'Car', 'pronunciation': 'chee-che'},
      {'word': '公共汽车', 'meaning': 'Bus', 'pronunciation': 'gong-gong-chee-che'},
      {'word': '火车', 'meaning': 'Train', 'pronunciation': 'hwo-che'},
      {'word': '飞机', 'meaning': 'Airplane', 'pronunciation': 'fay-jee'},
      {'word': '船', 'meaning': 'Ship', 'pronunciation': 'chwahn'},
      {'word': '自行车', 'meaning': 'Bicycle', 'pronunciation': 'dzuh-hing-che'},
      {'word': '时间', 'meaning': 'Time', 'pronunciation': 'shih-jyen'},
      {'word': '天', 'meaning': 'Day', 'pronunciation': 'tyen'},
      {'word': '周', 'meaning': 'Week', 'pronunciation': 'jow'},
      {'word': '月', 'meaning': 'Month', 'pronunciation': 'yweh'},
      {'word': '年', 'meaning': 'Year', 'pronunciation': 'nyen'},
      {'word': '春天', 'meaning': 'Spring', 'pronunciation': 'chwun-tyen'},
      {'word': '夏天', 'meaning': 'Summer', 'pronunciation': 'shya-tyen'},
      {'word': '秋天', 'meaning': 'Autumn', 'pronunciation': 'chyoo-tyen'},
      {'word': '冬天', 'meaning': 'Winter', 'pronunciation': 'dong-tyen'},
      {'word': '天气', 'meaning': 'Weather', 'pronunciation': 'tyen-chee'},
      {'word': '雨', 'meaning': 'Rain', 'pronunciation': 'yoo'},
      {'word': '雪', 'meaning': 'Snow', 'pronunciation': 'shweh'},
      {'word': '风', 'meaning': 'Wind', 'pronunciation': 'feng'},
      {'word': '太阳', 'meaning': 'Sun', 'pronunciation': 'tai-yang'},
      {'word': '月亮', 'meaning': 'Moon', 'pronunciation': 'yweh-liang'},
      {'word': '星星', 'meaning': 'Star', 'pronunciation': 'shing-shing'},
      {'word': '天空', 'meaning': 'Sky', 'pronunciation': 'tyen-kong'},
      {'word': '大海', 'meaning': 'Sea', 'pronunciation': 'da-hai'},
      {'word': '山', 'meaning': 'Mountain', 'pronunciation': 'shan'},
      {'word': '河', 'meaning': 'River', 'pronunciation': 'her'},
      {'word': '森林', 'meaning': 'Forest', 'pronunciation': 'sen-lin'},
      {'word': '花', 'meaning': 'Flower', 'pronunciation': 'hwa'},
      {'word': '树', 'meaning': 'Tree', 'pronunciation': 'shoo'},
      {'word': '草', 'meaning': 'Grass', 'pronunciation': 'tsao'},
      {'word': '鸟', 'meaning': 'Bird', 'pronunciation': 'nyao'},
      {'word': '狗', 'meaning': 'Dog', 'pronunciation': 'gow'},
      {'word': '猫', 'meaning': 'Cat', 'pronunciation': 'mao'},
      {'word': '马', 'meaning': 'Horse', 'pronunciation': 'ma'},
      {'word': '牛', 'meaning': 'Cow', 'pronunciation': 'nyoo'},
      {'word': '猪', 'meaning': 'Pig', 'pronunciation': 'joo'},
      {'word': '羊', 'meaning': 'Sheep', 'pronunciation': 'yang'},
      {'word': '鸡', 'meaning': 'Chicken', 'pronunciation': 'jee'},
      {'word': '红色', 'meaning': 'Red', 'pronunciation': 'hong-seh'},
      {'word': '蓝色', 'meaning': 'Blue', 'pronunciation': 'lan-seh'},
      {'word': '黄色', 'meaning': 'Yellow', 'pronunciation': 'hwang-seh'},
      {'word': '绿色', 'meaning': 'Green', 'pronunciation': 'lyoo-seh'},
      {'word': '白色', 'meaning': 'White', 'pronunciation': 'bai-seh'},
      {'word': '黑色', 'meaning': 'Black', 'pronunciation': 'hay-seh'},
      {'word': '大', 'meaning': 'Big', 'pronunciation': 'da'},
      {'word': '小', 'meaning': 'Small', 'pronunciation': 'shyaw'},
      {'word': '新', 'meaning': 'New', 'pronunciation': 'shin'},
      {'word': '旧', 'meaning': 'Old', 'pronunciation': 'jyoo'},
      {'word': '好', 'meaning': 'Good', 'pronunciation': 'hao'},
      {'word': '坏', 'meaning': 'Bad', 'pronunciation': 'hwai'},
      {'word': '高', 'meaning': 'High', 'pronunciation': 'gao'},
      {'word': '低', 'meaning': 'Low', 'pronunciation': 'dee'},
      {'word': '快', 'meaning': 'Fast', 'pronunciation': 'kwai'},
      {'word': '慢', 'meaning': 'Slow', 'pronunciation': 'man'},
      {'word': '难', 'meaning': 'Difficult', 'pronunciation': 'nan'},
      {'word': '容易', 'meaning': 'Easy', 'pronunciation': 'rong-yee'},
      {'word': '美丽', 'meaning': 'Beautiful', 'pronunciation': 'may-lee'},
      {'word': '脏', 'meaning': 'Dirty', 'pronunciation': 'zang'},
      {'word': '有趣', 'meaning': 'Fun', 'pronunciation': 'yow-koo'},
      {'word': '悲伤', 'meaning': 'Sad', 'pronunciation': 'bay-shang'},
      {'word': '高兴', 'meaning': 'Happy', 'pronunciation': 'gao-shing'},
      {'word': '生气', 'meaning': 'Angry', 'pronunciation': 'sheng-chee'},
      {'word': '害怕', 'meaning': 'Scary', 'pronunciation': 'hai-pa'},
      {'word': '累', 'meaning': 'Tired', 'pronunciation': 'lay'},
      {'word': '病', 'meaning': 'Sick', 'pronunciation': 'bing'},
      {'word': '健康', 'meaning': 'Healthy', 'pronunciation': 'jen-kang'},
      {'word': '强壮', 'meaning': 'Strong', 'pronunciation': 'chywang-jwang'},
      {'word': '弱', 'meaning': 'Weak', 'pronunciation': 'rwuh'},
      {'word': '年轻', 'meaning': 'Young', 'pronunciation': 'nyen-ching'},
      {'word': '老人', 'meaning': 'Old person', 'pronunciation': 'lao-ren'},
    ],
    'ko': [
      {'word': '안녕하세요', 'meaning': 'Hello', 'pronunciation': 'an-nyeong-ha-se-yo'},
      {'word': '감사합니다', 'meaning': 'Thank you', 'pronunciation': 'gam-sa-ham-ni-da'},
      {'word': '안녕히 가세요', 'meaning': 'Goodbye', 'pronunciation': 'an-nyeong-hi-ga-se-yo'},
      {'word': '네', 'meaning': 'Yes', 'pronunciation': 'ne'},
      {'word': '아니요', 'meaning': 'No', 'pronunciation': 'a-ni-yo'},
      {'word': '좋은 아침', 'meaning': 'Good morning', 'pronunciation': 'jo-eun-a-chim'},
      {'word': '좋은 저녁', 'meaning': 'Good evening', 'pronunciation': 'jo-eun-jeo-nyeok'},
      {'word': '죄송합니다', 'meaning': 'Sorry', 'pronunciation': 'joe-song-ham-ni-da'},
      {'word': '부탁합니다', 'meaning': 'Please', 'pronunciation': 'bu-tak-ham-ni-da'},
      {'word': '천만에요', 'meaning': 'You\'re welcome', 'pronunciation': 'cheon-man-e-yo'},
      {'word': '이름', 'meaning': 'Name', 'pronunciation': 'i-reum'},
      {'word': '나이', 'meaning': 'Age', 'pronunciation': 'na-i'},
      {'word': '국가', 'meaning': 'Country', 'pronunciation': 'guk-ga'},
      {'word': '언어', 'meaning': 'Language', 'pronunciation': 'eon-eo'},
      {'word': '친구', 'meaning': 'Friend', 'pronunciation': 'chin-gu'},
      {'word': '가족', 'meaning': 'Family', 'pronunciation': 'ga-jog'},
      {'word': '선생님', 'meaning': 'Teacher', 'pronunciation': 'seon-saeng-nim'},
      {'word': '학생', 'meaning': 'Student', 'pronunciation': 'hak-saeng'},
      {'word': '일', 'meaning': 'Work', 'pronunciation': 'il'},
      {'word': '학교', 'meaning': 'School', 'pronunciation': 'hak-gyo'},
      {'word': '음식', 'meaning': 'Food', 'pronunciation': 'eum-sig'},
      {'word': '물', 'meaning': 'Water', 'pronunciation': 'mul'},
      {'word': '차', 'meaning': 'Tea', 'pronunciation': 'cha'},
      {'word': '커피', 'meaning': 'Coffee', 'pronunciation': 'keo-pi'},
      {'word': '빵', 'meaning': 'Bread', 'pronunciation': 'ppang'},
      {'word': '고기', 'meaning': 'Meat', 'pronunciation': 'go-gi'},
      {'word': '생선', 'meaning': 'Fish', 'pronunciation': 'saeng-seon'},
      {'word': '채소', 'meaning': 'Vegetable', 'pronunciation': 'chae-so'},
      {'word': '과일', 'meaning': 'Fruit', 'pronunciation': 'gwa-il'},
      {'word': '집', 'meaning': 'House', 'pronunciation': 'jib'},
      {'word': '방', 'meaning': 'Room', 'pronunciation': 'bang'},
      {'word': '창문', 'meaning': 'Window', 'pronunciation': 'chang-mun'},
      {'word': '문', 'meaning': 'Door', 'pronunciation': 'mun'},
      {'word': '책상', 'meaning': 'Desk', 'pronunciation': 'chaek-sang'},
      {'word': '의자', 'meaning': 'Chair', 'pronunciation': 'ui-ja'},
      {'word': '책', 'meaning': 'Book', 'pronunciation': 'chaek'},
      {'word': '펜', 'meaning': 'Pen', 'pronunciation': 'pen'},
      {'word': '종이', 'meaning': 'Paper', 'pronunciation': 'jong-i'},
      {'word': '전화', 'meaning': 'Phone', 'pronunciation': 'jeon-hwa'},
      {'word': '컴퓨터', 'meaning': 'Computer', 'pronunciation': 'keom-pyu-teo'},
      {'word': '자동차', 'meaning': 'Car', 'pronunciation': 'ja-dong-cha'},
      {'word': '버스', 'meaning': 'Bus', 'pronunciation': 'beo-seu'},
      {'word': '기차', 'meaning': 'Train', 'pronunciation': 'gi-cha'},
      {'word': '비행기', 'meaning': 'Airplane', 'pronunciation': 'bi-haeng-gi'},
      {'word': '배', 'meaning': 'Ship', 'pronunciation': 'bae'},
      {'word': '자전거', 'meaning': 'Bicycle', 'pronunciation': 'ja-jeon-geo'},
      {'word': '시간', 'meaning': 'Time', 'pronunciation': 'si-gan'},
      {'word': '날', 'meaning': 'Day', 'pronunciation': 'nal'},
      {'word': '주', 'meaning': 'Week', 'pronunciation': 'ju'},
      {'word': '월', 'meaning': 'Month', 'pronunciation': 'wol'},
      {'word': '년', 'meaning': 'Year', 'pronunciation': 'nyeon'},
      {'word': '봄', 'meaning': 'Spring', 'pronunciation': 'bom'},
      {'word': '여름', 'meaning': 'Summer', 'pronunciation': 'yeo-reum'},
      {'word': '가을', 'meaning': 'Autumn', 'pronunciation': 'ga-eul'},
      {'word': '겨울', 'meaning': 'Winter', 'pronunciation': 'gyeo-ul'},
      {'word': '날씨', 'meaning': 'Weather', 'pronunciation': 'nal-ssi'},
      {'word': '비', 'meaning': 'Rain', 'pronunciation': 'bi'},
      {'word': '눈', 'meaning': 'Snow', 'pronunciation': 'nun'},
      {'word': '바람', 'meaning': 'Wind', 'pronunciation': 'ba-ram'},
      {'word': '태양', 'meaning': 'Sun', 'pronunciation': 'tae-yang'},
      {'word': '달', 'meaning': 'Moon', 'pronunciation': 'dal'},
      {'word': '별', 'meaning': 'Star', 'pronunciation': 'byeol'},
      {'word': '하늘', 'meaning': 'Sky', 'pronunciation': 'ha-neul'},
      {'word': '바다', 'meaning': 'Sea', 'pronunciation': 'ba-da'},
      {'word': '산', 'meaning': 'Mountain', 'pronunciation': 'san'},
      {'word': '강', 'meaning': 'River', 'pronunciation': 'gang'},
      {'word': '숲', 'meaning': 'Forest', 'pronunciation': 'sup'},
      {'word': '꽃', 'meaning': 'Flower', 'pronunciation': 'kkot'},
      {'word': '나무', 'meaning': 'Tree', 'pronunciation': 'na-mu'},
      {'word': '잔디', 'meaning': 'Grass', 'pronunciation': 'jan-di'},
      {'word': '새', 'meaning': 'Bird', 'pronunciation': 'sae'},
      {'word': '개', 'meaning': 'Dog', 'pronunciation': 'gae'},
      {'word': '고양이', 'meaning': 'Cat', 'pronunciation': 'go-yang-i'},
      {'word': '말', 'meaning': 'Horse', 'pronunciation': 'mal'},
      {'word': '소', 'meaning': 'Cow', 'pronunciation': 'so'},
      {'word': '돼지', 'meaning': 'Pig', 'pronunciation': 'dwae-ji'},
      {'word': '양', 'meaning': 'Sheep', 'pronunciation': 'yang'},
      {'word': '닭', 'meaning': 'Chicken', 'pronunciation': 'dak'},
      {'word': '빨간색', 'meaning': 'Red', 'pronunciation': 'bbal-gan-saek'},
      {'word': '파란색', 'meaning': 'Blue', 'pronunciation': 'pa-ran-saek'},
      {'word': '노란색', 'meaning': 'Yellow', 'pronunciation': 'no-ran-saek'},
      {'word': '초록색', 'meaning': 'Green', 'pronunciation': 'cho-rok-saek'},
      {'word': '흰색', 'meaning': 'White', 'pronunciation': 'huin-saek'},
      {'word': '검은색', 'meaning': 'Black', 'pronunciation': 'geom-eun-saek'},
      {'word': '크다', 'meaning': 'Big', 'pronunciation': 'keu-da'},
      {'word': '작다', 'meaning': 'Small', 'pronunciation': 'jak-da'},
      {'word': '새로운', 'meaning': 'New', 'pronunciation': 'sae-ro-un'},
      {'word': '오래된', 'meaning': 'Old', 'pronunciation': 'o-rae-doen'},
      {'word': '좋다', 'meaning': 'Good', 'pronunciation': 'jo-ta'},
      {'word': '나쁘다', 'meaning': 'Bad', 'pronunciation': 'na-ppu-da'},
      {'word': '높다', 'meaning': 'High', 'pronunciation': 'nop-da'},
      {'word': '낮다', 'meaning': 'Low', 'pronunciation': 'naj-da'},
      {'word': '빠르다', 'meaning': 'Fast', 'pronunciation': 'ppa-reu-da'},
      {'word': '느리다', 'meaning': 'Slow', 'pronunciation': 'neu-ri-da'},
      {'word': '어렵다', 'meaning': 'Difficult', 'pronunciation': 'eo-ryeop-da'},
      {'word': '쉽다', 'meaning': 'Easy', 'pronunciation': 'swip-da'},
      {'word': '아름답다', 'meaning': 'Beautiful', 'pronunciation': 'a-reum-dap-da'},
      {'word': '더럽다', 'meaning': 'Dirty', 'pronunciation': 'deo-reop-da'},
      {'word': '재미있다', 'meaning': 'Fun', 'pronunciation': 'jae-mi-it-da'},
      {'word': '슬프다', 'meaning': 'Sad', 'pronunciation': 'seul-peu-da'},
      {'word': '행복하다', 'meaning': 'Happy', 'pronunciation': 'haeng-bok-ha-da'},
      {'word': '화나다', 'meaning': 'Angry', 'pronunciation': 'hwa-na-da'},
      {'word': '무섭다', 'meaning': 'Scary', 'pronunciation': 'mu-seop-da'},
      {'word': '피곤하다', 'meaning': 'Tired', 'pronunciation': 'pi-gon-ha-da'},
      {'word': '아프다', 'meaning': 'Sick', 'pronunciation': 'a-peu-da'},
      {'word': '건강하다', 'meaning': 'Healthy', 'pronunciation': 'geon-gang-ha-da'},
      {'word': '강하다', 'meaning': 'Strong', 'pronunciation': 'gang-ha-da'},
      {'word': '약하다', 'meaning': 'Weak', 'pronunciation': 'yak-ha-da'},
      {'word': '젊다', 'meaning': 'Young', 'pronunciation': 'jeolm-da'},
      {'word': '노인', 'meaning': 'Old person', 'pronunciation': 'no-in'},
    ],
    'en': [
      {'word': 'Hello', 'meaning': 'Hello', 'pronunciation': 'heh-LOH'},
      {'word': 'Thank you', 'meaning': 'Thank you', 'pronunciation': 'THANGK-yoo'},
      {'word': 'Goodbye', 'meaning': 'Goodbye', 'pronunciation': 'good-BYE'},
      {'word': 'Yes', 'meaning': 'Yes', 'pronunciation': 'yes'},
      {'word': 'No', 'meaning': 'No', 'pronunciation': 'noh'},
      {'word': 'Good morning', 'meaning': 'Good morning', 'pronunciation': 'good MOR-ning'},
      {'word': 'Good evening', 'meaning': 'Good evening', 'pronunciation': 'good EEV-ning'},
      {'word': 'Excuse me', 'meaning': 'Excuse me', 'pronunciation': 'ex-KYOOZ mee'},
      {'word': 'Please', 'meaning': 'Please', 'pronunciation': 'pleez'},
      {'word': 'You\'re welcome', 'meaning': 'You\'re welcome', 'pronunciation': 'yoor WEL-kum'},
      {'word': 'Name', 'meaning': 'Name', 'pronunciation': 'naym'},
      {'word': 'Age', 'meaning': 'Age', 'pronunciation': 'ayj'},
      {'word': 'Country', 'meaning': 'Country', 'pronunciation': 'KUN-tree'},
      {'word': 'Language', 'meaning': 'Language', 'pronunciation': 'LANG-gwij'},
      {'word': 'Friend', 'meaning': 'Friend', 'pronunciation': 'frend'},
      {'word': 'Family', 'meaning': 'Family', 'pronunciation': 'FAM-uh-lee'},
      {'word': 'Teacher', 'meaning': 'Teacher', 'pronunciation': 'TEE-chur'},
      {'word': 'Student', 'meaning': 'Student', 'pronunciation': 'STOO-dent'},
      {'word': 'Work', 'meaning': 'Work', 'pronunciation': 'wurk'},
      {'word': 'School', 'meaning': 'School', 'pronunciation': 'skool'},
      {'word': 'Food', 'meaning': 'Food', 'pronunciation': 'food'},
      {'word': 'Water', 'meaning': 'Water', 'pronunciation': 'WAW-ter'},
      {'word': 'Tea', 'meaning': 'Tea', 'pronunciation': 'tee'},
      {'word': 'Coffee', 'meaning': 'Coffee', 'pronunciation': 'KAW-fee'},
      {'word': 'Bread', 'meaning': 'Bread', 'pronunciation': 'bred'},
      {'word': 'Meat', 'meaning': 'Meat', 'pronunciation': 'meet'},
      {'word': 'Fish', 'meaning': 'Fish', 'pronunciation': 'fish'},
      {'word': 'Vegetable', 'meaning': 'Vegetable', 'pronunciation': 'VEJ-tuh-bul'},
      {'word': 'Fruit', 'meaning': 'Fruit', 'pronunciation': 'froot'},
      {'word': 'House', 'meaning': 'House', 'pronunciation': 'hows'},
      {'word': 'Room', 'meaning': 'Room', 'pronunciation': 'room'},
      {'word': 'Window', 'meaning': 'Window', 'pronunciation': 'WIN-doh'},
      {'word': 'Door', 'meaning': 'Door', 'pronunciation': 'dor'},
      {'word': 'Desk', 'meaning': 'Desk', 'pronunciation': 'desk'},
      {'word': 'Chair', 'meaning': 'Chair', 'pronunciation': 'chair'},
      {'word': 'Book', 'meaning': 'Book', 'pronunciation': 'book'},
      {'word': 'Pen', 'meaning': 'Pen', 'pronunciation': 'pen'},
      {'word': 'Paper', 'meaning': 'Paper', 'pronunciation': 'PAY-per'},
      {'word': 'Phone', 'meaning': 'Phone', 'pronunciation': 'fohn'},
      {'word': 'Computer', 'meaning': 'Computer', 'pronunciation': 'kom-PYOO-ter'},
      {'word': 'Car', 'meaning': 'Car', 'pronunciation': 'kar'},
      {'word': 'Bus', 'meaning': 'Bus', 'pronunciation': 'bus'},
      {'word': 'Train', 'meaning': 'Train', 'pronunciation': 'trayn'},
      {'word': 'Airplane', 'meaning': 'Airplane', 'pronunciation': 'AIR-playn'},
      {'word': 'Ship', 'meaning': 'Ship', 'pronunciation': 'ship'},
      {'word': 'Bicycle', 'meaning': 'Bicycle', 'pronunciation': 'BY-si-kul'},
      {'word': 'Time', 'meaning': 'Time', 'pronunciation': 'tyme'},
      {'word': 'Day', 'meaning': 'Day', 'pronunciation': 'day'},
      {'word': 'Week', 'meaning': 'Week', 'pronunciation': 'week'},
      {'word': 'Month', 'meaning': 'Month', 'pronunciation': 'munth'},
      {'word': 'Year', 'meaning': 'Year', 'pronunciation': 'yeer'},
      {'word': 'Spring', 'meaning': 'Spring', 'pronunciation': 'spring'},
      {'word': 'Summer', 'meaning': 'Summer', 'pronunciation': 'SUM-er'},
      {'word': 'Autumn', 'meaning': 'Autumn', 'pronunciation': 'AW-tum'},
      {'word': 'Winter', 'meaning': 'Winter', 'pronunciation': 'WIN-ter'},
      {'word': 'Weather', 'meaning': 'Weather', 'pronunciation': 'WETH-er'},
      {'word': 'Rain', 'meaning': 'Rain', 'pronunciation': 'rayn'},
      {'word': 'Snow', 'meaning': 'Snow', 'pronunciation': 'snoh'},
      {'word': 'Wind', 'meaning': 'Wind', 'pronunciation': 'wind'},
      {'word': 'Sun', 'meaning': 'Sun', 'pronunciation': 'sun'},
      {'word': 'Moon', 'meaning': 'Moon', 'pronunciation': 'moon'},
      {'word': 'Star', 'meaning': 'Star', 'pronunciation': 'star'},
      {'word': 'Sky', 'meaning': 'Sky', 'pronunciation': 'skye'},
      {'word': 'Sea', 'meaning': 'Sea', 'pronunciation': 'see'},
      {'word': 'Mountain', 'meaning': 'Mountain', 'pronunciation': 'MOWN-ten'},
      {'word': 'River', 'meaning': 'River', 'pronunciation': 'RIV-er'},
      {'word': 'Forest', 'meaning': 'Forest', 'pronunciation': 'FOR-ist'},
      {'word': 'Flower', 'meaning': 'Flower', 'pronunciation': 'FLOW-er'},
      {'word': 'Tree', 'meaning': 'Tree', 'pronunciation': 'tree'},
      {'word': 'Grass', 'meaning': 'Grass', 'pronunciation': 'gras'},
      {'word': 'Bird', 'meaning': 'Bird', 'pronunciation': 'burd'},
      {'word': 'Dog', 'meaning': 'Dog', 'pronunciation': 'dawg'},
      {'word': 'Cat', 'meaning': 'Cat', 'pronunciation': 'kat'},
      {'word': 'Horse', 'meaning': 'Horse', 'pronunciation': 'hors'},
      {'word': 'Cow', 'meaning': 'Cow', 'pronunciation': 'kow'},
      {'word': 'Pig', 'meaning': 'Pig', 'pronunciation': 'pig'},
      {'word': 'Sheep', 'meaning': 'Sheep', 'pronunciation': 'sheep'},
      {'word': 'Chicken', 'meaning': 'Chicken', 'pronunciation': 'CHIK-en'},
      {'word': 'Red', 'meaning': 'Red', 'pronunciation': 'red'},
      {'word': 'Blue', 'meaning': 'Blue', 'pronunciation': 'bloo'},
      {'word': 'Yellow', 'meaning': 'Yellow', 'pronunciation': 'YEL-oh'},
      {'word': 'Green', 'meaning': 'Green', 'pronunciation': 'green'},
      {'word': 'White', 'meaning': 'White', 'pronunciation': 'wite'},
      {'word': 'Black', 'meaning': 'Black', 'pronunciation': 'blak'},
      {'word': 'Big', 'meaning': 'Big', 'pronunciation': 'big'},
      {'word': 'Small', 'meaning': 'Small', 'pronunciation': 'smawl'},
      {'word': 'New', 'meaning': 'New', 'pronunciation': 'noo'},
      {'word': 'Old', 'meaning': 'Old', 'pronunciation': 'old'},
      {'word': 'Good', 'meaning': 'Good', 'pronunciation': 'good'},
      {'word': 'Bad', 'meaning': 'Bad', 'pronunciation': 'bad'},
      {'word': 'High', 'meaning': 'High', 'pronunciation': 'hye'},
      {'word': 'Low', 'meaning': 'Low', 'pronunciation': 'loh'},
      {'word': 'Fast', 'meaning': 'Fast', 'pronunciation': 'fast'},
      {'word': 'Slow', 'meaning': 'Slow', 'pronunciation': 'sloh'},
      {'word': 'Difficult', 'meaning': 'Difficult', 'pronunciation': 'DIF-uh-kult'},
      {'word': 'Easy', 'meaning': 'Easy', 'pronunciation': 'EE-zee'},
      {'word': 'Beautiful', 'meaning': 'Beautiful', 'pronunciation': 'BYOO-tuh-ful'},
      {'word': 'Dirty', 'meaning': 'Dirty', 'pronunciation': 'DUR-tee'},
      {'word': 'Fun', 'meaning': 'Fun', 'pronunciation': 'fun'},
      {'word': 'Sad', 'meaning': 'Sad', 'pronunciation': 'sad'},
      {'word': 'Happy', 'meaning': 'Happy', 'pronunciation': 'HAP-ee'},
      {'word': 'Angry', 'meaning': 'Angry', 'pronunciation': 'ANG-gree'},
      {'word': 'Scary', 'meaning': 'Scary', 'pronunciation': 'SKAIR-ee'},
      {'word': 'Tired', 'meaning': 'Tired', 'pronunciation': 'tyerd'},
      {'word': 'Sick', 'meaning': 'Sick', 'pronunciation': 'sik'},
      {'word': 'Healthy', 'meaning': 'Healthy', 'pronunciation': 'HEL-thee'},
      {'word': 'Strong', 'meaning': 'Strong', 'pronunciation': 'strawng'},
      {'word': 'Weak', 'meaning': 'Weak', 'pronunciation': 'week'},
      {'word': 'Young', 'meaning': 'Young', 'pronunciation': 'yung'},
      {'word': 'Old person', 'meaning': 'Old person', 'pronunciation': 'old PUR-sun'},
    ],
    'es': [
      {'word': 'Hola', 'meaning': 'Hello', 'pronunciation': 'OH-lah'},
      {'word': 'Gracias', 'meaning': 'Thank you', 'pronunciation': 'GRAH-syahs'},
      {'word': 'Adiós', 'meaning': 'Goodbye', 'pronunciation': 'ah-DYOHS'},
      {'word': 'Sí', 'meaning': 'Yes', 'pronunciation': 'see'},
      {'word': 'No', 'meaning': 'No', 'pronunciation': 'noh'},
      {'word': 'Buenos días', 'meaning': 'Good morning', 'pronunciation': 'BWEH-nohs DEE-ahs'},
      {'word': 'Buenas noches', 'meaning': 'Good evening', 'pronunciation': 'BWEH-nahs NOH-ches'},
      {'word': 'Disculpe', 'meaning': 'Excuse me', 'pronunciation': 'dees-KOOL-peh'},
      {'word': 'Por favor', 'meaning': 'Please', 'pronunciation': 'por fah-VOR'},
      {'word': 'De nada', 'meaning': 'You\'re welcome', 'pronunciation': 'deh NAH-dah'},
      {'word': 'Nombre', 'meaning': 'Name', 'pronunciation': 'NOHM-breh'},
      {'word': 'Edad', 'meaning': 'Age', 'pronunciation': 'eh-DAHD'},
      {'word': 'País', 'meaning': 'Country', 'pronunciation': 'pah-EES'},
      {'word': 'Idioma', 'meaning': 'Language', 'pronunciation': 'ee-DYOH-mah'},
      {'word': 'Amigo', 'meaning': 'Friend', 'pronunciation': 'ah-MEE-goh'},
      {'word': 'Familia', 'meaning': 'Family', 'pronunciation': 'fah-MEE-lyah'},
      {'word': 'Profesor', 'meaning': 'Teacher', 'pronunciation': 'proh-feh-SOR'},
      {'word': 'Estudiante', 'meaning': 'Student', 'pronunciation': 'ehs-too-dee-AHN-teh'},
      {'word': 'Trabajo', 'meaning': 'Work', 'pronunciation': 'trah-BAH-hoh'},
      {'word': 'Escuela', 'meaning': 'School', 'pronunciation': 'ehs-KWEH-lah'},
      {'word': 'Comida', 'meaning': 'Food', 'pronunciation': 'koh-MEE-dah'},
      {'word': 'Agua', 'meaning': 'Water', 'pronunciation': 'AH-gwah'},
      {'word': 'Té', 'meaning': 'Tea', 'pronunciation': 'teh'},
      {'word': 'Café', 'meaning': 'Coffee', 'pronunciation': 'kah-FEH'},
      {'word': 'Pan', 'meaning': 'Bread', 'pronunciation': 'pahn'},
      {'word': 'Carne', 'meaning': 'Meat', 'pronunciation': 'KAR-neh'},
      {'word': 'Pescado', 'meaning': 'Fish', 'pronunciation': 'pehs-KAH-doh'},
      {'word': 'Verdura', 'meaning': 'Vegetable', 'pronunciation': 'ber-DOO-rah'},
      {'word': 'Fruta', 'meaning': 'Fruit', 'pronunciation': 'FROO-tah'},
      {'word': 'Casa', 'meaning': 'House', 'pronunciation': 'KAH-sah'},
      {'word': 'Habitación', 'meaning': 'Room', 'pronunciation': 'ah-bee-tah-see-OHN'},
      {'word': 'Ventana', 'meaning': 'Window', 'pronunciation': 'ben-TAH-nah'},
      {'word': 'Puerta', 'meaning': 'Door', 'pronunciation': 'PWEHR-tah'},
      {'word': 'Escritorio', 'meaning': 'Desk', 'pronunciation': 'ehs-kree-TOH-ree-oh'},
      {'word': 'Silla', 'meaning': 'Chair', 'pronunciation': 'SEE-yah'},
      {'word': 'Libro', 'meaning': 'Book', 'pronunciation': 'LEE-broh'},
      {'word': 'Bolígrafo', 'meaning': 'Pen', 'pronunciation': 'bohl-EE-grah-foh'},
      {'word': 'Papel', 'meaning': 'Paper', 'pronunciation': 'pah-PEHL'},
      {'word': 'Teléfono', 'meaning': 'Phone', 'pronunciation': 'teh-LEH-foh-noh'},
      {'word': 'Computadora', 'meaning': 'Computer', 'pronunciation': 'kohm-poo-tah-DOH-rah'},
      {'word': 'Coche', 'meaning': 'Car', 'pronunciation': 'KOH-cheh'},
      {'word': 'Autobús', 'meaning': 'Bus', 'pronunciation': 'ow-toh-BOOS'},
      {'word': 'Tren', 'meaning': 'Train', 'pronunciation': 'trehn'},
      {'word': 'Avión', 'meaning': 'Airplane', 'pronunciation': 'ah-bee-OHN'},
      {'word': 'Barco', 'meaning': 'Ship', 'pronunciation': 'BAR-koh'},
      {'word': 'Bicicleta', 'meaning': 'Bicycle', 'pronunciation': 'bee-see-KLEH-tah'},
      {'word': 'Tiempo', 'meaning': 'Time', 'pronunciation': 'tee-EHM-poh'},
      {'word': 'Día', 'meaning': 'Day', 'pronunciation': 'DEE-ah'},
      {'word': 'Semana', 'meaning': 'Week', 'pronunciation': 'seh-MAH-nah'},
      {'word': 'Mes', 'meaning': 'Month', 'pronunciation': 'mehs'},
      {'word': 'Año', 'meaning': 'Year', 'pronunciation': 'AH-nyoh'},
      {'word': 'Primavera', 'meaning': 'Spring', 'pronunciation': 'pree-mah-VEH-rah'},
      {'word': 'Verano', 'meaning': 'Summer', 'pronunciation': 'beh-RAH-noh'},
      {'word': 'Otoño', 'meaning': 'Autumn', 'pronunciation': 'oh-TOH-nyoh'},
      {'word': 'Invierno', 'meaning': 'Winter', 'pronunciation': 'in-bee-EHR-noh'},
      {'word': 'Clima', 'meaning': 'Weather', 'pronunciation': 'KLEE-mah'},
      {'word': 'Lluvia', 'meaning': 'Rain', 'pronunciation': 'YOO-bee-ah'},
      {'word': 'Nieve', 'meaning': 'Snow', 'pronunciation': 'NYEH-beh'},
      {'word': 'Viento', 'meaning': 'Wind', 'pronunciation': 'bee-EHN-toh'},
      {'word': 'Sol', 'meaning': 'Sun', 'pronunciation': 'sohl'},
      {'word': 'Luna', 'meaning': 'Moon', 'pronunciation': 'LOO-nah'},
      {'word': 'Estrella', 'meaning': 'Star', 'pronunciation': 'ehs-TREH-yah'},
      {'word': 'Cielo', 'meaning': 'Sky', 'pronunciation': 'see-EH-loh'},
      {'word': 'Mar', 'meaning': 'Sea', 'pronunciation': 'mahr'},
      {'word': 'Montaña', 'meaning': 'Mountain', 'pronunciation': 'mohn-TAH-nyah'},
      {'word': 'Río', 'meaning': 'River', 'pronunciation': 'REE-oh'},
      {'word': 'Bosque', 'meaning': 'Forest', 'pronunciation': 'BOHS-keh'},
      {'word': 'Flor', 'meaning': 'Flower', 'pronunciation': 'FLOHR'},
      {'word': 'Árbol', 'meaning': 'Tree', 'pronunciation': 'AHR-bohl'},
      {'word': 'Césped', 'meaning': 'Grass', 'pronunciation': 'SEH-sped'},
      {'word': 'Pájaro', 'meaning': 'Bird', 'pronunciation': 'PAH-hah-roh'},
      {'word': 'Perro', 'meaning': 'Dog', 'pronunciation': 'PEH-roh'},
      {'word': 'Gato', 'meaning': 'Cat', 'pronunciation': 'GAH-toh'},
      {'word': 'Caballo', 'meaning': 'Horse', 'pronunciation': 'kah-BAH-yoh'},
      {'word': 'Vaca', 'meaning': 'Cow', 'pronunciation': 'BAH-kah'},
      {'word': 'Cerdo', 'meaning': 'Pig', 'pronunciation': 'SEHR-doh'},
      {'word': 'Oveja', 'meaning': 'Sheep', 'pronunciation': 'oh-VEH-hah'},
      {'word': 'Pollo', 'meaning': 'Chicken', 'pronunciation': 'POH-yoh'},
      {'word': 'Rojo', 'meaning': 'Red', 'pronunciation': 'ROH-hoh'},
      {'word': 'Azul', 'meaning': 'Blue', 'pronunciation': 'ah-SOOL'},
      {'word': 'Amarillo', 'meaning': 'Yellow', 'pronunciation': 'ah-mah-REE-yoh'},
      {'word': 'Verde', 'meaning': 'Green', 'pronunciation': 'BEHR-deh'},
      {'word': 'Blanco', 'meaning': 'White', 'pronunciation': 'BLAHN-koh'},
      {'word': 'Negro', 'meaning': 'Black', 'pronunciation': 'NEH-groh'},
      {'word': 'Grande', 'meaning': 'Big', 'pronunciation': 'GRAHN-deh'},
      {'word': 'Pequeño', 'meaning': 'Small', 'pronunciation': 'peh-KEH-nyoh'},
      {'word': 'Nuevo', 'meaning': 'New', 'pronunciation': 'NWEH-boh'},
      {'word': 'Viejo', 'meaning': 'Old', 'pronunciation': 'bee-EH-hoh'},
      {'word': 'Bueno', 'meaning': 'Good', 'pronunciation': 'BWEH-noh'},
      {'word': 'Malo', 'meaning': 'Bad', 'pronunciation': 'MAH-loh'},
      {'word': 'Alto', 'meaning': 'High', 'pronunciation': 'AHL-toh'},
      {'word': 'Bajo', 'meaning': 'Low', 'pronunciation': 'BAH-hoh'},
      {'word': 'Rápido', 'meaning': 'Fast', 'pronunciation': 'RAH-pee-doh'},
      {'word': 'Lento', 'meaning': 'Slow', 'pronunciation': 'LEHN-toh'},
      {'word': 'Difícil', 'meaning': 'Difficult', 'pronunciation': 'dee-FEE-seel'},
      {'word': 'Fácil', 'meaning': 'Easy', 'pronunciation': 'FAH-seel'},
      {'word': 'Hermoso', 'meaning': 'Beautiful', 'pronunciation': 'ehr-MOH-soh'},
      {'word': 'Sucio', 'meaning': 'Dirty', 'pronunciation': 'SOO-see-oh'},
      {'word': 'Divertido', 'meaning': 'Fun', 'pronunciation': 'dee-behr-TEE-doh'},
      {'word': 'Triste', 'meaning': 'Sad', 'pronunciation': 'TREEHS-teh'},
      {'word': 'Feliz', 'meaning': 'Happy', 'pronunciation': 'feh-LEES'},
      {'word': 'Enojado', 'meaning': 'Angry', 'pronunciation': 'eh-noh-HAH-doh'},
      {'word': 'Miedoso', 'meaning': 'Scary', 'pronunciation': 'mee-EH-doh-soh'},
      {'word': 'Cansado', 'meaning': 'Tired', 'pronunciation': 'kahn-SAH-doh'},
      {'word': 'Enfermo', 'meaning': 'Sick', 'pronunciation': 'ehn-FEHR-moh'},
      {'word': 'Saludable', 'meaning': 'Healthy', 'pronunciation': 'sah-loo-DAH-bleh'},
      {'word': 'Fuerte', 'meaning': 'Strong', 'pronunciation': 'FWEHR-teh'},
      {'word': 'Débil', 'meaning': 'Weak', 'pronunciation': 'DEH-beel'},
      {'word': 'Joven', 'meaning': 'Young', 'pronunciation': 'HOH-behn'},
      {'word': 'Anciano', 'meaning': 'Old person', 'pronunciation': 'ahn-see-AH-noh'},
    ],
  };
}
