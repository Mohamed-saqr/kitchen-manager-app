import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ChefsManagementScreen extends StatelessWidget {
  const ChefsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("chefs_screen.title".tr())),
      body: Center(child: Text("chefs_screen.list".tr())),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.person_add),
      ),
    );
  }
}