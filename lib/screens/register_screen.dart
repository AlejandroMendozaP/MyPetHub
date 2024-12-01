// ignore_for_file: prefer_const_constructors

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:mypethub/firebase/email_auth.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final EmailAuth emailAuth = EmailAuth();

  Future<void> _registerUser() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();
  final confirmPassword = confirmPasswordController.text.trim();

  if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    _showMessage("Por favor, llena todos los campos.");
    return;
  }

  if (password != confirmPassword) {
    _showMessage("Las contraseñas no coinciden.");
    return;
  }

  bool isSuccess = await emailAuth.createUser(email, password);
  if (isSuccess) {
    Navigator.pushNamed(context, "/email");
  } else {
    _showMessage("Error al crear la cuenta.");
  }
}


  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20,),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  FadeInUp(
                    duration: Duration(milliseconds: 1000),
                    child: Text(
                      "Registrarse",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeInUp(
                    duration: Duration(milliseconds: 1200),
                    child: Text(
                      "Crea una cuenta, es gratis.",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  FadeInUp(
                    duration: Duration(milliseconds: 1200),
                    child: makeInput(label: "Email", controller: emailController),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 1300),
                    child: makeInput(label: "Contraseña", controller: passwordController, obscureText: true),
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 1400),
                    child: makeInput(label: "Confirma Contraseña", controller: confirmPasswordController, obscureText: true),
                  ),
                ],
              ),
              FadeInUp(
                duration: Duration(milliseconds: 1500),
                child: Container(
                  padding: EdgeInsets.only(top: 3, left: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.black),
                  ),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height: 60,
                    onPressed: _registerUser,
                    color: const Color.fromARGB(255, 255, 127, 80),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    child: Text(
                      "Registrarse",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget makeInput({label, controller, obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400,),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
            border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
