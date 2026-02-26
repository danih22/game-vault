import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:game_vault/screens/register_screen.dart';
import 'package:game_vault/screens/home_screen.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

@override
void dispose(){

  emailController.dispose();
  passwordController.dispose();
  super.dispose();
}


Future <void> _login() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  try{
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
              debugPrint('Login Correcto!!');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
      builder: (_) =>  HomeScreen(),
  ),
);



  } catch (e) {
    debugPrint('Error al iniciar sesión: $e');
  }
  

  if(!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text ('Error al iniciar sesión: '),
      backgroundColor: Colors.red, 
    ),
  );







}

@override
Widget build(BuildContext context){
  return Scaffold(
    appBar: AppBar(
      title: const Text('Game Vault Login'),
    ),
    body:Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
          ),
        ),
  
  const SizedBox(height: 16.0),
  TextField(
    controller: passwordController,
    obscureText: true,
    decoration: const InputDecoration(
      labelText: 'Contraseña',
    ),
  ),
  const SizedBox(height: 24.0),

  ElevatedButton(
    onPressed: _login, 
    child: const Text ('Iniciar Sesión'),
  ),

  TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  },
  child: const Text('¿No tienes cuenta? Regístrate'),
),

  ],
    ),

  ),
    );
}


}
