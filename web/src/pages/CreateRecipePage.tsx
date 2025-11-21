import { useState, FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';
import { useRecipeStore } from '@/stores/recipeStore';
import { Layout } from '@/components/Layout';
import { Plus, Minus, ArrowLeft, Loader2 } from 'lucide-react';
import { Link } from 'react-router-dom';
import toast from 'react-hot-toast';
import { Ingredient, Instruction, CreateRecipeRequest } from '@/types';

export function CreateRecipePage() {
  const navigate = useNavigate();
  const { createRecipe, isLoading } = useRecipeStore();

  const [title, setTitle] = useState('');
  const [ingredients, setIngredients] = useState<Ingredient[]>([{ name: '', quantity: '', unit: '' }]);
  const [instructions, setInstructions] = useState<Instruction[]>([{ step: 1, description: '' }]);
  const [prepTime, setPrepTime] = useState('');
  const [cookTime, setCookTime] = useState('');
  const [servings, setServings] = useState('');
  const [difficulty, setDifficulty] = useState<'easy' | 'medium' | 'hard'>('easy');
  const [notes, setNotes] = useState('');

  const addIngredient = () => {
    setIngredients([...ingredients, { name: '', quantity: '', unit: '' }]);
  };

  const removeIngredient = (index: number) => {
    setIngredients(ingredients.filter((_, i) => i !== index));
  };

  const updateIngredient = (index: number, field: keyof Ingredient, value: string) => {
    const updated = [...ingredients];
    updated[index] = { ...updated[index], [field]: value };
    setIngredients(updated);
  };

  const addInstruction = () => {
    setInstructions([...instructions, { step: instructions.length + 1, description: '' }]);
  };

  const removeInstruction = (index: number) => {
    const updated = instructions.filter((_, i) => i !== index);
    setInstructions(updated.map((inst, i) => ({ ...inst, step: i + 1 })));
  };

  const updateInstruction = (index: number, description: string) => {
    const updated = [...instructions];
    updated[index] = { ...updated[index], description };
    setInstructions(updated);
  };

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();

    const data: CreateRecipeRequest = {
      title,
      ingredients: ingredients.filter(i => i.name && i.quantity),
      instructions: instructions.filter(i => i.description),
      prep_time: prepTime ? parseInt(prepTime) : undefined,
      cook_time: cookTime ? parseInt(cookTime) : undefined,
      servings: servings ? parseInt(servings) : undefined,
      difficulty,
      notes: notes || undefined,
    };

    try {
      const recipe = await createRecipe(data);
      toast.success('Recipe created successfully!');
      navigate(`/recipes/${recipe.id}`);
    } catch (error) {
      toast.error('Failed to create recipe');
    }
  };

  return (
    <Layout>
      <div className="max-w-3xl mx-auto">
        <Link to="/recipes" className="inline-flex items-center text-gray-600 hover:text-gray-900 dark:text-gray-400 dark:hover:text-gray-100 mb-6">
          <ArrowLeft className="w-5 h-5 mr-2" />
          Back
        </Link>

        <h1 className="text-3xl font-bold mb-6">Create New Recipe</h1>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Basic Info */}
          <div className="card p-6 space-y-4">
            <h2 className="text-xl font-semibold">Basic Information</h2>

            <div>
              <label className="block text-sm font-medium mb-2">Recipe Title *</label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="input w-full"
                required
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-medium mb-2">Prep Time (min)</label>
                <input
                  type="number"
                  value={prepTime}
                  onChange={(e) => setPrepTime(e.target.value)}
                  className="input w-full"
                  min="0"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Cook Time (min)</label>
                <input
                  type="number"
                  value={cookTime}
                  onChange={(e) => setCookTime(e.target.value)}
                  className="input w-full"
                  min="0"
                />
              </div>
              <div>
                <label className="block text-sm font-medium mb-2">Servings</label>
                <input
                  type="number"
                  value={servings}
                  onChange={(e) => setServings(e.target.value)}
                  className="input w-full"
                  min="1"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium mb-2">Difficulty</label>
              <select
                value={difficulty}
                onChange={(e) => setDifficulty(e.target.value as any)}
                className="input w-full"
              >
                <option value="easy">Easy</option>
                <option value="medium">Medium</option>
                <option value="hard">Hard</option>
              </select>
            </div>
          </div>

          {/* Ingredients */}
          <div className="card p-6 space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold">Ingredients</h2>
              <button type="button" onClick={addIngredient} className="btn-ghost">
                <Plus className="w-5 h-5" />
              </button>
            </div>

            {ingredients.map((ingredient, index) => (
              <div key={index} className="flex gap-2">
                <input
                  type="text"
                  placeholder="Quantity"
                  value={ingredient.quantity}
                  onChange={(e) => updateIngredient(index, 'quantity', e.target.value)}
                  className="input w-20"
                />
                <input
                  type="text"
                  placeholder="Unit"
                  value={ingredient.unit}
                  onChange={(e) => updateIngredient(index, 'unit', e.target.value)}
                  className="input w-24"
                />
                <input
                  type="text"
                  placeholder="Ingredient name"
                  value={ingredient.name}
                  onChange={(e) => updateIngredient(index, 'name', e.target.value)}
                  className="input flex-1"
                />
                {ingredients.length > 1 && (
                  <button
                    type="button"
                    onClick={() => removeIngredient(index)}
                    className="btn-ghost text-red-600"
                  >
                    <Minus className="w-5 h-5" />
                  </button>
                )}
              </div>
            ))}
          </div>

          {/* Instructions */}
          <div className="card p-6 space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold">Instructions</h2>
              <button type="button" onClick={addInstruction} className="btn-ghost">
                <Plus className="w-5 h-5" />
              </button>
            </div>

            {instructions.map((instruction, index) => (
              <div key={index} className="flex gap-2">
                <span className="flex-shrink-0 w-8 h-8 rounded-full bg-primary-600 text-white flex items-center justify-center font-bold mt-1">
                  {instruction.step}
                </span>
                <textarea
                  value={instruction.description}
                  onChange={(e) => updateInstruction(index, e.target.value)}
                  placeholder="Describe this step..."
                  className="input flex-1 min-h-[80px]"
                  rows={3}
                />
                {instructions.length > 1 && (
                  <button
                    type="button"
                    onClick={() => removeInstruction(index)}
                    className="btn-ghost text-red-600"
                  >
                    <Minus className="w-5 h-5" />
                  </button>
                )}
              </div>
            ))}
          </div>

          {/* Notes */}
          <div className="card p-6">
            <label className="block text-sm font-medium mb-2">Notes</label>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Any additional notes or tips..."
              className="input w-full min-h-[100px]"
              rows={4}
            />
          </div>

          {/* Submit */}
          <div className="flex gap-4">
            <button
              type="submit"
              disabled={isLoading || !title}
              className="btn-primary flex-1"
            >
              {isLoading ? (
                <>
                  <Loader2 className="w-5 h-5 animate-spin mr-2" />
                  Creating...
                </>
              ) : (
                'Create Recipe'
              )}
            </button>
            <Link to="/recipes" className="btn-secondary">
              Cancel
            </Link>
          </div>
        </form>
      </div>
    </Layout>
  );
}
