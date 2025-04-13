import axios from 'axios';

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';

export interface Category {
  id: number;
  name: string;
  label: string;
  created_at: string;
  updated_at: string;
}

export interface MetricValue {
  id: number;
  value: string;
  value_with_unit: string;
  recorded_at: string;
}

export interface Metric {
  id: number;
  name: string;
  label: string;
  unit: string;
  prefix_unit: boolean;
  values: MetricValue[];
}

export async function getCategories(): Promise<Category[]> {
  console.log(`${API_BASE_URL}/categories`);
  const response = await axios.get<{ categories: Category[] }>(`${API_BASE_URL}/categories`);
  console.log(response);
  return response.data.categories;
}

export async function getCategoryMetrics(categoryName: string): Promise<{ metrics: Metric[] }> {
  const response = await axios.get<{ metrics: Metric[] }>(`${API_BASE_URL}/categories/${categoryName}/metrics`);
  return response.data;
} 