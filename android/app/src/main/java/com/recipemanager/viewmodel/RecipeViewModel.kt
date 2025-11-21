package com.recipemanager.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.recipemanager.data.model.Category
import com.recipemanager.data.model.CreateRecipeRequest
import com.recipemanager.data.model.Recipe
import com.recipemanager.data.repository.RecipeRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed class RecipeListState {
    object Idle : RecipeListState()
    object Loading : RecipeListState()
    data class Success(val recipes: List<Recipe>) : RecipeListState()
    data class Error(val message: String) : RecipeListState()
}

sealed class RecipeDetailState {
    object Idle : RecipeDetailState()
    object Loading : RecipeDetailState()
    data class Success(val recipe: Recipe) : RecipeDetailState()
    data class Error(val message: String) : RecipeDetailState()
}

class RecipeViewModel(
    private val repository: RecipeRepository = RecipeRepository()
) : ViewModel() {

    private val _recipesState = MutableStateFlow<RecipeListState>(RecipeListState.Idle)
    val recipesState: StateFlow<RecipeListState> = _recipesState.asStateFlow()

    private val _recipeDetailState = MutableStateFlow<RecipeDetailState>(RecipeDetailState.Idle)
    val recipeDetailState: StateFlow<RecipeDetailState> = _recipeDetailState.asStateFlow()

    private val _dailyRecipeState = MutableStateFlow<RecipeDetailState>(RecipeDetailState.Idle)
    val dailyRecipeState: StateFlow<RecipeDetailState> = _dailyRecipeState.asStateFlow()

    private val _categoriesState = MutableStateFlow<List<Category>>(emptyList())
    val categoriesState: StateFlow<List<Category>> = _categoriesState.asStateFlow()

    private val _searchQuery = MutableStateFlow("")
    val searchQuery: StateFlow<String> = _searchQuery.asStateFlow()

    init {
        loadRecipes()
        loadCategories()
        loadDailyRecipe()
    }

    fun loadRecipes() {
        viewModelScope.launch {
            _recipesState.value = RecipeListState.Loading

            val result = repository.getRecipes()

            result.fold(
                onSuccess = { recipes ->
                    _recipesState.value = RecipeListState.Success(recipes)
                },
                onFailure = { error ->
                    _recipesState.value = RecipeListState.Error(
                        error.message ?: "Failed to load recipes"
                    )
                }
            )
        }
    }

    fun loadRecipe(id: String) {
        viewModelScope.launch {
            _recipeDetailState.value = RecipeDetailState.Loading

            val result = repository.getRecipe(id)

            result.fold(
                onSuccess = { recipe ->
                    _recipeDetailState.value = RecipeDetailState.Success(recipe)
                },
                onFailure = { error ->
                    _recipeDetailState.value = RecipeDetailState.Error(
                        error.message ?: "Failed to load recipe"
                    )
                }
            )
        }
    }

    fun loadDailyRecipe() {
        viewModelScope.launch {
            _dailyRecipeState.value = RecipeDetailState.Loading

            val result = repository.getDailyRecipe()

            result.fold(
                onSuccess = { recipe ->
                    _dailyRecipeState.value = RecipeDetailState.Success(recipe)
                },
                onFailure = { error ->
                    _dailyRecipeState.value = RecipeDetailState.Error(
                        error.message ?: "Failed to load daily recipe"
                    )
                }
            )
        }
    }

    fun searchRecipes(query: String) {
        _searchQuery.value = query

        if (query.isBlank()) {
            loadRecipes()
            return
        }

        viewModelScope.launch {
            _recipesState.value = RecipeListState.Loading

            val result = repository.searchRecipes(query)

            result.fold(
                onSuccess = { recipes ->
                    _recipesState.value = RecipeListState.Success(recipes)
                },
                onFailure = { error ->
                    _recipesState.value = RecipeListState.Error(
                        error.message ?: "Search failed"
                    )
                }
            )
        }
    }

    fun createRecipe(request: CreateRecipeRequest, onSuccess: () -> Unit) {
        viewModelScope.launch {
            val result = repository.createRecipe(request)

            result.fold(
                onSuccess = {
                    loadRecipes()
                    onSuccess()
                },
                onFailure = { error ->
                    _recipesState.value = RecipeListState.Error(
                        error.message ?: "Failed to create recipe"
                    )
                }
            )
        }
    }

    fun deleteRecipe(id: String) {
        viewModelScope.launch {
            val result = repository.deleteRecipe(id)

            result.fold(
                onSuccess = {
                    loadRecipes()
                },
                onFailure = { error ->
                    _recipesState.value = RecipeListState.Error(
                        error.message ?: "Failed to delete recipe"
                    )
                }
            )
        }
    }

    fun toggleFavorite(id: String) {
        viewModelScope.launch {
            val result = repository.toggleFavorite(id)

            result.fold(
                onSuccess = { updatedRecipe ->
                    // Update the recipe in the list
                    val currentState = _recipesState.value
                    if (currentState is RecipeListState.Success) {
                        val updatedList = currentState.recipes.map { recipe ->
                            if (recipe.id == id) updatedRecipe else recipe
                        }
                        _recipesState.value = RecipeListState.Success(updatedList)
                    }

                    // Update detail if showing this recipe
                    val detailState = _recipeDetailState.value
                    if (detailState is RecipeDetailState.Success && detailState.recipe.id == id) {
                        _recipeDetailState.value = RecipeDetailState.Success(updatedRecipe)
                    }
                },
                onFailure = { error ->
                    // Handle error silently or show a toast
                }
            )
        }
    }

    private fun loadCategories() {
        viewModelScope.launch {
            val result = repository.getCategories()

            result.fold(
                onSuccess = { categories ->
                    _categoriesState.value = categories
                },
                onFailure = {
                    _categoriesState.value = emptyList()
                }
            )
        }
    }

    fun resetDetailState() {
        _recipeDetailState.value = RecipeDetailState.Idle
    }
}
