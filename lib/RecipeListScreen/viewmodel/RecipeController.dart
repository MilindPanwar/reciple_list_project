import 'package:get/get.dart';

import '../data/api/RecipeListApi.dart';
import '../data/model/RecipeListModel.dart';

class RecipeController extends GetxController {
  final RecipeListApi api;

  RecipeController(this.api);

  RxList<RecipeModel> recipes = <RecipeModel>[].obs;

  RxBool isLoading = false.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasMore = true.obs;
  RxString query = ''.obs;
  int limit = 10;
  int skip = 0;
  int total = 0;

  void setQuery(String q) {
    query.value=q;
  }

  Future<void> loadInitial() async {
    isLoading.value = true;
    skip = 0;
    hasMore.value = true;

    try {
      final data = query.value.isEmpty
          ? await api.getRecipes(limit, skip)
          : await api.searchRecipes(query.value, limit, skip);

      recipes.assignAll(data.data.recipes);
      total = data.data.total;
      skip += data.data.recipes.length;
      hasMore.value = skip < total;
    } catch (e) {
      print('Error : ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    try {
      final data = query.value.isEmpty
          ? await api.getRecipes(limit, skip)
          : await api.searchRecipes(query.value, limit, skip);
      recipes.addAll(data.data.recipes);
      skip += data.data.recipes.length;
      hasMore.value = skip < total;
    } catch (e) {
      print('Error Loading More : ${e.toString()}');
    } finally {
      isLoadingMore.value = false;
    }
  }
}
