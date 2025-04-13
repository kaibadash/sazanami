'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { getCategoryMetrics, Metric } from '@/lib/api';

export default function CategoryMetricsPage({ 
  params 
}: { 
  params: { categoryName: string } 
}) {
  const { categoryName } = params;
  const [metrics, setMetrics] = useState<Metric[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchMetrics() {
      try {
        const data = await getCategoryMetrics(categoryName);
        setMetrics(data.metrics);
      } catch (err) {
        setError('メトリクスの取得に失敗しました');
        console.error(err);
      } finally {
        setLoading(false);
      }
    }

    fetchMetrics();
  }, [categoryName]);

  if (loading) {
    return <div className="p-8 text-center">読み込み中...</div>;
  }

  if (error) {
    return <div className="p-8 text-center text-red-500">{error}</div>;
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-2">{categoryName}</h1>
      <p className="text-gray-500 mb-6">メトリクス一覧</p>
      
      {metrics.length === 0 ? (
        <p>メトリクスがありません</p>
      ) : (
        <div className="space-y-8">
          {metrics.map((metric) => (
            <div 
              key={metric.id} 
              className="bg-white dark:bg-gray-800 rounded-lg shadow p-6"
            >
              <div className="font-bold text-xl mb-2">{metric.label}</div>
              <div className="text-sm text-gray-500 mb-4">{metric.name}</div>
              
              <h3 className="text-md font-semibold mb-2">値の履歴</h3>
              {metric.values.length === 0 ? (
                <p className="text-sm">値がありません</p>
              ) : (
                <ul className="divide-y">
                  {metric.values.map((value) => (
                    <li key={value.id} className="py-3 flex justify-between">
                      <span>{new Date(value.recorded_at).toLocaleDateString()}</span>
                      <span className="font-mono">{value.value_with_unit}</span>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          ))}
        </div>
      )}
      
      <div className="mt-6">
        <Link 
          href="/categories" 
          className="text-blue-500 hover:underline"
        >
          カテゴリ一覧に戻る
        </Link>
      </div>
    </div>
  );
} 