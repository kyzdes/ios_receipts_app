package com.recipemanager.ui.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Timer
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.recipemanager.data.model.Recipe

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RecipeCard(
    recipe: Recipe,
    onClick: () -> Unit,
    onFavoriteClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column {
            Box {
                AsyncImage(
                    model = recipe.primaryImage?.url ?: "https://via.placeholder.com/400x200?text=Recipe",
                    contentDescription = recipe.title,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(180.dp),
                    contentScale = ContentScale.Crop
                )

                IconButton(
                    onClick = onFavoriteClick,
                    modifier = Modifier
                        .align(Alignment.TopEnd)
                        .padding(8.dp)
                ) {
                    Icon(
                        imageVector = if (recipe.is_favorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                        contentDescription = if (recipe.is_favorite) "Remove from favorites" else "Add to favorites",
                        tint = if (recipe.is_favorite) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurface
                    )
                }
            }

            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(
                    text = recipe.title,
                    style = MaterialTheme.typography.titleLarge,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )

                Spacer(modifier = Modifier.height(8.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    recipe.totalTime?.let { time ->
                        Row(
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = Icons.Default.Timer,
                                contentDescription = null,
                                modifier = Modifier.size(16.dp),
                                tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                            )
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                text = "$time min",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                            )
                        }
                    }

                    recipe.difficulty?.let { difficulty ->
                        val difficultyColor = when (difficulty.lowercase()) {
                            "easy" -> MaterialTheme.colorScheme.primary
                            "medium" -> MaterialTheme.colorScheme.tertiary
                            "hard" -> MaterialTheme.colorScheme.error
                            else -> MaterialTheme.colorScheme.onSurface
                        }

                        Text(
                            text = difficulty.uppercase(),
                            style = MaterialTheme.typography.labelSmall,
                            color = difficultyColor
                        )
                    }
                }

                if (!recipe.categories.isNullOrEmpty()) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        recipe.categories.take(2).forEach { category ->
                            SuggestionChip(
                                onClick = { },
                                label = { Text(category.name, style = MaterialTheme.typography.labelSmall) }
                            )
                        }
                    }
                }
            }
        }
    }
}
