import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mypethub/firebase/database.dart';
import 'package:mypethub/screens/edit_profile_screen.dart';
import 'package:mypethub/screens/theme_switcher.dart';

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
                Icon(leadingIcon,),
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
                    Colors.deepPurple[800]!,
                    Colors.deepPurpleAccent,
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
                        "Interests",
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
                      MaterialPageRoute(builder: (context) => EditProfileScreen()),
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
                      MaterialPageRoute(builder: (context) => ThemeSwitcher()));
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
