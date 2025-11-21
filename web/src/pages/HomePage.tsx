import { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useRecipeStore } from '@/stores/recipeStore';
import { RecipeCard } from '@/components/RecipeCard';
import { Plus, Camera, Sparkles, Loader2 } from 'lucide-react';
import { Layout } from '@/components/Layout';

export function HomePage() {
  const { recipes, dailyRecipe, isLoading, fetchRecipes, fetchDailyRecipe } = useRecipeStore();

  useEffect(() => {
    fetchRecipes();
    fetchDailyRecipe();
  }, []);

  return (
    <Layout>
      <div className="space-y-8">
        {/* Hero Section */}
        <div className="relative overflow-hidden rounded-2xl bg-gradient-to-r from-primary-600 to-primary-700 p-8 text-white">
          <div className="relative z-10">
            <h1 className="text-3xl sm:text-4xl font-bold mb-4">
              Welcome to Recipe Manager
            </h1>
            <p className="text-primary-100 mb-6 max-w-2xl">
              Create, organize, and discover amazing recipes. Your personal cookbook in the cloud.
            </p>
            <div className="flex flex-wrap gap-3">
              <Link to="/recipes/new" className="btn bg-white text-primary-600 hover:bg-primary-50">
                <Plus className="w-5 h-5 mr-2" />
                New Recipe
              </Link>
            </div>
          </div>
          <div className="absolute right-0 top-0 h-full w-1/3 opacity-10">
            <Sparkles className="absolute right-8 top-8 w-16 h-16 animate-pulse" />
            <Camera className="absolute right-24 bottom-12 w-12 h-12 animate-pulse delay-150" />
          </div>
        </div>

        {/* Recipe of the Day */}
        {dailyRecipe && (
          <section>
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-2xl font-bold">Recipe of the Day</h2>
            </div>
            <div className="max-w-2xl">
              <RecipeCard recipe={dailyRecipe} />
            </div>
          </section>
        )}

        {/* Recent Recipes */}
        <section>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-2xl font-bold">Recent Recipes</h2>
            <Link to="/recipes" className="text-primary-600 hover:text-primary-700 font-medium">
              View All →
            </Link>
          </div>

          {isLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="w-8 h-8 animate-spin text-primary-600" />
            </div>
          ) : recipes.length > 0 ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {recipes.slice(0, 8).map((recipe) => (
                <RecipeCard key={recipe.id} recipe={recipe} />
              ))}
            </div>
          ) : (
            <div className="text-center py-12 card">
              <p className="text-gray-600 dark:text-gray-400 mb-4">
                No recipes yet. Create your first one!
              </p>
              <Link to="/recipes/new" className="btn-primary">
                <Plus className="w-5 h-5 mr-2" />
                Create Recipe
              </Link>
            </div>
          )}
        </section>
      </div>
    </Layout>
  );
}
