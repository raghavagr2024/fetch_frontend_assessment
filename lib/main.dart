import 'package:fetch/dog_gallery.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
//Basic setup for the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DogGallery()
    );
  }
}




