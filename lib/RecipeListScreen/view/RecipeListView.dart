import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider_demo_alpha/RecipeListScreen/viewmodel/RecipeController.dart';
import '../data/model/RecipeListModel.dart';

class RecipeListView extends StatefulWidget {
  const RecipeListView({super.key});

  @override
  State<RecipeListView> createState() => _RecipeListViewState();
}

class _RecipeListViewState extends State<RecipeListView> {
  final RecipeController ctrl = Get.find<RecipeController>();
  final ScrollController scrollCtrl = ScrollController();
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// ✅ Load only once when screen opens
    ctrl.loadInitial();

    /// ✅ Proper infinite scroll listener
    scrollCtrl.addListener(() {
      if (scrollCtrl.position.pixels >=
          scrollCtrl.position.maxScrollExtent - 100 &&
          ctrl.hasMore.value &&
          !ctrl.isLoadingMore.value &&
          !ctrl.isLoading.value) {
        ctrl.loadMore();
      }
    });
  }

  @override
  void dispose() {
    scrollCtrl.dispose();
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.orange.shade50,
        appBar: AppBar(
          backgroundColor: Colors.orange,
          elevation: 0,
          title: TextField(
            controller: searchCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textInputAction: TextInputAction.search,
            onSubmitted: (v) {
              ctrl.setQuery(v.trim());
              ctrl.loadInitial();
            },
            decoration: InputDecoration(
              hintText: 'Search Recipes...',
              hintStyle: const TextStyle(color: Colors.white70),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  ctrl.setQuery(searchCtrl.text.trim());
                  ctrl.loadInitial();
                },
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        body: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ctrl.recipes.isEmpty) {
            return const Center(
              child: Text(
                'No Recipes Found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(10),
            child: NotificationListener<ScrollEndNotification>(
              onNotification: (_) {
                /// Optional smooth trigger when scroll ends
                if (scrollCtrl.position.pixels >=
                    scrollCtrl.position.maxScrollExtent - 50 &&
                    ctrl.hasMore.value &&
                    !ctrl.isLoadingMore.value) {
                  ctrl.loadMore();
                }
                return false;
              },
              child: GridView.builder(
                controller: scrollCtrl,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: ctrl.recipes.length + (ctrl.hasMore.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == ctrl.recipes.length) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final RecipeModel recipe = ctrl.recipes[index];
                  return GestureDetector(
                    onTap: () => _showRecipeDialog(context, recipe),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.network(
                              recipe.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.orange.shade200,
                                child: const Icon(Icons.fastfood, size: 50),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              recipe.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  void _showRecipeDialog(BuildContext context, RecipeModel recipe) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade100, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          recipe.image,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: Colors.orange.shade200,
                            child: const Icon(Icons.fastfood, size: 70),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        recipe.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cuisine: ${recipe.cuisine} | ${recipe.difficulty.name}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '⏱ ${recipe.prepTimeMinutes + recipe.cookTimeMinutes} mins | 🍽 ${recipe.servings} servings',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const Divider(height: 20),
                      Wrap(
                        spacing: 6,
                        runSpacing: -6,
                        children: recipe.tags
                            .take(6)
                            .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.orange.shade200,
                        ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Instructions:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      ...recipe.instructions.take(4).map(
                            (step) => Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text('• $step'),
                        ),
                      ),
                      if (recipe.instructions.length > 4)
                        const Text('...'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}