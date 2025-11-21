package com.recipemanager.data.model

data class User(
    val id: String,
    val email: String,
    val username: String
)

data class AuthResponse(
    val user: User,
    val accessToken: String,
    val refreshToken: String
)

data class LoginRequest(
    val email: String,
    val password: String
)

data class RegisterRequest(
    val email: String,
    val password: String,
    val username: String
)

data class Recipe(
    val id: String,
    val title: String,
    val ingredients: List<Ingredient>,
    val instructions: List<Instruction>,
    val prep_time: Int?,
    val cook_time: Int?,
    val servings: Int?,
    val difficulty: String?,
    val is_favorite: Boolean,
    val notes: String?,
    val images: List<RecipeImage>,
    val categories: List<Category>?
) {
    val totalTime: Int?
        get() = if (prep_time != null && cook_time != null) prep_time + cook_time else null

    val primaryImage: RecipeImage?
        get() = images.firstOrNull { it.isPrimary } ?: images.firstOrNull()
}

data class Ingredient(
    val name: String,
    val quantity: String,
    val unit: String?
)

data class Instruction(
    val step: Int,
    val description: String
)

data class RecipeImage(
    val id: String,
    val url: String,
    val isPrimary: Boolean
)

data class Category(
    val id: String,
    val name: String,
    val color: String?,
    val recipe_count: Int?
)

data class RecipesResponse(
    val recipes: List<Recipe>,
    val count: Int
)

data class RecipeResponse(
    val recipe: Recipe
)

data class DailyRecipeResponse(
    val recipe: Recipe
)

data class CreateRecipeRequest(
    val title: String,
    val ingredients: List<Ingredient>,
    val instructions: List<Instruction>,
    val prep_time: Int?,
    val cook_time: Int?,
    val servings: Int?,
    val difficulty: String?,
    val notes: String?
)
