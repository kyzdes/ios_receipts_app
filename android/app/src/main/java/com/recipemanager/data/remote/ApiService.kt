package com.recipemanager.data.remote

import com.recipemanager.data.model.*
import retrofit2.http.*

interface ApiService {
    // Auth
    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): AuthResponse

    @POST("auth/register")
    suspend fun register(@Body request: RegisterRequest): AuthResponse

    @POST("auth/logout")
    suspend fun logout()

    // Recipes
    @GET("recipes")
    suspend fun getRecipes(
        @Query("limit") limit: Int = 50,
        @Query("offset") offset: Int = 0
    ): RecipesResponse

    @GET("recipes/{id}")
    suspend fun getRecipe(@Path("id") id: String): RecipeResponse

    @POST("recipes")
    suspend fun createRecipe(@Body request: CreateRecipeRequest): RecipeResponse

    @PUT("recipes/{id}")
    suspend fun updateRecipe(
        @Path("id") id: String,
        @Body request: CreateRecipeRequest
    ): RecipeResponse

    @DELETE("recipes/{id}")
    suspend fun deleteRecipe(@Path("id") id: String)

    @POST("recipes/{id}/favorite")
    suspend fun toggleFavorite(@Path("id") id: String): RecipeResponse

    @GET("recipes/search")
    suspend fun searchRecipes(@Query("q") query: String): RecipesResponse

    // Daily Recipe
    @GET("recipe-of-the-day")
    suspend fun getDailyRecipe(): DailyRecipeResponse

    // Categories
    @GET("categories")
    suspend fun getCategories(): CategoriesResponse
}

data class CategoriesResponse(val categories: List<Category>)
