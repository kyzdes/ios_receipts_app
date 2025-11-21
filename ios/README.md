# Recipe Manager iOS App

SwiftUI-based iOS application for managing recipes with ML-powered scanning capabilities.

## Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+
- Active Apple Developer account (for device testing)

## Features

### Core Functionality
- ✅ User authentication with JWT tokens
- ✅ Recipe CRUD operations
- ✅ Multi-image upload support
- ✅ Search and filter recipes
- ✅ Favorites and organization
- ✅ Categories and folders
- ✅ Recipe of the day

### ML & Vision
- ✅ Text recognition from photos using Vision framework
- ✅ Recipe scanning from images
- ✅ PDF text extraction
- ✅ Automatic recipe parsing

### Security
- ✅ Keychain integration for secure token storage
- ✅ Biometric authentication support (Face ID/Touch ID)
- ✅ Secure API communication

### UI/UX
- ✅ Dark mode support
- ✅ Accessibility (VoiceOver support)
- ✅ Haptic feedback
- ✅ Pull-to-refresh
- ✅ Smooth animations

## Project Structure

```
RecipeApp/
├── Models/              # Data models
│   ├── Recipe.swift
│   ├── User.swift
│   ├── Category.swift
│   └── Folder.swift
├── Views/              # SwiftUI views
│   ├── LoginView.swift
│   ├── MainTabView.swift
│   ├── RecipesView.swift
│   ├── RecipeDetailView.swift
│   └── CreateRecipeView.swift
├── ViewModels/         # MVVM view models
│   ├── AuthViewModel.swift
│   ├── RecipeViewModel.swift
│   └── CategoryViewModel.swift
├── Services/           # API & business logic
│   ├── APIClient.swift
│   ├── AuthService.swift
│   ├── RecipeService.swift
│   └── KeychainService.swift
├── Utils/              # Utilities
│   └── ImageProcessor.swift
└── Resources/          # Assets, localization
```

## Setup Instructions

### 1. Clone and Open Project

```bash
cd ios
open RecipeApp.xcodeproj
```

### 2. Configure API Endpoint

#### Option A: Using Xcode Configuration

1. Create `RecipeApp.xcconfig`:
```
API_BASE_URL = http:/$()/localhost:3000/api/v1
```

2. Add to project build settings

#### Option B: Using Info.plist

Edit `Info.plist` and add:
```xml
<key>API_BASE_URL</key>
<string>http://localhost:3000/api/v1</string>
```

#### Option C: Environment Variable

In Xcode:
1. Product → Scheme → Edit Scheme
2. Run → Arguments → Environment Variables
3. Add: `API_BASE_URL` = `http://localhost:3000/api/v1`

### 3. Update Signing & Capabilities

1. Select project in navigator
2. Select target → Signing & Capabilities
3. Select your team
4. Update bundle identifier

### 4. Add Required Capabilities

Ensure these capabilities are enabled:
- Keychain Sharing
- Camera access
- Photo Library access

### 5. Build and Run

Press `Cmd+R` or click the Run button

## API Configuration

### Development (Simulator)

```swift
// Use localhost for simulator
API_BASE_URL = "http://localhost:3000/api/v1"
```

### Development (Physical Device)

```swift
// Use your Mac's local IP address
API_BASE_URL = "http://192.168.1.XXX:3000/api/v1"
```

### Production

```swift
API_BASE_URL = "https://your-api-domain.com/api/v1"
```

## Architecture

### MVVM Pattern

```
View ← → ViewModel ← → Service ← → API
  ↓                      ↓
Model ← ← ← ← ← ← ← ← Model
```

### Data Flow

1. **View** displays UI and handles user interaction
2. **ViewModel** manages state and business logic
3. **Service** handles API communication
4. **Model** represents data structures

### Example: Creating a Recipe

```swift
// 1. View triggers action
Button("Save") {
    Task {
        await viewModel.createRecipe(recipe)
    }
}

// 2. ViewModel processes
func createRecipe(_ recipe: Recipe) async {
    isLoading = true
    let result = await recipeService.create(recipe)
    isLoading = false
    // Update state
}

// 3. Service makes API call
func create(_ recipe: Recipe) async throws -> Recipe {
    return try await apiClient.request(
        endpoint: "/recipes",
        method: "POST",
        body: recipe
    )
}
```

