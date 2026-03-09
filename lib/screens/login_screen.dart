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

  final _formKey = GlobalKey<FormState>();
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

  // FORMULARIO DE LOGIN VALIDADO

  Form(
  key: _formKey,
  child: Column(
    children: [

      // EMAIL
      TextFormField(
        controller: emailController,
        decoration: const InputDecoration(
          labelText: 'Email',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Introduce tu email';
          }

          final emailRegex =
              RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

          if (!emailRegex.hasMatch(value)) {
            return 'Email no válido';
          }

          return null;
        },
      ),

      const SizedBox(height: 16),

      // PASSWORD 

      TextFormField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Contraseña',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Introduce tu contraseña';
          }

          if (value.length < 6) {
            return 'Mínimo 6 caracteres';
          }

          return null;
        },
      ),

      

      const SizedBox(height: 20),

      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _login();
          }
        },
        child: const Text("Iniciar sesión"),
      ),
    ],
  ),
);


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
