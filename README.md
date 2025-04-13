# sazanami

sazanami is a simple monitoring tool that records metrics and notifies you when sudden spikes or drops are detected.

## Architecture

- Backend: Ruby on Rails API (API mode)
- Frontend: Next.js (TypeScript)

## Development Environment Setup

### Backend

```bash
docker compose up -d # postgresql
cd backend
bundle install
bin/rails db:setup
bin/rails server # use port 3001
```

### Frontend

```bash
cd frontend
npm install
npm run dev
open http://localhost:3000
```
