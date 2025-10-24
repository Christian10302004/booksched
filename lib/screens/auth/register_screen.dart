import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final AuthService _auth = AuthService();

  final String _role = 'user'; // Default role is always user
  bool _loading = false;

  void register() async {
    setState(() => _loading = true);
    String? res = await _auth.registerUser(
        _email.text.trim(), _password.text.trim(), _name.text.trim(), _role);
    setState(() => _loading = false);

    if (!mounted) return;

    if (res == "success") {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Registration successful!")));
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res ?? "An unknown error occurred")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/my_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: _name,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: "Full Name",
                            labelStyle: TextStyle(color: Colors.white))),
                    TextField(
                        controller: _email,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.white))),
                    TextField(
                        controller: _password,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.white))),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading ? null : register,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text("Register"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
