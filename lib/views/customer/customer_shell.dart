import 'dart:async';

import 'package:flutter/material.dart';
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
        actions: [
          IconButton(
            onPressed: state.signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
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
    if (activeMenu == 'Vocabulary') return const _LettersPage();
    if (activeMenu == 'Progress') {
      return _ProgressPage(progress: progress, streakCount: streakCount);
    }
    if (activeMenu == 'Achievements') {
      return _AchievementsPage(progress: progress, streakCount: streakCount);
    }
    if (activeMenu == 'Settings') return const _SettingsPage();
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
    this.muted = false,
  });
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
                    builder: (_, animated, __) => LinearProgressIndicator(
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

class _LettersPage extends StatelessWidget {
  const _LettersPage();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      Text(
        'Letters',
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      const Text('Build a stronger vocabulary with words you have saved.'),
      const SizedBox(height: 24),
      ...[
        'weathered',
        'surfaces',
        'architecture',
        'observation',
        'evidence',
      ].map(
        (word) => Card(
          child: ListTile(
            leading: const Icon(Icons.bookmark_outline, color: _indigo),
            title: Text(word),
            subtitle: const Text('Tap Practice to hear and use this word.'),
          ),
        ),
      ),
    ],
  );
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      const Text(
        'Settings',
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 20),
      Container(
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: const SwitchListTile(
          value: true,
          onChanged: null,
          title: Text('Daily reminders', style: TextStyle(color: Colors.white)),
          subtitle: Text(
            'Keep your learning streak active.',
            style: TextStyle(color: _muted),
          ),
        ),
      ),
    ],
  );
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
    if (score >= 70)
      await context.read<AppState>().learningRepository.saveAttempt(
        context.read<AppState>().currentUser!.id,
        QuizAttempt(
          language: widget.language.name,
          score: score,
          date: DateTime.now(),
        ),
      );
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
          if (questions.isEmpty)
            return const Center(child: CircularProgressIndicator());
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
