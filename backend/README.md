# Recipe Manager Backend API

RESTful API server for the Recipe Manager application.

## Technology Stack

- **Runtime:** Node.js 18+
- **Framework:** Express.js
- **Database:** PostgreSQL 15+
- **Authentication:** JWT
- **Image Processing:** Sharp
- **Validation:** express-validator

## Setup

### Installation

```bash
npm install
```

### Environment Configuration

Copy `.env.example` to `.env` and configure:

```env
# Server
NODE_ENV=development
PORT=3000
API_VERSION=v1

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=recipe_manager
DB_USER=postgres
DB_PASSWORD=your_password

# JWT
JWT_SECRET=your_jwt_secret_key_change_this
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=your_refresh_secret_key_change_this
JWT_REFRESH_EXPIRES_IN=30d

# File Upload
MAX_FILE_SIZE=5242880
UPLOAD_DIR=./uploads
```

### Database Setup

```bash
# Create database
createdb recipe_manager

# Run migrations
npm run migrate
```

## API Endpoints

### Authentication

#### Register User
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "username": "johndoe"
}
```

**Response:**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "username": "johndoe"
  },
  "accessToken": "jwt_token",
  "refreshToken": "refresh_token"
}
```

#### Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### Recipes

#### Create Recipe
```http
POST /api/v1/recipes
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "Chocolate Chip Cookies",
  "ingredients": [
    {
      "name": "flour",
      "quantity": "2",
      "unit": "cups"
    },
    {
      "name": "chocolate chips",
      "quantity": "1",
      "unit": "cup"
    }
  ],
  "instructions": [
    {
      "step": 1,
      "description": "Preheat oven to 350°F"
    },
    {
      "step": 2,
      "description": "Mix dry ingredients"
    }
  ],
  "prep_time": 15,
  "cook_time": 12,
  "servings": 24,
  "difficulty": "easy",
  "notes": "Best when served warm"
}
```

#### Get All Recipes
```http
GET /api/v1/recipes?limit=50&offset=0&sortBy=created_at&order=DESC
Authorization: Bearer {access_token}
```

#### Get Recipe by ID
```http
GET /api/v1/recipes/:id
Authorization: Bearer {access_token}
```

#### Update Recipe
```http
PUT /api/v1/recipes/:id
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "title": "Updated Recipe Name",
  "prep_time": 20
}
```

#### Delete Recipe
```http
DELETE /api/v1/recipes/:id
Authorization: Bearer {access_token}
```

#### Search Recipes
```http
GET /api/v1/recipes/search?q=chocolate
Authorization: Bearer {access_token}
```

#### Toggle Favorite
```http
POST /api/v1/recipes/:id/favorite
Authorization: Bearer {access_token}
```

#### Upload Images
```http
POST /api/v1/recipes/:id/images
Authorization: Bearer {access_token}
Content-Type: multipart/form-data

images: [file1, file2, file3]
```

### Categories

#### Get All Categories
```http
GET /api/v1/categories
Authorization: Bearer {access_token}
```

#### Create Category
```http
POST /api/v1/categories
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "Desserts",
  "color": "#FF6B6B",
  "icon": "🍰"
}
```

### Folders

#### Get All Folders
```http
GET /api/v1/folders
Authorization: Bearer {access_token}
```

#### Create Folder
```http
POST /api/v1/folders
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "name": "Family Favorites",
  "parent_folder_id": null
}
```

### Daily Recipe

#### Get Today's Recipe
```http
GET /api/v1/recipe-of-the-day
```

#### Get History
```http
GET /api/v1/recipe-of-the-day/history?limit=30
```

## Error Responses

All endpoints return errors in the following format:

```json
{
  "error": "Error message",
  "details": []
}
```

### HTTP Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `409` - Conflict
- `429` - Too Many Requests
- `500` - Internal Server Error

## Database Schema

### Users
```sql
- id (UUID, PK)
- email (VARCHAR, UNIQUE)
- password_hash (VARCHAR)
- username (VARCHAR)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### Recipes
```sql
- id (UUID, PK)
- user_id (UUID, FK)
- title (VARCHAR)
- ingredients (JSONB)
- instructions (JSONB)
- prep_time (INTEGER)
- cook_time (INTEGER)
- servings (INTEGER)
- difficulty (VARCHAR)
- is_favorite (BOOLEAN)
- notes (TEXT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

### Categories
```sql
- id (UUID, PK)
- user_id (UUID, FK)
- name (VARCHAR)
- color (VARCHAR)
- icon (VARCHAR)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

## Development

### Run Development Server
```bash
npm run dev
```

### Run Tests
```bash
npm test
```

### Run Migrations
```bash
npm run migrate
```

### Backup Database
```bash
chmod +x scripts/backup-db.sh
./scripts/backup-db.sh
```

## Production Deployment

### Using PM2
```bash
npm install -g pm2
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### Using Docker
```bash
docker build -t recipe-api .
docker run -p 3000:3000 --env-file .env recipe-api
```

## Security Considerations

1. **Environment Variables:** Never commit `.env` file
2. **JWT Secrets:** Use strong, random secrets in production
3. **HTTPS:** Always use HTTPS in production
4. **Rate Limiting:** Configured for 100 requests per 15 minutes
5. **Input Validation:** All inputs are validated and sanitized
6. **SQL Injection:** Using parameterized queries
7. **Password Security:** Bcrypt with salt rounds of 10

## Performance Optimization

1. **Database Indexes:** Optimized indexes on frequently queried fields
2. **Connection Pooling:** PostgreSQL connection pool (max 20 connections)
3. **Image Optimization:** Automatic image compression with Sharp
4. **Caching:** Implement Redis for frequently accessed data (future)

## Monitoring

### Health Check
```http
GET /health
```

Response:
```json
{
  "status": "OK",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": 3600
}
```

## License

MIT
