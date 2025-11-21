package com.recipemanager

import android.app.Application
import com.recipemanager.data.remote.ApiClient

class RecipeApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        ApiClient.init(this)
    }
}
