'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { getCategories, Category } from '@/lib/api';

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchCategories() {
      try {
        const data = await getCategories();
        setCategories(data);
      } catch (err) {
        setError('Failed to fetch categories');
        console.error(err);
      } finally {
        setLoading(false);
      }
    }

    fetchCategories();
  }, []);

  if (loading) {
    return <div className="p-8 text-center">Loading...</div>;
  }

  if (error) {
    return <div className="p-8 text-center text-red-500">{error}</div>;
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Categories</h1>
      
      {categories.length === 0 ? (
        <p>No categories available</p>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {categories.map((category) => (
            <Link 
              key={category.id} 
              href={`/categories/${category.name}`}
              className="block p-4 bg-white dark:bg-gray-800 rounded-lg shadow hover:shadow-md transition-shadow"
            >
              <div className="font-bold">{category.label}</div>
              <div className="text-sm text-gray-500">{category.name}</div>
            </Link>
          ))}
        </div>
      )}
      
      <div className="mt-6">
        <Link 
          href="/" 
          className="text-blue-500 hover:underline"
        >
          Back to Home
        </Link>
      </div>
    </div>
  );
} 