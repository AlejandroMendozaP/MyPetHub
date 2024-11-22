import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mypethub/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class ThemeSwitcher extends StatelessWidget {
  final List<String> fonts = [
    'Roboto',
    'Lobster',
    'Pacifico',
    'Open Sans',
    'Montserrat'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return Text(
              "Configuración",
              style: GoogleFonts.getFont(themeProvider.fontFamily),
            );
          },
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return Text(
                  "Personaliza tu experiencia",
                  style: GoogleFonts.getFont(
                    themeProvider.fontFamily,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Cambiar Tema
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return Text(
                          "Modo de Tema",
                          style: GoogleFonts.getFont(
                            themeProvider.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return SwitchListTile(
                          title: Text(
                            themeProvider.themeMode == ThemeMode.dark
                                ? "Tema Oscuro Activado"
                                : "Tema Claro Activado",
                            style: GoogleFonts.getFont(
                              themeProvider.fontFamily,
                              fontSize: 16,
                            ),
                          ),
                          value: themeProvider.themeMode == ThemeMode.dark,
                          activeColor: Theme.of(context).colorScheme.primary,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Cambiar Fuente
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) {
                          return Text(
                            "Seleccionar Fuente",
                            style: GoogleFonts.getFont(
                              themeProvider.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Consumer<ThemeProvider>(
                          builder: (context, themeProvider, _) {
                            return ListView.builder(
                              itemCount: fonts.length,
                              itemBuilder: (context, index) {
                                final font = fonts[index];
                                return ListTile(
                                  leading: Icon(Icons.text_fields_rounded),
                                  title: Text(
                                    font,
                                    style: TextStyle(
                                      fontFamily: GoogleFonts.getFont(font)
                                          .fontFamily,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onTap: () {
                                    themeProvider.changeFont(font);
                                  },
                                  trailing: themeProvider.fontFamily == font
                                      ? Icon(Icons.check, color: Colors.green)
                                      : null,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
