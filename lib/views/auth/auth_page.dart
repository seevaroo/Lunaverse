import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/app_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool registerMode = false;
  bool busy = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool showWelcomeScreen = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (registerMode && passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    setState(() => busy = true);
    final state = context.read<AppState>();
    final success = registerMode
        ? await state.register(
            nameController.text.trim(),
            emailController.text.trim(),
            passwordController.text,
          )
        : await state.signIn(
            emailController.text.trim(),
            passwordController.text,
          );
    if (!mounted) return;
    setState(() => busy = false);
    if (state.registrationMessage != null) {
      setState(() => registerMode = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.registrationMessage!)));
    } else if (!success && state.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showWelcomeScreen) {
      return WelcomeScreen(
        onNavigateToAuth: () => setState(() => showWelcomeScreen = false),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xff1a0b2e),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: _LoginForm(
                formKey: formKey,
                nameController: nameController,
                emailController: emailController,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                registerMode: registerMode,
                busy: busy,
                obscurePassword: obscurePassword,
                obscureConfirmPassword: obscureConfirmPassword,
                onTogglePassword: () =>
                    setState(() => obscurePassword = !obscurePassword),
                onToggleConfirmPassword: () =>
                    setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                onSubmit: submit,
                onToggleMode: () => setState(() => registerMode = !registerMode),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, required this.onNavigateToAuth});

  final VoidCallback onNavigateToAuth;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0f0a1e),
      body: GestureDetector(
        onTap: widget.onNavigateToAuth,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _BackgroundPainter()),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xff1a0b2e).withValues(alpha: 0.8),
                      const Color(0xff0f0a1e),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xff7c3aed), Color(0xffa855f7)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff7c3aed).withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'L',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'LinguaNova',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        if (MediaQuery.of(context).size.width > 800) ...[
                          _navItem('Features'),
                          _navItem('Languages'),
                          _navItem('Pricing'),
                          _navItem('Community'),
                          const SizedBox(width: 24),
                          _navButton('Login'),
                          const SizedBox(width: 16),
                          _navButton('Get Started', filled: true),
                        ],
                      ],
                    ),
                    const Spacer(flex: 2),
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Master Languages\nBeautifully.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              letterSpacing: -1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: MediaQuery.of(context).size.width > 600 ? 600 : double.infinity,
                            child: const Text(
                              'Learn Japanese, Chinese, Korean, English and Spanish using AI conversations, flashcards, grammar lessons and pronunciation practice.',
                              style: TextStyle(
                                color: Color(0xffc4b5fd),
                                fontSize: 18,
                                height: 1.6,
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 48),
                          _actionButton('Start Learning', filled: true),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _navButton(String text, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: filled ? const Color(0xff7c3aed) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: filled
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: filled ? Colors.white : Colors.white.withValues(alpha: 0.9),
          fontSize: 14,
          fontWeight: filled ? FontWeight.w600 : FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _actionButton(String text, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
      decoration: BoxDecoration(
        gradient: filled
            ? const LinearGradient(
                colors: [Color(0xff7c3aed), Color(0xffa855f7)],
              )
            : null,
        color: filled ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: filled
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: const Color(0xff7c3aed).withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: filled ? Colors.white : Colors.white.withValues(alpha: 0.9),
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final characters = ['日', '中', '한', '英', '西', '語', '学', '習'];
    final random = DateTime.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < 15; i++) {
      final x = ((i * 137 + random) % size.width).toDouble();
      final y = ((i * 89 + random) % size.height).toDouble();
      final charIndex = i % characters.length;
      
      final paint = Paint()
        ..color = const Color(0xff7c3aed).withValues(alpha: 0.15)
        ..style = PaintingStyle.fill;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 60, height: 60),
        const Radius.circular(16),
      );
      canvas.drawRRect(rect, paint);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: characters[charIndex],
          style: const TextStyle(
            color: Color(0xffa78bfa),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.registerMode,
    required this.busy,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
    required this.onSubmit,
    required this.onToggleMode,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool registerMode;
  final bool busy;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xff2d1b4e),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xff7c3aed),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'LinguaNova',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              registerMode ? 'Create an Account' : 'Welcome Back',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              registerMode
                  ? 'Start your language learning journey'
                  : 'Log in to continue learning',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            if (registerMode) ...[
              _buildTextField(
                nameController,
                'Name',
                Icons.person_outline,
                (value) => value == null || value.trim().isEmpty
                    ? 'Name is required'
                    : null,
              ),
              const SizedBox(height: 16),
            ],
            _buildTextField(
              emailController,
              'Email',
              Icons.email_outlined,
              (value) => value == null || !value.contains('@')
                  ? 'Invalid email'
                  : null,
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              passwordController,
              obscurePassword,
              onTogglePassword,
              'Password',
              (value) => value == null || value.length < 6
                  ? 'Password must be at least 6 characters'
                  : null,
            ),
            if (registerMode) ...[
              const SizedBox(height: 16),
              _buildPasswordField(
                confirmPasswordController,
                obscureConfirmPassword,
                onToggleConfirmPassword,
                'Confirm Password',
                (value) => value == null || value.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: busy ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7c3aed),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: busy
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(registerMode ? 'Register' : 'Log In'),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: onToggleMode,
                  child: Text(
                    registerMode ? 'Already registered?' : 'Create an account',
                    style: const TextStyle(color: Color(0xffa78bfa)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String? Function(String?) validator, {
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff7c3aed), width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    bool obscureText,
    VoidCallback onToggle,
    String label,
    String? Function(String?) validator,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.7)),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff7c3aed), width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }
}

class _AuthIllustration extends StatelessWidget {
  const _AuthIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff3b82d0),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _SkyPainter())),
          Padding(
            padding: const EdgeInsets.all(64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Learn beyond\nborders.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 46,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Build a daily habit.\nOpen a new world.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 19,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 44),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Your next lesson is waiting.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: .08);
    for (var i = 0; i < 14; i++) {
      final x = (i * 83.0) % size.width;
      final y = 30 + ((i * 137.0) % size.height);
      canvas.drawCircle(Offset(x, y), i.isEven ? 2.5 : 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
