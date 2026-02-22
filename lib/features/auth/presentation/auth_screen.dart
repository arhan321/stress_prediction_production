import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/services/auth_api_service.dart';
import '../../home/presentation/main_navigation.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register controllers
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerCompanyController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  bool _isLoginLoading = false;
  bool _isRegisterLoading = false;
  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerCompanyController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // body: SafeArea(
      //   child: SingleChildScrollView(
      //     child: Padding(
      //       padding: const EdgeInsets.all(24.0),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           const SizedBox(height: 40),
      //           // LOGO
      //           Center(
      //             child: Container(
      //               width: 140, // ukuran lingkaran lebih besar
      //               height: 140,
      //               decoration: BoxDecoration(
      //                 shape: BoxShape.circle,
      //                 color: Colors.white,
      //                 boxShadow: [
      //                   BoxShadow(
      //                     color: Colors.black12,
      //                     blurRadius: 10,
      //                     spreadRadius: 2,
      //                   ),
      //                 ],
      //               ),
      //               child: ClipOval(
      //                 child: Image.asset(
      //                   'asset/images/LWS.png',
      //                   fit: BoxFit.cover,
      //                 ),
      //               ),
      //             ),
      //           ),
      //           const SizedBox(height: 32),

      //           // Header
      //           _buildHeader(),

      //           const SizedBox(height: 32),

      //           // Tab Bar
      //           _buildTabBar(),

      //           const SizedBox(height: 24),

      //           // Tab Content
      //           SizedBox(
      //             height: MediaQuery.of(context).size.height * 0.6,
      //             child: TabBarView(
      //               controller: _tabController,
      //               children: [
      //                 _buildLoginForm(),
      //                 _buildRegisterForm(),
      //               ],
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Logo (tidak usah di-scroll)
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'asset/images/LWS.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildHeader(),

              const SizedBox(height: 32),

              _buildTabBar(),

              const SizedBox(height: 16),

              // IMPORTANT: Expanded agar TabBarView mengisi ruang tersisa
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB LOGIN (scrollable)
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _buildLoginForm(),
                    ),

                    // TAB REGISTER (scrollable)
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: _buildRegisterForm(),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Login untuk mengakses dashboard analisis stres',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _tabController.animateTo(0);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _tabController.index == 0
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: _tabController.index == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _tabController.index == 0
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _tabController.animateTo(1);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _tabController.index == 1
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: _tabController.index == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Daftar',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _tabController.index == 1
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Email Field
          _buildTextField(
            controller: _loginEmailController,
            label: 'Email',
            hint: 'nama@perusahaan.com',
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),

          const SizedBox(height: 16),

          // Password Field
          _buildTextField(
            controller: _loginPasswordController,
            label: 'Password',
            obscureText: _obscureLoginPassword,
            validator: _validatePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureLoginPassword = !_obscureLoginPassword;
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Fitur lupa password akan segera tersedia')),
                );
              },
              child: const Text(
                'Lupa password?',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Login Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoginLoading ? null : _handleLogin,
              child: _isLoginLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),

          // Form Title
          Text(
            'Buat Akun',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),

          const SizedBox(height: 4),

          Text(
            'Daftar untuk mulai menganalisis pola stres karyawan',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),

          const SizedBox(height: 24),

          // Name Field
          _buildTextField(
            controller: _registerNameController,
            label: 'Nama Lengkap',
            validator: _validateName,
          ),

          const SizedBox(height: 16),

          // Email Field
          _buildTextField(
            controller: _registerEmailController,
            label: 'Email',
            hint: 'nama@perusahaan.com',
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),

          const SizedBox(height: 16),

          // Company Field (Optional)
          _buildTextField(
            controller: _registerCompanyController,
            label: 'Organisasi/Perusahaan (Opsional)',
          ),

          const SizedBox(height: 16),

          // Password Field
          _buildTextField(
            controller: _registerPasswordController,
            label: 'Password',
            hint: 'Minimal 8 karakter',
            obscureText: _obscureRegisterPassword,
            validator: _validatePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegisterPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppTheme.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscureRegisterPassword = !_obscureRegisterPassword;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Register Button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isRegisterLoading ? null : _handleRegister,
              child: _isRegisterLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Daftar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
    return null;
  }

  void _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() {
      _isLoginLoading = true;
    });

    try {
      // Call real login API
      final result = await AuthApiService.loginUser(
        usernameOrEmail: _loginEmailController.text,
        password: _loginPasswordController.text,
      );

      if (mounted) {
        if (result['success'] == true) {
          // Update app state with real user data
          context.read<AppStateProvider>().setUser({
            'id': result['user']['id'],
            'username': result['user']['username'],
            'email': result['user']['email'],
            'full_name': result['user']['full_name'],
            'role': result['user']['role'],
            'department': result['user']['department'],
            'token': result['token'],
            'session_token': result['session_token'],
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${result['message']}'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to main app
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainNavigation(),
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Login gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoginLoading = false;
        });
      }
    }
  }

  void _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    setState(() {
      _isRegisterLoading = true;
    });

    try {
      // Generate username from email (before @ symbol)
      final username = _registerEmailController.text.split('@')[0];

      // Call real registration API
      final result = await AuthApiService.registerUser(
        username: username,
        email: _registerEmailController.text,
        password: _registerPasswordController.text,
        fullName: _registerNameController.text,
        department: _registerCompanyController.text.isNotEmpty
            ? _registerCompanyController.text
            : null,
      );

      if (mounted) {
        if (result['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${result['message']}'),
              backgroundColor: Colors.green,
            ),
          );

          // Clear registration form
          _registerNameController.clear();
          _registerEmailController.clear();
          _registerCompanyController.clear();
          _registerPasswordController.clear();

          // Switch to login tab
          _tabController.animateTo(0);

          // Show info to login
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('📝 Silakan login dengan akun yang baru dibuat'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          });
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Pendaftaran gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegisterLoading = false;
        });
      }
    }
  }
}
