import { useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { useRecipeStore } from '@/stores/recipeStore';
import { Layout } from '@/components/Layout';
import { Clock, Users, Heart, Edit, Trash2, ArrowLeft, Loader2 } from 'lucide-react';
import toast from 'react-hot-toast';

export function RecipeDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { selectedRecipe, isLoading, fetchRecipe, deleteRecipe, toggleFavorite } = useRecipeStore();

  useEffect(() => {
    if (id) {
      fetchRecipe(id);
    }
  }, [id]);

  const handleDelete = async () => {
    if (!id || !confirm('Are you sure you want to delete this recipe?')) return;

    try {
      await deleteRecipe(id);
      toast.success('Recipe deleted');
      navigate('/recipes');
    } catch (error) {
      toast.error('Failed to delete recipe');
    }
  };

  const handleToggleFavorite = async () => {
    if (id) {
      await toggleFavorite(id);
    }
  };

  if (isLoading || !selectedRecipe) {
    return (
      <Layout>
        <div className="flex items-center justify-center py-12">
          <Loader2 className="w-8 h-8 animate-spin text-primary-600" />
        </div>
      </Layout>
    );
  }

  const totalTime = (selectedRecipe.prep_time || 0) + (selectedRecipe.cook_time || 0);
  const primaryImage = selectedRecipe.images?.find(img => img.isPrimary) || selectedRecipe.images?.[0];

  return (
    <Layout>
      <div className="max-w-4xl mx-auto space-y-6">
        {/* Back Button */}
        <Link to="/recipes" className="inline-flex items-center text-gray-600 hover:text-gray-900 dark:text-gray-400 dark:hover:text-gray-100">
          <ArrowLeft className="w-5 h-5 mr-2" />
          Back to Recipes
        </Link>

        {/* Header Image */}
        {primaryImage && (
          <div className="relative aspect-video rounded-2xl overflow-hidden bg-gray-200 dark:bg-gray-800">
            <img
              src={primaryImage.url}
              alt={selectedRecipe.title}
              className="w-full h-full object-cover"
            />
          </div>
        )}

        {/* Recipe Header */}
        <div className="flex items-start justify-between gap-4">
          <div className="flex-1">
            <h1 className="text-4xl font-bold mb-4">{selectedRecipe.title}</h1>
            <div className="flex flex-wrap items-center gap-4 text-gray-600 dark:text-gray-400">
              {totalTime > 0 && (
                <div className="flex items-center gap-2">
                  <Clock className="w-5 h-5" />
                  <span>{totalTime} minutes</span>
                </div>
              )}
              {selectedRecipe.servings && (
                <div className="flex items-center gap-2">
                  <Users className="w-5 h-5" />
                  <span>{selectedRecipe.servings} servings</span>
                </div>
              )}
              {selectedRecipe.difficulty && (
                <span className="px-3 py-1 rounded-full bg-gray-100 dark:bg-gray-800 font-medium capitalize">
                  {selectedRecipe.difficulty}
                </span>
              )}
            </div>
          </div>

          {/* Actions */}
          <div className="flex gap-2">
            <button
              onClick={handleToggleFavorite}
              className={`btn ${selectedRecipe.is_favorite ? 'text-red-500' : 'btn-ghost'}`}
            >
              <Heart className={`w-5 h-5 ${selectedRecipe.is_favorite ? 'fill-current' : ''}`} />
            </button>
            <Link to={`/recipes/${id}/edit`} className="btn-secondary">
              <Edit className="w-5 h-5" />
            </Link>
            <button onClick={handleDelete} className="btn text-red-600 hover:bg-red-50 dark:hover:bg-red-900/10">
              <Trash2 className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Ingredients */}
        <div className="card p-6">
          <h2 className="text-2xl font-bold mb-4">Ingredients</h2>
          <ul className="space-y-2">
            {selectedRecipe.ingredients.map((ingredient, index) => (
              <li key={index} className="flex items-start gap-3">
                <span className="w-2 h-2 rounded-full bg-primary-600 mt-2" />
                <span>
                  {ingredient.quantity} {ingredient.unit} {ingredient.name}
                </span>
              </li>
            ))}
          </ul>
        </div>

        {/* Instructions */}
        <div className="card p-6">
          <h2 className="text-2xl font-bold mb-4">Instructions</h2>
          <ol className="space-y-4">
            {selectedRecipe.instructions.map((instruction) => (
              <li key={instruction.step} className="flex gap-4">
                <span className="flex-shrink-0 w-8 h-8 rounded-full bg-primary-600 text-white flex items-center justify-center font-bold">
                  {instruction.step}
                </span>
                <p className="flex-1 pt-1">{instruction.description}</p>
              </li>
            ))}
          </ol>
        </div>

        {/* Notes */}
        {selectedRecipe.notes && (
          <div className="card p-6">
            <h2 className="text-2xl font-bold mb-4">Notes</h2>
            <p className="text-gray-600 dark:text-gray-400">{selectedRecipe.notes}</p>
          </div>
        )}
      </div>
    </Layout>
  );
}
