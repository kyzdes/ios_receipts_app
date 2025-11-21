package com.recipemanager.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.recipemanager.data.model.User
import com.recipemanager.data.repository.RecipeRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed class AuthState {
    object Idle : AuthState()
    object Loading : AuthState()
    data class Success(val user: User) : AuthState()
    data class Error(val message: String) : AuthState()
}

class AuthViewModel(
    private val repository: RecipeRepository = RecipeRepository()
) : ViewModel() {

    private val _authState = MutableStateFlow<AuthState>(AuthState.Idle)
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    private val _isAuthenticated = MutableStateFlow(false)
    val isAuthenticated: StateFlow<Boolean> = _isAuthenticated.asStateFlow()

    init {
        checkAuthentication()
    }

    private fun checkAuthentication() {
        viewModelScope.launch {
            _isAuthenticated.value = repository.isAuthenticated()
        }
    }

    fun login(email: String, password: String) {
        viewModelScope.launch {
            _authState.value = AuthState.Loading

            val result = repository.login(email, password)

            result.fold(
                onSuccess = { response ->
                    _authState.value = AuthState.Success(response.user)
                    _isAuthenticated.value = true
                },
                onFailure = { error ->
                    _authState.value = AuthState.Error(
                        error.message ?: "Login failed. Please try again."
                    )
                }
            )
        }
    }

    fun register(email: String, password: String, username: String) {
        viewModelScope.launch {
            _authState.value = AuthState.Loading

            val result = repository.register(email, password, username)

            result.fold(
                onSuccess = { response ->
                    _authState.value = AuthState.Success(response.user)
                    _isAuthenticated.value = true
                },
                onFailure = { error ->
                    _authState.value = AuthState.Error(
                        error.message ?: "Registration failed. Please try again."
                    )
                }
            )
        }
    }

    fun logout() {
        viewModelScope.launch {
            repository.logout()
            _isAuthenticated.value = false
            _authState.value = AuthState.Idle
        }
    }

    fun resetAuthState() {
        _authState.value = AuthState.Idle
    }
}
