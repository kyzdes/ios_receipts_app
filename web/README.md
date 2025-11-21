# Recipe Manager Web Application

Modern, responsive web application for managing recipes built with React, TypeScript, and Tailwind CSS.

## Features

- 🎨 Beautiful, responsive UI with Tailwind CSS
- 🌙 Dark mode support
- 🔐 Secure authentication with JWT
- 📱 Mobile-first design
- ⚡ Fast and optimized with Vite
- 🎯 Type-safe with TypeScript
- 🔄 Real-time updates with Zustand state management
- 🎭 Smooth animations with Framer Motion
- 🍞 Toast notifications

## Tech Stack

- **Framework:** React 18
- **Build Tool:** Vite
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **State Management:** Zustand
- **Routing:** React Router v6
- **HTTP Client:** Axios
- **Form Handling:** React Hook Form
- **Notifications:** React Hot Toast
- **Icons:** Lucide React

## Quick Start

### Development

1. **Install dependencies:**
   ```bash
   cd web
   npm install
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your API URL
   ```

3. **Start development server:**
   ```bash
   npm run dev
   ```

   The app will be available at `http://localhost:5173`

### Production Build

```bash
npm run build
```

The optimized build will be in the `dist/` directory.

### Preview Production Build

```bash
npm run preview
```

## Environment Variables

Create a `.env` file:

```env
VITE_API_URL=http://localhost:3000
```

## Project Structure

```
web/
├── public/              # Static assets
├── src/
│   ├── components/     # Reusable components
│   │   ├── Layout.tsx
│   │   └── RecipeCard.tsx
│   ├── pages/          # Page components
│   │   ├── HomePage.tsx
│   │   ├── LoginPage.tsx
│   │   ├── RecipesPage.tsx
│   │   └── ...
│   ├── services/       # API services
│   │   ├── api.ts
│   │   ├── auth.service.ts
│   │   └── recipe.service.ts
│   ├── stores/         # Zustand stores
│   │   ├── authStore.ts
│   │   └── recipeStore.ts
│   ├── types/          # TypeScript types
│   │   └── index.ts
│   ├── App.tsx         # Main app component
│   ├── main.tsx        # Entry point
│   └── index.css       # Global styles
├── index.html
├── vite.config.ts
├── tailwind.config.js
└── package.json
```

## Available Pages

- `/` - Home page with daily recipe and recent recipes
- `/login` - User login
- `/register` - User registration
- `/recipes` - Recipe list with search
- `/recipes/new` - Create new recipe
- `/recipes/:id` - Recipe detail view
- `/categories` - Categories management
- `/profile` - User profile

## Key Components

### Layout
Main application layout with navigation, mobile menu, and user menu.

### RecipeCard
Reusable recipe card component with image, title, and metadata.

### Forms
- Login/Register forms with validation
- Recipe creation form with dynamic ingredients/instructions
- Category creation modal

## State Management

The app uses Zustand for state management:

- **authStore** - User authentication state
- **recipeStore** - Recipe data and operations

Example usage:
```typescript
import { useAuthStore } from '@/stores/authStore';

function MyComponent() {
  const { user, login, logout } = useAuthStore();

  // Component logic
}
```

## API Integration

All API calls go through the centralized `api.ts` client which handles:
- Authentication headers
- Token refresh
- Error handling
- Request/response interceptors

Example:
```typescript
import { recipeService } from '@/services/recipe.service';

const recipes = await recipeService.getRecipes();
```

## Styling

### Tailwind CSS

The app uses Tailwind CSS for styling with custom configuration:

```javascript
// Custom colors in tailwind.config.js
colors: {
  primary: {
    50: '#f0f9ff',
    // ... more shades
    900: '#0c4a6e',
  },
}
```

### Custom Classes

Common utility classes defined in `index.css`:
- `.btn` - Base button
- `.btn-primary` - Primary button
- `.btn-secondary` - Secondary button
- `.input` - Form input
- `.card` - Card container

## Responsive Design

The app is fully responsive with breakpoints:
- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px
- `2xl`: 1536px

Example:
```jsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
  {/* Responsive grid */}
</div>
```

## Docker Deployment

### Build Docker Image

```bash
docker build -t recipe-web .
```

### Run Container

```bash
docker run -p 80:80 recipe-web
```

### Docker Compose

The web app is included in the main `docker-compose.yml`:

```bash
cd ..
docker-compose up -d
```

Access the app at `http://localhost`

## Deployment to VPS

### Option 1: Docker Compose (Recommended)

```bash
# On your VPS
git clone <repository-url>
cd recipe-app
docker-compose up -d
```

### Option 2: Build and Serve with Nginx

```bash
# Build the app
npm run build

# Copy to nginx directory
sudo cp -r dist/* /var/www/recipe-app/

# Configure nginx (see nginx.conf)
sudo systemctl restart nginx
```

## Nginx Configuration

For standalone deployment:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/recipe-app;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Performance Optimization

### Code Splitting

Vite automatically code-splits routes for optimal loading.

### Image Optimization

Images are lazy-loaded and cached:
```jsx
<img loading="lazy" src={image.url} alt={title} />
```

### Caching Strategy

- Static assets: 1 year cache
- API responses: No cache
- Service worker: Available for PWA

## Browser Support

- Chrome/Edge (latest 2 versions)
- Firefox (latest 2 versions)
- Safari (latest 2 versions)
- iOS Safari 12+
- Chrome Android (latest)

## Development Tips

### Hot Reload

Vite provides instant hot module replacement during development.

### TypeScript

All components are TypeScript for type safety:
```typescript
interface RecipeCardProps {
  recipe: Recipe;
  onToggleFavorite?: (id: string) => void;
}
```

### Linting

```bash
npm run lint
```

### Path Aliases

Use `@/` for imports:
```typescript
import { Recipe } from '@/types';
import { useAuthStore } from '@/stores/authStore';
```

## Troubleshooting

### Port already in use

Change the port in `vite.config.ts`:
```typescript
server: {
  port: 5174,
}
```

### API connection issues

Check the `VITE_API_URL` in your `.env` file matches your backend URL.

### Build errors

Clear node_modules and reinstall:
```bash
rm -rf node_modules package-lock.json
npm install
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## License

MIT
