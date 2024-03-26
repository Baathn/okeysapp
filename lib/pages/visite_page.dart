import 'package:flutter/material.dart';
import 'package:okeys/colors.dart';

class VisitePage extends StatefulWidget {
  const VisitePage({Key? key}) : super(key: key);

  @override
  State<VisitePage> createState() => _VisitePageState();
}

class _VisitePageState extends State<VisitePage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.background,
        appBar: AppBar(
          backgroundColor: Palette.background,
          title: const Text('Visiter !'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Date sélectionnée : ${selectedDate.toLocal()}".split(' ')[0]),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Sélectionner une date'),
            ),
          ],
        ),
      );
}
