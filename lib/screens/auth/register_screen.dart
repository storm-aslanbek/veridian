import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veridian/screens/auth/login_screen.dart';
import 'package:veridian/services/user_service.dart';
import 'package:veridian/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Контроллеры для полей
  final _surnameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _iinController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // === ФИКС: Обработка необязательного поля patronymic ===
    // Если поле Отчество пустое, отправляем null, а не пустую строку.
    final String patronymicValue = _patronymicController.text.trim();
    final String? patronymic = patronymicValue.isEmpty ? null : patronymicValue;
    // ========================================================

    final success = await context.read<UserService>().register(
      surname: _surnameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      patronymic: patronymic, // Используем явно null или значение
      iin: _iinController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (mounted) setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка регистрации. Проверьте правильность введенных данных.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Личные данные", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Фамилия', prefixIcon: Icon(Icons.person)),
                  validator: (v) => v!.isEmpty ? 'Обязательное поле' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Имя', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v!.isEmpty ? 'Обязательное поле' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _patronymicController,
                  decoration: const InputDecoration(labelText: 'Отчество (если есть)', prefixIcon: Icon(Icons.person_outline)),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _iinController,
                  decoration: const InputDecoration(labelText: 'ИИН', prefixIcon: Icon(Icons.badge)),
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  validator: (v) => v!.length != 12 ? 'ИИН должен быть 12 цифр' : null,
                ),

                const SizedBox(height: 24),
                const Text("Контакты", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Телефон', prefixIcon: Icon(Icons.phone)),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Обязательное поле' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Обязательное поле' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Пароль', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Минимум 6 символов' : null,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Зарегистрироваться'),
                  ),
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Уже есть аккаунт? Войти'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}