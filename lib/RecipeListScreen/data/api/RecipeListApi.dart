
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import '../model/RecipeListModel.dart';

part 'RecipeListApi.g.dart';

@RestApi(baseUrl: "https://dummyjson.com/recipes")
abstract class RecipeListApi {
  factory RecipeListApi(Dio dio, {String baseUrl}) = _RecipeListApi;

  @GET('')
  Future<HttpResponse <RecipeListModel>> getRecipes(
      @Query("limit") int limit, @Query("skip") int skip);

  @GET('/search')
  Future<HttpResponse <RecipeListModel>> searchRecipes(@Query("q") String query,
      @Query("limit") int limit, @Query("skip") int skip);
}
