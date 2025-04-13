import Link from "next/link";

export default function About() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-8">
      <div className="max-w-4xl w-full bg-white dark:bg-gray-800 rounded-lg shadow-md p-8">
        <h1 className="text-3xl font-bold mb-6 text-center">
          このアプリケーションについて
        </h1>
        <div className="mb-8">
          <p className="text-gray-600 dark:text-gray-300 mb-4">
            このアプリケーションは、以下の技術を使用しています：
          </p>
          <ul className="list-disc pl-8 text-gray-600 dark:text-gray-300">
            <li>バックエンド: Ruby on Rails (API mode)</li>
            <li>フロントエンド: Next.js (TypeScript)</li>
            <li>スタイリング: Tailwind CSS</li>
            <li>テスト: RSpec (バックエンド)</li>
          </ul>
        </div>
        <div className="flex justify-center">
          <Link 
            href="/" 
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
          >
            ホームに戻る
          </Link>
        </div>
      </div>
    </div>
  );
} 