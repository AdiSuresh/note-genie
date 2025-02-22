import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:note_maker/app/app.dart';

Future<void> main() async {
  await dotenv.load(
    fileName: '.env',
  );
  runApp(
    const NoteMaker(),
  );
}