## Testing

### Unit Tests

```bash
# Run in Xcode
Cmd+U

# Or via command line
xcodebuild test -scheme RecipeApp -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI Tests

1. Open Test Navigator (Cmd+6)
2. Run specific test or all tests
3. Review test results

## Common Tasks

### Adding a New View

1. Create SwiftUI view file
2. Add to appropriate folder
3. Register in navigation hierarchy
4. Connect to ViewModel if needed

### Adding a New API Endpoint

1. Update Service class:
```swift
func newEndpoint() async throws -> Response {
    return try await apiClient.request(
        endpoint: "/new-endpoint",
        method: "GET"
    )
}
```

2. Update ViewModel:
```swift
@Published var data: [Model] = []

func loadData() async {
    data = try await service.newEndpoint()
}
```

3. Use in View:
```swift
.task {
    await viewModel.loadData()
}
```

### Handling Images

```swift
// 1. Select image
PhotosPicker(selection: $selectedItem) {
    Text("Select Photo")
}

// 2. Convert to Data
if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
    imageData = data
}

// 3. Upload
await viewModel.uploadImage(data)
```

## Debugging

### Network Debugging

Enable in `APIClient.swift`:
```swift
private func logRequest(_ request: URLRequest) {
    print("🌐 Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
    if let body = request.httpBody {
        print("📤 Body: \(String(data: body, encoding: .utf8) ?? "")")
    }
}
```

### View Debugging

Use Xcode's View Hierarchy Debugger:
1. Run app
2. Debug → View Debugging → Capture View Hierarchy

### Network Inspector

Use Charles Proxy or Proxyman to inspect HTTP traffic.

## Performance Optimization

### Image Caching

Images are automatically cached using `AsyncImage`. For custom caching:

```swift
import SDWebImage

WebImage(url: URL(string: imageUrl))
    .resizable()
    .placeholder { ProgressView() }
```

### Lazy Loading

Use `LazyVStack` and `LazyHStack` for large lists:

```swift
LazyVStack {
    ForEach(recipes) { recipe in
        RecipeCard(recipe: recipe)
    }
}
```

### Debouncing Search

Search is automatically debounced in `RecipeViewModel`:

```swift
$searchText
    .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
    .sink { text in
        // Search after user stops typing
    }
```

## Accessibility

### VoiceOver Support

All interactive elements have labels:

```swift
Button(action: save) {
    Image(systemName: "checkmark")
}
.accessibilityLabel("Save recipe")
```

### Dynamic Type

Text automatically scales with user preferences:

```swift
Text("Recipe Title")
    .font(.title)  // Automatically scales
```

## Security Best Practices

### Token Storage

```swift
// ✅ DO: Use Keychain
KeychainService.shared.saveAccessToken(token)

// ❌ DON'T: Use UserDefaults
UserDefaults.standard.set(token, forKey: "token")
```

### API Keys

```swift
// ✅ DO: Use xcconfig or build settings
let apiKey = ProcessInfo.processInfo.environment["API_KEY"]

// ❌ DON'T: Hardcode
let apiKey = "my-secret-key"
```

## Troubleshooting

### Build Errors

**"Failed to register bundle identifier"**
- Change bundle identifier to unique value
- Verify Apple Developer account

**"Code signing error"**
- Select valid development team
- Update provisioning profile

### Runtime Errors

**"Network request failed"**
- Verify API endpoint URL
- Check backend server is running
- Ensure device is on same network (for local development)

**"Keychain access denied"**
- Reset simulator: Device → Erase All Content and Settings
- Check Keychain Sharing capability

### Performance Issues

**Slow scrolling**
- Use `LazyVStack` instead of `VStack`
- Optimize image sizes
- Profile with Instruments

## Contributing

1. Follow Swift API Design Guidelines
2. Use SwiftLint for code style
3. Write unit tests for ViewModels
4. Document complex logic
5. Use meaningful commit messages

## Resources

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Vision Framework](https://developer.apple.com/documentation/vision)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

## License

MIT
