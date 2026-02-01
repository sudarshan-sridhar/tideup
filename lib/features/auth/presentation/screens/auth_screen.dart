import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/providers.dart';
import '../../../auth/data/user_model.dart';
import 'demo_login_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'player';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF22D3EE), Color(0xFF3B82F6), Color(0xFF2563EB)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: const Icon(Icons.waves, size: 48, color: Color(0xFF0891B2)),
                  ),
                  const SizedBox(height: 16),
                  const Text('TideUp', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Clean Oceans, Earn Rewards', style: TextStyle(fontSize: 16, color: Colors.white.withAlpha(230))),
                  const SizedBox(height: 32),

                  // Main Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 30, offset: const Offset(0, 15))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tab Bar
                        Container(
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(color: const Color(0xFF0891B2), borderRadius: BorderRadius.circular(12)),
                            labelColor: Colors.white,
                            unselectedLabelColor: const Color(0xFF64748B),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            tabs: const [Tab(text: 'Login'), Tab(text: 'Sign Up')],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Message
                        if (_error != null) Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
                          child: Row(children: [
                            const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13))),
                          ]),
                        ),

                        // Role Selection
                        const Align(alignment: Alignment.centerLeft, child: Text('I am a...', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _RoleButton(label: '🌊 Player', isSelected: _selectedRole == 'player', onTap: () => setState(() => _selectedRole = 'player'))),
                          const SizedBox(width: 12),
                          Expanded(child: _RoleButton(label: '🏢 Organization', isSelected: _selectedRole == 'organization', onTap: () => setState(() => _selectedRole = 'organization'))),
                        ]),
                        const SizedBox(height: 20),

                        // Name Field (Sign Up only)
                        AnimatedBuilder(
                          animation: _tabController,
                          builder: (context, _) {
                            if (_tabController.index == 0) return const SizedBox.shrink();
                            return Column(children: [
                              _buildTextField(_nameController, _selectedRole == 'player' ? 'Full Name' : 'Organization Name', Icons.person_outline),
                              const SizedBox(height: 16),
                            ]);
                          },
                        ),

                        // Email Field
                        _buildTextField(_emailController, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 16),

                        // Password Field
                        _buildTextField(_passwordController, 'Password', Icons.lock_outline, obscureText: true),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.zero,
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF2563EB)]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                child: _isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : AnimatedBuilder(animation: _tabController, builder: (_, __) => Text(_tabController.index == 0 ? 'Login' : 'Sign Up', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16))),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Google Sign In
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          icon: Image.network('https://www.google.com/favicon.ico', height: 20, width: 20, errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 20)),
                          label: const Text('Continue with Google'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Demo Mode Button
                  TextButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DemoLoginScreen())),
                    icon: const Icon(Icons.science, color: Colors.white),
                    label: const Text('Demo Mode (For Judges)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(30),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Join thousands of ocean warriors making a difference', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0891B2), width: 2)),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) { setState(() => _error = 'Please fill in all fields'); return; }
    if (password.length < 6) { setState(() => _error = 'Password must be at least 6 characters'); return; }

    setState(() { _isLoading = true; _error = null; });
    try {
      final firebase = ref.read(firebaseServiceProvider);
      if (_tabController.index == 0) {
        await firebase.signInWithEmail(email, password);
      } else {
        final name = _nameController.text.trim();
        if (name.isEmpty) { setState(() { _isLoading = false; _error = 'Please enter your name'; }); return; }
        final credential = await firebase.signUpWithEmail(email, password);
        final user = UserModel(uid: credential.user!.uid, email: email, name: name, role: _selectedRole, createdAt: DateTime.now(), lastActive: DateTime.now(), organizationName: _selectedRole == 'organization' ? name : null);
        await firebase.saveUser(user);
      }
    } catch (e) {
      setState(() => _error = _mapFirebaseError(e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final firebase = ref.read(firebaseServiceProvider);
      final result = await firebase.signInWithGoogle();
      if (result == null) { setState(() { _isLoading = false; _error = 'Google sign-in cancelled'; }); return; }
      final exists = await firebase.userProfileExists(result.user!.uid);
      if (!exists && mounted) {
        final role = await _showRoleDialog();
        if (role != null) {
          final user = UserModel(uid: result.user!.uid, email: result.user!.email ?? '', name: result.user!.displayName ?? 'User', role: role, photoUrl: result.user!.photoURL, createdAt: DateTime.now(), lastActive: DateTime.now(), organizationName: role == 'organization' ? (result.user!.displayName ?? 'Organization') : null);
          await firebase.saveUser(user);
        }
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _showRoleDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Welcome to TideUp!'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('How will you use TideUp?'),
          const SizedBox(height: 20),
          _RoleButton(label: '🌊 Player - Join cleanups', isSelected: false, onTap: () => Navigator.pop(ctx, 'player')),
          const SizedBox(height: 12),
          _RoleButton(label: '🏢 Organization - Create events', isSelected: false, onTap: () => Navigator.pop(ctx, 'organization')),
        ]),
      ),
    );
  }

  String _mapFirebaseError(String error) {
    if (error.contains('user-not-found')) return 'No account found with this email';
    if (error.contains('wrong-password')) return 'Incorrect password';
    if (error.contains('email-already-in-use')) return 'Email already registered';
    if (error.contains('invalid-email')) return 'Invalid email address';
    if (error.contains('weak-password')) return 'Password is too weak';
    return 'An error occurred. Please try again.';
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _RoleButton({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0891B2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF0891B2) : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
        ),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.w600))),
      ),
    );
  }
}
