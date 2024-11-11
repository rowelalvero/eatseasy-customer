import 'package:flutter/material.dart';
import '../../common/app_style.dart';
import '../../common/reusable_text.dart';
import '../../constants/constants.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meet Our Team',
              style: appStyle(28, Colors.teal, FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildTeamMember(
                    name: "Red M. Landicho",
                    role: "Red is our operations guru, ensuring smooth workflows.",
                    imagePath: 'assets/devs/red.jpeg',
                  ),
                  const SizedBox(height: 20),
                  _buildTeamMember(
                    name: "John Francis V. Aguilar",
                    role: "John is our technology expert, driving our technical advancements.",
                    imagePath: 'assets/devs/agui.jpeg',
                  ),
                  const SizedBox(height: 20),
                  _buildTeamMember(
                    name: "Rowel B. Alvero Jr.",
                    role: "Rowel is the creative force behind our product designs.",
                    imagePath: 'assets/devs/rowel.jpeg',
                  ),
                  const SizedBox(height: 20),
                  _buildTeamMember(
                    name: "Benedict M. Solina",
                    role: "Benedict strategizes our marketing efforts with expertise.",
                    imagePath: 'assets/devs/solina.jpg',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember({required String name, required String role, required String imagePath}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(height: 10),
          ReusableText(
            text: name,
            style: appStyle(20, kDark, FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            role,
            textAlign: TextAlign.center,
            style: appStyle(14, kGray, FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
