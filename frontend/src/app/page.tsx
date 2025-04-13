import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-8">
      <div className="max-w-4xl w-full bg-white dark:bg-gray-800 rounded-lg shadow-md p-8">
        <h1 className="text-3xl font-bold mb-6 text-center">
          Rails API + Next.js アプリケーション
        </h1>
        <p className="text-gray-600 dark:text-gray-300 mb-8 text-center">
          Railsバックエンド（API）とNext.jsフロントエンドの連携アプリケーション
        </p>
        <div className="flex justify-center space-x-4">
          <Link 
            href="/about" 
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
          >
            詳細へ
          </Link>
        </div>
      </div>
    </div>
  );
}
