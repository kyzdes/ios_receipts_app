package com.recipemanager.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.recipemanager.ui.screens.*
import com.recipemanager.viewmodel.AuthViewModel
import com.recipemanager.viewmodel.RecipeViewModel

sealed class Screen(val route: String) {
    object Login : Screen("login")
    object Register : Screen("register")
    object Home : Screen("home")
    object RecipeDetail : Screen("recipe/{recipeId}") {
        fun createRoute(recipeId: String) = "recipe/$recipeId"
    }
    object Search : Screen("search")
    object AddRecipe : Screen("add_recipe")
}

@Composable
fun RecipeManagerNavigation(
    navController: NavHostController,
    authViewModel: AuthViewModel = viewModel(),
    recipeViewModel: RecipeViewModel = viewModel()
) {
    val isAuthenticated by authViewModel.isAuthenticated.collectAsState()

    val startDestination = if (isAuthenticated) Screen.Home.route else Screen.Login.route

    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        // Authentication Screens
        composable(Screen.Login.route) {
            LoginScreen(
                authViewModel = authViewModel,
                onNavigateToRegister = {
                    navController.navigate(Screen.Register.route)
                },
                onLoginSuccess = {
                    navController.navigate(Screen.Home.route) {
                        popUpTo(Screen.Login.route) { inclusive = true }
                    }
                }
            )
        }

        composable(Screen.Register.route) {
            RegisterScreen(
                authViewModel = authViewModel,
                onNavigateToLogin = {
                    navController.popBackStack()
                },
                onRegisterSuccess = {
                    navController.navigate(Screen.Home.route) {
                        popUpTo(Screen.Register.route) { inclusive = true }
                        popUpTo(Screen.Login.route) { inclusive = true }
                    }
                }
            )
        }

        // Main App Screens
        composable(Screen.Home.route) {
            HomeScreen(
                authViewModel = authViewModel,
                recipeViewModel = recipeViewModel,
                onRecipeClick = { recipeId ->
                    navController.navigate(Screen.RecipeDetail.createRoute(recipeId))
                },
                onNavigateToSearch = {
                    navController.navigate(Screen.Search.route)
                },
                onNavigateToAdd = {
                    navController.navigate(Screen.AddRecipe.route)
                },
                onLogout = {
                    navController.navigate(Screen.Login.route) {
                        popUpTo(0) { inclusive = true }
                    }
                }
            )
        }

        composable(
            route = Screen.RecipeDetail.route,
            arguments = listOf(
                navArgument("recipeId") { type = NavType.StringType }
            )
        ) { backStackEntry ->
            val recipeId = backStackEntry.arguments?.getString("recipeId") ?: return@composable
            RecipeDetailScreen(
                recipeId = recipeId,
                recipeViewModel = recipeViewModel,
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }

        composable(Screen.Search.route) {
            SearchScreen(
                recipeViewModel = recipeViewModel,
                onRecipeClick = { recipeId ->
                    navController.navigate(Screen.RecipeDetail.createRoute(recipeId))
                },
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }

        composable(Screen.AddRecipe.route) {
            AddRecipeScreen(
                recipeViewModel = recipeViewModel,
                onNavigateBack = {
                    navController.popBackStack()
                }
            )
        }
    }
}
