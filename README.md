# Recipe Manager - Full-Stack Application

A comprehensive recipe management system with iOS (SwiftUI), Web (React), and Backend (Node.js/Express) applications.

## Features

### Web Application ⭐ NEW!
- 🎨 Beautiful, responsive UI with Tailwind CSS
- 🌙 Dark mode support
- 📱 Mobile-first responsive design
- ⚡ Fast and optimized with Vite
- 🔐 Secure JWT authentication
- 📖 Full recipe CRUD operations
- 🔍 Real-time search functionality
- 📁 Categories and folder management
- 🍽️ Daily featured recipe showcase
- 🎯 TypeScript for type safety

### iOS Application
- 📱 Modern SwiftUI interface with dark mode support
- 🔐 Secure authentication with JWT and Keychain storage
- 📖 Create, edit, and manage recipes with ingredients and instructions
- 📸 Multiple photo uploads per recipe with image optimization
- 🤖 ML-powered recipe scanning using Vision framework
- 📁 Organize recipes with categories and folders
- ⭐ Favorite recipes and quick search
- 🍽️ Daily featured recipe
- 🔄 Offline support with local data caching
- ♿ Full accessibility support with VoiceOver

### Backend API
- 🚀 RESTful API built with Express.js
- 🗄️ PostgreSQL database with optimized indexes
- 🔒 JWT-based authentication
- 📤 Image upload and optimization with Sharp
- 🔍 Full-text search for recipes
- 📊 Recipe of the day algorithm
- 🛡️ Security features: rate limiting, helmet, input validation
- 🐳 Docker containerization
- 📝 Comprehensive API documentation

## Project Structure

```
recipe-app/
├── backend/                 # Node.js/Express API
│   ├── src/
│   │   ├── controllers/    # Request handlers
│   │   ├── models/        # Database models
│   │   ├── routes/        # API routes
│   │   ├── middleware/    # Auth, validation, error handling
│   │   ├── services/      # Business logic
│   │   ├── utils/         # Utilities (upload, etc.)
│   │   └── server.js      # Main server file
│   ├── Dockerfile
│   └── package.json
├── web/                    # React Web Application ⭐ NEW!
│   ├── src/
│   │   ├── components/    # Reusable components
│   │   ├── pages/         # Page components
│   │   ├── services/      # API services
│   │   ├── stores/        # Zustand state management
│   │   └── types/         # TypeScript types
│   ├── Dockerfile
│   └── package.json
├── ios/                    # iOS SwiftUI application
│   └── RecipeApp/
│       ├── Models/        # Data models
│       ├── Views/         # SwiftUI views
│       ├── ViewModels/    # MVVM view models
│       ├── Services/      # API clients & services
│       └── Utils/         # Utilities & helpers
├── database/              # Database migrations
│   └── migrations/       # SQL migration files
├── nginx/                 # Nginx configuration
├── docker-compose.yml    # Docker composition
└── README.md

```

## Quick Start

### Prerequisites

- **Backend:**
  - Node.js 18+ and npm
  - PostgreSQL 15+
  - Docker & Docker Compose (optional)

- **iOS:**
  - macOS with Xcode 15+
  - iOS 15.0+ device or simulator
  - CocoaPods (if using dependencies)

### Backend Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd recipe-app
   ```

2. **Install backend dependencies:**
   ```bash
   cd backend
   npm install
   ```

3. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Setup database:**
   ```bash
   # Create PostgreSQL database
   createdb recipe_manager

   # Run migrations
   npm run migrate
   ```

5. **Start the server:**
   ```bash
   npm run dev    # Development mode
   npm start      # Production mode
   ```

   The API will be available at `http://localhost:3000`

### iOS Setup

1. **Open Xcode:**
   ```bash
   cd ios
   open RecipeApp.xcodeproj
   ```

2. **Configure API endpoint:**
   - Edit `RecipeApp.xcconfig` or add environment variable:
   - Set `API_BASE_URL` to your backend URL (e.g., `http://localhost:3000/api/v1`)

