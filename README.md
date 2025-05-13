# sazanami

sazanami is a simple monitoring tool that records metrics and notifies you when sudden spikes or drops are detected.

## Architecture

- Backend: Ruby on Rails API (API mode)
- Frontend: Next.js (TypeScript)

## Development Environment Setup

### Backend

```bash
cd backend
docker compose up -d # postgresql port 5435
bundle install
bin/rails db:setup
bin/rails server # use port 3001
```

### Frontend

```bash
cd frontend
npm install
npm run dev
open http://localhost:8888
```

### Example: Insert metrics

```bash
 curl -X PUT \
  'http://localhost:8888/api/categories/AWS/metrics/Lambda' \
  -H 'Content-Type: application/json' \
  -d '{
    "value": "$10"
  }'
```
