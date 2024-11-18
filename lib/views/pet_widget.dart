import 'package:flutter/material.dart';
import 'package:mypethub/models/pet.dart';
import 'package:mypethub/screens/pet_detail_screen.dart';

class PetWidget extends StatelessWidget {

  final Pet pet;
  final int index;

  PetWidget({required this.pet, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PetDetailScreen(pet: pet)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20)
          ),
          border: Border.all(
            color: const Color.fromARGB(255, 230, 230, 230),
            width: 1,
          ),
        ),
        margin: EdgeInsets.only(right: index != null ? 16 : 0, left: index == 0 ? 16 : 0, bottom: 16, top: 10),
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            Expanded(
              child: Stack(
                children: [

                  /*Hero(
                    tag: pet.imageUrl,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(pet.imageUrl),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),*/

                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          /*color: pet.favorite ? Colors.red[400] : Colors.white,
                        ),
                        child: Icon(
                          Icons.favorite,
                          size: 16,
                          color: pet.favorite ? Colors.white : Colors.grey[300],*/
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  Text(
                    pet.name,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  Row(
                    children: [

                      Icon(
                        Icons.location_on,
                        color: Colors.grey[600],
                        size: 18,
                      ),

                      SizedBox(
                        width: 4,
                      ),

                    ],
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}