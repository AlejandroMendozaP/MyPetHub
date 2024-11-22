import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mypethub/screens/lost_screen.dart';
import 'package:mypethub/screens/my_pets_screen.dart';
import 'package:mypethub/screens/profile_screen.dart';

class PrincipalScreen extends StatefulWidget {
  @override
  _PrincipalScreenState createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _selectedIndex = 0;

  // Lista de widgets para cada apartado
  final List<Widget> _screens = [
    MyPetsScreen(),
    AdoptarScreen(),
    LostScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Muestra la pantalla correspondiente
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(80, 158, 158, 158))
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: GNav(
            gap: 8,
            activeColor: Colors.white,
            color: Colors.grey[600],
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            duration: Duration(milliseconds: 400),
            tabBackgroundColor: const Color.fromARGB(255, 222, 49, 99),
            tabs: [
              GButton(
                icon: Icons.pets,
                text: 'Mascotas',
              ),
              GButton(
                icon: Icons.house_siding_rounded,
                text: 'Adoptar',
              ),
              GButton(
                icon: Icons.location_searching,
                text: 'Perdidos',
              ),
              GButton(
                icon: Icons.person,
                text: 'Perfil',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index; // Cambiar índice al seleccionar un tab
              });
            },
          ),
        ),
      ),
    );
  }
}

class AdoptarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("Adoptar", style: TextStyle(fontSize: 24)),
    );
  }
}
