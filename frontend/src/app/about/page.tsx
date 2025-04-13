import Link from "next/link";

export default function About() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-8">
      <div className="max-w-4xl w-full bg-white dark:bg-gray-800 rounded-lg shadow-md p-8">
        <h1 className="text-3xl font-bold mb-6 text-center">
          About This Application
        </h1>
        <div className="mb-8">
          <p className="text-gray-600 dark:text-gray-300 mb-4">
            This application uses the following technologies:
          </p>
          <ul className="list-disc pl-8 text-gray-600 dark:text-gray-300">
            <li>Backend: Ruby on Rails (API mode)</li>
            <li>Frontend: Next.js (TypeScript)</li>
            <li>Styling: Tailwind CSS</li>
            <li>Testing: RSpec (Backend)</li>
          </ul>
        </div>
        <div className="flex justify-center">
          <Link 
            href="/" 
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
          >
            Back to Home
          </Link>
        </div>
      </div>
    </div>
  );
} 