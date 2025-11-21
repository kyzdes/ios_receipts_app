import { create } from 'zustand';
import { Recipe, CreateRecipeRequest } from '@/types';
import { recipeService } from '@/services/recipe.service';

interface RecipeState {
  recipes: Recipe[];
  selectedRecipe: Recipe | null;
  dailyRecipe: Recipe | null;
  isLoading: boolean;
  error: string | null;
  searchQuery: string;

  fetchRecipes: () => Promise<void>;
  fetchRecipe: (id: string) => Promise<void>;
  fetchDailyRecipe: () => Promise<void>;
  createRecipe: (data: CreateRecipeRequest) => Promise<Recipe>;
  updateRecipe: (id: string, data: Partial<CreateRecipeRequest>) => Promise<void>;
  deleteRecipe: (id: string) => Promise<void>;
  searchRecipes: (query: string) => Promise<void>;
  toggleFavorite: (id: string) => Promise<void>;
  setSearchQuery: (query: string) => void;
  clearError: () => void;
}

export const useRecipeStore = create<RecipeState>((set, get) => ({
  recipes: [],
  selectedRecipe: null,
  dailyRecipe: null,
  isLoading: false,
  error: null,
  searchQuery: '',

  fetchRecipes: async () => {
    set({ isLoading: true, error: null });
    try {
      const recipes = await recipeService.getRecipes();
      set({ recipes, isLoading: false });
    } catch (error: any) {
      set({
        error: error.response?.data?.error || 'Failed to fetch recipes',
        isLoading: false
      });
    }
  },

  fetchRecipe: async (id) => {
    set({ isLoading: true, error: null });
    try {
      const recipe = await recipeService.getRecipe(id);
      set({ selectedRecipe: recipe, isLoading: false });
    } catch (error: any) {
      set({
        error: error.response?.data?.error || 'Failed to fetch recipe',
        isLoading: false
      });
    }
  },

  fetchDailyRecipe: async () => {
    set({ isLoading: true, error: null });
    try {
      const recipe = await recipeService.getDailyRecipe();
      set({ dailyRecipe: recipe, isLoading: false });
    } catch (error: any) {
      set({
        error: error.response?.data?.error || 'Failed to fetch daily recipe',
        isLoading: false
      });
    }
  },

  createRecipe: async (data) => {
    set({ isLoading: true, error: null });
    try {
      const recipe = await recipeService.createRecipe(data);
      set((state) => ({
        recipes: [recipe, ...state.recipes],
        selectedRecipe: recipe,
        isLoading: false
      }));
      return recipe;
    } catch (error: any) {
      set({
        error: error.response?.data?.error || 'Failed to create recipe',
        isLoading: false
      });
      throw error;
    }
  },

  updateRecipe: async (id, data) => {
    set({ isLoading: true, error: null });
    try {
      const recipe = await recipeService.updateRecipe(id, data);
      set((state) => ({
        recipes: state.recipes.map((r) => r.id === id ? recipe : r),
        selectedRecipe: recipe,
        isLoading: false
      }));
    } catch (error: any) {
      set({
        error: error.response?.data?.error || 'Failed to update recipe',
        isLoading: false
      });
      throw error;
    }
  },

  deleteRecipe: async (id) => {
    set({ isLoading: true, error: null });
    try {
      await recipeService.deleteRecipe(id);
      set((state) => ({
        recipes: state.recipes.filter((r) => r.id !== id),
        selectedRecipe: null,
        isLoading: false
      }));
    } catch (error: any) {
      set({
        error: error.response?.data?.error || 'Failed to delete recipe',
        isLoading: false
      });
      throw error;
    }
  },

  searchRecipes: async (query) => {
    if (!query.trim()) {
      get().fetchRecipes();
      return;
    }

    set({ isLoading: true, error: null });
    try {
      const recipes = await recipeService.searchRecipes(query);
      set({ recipes, isLoading: false });
    } catch (error: any) {
      set({
        error: error.response?.data?.error || 'Search failed',
        isLoading: false
      });
    }
  },

  toggleFavorite: async (id) => {
    try {
      const recipe = await recipeService.toggleFavorite(id);
      set((state) => ({
        recipes: state.recipes.map((r) => r.id === id ? recipe : r),
        selectedRecipe: state.selectedRecipe?.id === id ? recipe : state.selectedRecipe
      }));
    } catch (error: any) {
      set({ error: error.response?.data?.error || 'Failed to toggle favorite' });
    }
  },

  setSearchQuery: (query) => set({ searchQuery: query }),
  clearError: () => set({ error: null }),
}));
