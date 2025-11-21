package com.recipemanager.data.repository

import com.recipemanager.data.model.*
import com.recipemanager.data.remote.ApiClient
import com.recipemanager.data.remote.ApiService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class RecipeRepository(private val apiService: ApiService = ApiClient.apiService) {

    suspend fun login(email: String, password: String): Result<AuthResponse> = withContext(Dispatchers.IO) {
        try {
            val response = apiService.login(LoginRequest(email, password))
            ApiClient.saveTokens(response.accessToken, response.refreshToken)
            Result.success(response)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun register(email: String, password: String, username: String): Result<AuthResponse> =
        withContext(Dispatchers.IO) {
            try {
                val response = apiService.register(RegisterRequest(email, password, username))
                ApiClient.saveTokens(response.accessToken, response.refreshToken)
                Result.success(response)
            } catch (e: Exception) {
                Result.failure(e)
            }
        }

    suspend fun logout() = withContext(Dispatchers.IO) {
        try {
            apiService.logout()
            ApiClient.clearTokens()
        } catch (e: Exception) {
            ApiClient.clearTokens()
        }
    }

    suspend fun getRecipes(): Result<List<Recipe>> = withContext(Dispatchers.IO) {
        try {
            val response = apiService.getRecipes()
            Result.success(response.recipes)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getRecipe(id: String): Result<Recipe> = withContext(Dispatchers.IO) {
        try {
            val response = apiService.getRecipe(id)
            Result.success(response.recipe)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun createRecipe(request: CreateRecipeRequest): Result<Recipe> = withContext(Dispatchers.IO) {
        try {
            val response = apiService.createRecipe(request)
            Result.success(response.recipe)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun deleteRecipe(id: String): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            apiService.deleteRecipe(id)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun toggleFavorite(id: String): Result<Recipe> = withContext(Dispatchers.IO) {
        try {
            val response = apiService.toggleFavorite(id)
            Result.success(response.recipe)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun searchRecipes(query: String): Result<List<Recipe>> = withContext(Dispatchers.IO) {
        try {
            val response = apiService.searchRecipes(query)
            Result.success(response.recipes)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getDailyRecipe(): Result<Recipe> = withContext(Dispatchers.IO) {
        try {
            val response = apiService.getDailyRecipe()
            Result.success(response.recipe)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getCategories(): Result<List<Category>> = withContext(Dispatchers.IO) {
        try {
            val response = apiService.getCategories()
            Result.success(response.categories)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun isAuthenticated(): Boolean {
        return ApiClient.getAccessToken() != null
    }
}
