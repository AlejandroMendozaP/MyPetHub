import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mypethub/screens/edit_profile_screen.dart';
import 'package:mypethub/screens/theme_switcher.dart';
import 'package:http/http.dart' as http;
import 'package:mypethub/views/web_view_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        String? photoUrl = currentUser.photoURL;

        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
          profileImageUrl = photoUrl;
        });
      }
    } catch (e) {
      print("Error al cargar datos del usuario: $e");
    }
  }

  Widget _buildOptionButton(
      String title, IconData leadingIcon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  leadingIcon,
                ),
                SizedBox(width: 15),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  void _showSubscriptionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Opciones de Suscripción",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.credit_card),
                title: Text("Stripe"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.paypal),
                title: Text("PayPal"),
                onTap: () {
                  _handlePayPalPayment();
                  Navigator.pop(context);
                }
              ),
              ListTile(
                leading: Icon(Icons.money),
                title: Text("Pago en Efectivo"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handlePayPalPayment() async {
  const clientId =
      'AZUbyyYqEKuDKOaSitfw4_DH8i2_F7Qdzfu2ZkvGoLGGCNzOfBR6hxiN6YGRFyGesPcJd18RCcAoygUD';
  const secret =
      'ELNC5xACQGulVvfa2oc7kp6P8rrM8iE3ote2bUeayxoUvG6gJNyMiTemEJ_IxY-TpAP5MRPSjPF1yqsb';

  final response = await http.post(
    Uri.parse('https://api-m.sandbox.paypal.com/v1/oauth2/token'),
    headers: {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$secret'))}',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {'grant_type': 'client_credentials'},
  );

  if (response.statusCode == 200) {
    final accessToken = json.decode(response.body)['access_token'];

    final paymentResponse = await http.post(
      Uri.parse('https://api-m.sandbox.paypal.com/v1/payments/payment'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        "intent": "sale",
        "payer": {"payment_method": "paypal"},
        "transactions": [
          {
            "amount": {"total": "10.00", "currency": "MXN"},
            "description": "Suscripción Premium"
          }
        ],
        "redirect_urls": {
          "return_url": "https://example.com/success",
          "cancel_url": "https://example.com/cancel"
        }
      }),
    );

    if (paymentResponse.statusCode == 201) {
      final links = json.decode(paymentResponse.body)['links'];
      final approvalUrl =
          links.firstWhere((link) => link['rel'] == 'approval_url')['href'];

      // Redirigir al WebView para mostrar PayPal dentro de la app
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayPalWebView(url: approvalUrl),
        ),
      );
    } else {
      print("Error al crear el pago: ${paymentResponse.body}");
    }
  } else {
    print("Error al obtener el token de acceso: ${response.body}");
  }
}


  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height:
                  MediaQuery.of(context).size.height * 0.4, // Altura responsiva
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 222, 49, 99),
                    const Color.fromARGB(255, 255, 138, 138),
                  ],
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 110.0),
                  CircleAvatar(
                    radius: 65.0,
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(userData!['photo'])
                        : AssetImage('assets/default_avatar.jpg')
                            as ImageProvider,
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    userData!['name'] ?? 'Nombre no disponible',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    "${userData!['state']}, ${userData!['city']}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 222, 49, 99),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => _showSubscriptionOptions(context),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: Text(
                  "Premium",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            Center(
              child: Card(
                margin: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
                child: Container(
                  width: 310.0,
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Intereses",
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Divider(color: Colors.grey[300]),
                      ...List.generate(
                        (userData!['interests'] as List<dynamic>).length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.blueAccent[400],
                              ),
                              SizedBox(width: 10),
                              Text(
                                userData!['interests'][index],
                                style: TextStyle(fontSize: 15.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 60),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOptionButton(
                  "Configurar perfil",
                  Icons.settings,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfileScreen()),
                    ).then((_) {
                      // Refresca la lista después de registrar una nueva mascota
                      setState(() {
                        _loadUserData();
                      });
                    });
                  },
                ),
                _buildOptionButton(
                  "Modificar tema",
                  Icons.color_lens,
                  () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ThemeSwitcher()));
                  },
                ),
                _buildOptionButton(
                  "Cerrar sesión",
                  Icons.logout,
                  () async {
                    try {
                      await _auth.signOut();
                      Navigator.of(context).pushReplacementNamed(
                          '/welcome'); // Reemplaza con la ruta de tu pantalla de inicio de sesión
                    } catch (e) {
                      print("Error al cerrar sesión: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error al cerrar sesión: $e")),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
