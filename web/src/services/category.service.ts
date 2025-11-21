import { api } from './api';
import { Category } from '@/types';

interface CategoriesResponse {
  categories: Category[];
}

interface CategoryResponse {
  category: Category;
  message?: string;
}

export const categoryService = {
  async getCategories(): Promise<Category[]> {
    const response = await api.get<CategoriesResponse>('/categories');
    return response.categories;
  },

  async createCategory(data: { name: string; color?: string; icon?: string }): Promise<Category> {
    const response = await api.post<CategoryResponse>('/categories', data);
    return response.category;
  },

  async updateCategory(id: string, data: { name?: string; color?: string; icon?: string }): Promise<Category> {
    const response = await api.put<CategoryResponse>(`/categories/${id}`, data);
    return response.category;
  },

  async deleteCategory(id: string): Promise<void> {
    await api.delete(`/categories/${id}`);
  },
};
