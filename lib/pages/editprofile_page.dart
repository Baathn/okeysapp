import 'package:flutter/material.dart';
import 'package:okeys/colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Palette.secondary),
        backgroundColor: Palette.background,
        title: Text(
          'Edit profile',
          style: TextStyle(color: Palette.text),
        ),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            maxLength: 160,
            controller: _bioController,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Enter your bio',
              fillColor: Palette.background,
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(
          width: 250,
        ),
      ]));
}
