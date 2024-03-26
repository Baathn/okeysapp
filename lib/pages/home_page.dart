// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:okeys/colors.dart';
import 'package:okeys/pages/center_page.dart';
import 'package:okeys/pages/profil_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _selectedIndex =
      0; // Index de la page sélectionnée dans la barre de navigation

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [CenterPage(), ProfilPage()],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Palette.background,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavBarItem(Icons.home, '', 0),
                _buildNavBarItem(Icons.person, '', 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthode pour construire un élément de la barre de navigation
  Widget _buildNavBarItem(IconData icon, String text, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        });
      },
      borderRadius: BorderRadius.circular(
          50), // Augmenter la taille du rayon pour une plus grande zone de détection
      child: Ink(
        padding: const EdgeInsets.all(
            20), // Augmenter la taille du padding pour une plus grande zone de détection
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
              40), // Correspond au rayon du borderRadius de InkWell
          color: _selectedIndex == index
              ? Palette.primary.withOpacity(0.3)
              : Colors.transparent,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: _selectedIndex == index ? Palette.primary : Colors.black,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