3. **Build and run:**
   - Select your target device/simulator
   - Press Cmd+R or click Run

### Docker Deployment

1. **Configure environment variables:**
   ```bash
   cp backend/.env.example .env
   # Edit .env with production values
   ```

2. **Start services:**
   ```bash
   docker-compose up -d
   ```

3. **Run migrations:**
   ```bash
   docker-compose exec backend npm run migrate
   ```

4. **Access the application:**
   - API: `http://localhost:3000`
   - Health check: `http://localhost:3000/health`

## API Documentation

### Base URL
```
http://localhost:3000/api/v1
```

### Authentication Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register new user |
| POST | `/auth/login` | User login |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/logout` | User logout |
| GET | `/auth/profile` | Get user profile |

### Recipe Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/recipes` | List all recipes |
| POST | `/recipes` | Create new recipe |
| GET | `/recipes/:id` | Get recipe details |
| PUT | `/recipes/:id` | Update recipe |
| DELETE | `/recipes/:id` | Delete recipe |
| GET | `/recipes/search?q=` | Search recipes |
| POST | `/recipes/:id/favorite` | Toggle favorite |
| POST | `/recipes/:id/images` | Upload images |

### Category & Folder Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/categories` | List categories |
| POST | `/categories` | Create category |
| GET | `/folders` | List folders |
| POST | `/folders` | Create folder |

### Daily Recipe

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/recipe-of-the-day` | Get today's recipe |
| GET | `/recipe-of-the-day/history` | Get history |

See [backend/README.md](backend/README.md) for detailed API documentation.

## Technology Stack

### Backend
- **Runtime:** Node.js 18
- **Framework:** Express.js
- **Database:** PostgreSQL 15
- **Authentication:** JWT (jsonwebtoken)
- **Image Processing:** Sharp
- **Security:** Helmet, express-rate-limit, bcrypt
- **Validation:** express-validator
- **Deployment:** Docker, PM2, Nginx

### iOS
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Architecture:** MVVM
- **Networking:** URLSession with async/await
- **ML:** Vision, VisionKit
- **Storage:** Core Data, Keychain
- **Image Handling:** PhotosUI, AsyncImage

## Security Features

- 🔐 Password hashing with bcrypt
- 🎫 JWT access and refresh tokens
- 🔒 Secure token storage in iOS Keychain
- 🛡️ Rate limiting on API endpoints
- ✅ Input validation and sanitization
- 🚫 SQL injection prevention
- 🔑 Biometric authentication support (Face ID/Touch ID)
- 🌐 HTTPS enforcement in production

## Development

### Backend Development

```bash
cd backend
npm run dev    # Start with nodemon
npm test       # Run tests
npm run migrate  # Run database migrations
```

### iOS Development

1. Open project in Xcode
2. Select scheme and device
3. Build: Cmd+B
4. Run: Cmd+R
5. Test: Cmd+U

### Database Migrations

Create a new migration:
```bash
cd database/migrations
touch 008_your_migration_name.sql
```

Run migrations:
```bash
cd backend
npm run migrate
```

## Testing

### Backend Tests
```bash
cd backend
npm test              # Run all tests
npm run test:watch   # Watch mode
npm run test:coverage  # With coverage
```

### iOS Tests
- Unit tests: Cmd+U in Xcode
- UI tests: Test navigator in Xcode

## Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions covering:
- Ubuntu VPS setup
- Docker deployment
- Nginx configuration
- SSL setup with Let's Encrypt
- Database backup strategies
- Monitoring and logging

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or contributions, please open an issue on GitHub.

## Roadmap

- [ ] Social sharing of recipes
- [ ] Meal planning calendar
- [ ] Shopping list generation
- [ ] Nutrition information
- [ ] Recipe rating and reviews
- [ ] Import from popular recipe websites
- [ ] Export recipes as PDF
- [ ] Multi-language support
- [ ] Apple Watch companion app
- [ ] Widget support

---

Built with ❤️ using Swift, SwiftUI, Node.js, and PostgreSQL
