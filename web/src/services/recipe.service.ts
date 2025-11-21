import { api } from './api';
import { Recipe, CreateRecipeRequest } from '@/types';

interface RecipesResponse {
  recipes: Recipe[];
  count: number;
}

interface RecipeResponse {
  recipe: Recipe;
  message?: string;
}

export const recipeService = {
  async getRecipes(params?: {
    limit?: number;
    offset?: number;
    sortBy?: string;
    order?: string;
  }): Promise<Recipe[]> {
    const queryParams = new URLSearchParams(params as any).toString();
    const response = await api.get<RecipesResponse>(
      `/recipes${queryParams ? `?${queryParams}` : ''}`
    );
    return response.recipes;
  },

  async getRecipe(id: string): Promise<Recipe> {
    const response = await api.get<RecipeResponse>(`/recipes/${id}`);
    return response.recipe;
  },

  async createRecipe(data: CreateRecipeRequest): Promise<Recipe> {
    const response = await api.post<RecipeResponse>('/recipes', data);
    return response.recipe;
  },

  async updateRecipe(id: string, data: Partial<CreateRecipeRequest>): Promise<Recipe> {
    const response = await api.put<RecipeResponse>(`/recipes/${id}`, data);
    return response.recipe;
  },

  async deleteRecipe(id: string): Promise<void> {
    await api.delete(`/recipes/${id}`);
  },

  async searchRecipes(query: string): Promise<Recipe[]> {
    const response = await api.get<RecipesResponse>(`/recipes/search?q=${encodeURIComponent(query)}`);
    return response.recipes;
  },

  async toggleFavorite(id: string): Promise<Recipe> {
    const response = await api.post<RecipeResponse>(`/recipes/${id}/favorite`);
    return response.recipe;
  },

  async uploadImages(recipeId: string, images: File[]): Promise<void> {
    const formData = new FormData();
    images.forEach((image) => {
      formData.append('images', image);
    });
    await api.uploadFormData(`/recipes/${recipeId}/images`, formData);
  },

  async getDailyRecipe(): Promise<Recipe> {
    const response = await api.get<{ recipe: Recipe }>('/recipe-of-the-day');
    return response.recipe;
  },
};
