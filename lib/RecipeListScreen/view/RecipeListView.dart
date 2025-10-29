import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider_demo_alpha/RecipeListScreen/viewmodel/RecipeController.dart';

import '../data/model/RecipeListModel.dart';

class RecipeListView extends StatelessWidget {
  RecipeListView({super.key});

  final RecipeController ctrl = Get.find<RecipeController>();
  final ScrollController scrollCtrl = ScrollController();

  final TextEditingController searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ctrl.loadInitial();
    scrollCtrl.addListener(() {
      if (scrollCtrl.position.pixels >
              scrollCtrl.position.maxScrollExtent - 200 &&
          ctrl.hasMore.value &&
          !ctrl.isLoadingMore.value) {
        ctrl.loadMore();
      }
    });
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.orange.shade100,
        appBar: AppBar(
          title: TextField(
            controller: searchCtrl,
            textInputAction: TextInputAction.search,
            onSubmitted: (v) => ctrl.setQuery(v),
            decoration: InputDecoration(
              hintText: 'Search Recipes',
              border: InputBorder.none,
            ),
          ),
        ),
        body: Obx(
          () {
            if (ctrl.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (ctrl.recipes.isEmpty) {
              return Text('No Recipes Available');
            }
            return GridView.builder(

              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,

              ),
              itemCount: ctrl.recipes.length +(ctrl.hasMore.value ? 1: 0),
              itemBuilder: (BuildContext context, int index) {
                if(index ==ctrl.recipes.length){
                  return CircularProgressIndicator();
                }
                final RecipeModel recipe = ctrl.recipes[index];
                return Container(
                  child: Text('${recipe.name}'),
                );

              },

            );
          },
        ),
      ),
    );
  }
}
