package com.recipemanager.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.recipemanager.data.model.CreateRecipeRequest
import com.recipemanager.data.model.Ingredient
import com.recipemanager.data.model.Instruction
import com.recipemanager.viewmodel.RecipeViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AddRecipeScreen(
    recipeViewModel: RecipeViewModel,
    onNavigateBack: () -> Unit
) {
    var title by remember { mutableStateOf("") }
    var prepTime by remember { mutableStateOf("") }
    var cookTime by remember { mutableStateOf("") }
    var servings by remember { mutableStateOf("") }
    var difficulty by remember { mutableStateOf("Easy") }
    var notes by remember { mutableStateOf("") }

    var ingredients by remember { mutableStateOf(listOf(IngredientInput("", "", ""))) }
    var instructions by remember { mutableStateOf(listOf(InstructionInput(1, ""))) }

    var showDifficultyMenu by remember { mutableStateOf(false) }
    var isSubmitting by remember { mutableStateOf(false) }

    val difficulties = listOf("Easy", "Medium", "Hard")

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Add New Recipe") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    IconButton(
                        onClick = {
                            if (title.isNotBlank() && ingredients.any { it.name.isNotBlank() } &&
                                instructions.any { it.description.isNotBlank() }) {
                                isSubmitting = true

                                val request = CreateRecipeRequest(
                                    title = title,
                                    ingredients = ingredients
                                        .filter { it.name.isNotBlank() }
                                        .map { Ingredient(it.name, it.quantity, it.unit) },
                                    instructions = instructions
                                        .filter { it.description.isNotBlank() }
                                        .mapIndexed { index, inst ->
                                            Instruction(index + 1, inst.description)
                                        },
                                    prep_time = prepTime.toIntOrNull(),
                                    cook_time = cookTime.toIntOrNull(),
                                    servings = servings.toIntOrNull(),
                                    difficulty = difficulty,
                                    notes = notes.ifBlank { null }
                                )

                                recipeViewModel.createRecipe(request) {
                                    isSubmitting = false
                                    onNavigateBack()
                                }
                            }
                        },
                        enabled = !isSubmitting && title.isNotBlank() &&
                                 ingredients.any { it.name.isNotBlank() } &&
                                 instructions.any { it.description.isNotBlank() }
                    ) {
                        if (isSubmitting) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(24.dp),
                                color = MaterialTheme.colorScheme.onPrimary
                            )
                        } else {
                            Icon(Icons.Default.Check, contentDescription = "Save")
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                    navigationIconContentColor = MaterialTheme.colorScheme.onPrimary,
                    actionIconContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Title
            item {
                OutlinedTextField(
                    value = title,
                    onValueChange = { title = it },
                    label = { Text("Recipe Title *") },
                    singleLine = true,
                    modifier = Modifier.fillMaxWidth()
                )
            }

            // Recipe Info Row
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = prepTime,
                        onValueChange = { prepTime = it },
                        label = { Text("Prep (min)") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        singleLine = true,
                        modifier = Modifier.weight(1f)
                    )
                    OutlinedTextField(
                        value = cookTime,
                        onValueChange = { cookTime = it },
                        label = { Text("Cook (min)") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        singleLine = true,
                        modifier = Modifier.weight(1f)
                    )
                    OutlinedTextField(
                        value = servings,
                        onValueChange = { servings = it },
                        label = { Text("Servings") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        singleLine = true,
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            // Difficulty
            item {
                ExposedDropdownMenuBox(
                    expanded = showDifficultyMenu,
                    onExpandedChange = { showDifficultyMenu = !showDifficultyMenu }
                ) {
                    OutlinedTextField(
                        value = difficulty,
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("Difficulty") },
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = showDifficultyMenu) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .menuAnchor()
                    )
                    ExposedDropdownMenu(
                        expanded = showDifficultyMenu,
                        onDismissRequest = { showDifficultyMenu = false }
                    ) {
                        difficulties.forEach { diff ->
                            DropdownMenuItem(
                                text = { Text(diff) },
                                onClick = {
                                    difficulty = diff
                                    showDifficultyMenu = false
                                }
                            )
                        }
                    }
                }
            }

            // Ingredients Section
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Ingredients *",
                        style = MaterialTheme.typography.titleMedium
                    )
                    IconButton(onClick = {
                        ingredients = ingredients + IngredientInput("", "", "")
                    }) {
                        Icon(Icons.Default.Add, contentDescription = "Add ingredient")
                    }
                }
            }

            itemsIndexed(ingredients) { index, ingredient ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceVariant
                    )
                ) {
                    Column(
                        modifier = Modifier.padding(12.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text("Ingredient ${index + 1}", style = MaterialTheme.typography.labelLarge)
                            if (ingredients.size > 1) {
                                IconButton(
                                    onClick = { ingredients = ingredients.filterIndexed { i, _ -> i != index } },
                                    modifier = Modifier.size(24.dp)
                                ) {
                                    Icon(Icons.Default.Close, contentDescription = "Remove", modifier = Modifier.size(18.dp))
                                }
                            }
                        }
                        OutlinedTextField(
                            value = ingredient.name,
                            onValueChange = {
                                ingredients = ingredients.toMutableList().also { it[index] = ingredient.copy(name = it) }
                            },
                            label = { Text("Name") },
                            singleLine = true,
                            modifier = Modifier.fillMaxWidth()
                        )
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            OutlinedTextField(
                                value = ingredient.quantity,
                                onValueChange = {
                                    ingredients = ingredients.toMutableList().also { it[index] = ingredient.copy(quantity = it) }
                                },
                                label = { Text("Quantity") },
                                singleLine = true,
                                modifier = Modifier.weight(1f)
                            )
                            OutlinedTextField(
                                value = ingredient.unit,
                                onValueChange = {
                                    ingredients = ingredients.toMutableList().also { it[index] = ingredient.copy(unit = it) }
                                },
                                label = { Text("Unit") },
                                singleLine = true,
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }
                }
            }

            // Instructions Section
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Instructions *",
                        style = MaterialTheme.typography.titleMedium
                    )
                    IconButton(onClick = {
                        instructions = instructions + InstructionInput(instructions.size + 1, "")
                    }) {
                        Icon(Icons.Default.Add, contentDescription = "Add instruction")
                    }
                }
            }

            itemsIndexed(instructions) { index, instruction ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.surfaceVariant
                    )
                ) {
                    Column(
                        modifier = Modifier.padding(12.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text("Step ${index + 1}", style = MaterialTheme.typography.labelLarge)
                            if (instructions.size > 1) {
                                IconButton(
                                    onClick = {
                                        instructions = instructions.filterIndexed { i, _ -> i != index }
                                            .mapIndexed { i, inst -> inst.copy(step = i + 1) }
                                    },
                                    modifier = Modifier.size(24.dp)
                                ) {
                                    Icon(Icons.Default.Close, contentDescription = "Remove", modifier = Modifier.size(18.dp))
                                }
                            }
                        }
                        OutlinedTextField(
                            value = instruction.description,
                            onValueChange = {
                                instructions = instructions.toMutableList().also {
                                    it[index] = instruction.copy(description = it)
                                }
                            },
                            label = { Text("Description") },
                            minLines = 2,
                            modifier = Modifier.fillMaxWidth()
                        )
                    }
                }
            }

            // Notes
            item {
                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    label = { Text("Notes (optional)") },
                    minLines = 3,
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }
    }
}

data class IngredientInput(
    val name: String,
    val quantity: String,
    val unit: String
)

data class InstructionInput(
    val step: Int,
    val description: String
)
