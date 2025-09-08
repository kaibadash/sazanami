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

## Usage

Post metric data with category and metric values (with unit).
Here's an example of posting RDS cost to the AWS category:

```bash
curl -X PUT "http://localhost:3001/categories/AWS/metrics/RDS" \
  -H "Content-Type: application/json" \
  -d '{"value": "$123.45"}'
```

You can then view the data at:
http://localhost:3000/categories/aws

