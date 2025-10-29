import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider_demo_alpha/RecipeListScreen/viewmodel/RecipeController.dart';

import 'RecipeListScreen/data/api/RecipeListApi.dart';
import 'RecipeListScreen/view/RecipeListView.dart';

void main() {
  final dio = Dio();
  final api = RecipeListApi(dio);
  Get.put<RecipeListApi>(api);

  Get.put<RecipeController>(RecipeController(api));
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Recipe App",
      home: RecipeListView(),
    );
  }
}


