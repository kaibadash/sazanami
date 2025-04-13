import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-8">
      <div className="max-w-4xl w-full bg-white dark:bg-gray-800 rounded-lg shadow-md p-8">
        <h1 className="text-3xl font-bold mb-6 text-center">
          Rails API + Next.js Application
        </h1>
        <p className="text-gray-600 dark:text-gray-300 mb-8 text-center">
          Integrated application with Rails backend (API) and Next.js frontend
        </p>
        <div className="flex justify-center space-x-4">
          <Link 
            href="/categories" 
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
          >
            Categories
          </Link>
          <Link 
            href="/about" 
            className="px-4 py-2 bg-gray-200 text-gray-700 rounded hover:bg-gray-300 transition-colors"
          >
            About
          </Link>
        </div>
      </div>
    </div>
  );
}
