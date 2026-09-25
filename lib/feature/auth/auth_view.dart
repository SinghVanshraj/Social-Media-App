import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app/core/utils/error_handler.dart';
import 'package:social_media_app/core/widgets/responsive_wrapper.dart';
import 'package:social_media_app/feature/auth/auth_state.dart';
import 'package:social_media_app/feature/auth/auth_view_model.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.error != null) {
        AppSnackBar.showError(context, next.error);
      }
      if (next.status == AuthStatus.authenticated) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: Breakpoints.maxFormWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "See what's happening\nin the world right now.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.8,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Welcome back to Spark.",
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                      const SizedBox(height: 40),

                      _buildTextField(
                        controller: _emailController,
                        hintText: "Phone, email, or username",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _passwordController,
                        hintText: "Password",
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onToggleVisibility: () {
                          setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          );
                        },
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            final email = _emailController.text.trim();
                            if (email.isEmpty) {
                              AppSnackBar.showError(
                                context,
                                'Please enter your email to reset password.',
                              );
                              return;
                            }
                            ref
                                .read(authViewModelProvider.notifier)
                                .forgetPassword(email);
                            AppSnackBar.showSuccess(
                              context,
                              'Password reset link sent if account exists.',
                            );
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Colors.blueAccent[400],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      state.isLoading
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                final email = _emailController.text.trim();
                                final password = _passwordController.text.trim();
                                if (email.isEmpty || password.isEmpty) {
                                  AppSnackBar.showError(
                                    context,
                                    'Please enter your email and password.',
                                  );
                                  return;
                                }
                                ref
                                    .read(authViewModelProvider.notifier)
                                    .signIn(email, password);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/signup'),
                              child: const Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16181C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[900]!, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    ref.listenManual<AuthState>(authViewModelProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.error != null) {
        AppSnackBar.showError(context, next.error);
      }

      if (next.status == AuthStatus.authenticated) {
        Navigator.pushReplacementNamed(context, '/setup-profile');
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, elevation: 0),
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: Breakpoints.maxFormWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Create your account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Join Spark today and setup your space.",
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                      const SizedBox(height: 32),

                      _buildTextField(
                        controller: _nameController,
                        hintText: "Legal Name",
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _emailController,
                        hintText: "Email address",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _passwordController,
                        hintText: "Password (6+ characters)",
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onToggleVisibility: () {
                          setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      Text.rich(
                        TextSpan(
                          text: "By signing up, you agree to our ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: "Terms of Service",
                              style: TextStyle(color: Colors.blueAccent[400]),
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(color: Colors.blueAccent[400]),
                            ),
                            const TextSpan(text: "."),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      state.isLoading
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                final name = _nameController.text.trim();
                                final email = _emailController.text.trim();
                                final password =
                                    _passwordController.text.trim();

                                if (name.isEmpty ||
                                    email.isEmpty ||
                                    password.isEmpty) {
                                  AppSnackBar.showError(
                                    context,
                                    'Please fill in all fields.',
                                  );
                                  return;
                                }

                                if (password.length < 6) {
                                  AppSnackBar.showError(
                                    context,
                                    'Password must be at least 6 characters long.',
                                  );
                                  return;
                                }

                                ref
                                    .read(authViewModelProvider.notifier)
                                    .signUp(email, password, name);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent[400],
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Have an account already? ",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                "Log in",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16181C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[900]!, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          border: InputBorder.none,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
        ),
      ),
    );
  }
}
