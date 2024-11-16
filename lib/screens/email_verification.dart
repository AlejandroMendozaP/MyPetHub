import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mypethub/firebase/email_auth.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final EmailAuth emailAuth = EmailAuth();
  bool _canResend = false; // Por defecto, no se puede reenviar
  int _secondsLeft = 30; // Tiempo inicial de espera
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer(); // Iniciar el temporizador automáticamente
  }

  Future<void> _startTimer() async {
    setState(() {
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return; // Evitar reenvíos antes del tiempo establecido

    final success = await emailAuth.resendVerificationEmail();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Correo de verificación reenviado con éxito.")),
      );
      _secondsLeft = 30; // Reinicia el tiempo de espera
      _startTimer(); // Reinicia el temporizador
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo reenviar el correo de verificación.")),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el temporizador si se cierra la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
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
                      "Verificación enviada",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeInUp(
                    duration: Duration(milliseconds: 1200),
                    child: Text(
                      "Antes de iniciar sesión verifica tu correo entrando al link enviado a tu correo :)",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              FadeInUp(
                duration: Duration(milliseconds: 1200),
                child: Container(
                  height: MediaQuery.of(context).size.height / 2.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/send.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              FadeInUp(
                duration: Duration(milliseconds: 1500),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 3, left: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.black),
                      ),
                      child: MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        color: const Color.fromARGB(255, 255, 127, 80),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Text(
                          "Ir a Iniciar Sesión",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        text: "¿No te ha llegado el correo? ",
                        style: TextStyle(color: Colors.grey[700], fontSize: 15),
                        children: [
                          TextSpan(
                            text: _canResend
                                ? "Reenviar"
                                : "Reintentar en $_secondsLeft s",
                            style: TextStyle(
                              color: _canResend ? Colors.blue : Colors.grey,
                              fontWeight: FontWeight.bold,
                              decoration: _canResend
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = _canResend ? _resendEmail : null,
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
    );
  }
}
