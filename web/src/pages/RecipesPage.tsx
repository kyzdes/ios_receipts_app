import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useRecipeStore } from '@/stores/recipeStore';
import { RecipeCard } from '@/components/RecipeCard';
import { Layout } from '@/components/Layout';
import { Plus, Search, Loader2, Grid, List } from 'lucide-react';

export function RecipesPage() {
  const { recipes, isLoading, fetchRecipes, searchRecipes, toggleFavorite } = useRecipeStore();
  const [searchQuery, setSearchQuery] = useState('');
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');

  useEffect(() => {
    fetchRecipes();
  }, []);

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    if (query.trim()) {
      searchRecipes(query);
    } else {
      fetchRecipes();
    }
  };

  return (
    <Layout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center justify-between">
          <h1 className="text-3xl font-bold">My Recipes</h1>
          <Link to="/recipes/new" className="btn-primary">
            <Plus className="w-5 h-5 mr-2" />
            New Recipe
          </Link>
        </div>

        {/* Search and Filters */}
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="search"
              placeholder="Search recipes..."
              value={searchQuery}
              onChange={(e) => handleSearch(e.target.value)}
              className="input pl-10 w-full"
            />
          </div>
          <div className="flex gap-2">
            <button
              onClick={() => setViewMode('grid')}
              className={`btn ${viewMode === 'grid' ? 'btn-primary' : 'btn-secondary'}`}
            >
              <Grid className="w-5 h-5" />
            </button>
            <button
              onClick={() => setViewMode('list')}
              className={`btn ${viewMode === 'list' ? 'btn-primary' : 'btn-secondary'}`}
            >
              <List className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Recipes Grid */}
        {isLoading ? (
          <div className="flex items-center justify-center py-12">
            <Loader2 className="w-8 h-8 animate-spin text-primary-600" />
          </div>
        ) : recipes.length > 0 ? (
          <div className={viewMode === 'grid'
            ? 'grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6'
            : 'space-y-4'
          }>
            {recipes.map((recipe) => (
              <RecipeCard
                key={recipe.id}
                recipe={recipe}
                onToggleFavorite={toggleFavorite}
              />
            ))}
          </div>
        ) : (
          <div className="text-center py-12 card">
            <p className="text-gray-600 dark:text-gray-400 mb-4">
              {searchQuery ? 'No recipes found' : 'No recipes yet'}
            </p>
            {!searchQuery && (
              <Link to="/recipes/new" className="btn-primary">
                <Plus className="w-5 h-5 mr-2" />
                Create Your First Recipe
              </Link>
            )}
          </div>
        )}
      </div>
    </Layout>
  );
}
