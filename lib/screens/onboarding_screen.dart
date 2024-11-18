import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:mypethub/firebase/database.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Color kDarkBlueColor = const Color.fromARGB(255, 222, 49, 99);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  final List<String> _allInterests = [];
  final List<String> _selectedInterests = [];
  final Database db = Database();

  @override
  void initState() {
    super.initState();
    _populateUserInfo();
    _loadInterests();
  }

  Future<void> _populateUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user.displayName != null) {
        nameController.text = user.displayName!;
      }
    } else {
      print("No hay usuario autenticado.");
    }
  }

  Future<void> _loadInterests() async {
    final interests = await db.fetchInterests();
    setState(() {
      _allInterests.addAll(interests);
    });
  }

  Future<void> _saveUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userInfo = {
        'name': nameController.text,
        'phone': phoneController.text,
        'state': stateController.text,
        'city': cityController.text,
        'interests': _selectedInterests,
        'photo': user.photoURL ?? null, // Si photoURL es null, se inserta null
      };
      await db.insertUser(user.uid, userInfo);
    } else {
      print("No hay usuario autenticado.");
    }
  }


  Widget makeInput({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400)),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400)),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnBoardingSlider(
      finishButtonText: 'Iniciar',
      onFinish: () async {
        await _saveUserInfo();
        print("Datos guardados correctamente.");
        Navigator.pushNamed(context, "/principal");
      },
      finishButtonStyle: FinishButtonStyle(
        backgroundColor: kDarkBlueColor,
      ),
      skipTextButton: Text(
        'Skip',
        style: TextStyle(
          fontSize: 16,
          color: kDarkBlueColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      controllerColor: kDarkBlueColor,
      totalPage: 3,
      headerBackgroundColor: Colors.white,
      pageBackgroundColor: Colors.white,
      background: [
        Image.asset('assets/background2.png', height: 400),
        Image.asset('assets/background4.png', height: 2000),
        Image.asset('assets/background3.png', height: 400),
      ],
      speed: 1.8,
      pageBodies: [
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 480),
              Text(
                'MyPetHub',
                style: TextStyle(
                    color: kDarkBlueColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              const Text(
                'La app donde puedes administrar a tus mejores amigos',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black26,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SingleChildScrollView(
            // Solución para evitar overflow
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  'Cuentanos más sobre ti',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: kDarkBlueColor,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                makeInput(label: "Nombre Completo", controller: nameController),
                makeInput(label: "Teléfono", controller: phoneController),
                makeInput(
                    label: "Estado",
                    controller: stateController), // Campo nuevo
                makeInput(
                    label: "Municipio",
                    controller: cityController), // Campo nuevo
                const SizedBox(height: 10),
                Text(
                  'Selecciona tus intereses',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                _allInterests.isEmpty
                    ? CircularProgressIndicator()
                    : Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _allInterests.map((interest) {
                          final isSelected =
                              _selectedInterests.contains(interest);
                          return ChoiceChip(
                            label: Text(
                              interest,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: kDarkBlueColor,
                            backgroundColor: Colors.grey.shade300,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInterests.add(interest);
                                } else {
                                  _selectedInterests.remove(interest);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const SizedBox(height: 480),
              Text(
                'Start now!',
                style: TextStyle(
                    color: kDarkBlueColor,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              const Text(
                'Where everything is possible and customize your onboarding.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black26,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
