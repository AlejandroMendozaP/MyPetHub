import 'package:flutter/material.dart';
import 'package:mypethub/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Cambiar Tema"),
      ),
      body: Center(
        child: SwitchListTile(
          title: Text("Activar Tema Oscuro"),
          value: themeProvider.themeMode == ThemeMode.dark,
          onChanged: (value) {
            themeProvider.toggleTheme(value); // Cambia el tema
          },
        ),
      ),
    );
  }
}
