package com.recipemanager.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.recipemanager.data.model.Recipe
import com.recipemanager.viewmodel.RecipeDetailState
import com.recipemanager.viewmodel.RecipeViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RecipeDetailScreen(
    recipeId: String,
    recipeViewModel: RecipeViewModel,
    onNavigateBack: () -> Unit
) {
    val recipeDetailState by recipeViewModel.recipeDetailState.collectAsState()
    var showDeleteDialog by remember { mutableStateOf(false) }

    LaunchedEffect(recipeId) {
        recipeViewModel.loadRecipe(recipeId)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Recipe Details") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                    navigationIconContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    ) { paddingValues ->
        when (val state = recipeDetailState) {
            is RecipeDetailState.Loading -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }
            is RecipeDetailState.Success -> {
                RecipeDetailContent(
                    recipe = state.recipe,
                    onFavoriteClick = { recipeViewModel.toggleFavorite(recipeId) },
                    onDeleteClick = { showDeleteDialog = true },
                    modifier = Modifier.padding(paddingValues)
                )

                if (showDeleteDialog) {
                    AlertDialog(
                        onDismissRequest = { showDeleteDialog = false },
                        title = { Text("Delete Recipe") },
                        text = { Text("Are you sure you want to delete this recipe? This action cannot be undone.") },
                        confirmButton = {
                            TextButton(
                                onClick = {
                                    recipeViewModel.deleteRecipe(recipeId)
                                    showDeleteDialog = false
                                    onNavigateBack()
                                }
                            ) {
                                Text("Delete", color = MaterialTheme.colorScheme.error)
                            }
                        },
                        dismissButton = {
                            TextButton(onClick = { showDeleteDialog = false }) {
                                Text("Cancel")
                            }
                        }
                    )
                }
            }
            is RecipeDetailState.Error -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        Text(
                            text = state.message,
                            color = MaterialTheme.colorScheme.error,
                            style = MaterialTheme.typography.bodyLarge
                        )
                        Button(onClick = { recipeViewModel.loadRecipe(recipeId) }) {
                            Text("Retry")
                        }
                    }
                }
            }
            else -> {}
        }
    }
}

@Composable
fun RecipeDetailContent(
    recipe: Recipe,
    onFavoriteClick: () -> Unit,
    onDeleteClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(bottom = 16.dp)
    ) {
        // Header Image
        item {
            Box {
                AsyncImage(
                    model = recipe.primaryImage?.url ?: "https://via.placeholder.com/400x300?text=Recipe",
                    contentDescription = recipe.title,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(250.dp),
                    contentScale = ContentScale.Crop
                )
            }
        }

        // Title and Actions
        item {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = recipe.title,
                        style = MaterialTheme.typography.headlineMedium,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.weight(1f)
                    )
                    Row {
                        IconButton(onClick = onFavoriteClick) {
                            Icon(
                                imageVector = if (recipe.is_favorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                                contentDescription = if (recipe.is_favorite) "Remove from favorites" else "Add to favorites",
                                tint = if (recipe.is_favorite) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurface
                            )
                        }
                        IconButton(onClick = onDeleteClick) {
                            Icon(
                                imageVector = Icons.Default.Delete,
                                contentDescription = "Delete recipe",
                                tint = MaterialTheme.colorScheme.error
                            )
                        }
                    }
                }
            }
        }

        // Recipe Info Cards
        item {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                recipe.prep_time?.let { prepTime ->
                    InfoCard(
                        title = "Prep",
                        value = "$prepTime min",
                        icon = Icons.Default.Timer,
                        modifier = Modifier.weight(1f)
                    )
                }
                recipe.cook_time?.let { cookTime ->
                    InfoCard(
                        title = "Cook",
                        value = "$cookTime min",
                        icon = Icons.Default.Fireplace,
                        modifier = Modifier.weight(1f)
                    )
                }
                recipe.servings?.let { servings ->
                    InfoCard(
                        title = "Servings",
                        value = servings.toString(),
                        icon = Icons.Default.Restaurant,
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        }

        // Categories
        if (!recipe.categories.isNullOrEmpty()) {
            item {
                Spacer(modifier = Modifier.height(16.dp))
                Row(
                    modifier = Modifier.padding(horizontal = 16.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    recipe.categories.forEach { category ->
                        AssistChip(
                            onClick = { },
                            label = { Text(category.name) }
                        )
                    }
                }
            }
        }

        // Ingredients Section
        item {
            Spacer(modifier = Modifier.height(24.dp))
            Text(
                text = "Ingredients",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(horizontal = 16.dp)
            )
            Spacer(modifier = Modifier.height(8.dp))
        }

        items(recipe.ingredients) { ingredient ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.CheckCircleOutline,
                        contentDescription = null,
                        modifier = Modifier.size(20.dp),
                        tint = MaterialTheme.colorScheme.primary
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Text(
                        text = "${ingredient.quantity} ${ingredient.unit ?: ""} ${ingredient.name}".trim(),
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
            }
        }

        // Instructions Section
        item {
            Spacer(modifier = Modifier.height(24.dp))
            Text(
                text = "Instructions",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(horizontal = 16.dp)
            )
            Spacer(modifier = Modifier.height(8.dp))
        }

        itemsIndexed(recipe.instructions) { index, instruction ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 4.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(12.dp)
                ) {
                    Surface(
                        shape = MaterialTheme.shapes.small,
                        color = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(28.dp)
                    ) {
                        Box(contentAlignment = Alignment.Center) {
                            Text(
                                text = "${instruction.step}",
                                style = MaterialTheme.typography.labelMedium,
                                color = MaterialTheme.colorScheme.onPrimary,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                    Spacer(modifier = Modifier.width(12.dp))
                    Text(
                        text = instruction.description,
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.weight(1f)
                    )
                }
            }
        }

        // Notes Section
        if (!recipe.notes.isNullOrBlank()) {
            item {
                Spacer(modifier = Modifier.height(24.dp))
                Text(
                    text = "Notes",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(horizontal = 16.dp)
                )
                Spacer(modifier = Modifier.height(8.dp))
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceVariant
                    )
                ) {
                    Text(
                        text = recipe.notes,
                        style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.padding(16.dp)
                    )
                }
            }
        }
    }
}

@Composable
fun InfoCard(
    title: String,
    value: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onPrimaryContainer
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = value,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onPrimaryContainer
            )
            Text(
                text = title,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onPrimaryContainer
            )
        }
    }
}
