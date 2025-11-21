export interface User {
  id: string;
  email: string;
  username: string;
  created_at?: string;
}

export interface AuthResponse {
  user: User;
  accessToken: string;
  refreshToken: string;
  message?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  username: string;
}

export interface Ingredient {
  id?: string;
  name: string;
  quantity: string;
  unit?: string;
}

export interface Instruction {
  id?: string;
  step: number;
  description: string;
}

export interface RecipeImage {
  id: string;
  url: string;
  isPrimary: boolean;
}

export type Difficulty = 'easy' | 'medium' | 'hard';

export interface Recipe {
  id: string;
  user_id?: string;
  title: string;
  ingredients: Ingredient[];
  instructions: Instruction[];
  prep_time?: number;
  cook_time?: number;
  servings?: number;
  difficulty?: Difficulty;
  is_favorite: boolean;
  notes?: string;
  images: RecipeImage[];
  categories?: Category[];
  folders?: Folder[];
  created_at?: string;
  updated_at?: string;
}

export interface CreateRecipeRequest {
  title: string;
  ingredients: Ingredient[];
  instructions: Instruction[];
  prep_time?: number;
  cook_time?: number;
  servings?: number;
  difficulty?: Difficulty;
  notes?: string;
}

export interface Category {
  id: string;
  user_id?: string;
  name: string;
  color?: string;
  icon?: string;
  recipe_count?: number;
  created_at?: string;
  updated_at?: string;
}

export interface Folder {
  id: string;
  user_id?: string;
  name: string;
  parent_folder_id?: string;
  recipe_count?: number;
  recipes?: Recipe[];
  created_at?: string;
  updated_at?: string;
}

export interface APIError {
  error: string;
  details?: any[];
}
