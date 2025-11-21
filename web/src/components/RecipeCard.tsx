import { Recipe } from '@/types';
import { Clock, Users, Heart } from 'lucide-react';
import { Link } from 'react-router-dom';

interface RecipeCardProps {
  recipe: Recipe;
  onToggleFavorite?: (id: string) => void;
}

export function RecipeCard({ recipe, onToggleFavorite }: RecipeCardProps) {
  const totalTime = (recipe.prep_time || 0) + (recipe.cook_time || 0);
  const primaryImage = recipe.images?.find(img => img.isPrimary) || recipe.images?.[0];

  return (
    <div className="card group overflow-hidden hover:shadow-lg transition-all duration-300">
      <Link to={`/recipes/${recipe.id}`}>
        <div className="relative aspect-video overflow-hidden bg-gray-200 dark:bg-gray-800">
          {primaryImage ? (
            <img
              src={primaryImage.url}
              alt={recipe.title}
              className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center text-gray-400">
              <Clock className="w-12 h-12" />
            </div>
          )}
          {recipe.is_favorite && (
            <div className="absolute top-2 right-2 p-2 rounded-full bg-white/90 dark:bg-gray-900/90">
              <Heart className="w-4 h-4 fill-red-500 text-red-500" />
            </div>
          )}
        </div>
      </Link>

      <div className="p-4">
        <Link to={`/recipes/${recipe.id}`}>
          <h3 className="font-semibold text-lg line-clamp-2 mb-2 group-hover:text-primary-600 dark:group-hover:text-primary-400 transition-colors">
            {recipe.title}
          </h3>
        </Link>

        <div className="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-400">
          {totalTime > 0 && (
            <div className="flex items-center gap-1">
              <Clock className="w-4 h-4" />
              <span>{totalTime}m</span>
            </div>
          )}
          {recipe.servings && (
            <div className="flex items-center gap-1">
              <Users className="w-4 h-4" />
              <span>{recipe.servings}</span>
            </div>
          )}
          {recipe.difficulty && (
            <span className="px-2 py-0.5 rounded-full bg-gray-100 dark:bg-gray-800 text-xs font-medium capitalize">
              {recipe.difficulty}
            </span>
          )}
        </div>
      </div>
    </div>
  );
}
