# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sazanami is a monitoring tool that records metrics and notifies when sudden spikes or drops are detected. It consists of:
- **Backend**: Rails API (port 3001) 
- **Frontend**: Next.js with TypeScript (port 3000)
- **Database**: PostgreSQL (via Docker Compose)

## Development Commands

### Backend (Rails API)
```bash
cd backend
docker compose up -d        # Start PostgreSQL
bundle install              # Install dependencies
bin/rails db:setup          # Setup database
bin/rails server            # Start server on port 3001
bundle exec rspec           # Run all tests
bundle exec rspec spec/path/to/spec.rb  # Run single test
bundle exec rubocop         # Run linter
bundle exec rubocop -a      # Auto-fix linting issues
```

### Frontend (Next.js)
```bash
cd frontend
npm install                 # Install dependencies
npm run dev                 # Start development server
npm run build              # Build for production
npm run lint               # Run linter
```

## Architecture

### Data Model
- **Categories**: Groups metrics by category (name, label)
- **Metrics**: Individual metrics within categories (name, label, unit, prefix_unit)
- **MetricValues**: Time-series data points for metrics (value, recorded_at)

### API Routes
- `GET /health_checks` - Health check endpoint
- `GET /categories` - List all categories
- `GET /categories/:name/metrics` - List metrics for a category
- `PUT /categories/:name/metrics/:metric_name` - Update metric values

### Frontend Structure
- `src/app/` - Next.js app router pages and components
- Uses D3.js for data visualization
- Axios for API communication
- Tailwind CSS for styling

### Testing
- Backend: RSpec with FactoryBot for test data
- Frontend: Next.js built-in testing with ESLint

## Key Dependencies
- Backend: Rails 8.0.2, Ruby 3.4.1, PostgreSQL, RSpec, Rubocop
- Frontend: Next.js 15.3, React 19, TypeScript 5, D3.js 7.9, Tailwind CSS 4