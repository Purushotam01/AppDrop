# AppDrop - Dynamic Widget Rendering Engine

A Flutter application that renders UI components dynamically from JSON schemas. This mini rendering engine supports multiple component types and demonstrates clean, extensible MVVM architecture.

## Features

- **Dynamic UI Rendering**: Renders complete screens from JSON data stored in assets
- **5 Component Types**: Banner, Carousel, Grid, Video, and Text
- **MVVM Architecture**: Clean separation of concerns with Model-View-ViewModel pattern
- **Dark Mode Support**: Complete theme system with light and dark modes
- **Responsive Design**: Adapts to portrait and landscape orientations
- **Video Playback**: Full-featured video player with controls and lifecycle management
- **Image Caching**: Efficient image loading with `CachedNetworkImage`
- **Error Handling**: Graceful handling of missing/invalid data with retry mechanisms
- **Loading States**: Shimmer effects and placeholders
- **Custom App Bar**: Gradient design with curved bottom corners
- **Performance Optimized**: Video stays in memory when scrolling, efficient widget rebuilds

## Requirements

- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0
- iOS 11.0+ / Android API 21+

## 🛠️ Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd app_drop
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── app/                    # Application-level configuration
│   └── app.dart            # Main app widget with theme configuration
│
├── core/                   # Core business logic and models
│   ├── constants/          # App-wide constants
│   ├── models/              # Data models
│   │   ├── app_theme.dart  # Theme configuration (light/dark)
│   │   ├── component.dart  # Component and PageSchema models
│   │   └── page.dart       # Page configuration model
│   └── services/           # Business logic services
│       └── json_service.dart # JSON parsing and data loading
│
├── home/                   # Home screen module
│   ├── home_view.dart      # Home screen UI (View)
│   └── Home_viewmodel.dart # Home screen state management (ViewModel)
│
├── utils/                  # Utility classes
│   ├── audio_manager.dart  # Audio session management
│   ├── network_image_builder.dart # Network image loading utility
│   └── responsive.dart     # Responsive design utilities
│
├── widgets/                # Reusable UI components
│   ├── components/         # Dynamic component widgets
│   ├── placeholder/        # Loading placeholders
│   ├── app_bar_painter.dart # Custom app bar painter
│   ├── component_factory.dart # Factory for creating components
│   └── splash_screen.dart  # Splash screen widget
│
└── main.dart               # Application entry point

assets/
└── page_schema.json        # JSON schema for page components
```

## Component Types

### 1. Image Banner
Displays a single image with gradient overlay and customizable styling.

```json
{
  "type": "banner",
  "image": "https://example.com/image.jpg",
  "height": 200,
  "padding": 16,
  "radius": 20
}
```

**Properties:**
- `image` (string): Image URL
- `height` (number): Banner height in pixels
- `padding` (number): Padding around the banner
- `radius` (number): Border radius for rounded corners

### 2. Image Carousel
Displays multiple images in a carousel with auto-play functionality.

```json
{
  "type": "carousel",
  "images": [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg"
  ],
  "height": 240,
  "autoPlay": true,
  "padding": 16
}
```

**Properties:**
- `images` (array): Array of image URLs
- `height` (number): Carousel height in pixels
- `autoPlay` (boolean): Enable/disable auto-play
- `padding` (number): Padding around the carousel

### 3. Image Grid
Displays images in a grid layout with customizable columns and spacing.

```json
{
  "type": "grid",
  "images": [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg"
  ],
  "columns": 2,
  "spacing": 12,
  "padding": 16
}
```

**Properties:**
- `images` (array): Array of image URLs
- `columns` (number): Number of columns in the grid
- `spacing` (number): Spacing between grid items
- `padding` (number): Padding around the grid

### 4. Video Player
Full-featured video player with controls, auto-play, and loop options.

```json
{
  "type": "video",
  "url": "https://example.com/video.mp4",
  "autoPlay": false,
  "loop": false,
  "height": 220,
  "padding": 16,
  "showControls": true,
  "muted": false
}
```

**Properties:**
- `url` (string): Video URL
- `autoPlay` (boolean): Start playing automatically
- `loop` (boolean): Loop the video
- `height` (number): Video player height in pixels
- `padding` (number): Padding around the video
- `showControls` (boolean): Show video controls
- `muted` (boolean): Start muted

**Features:**
- Fullscreen support
- Auto-pause when app goes to background
- Stays in memory when scrolling (no reload)
- Proper lifecycle management

### 5. Text Component
Displays text with customizable styling options.

```json
{
  "type": "text",
  "value": "Welcome to AppDrop",
  "size": 24,
  "weight": "bold",
  "align": "center",
  "padding": 24,
  "color": "#333333"
}
```

**Properties:**
- `value` (string): Text content
- `size` (number): Font size
- `weight` (string): Font weight (normal, bold, w100-w900)
- `align` (string): Text alignment (left, right, center, justify)
- `padding` (number): Padding around the text
- `color` (string): Text color in hex format (optional)

## JSON Schema Format

The app reads component configuration from `assets/page_schema.json`. The JSON structure should follow this format:

```json
{
  "page": {
    "components": [
      {
        "type": "banner",
        "image": "...",
        "height": 200
      },
      {
        "type": "carousel",
        "images": [...],
        "height": 240
      }
    ]
  }
}
```

## Architecture

### MVVM Pattern

The application follows the **MVVM (Model-View-ViewModel)** architectural pattern:

- **Model**: Data models and business logic (`lib/core/models/`, `lib/core/services/`)
- **View**: UI components and screens (`lib/home/home_view.dart`, `lib/widgets/`)
- **ViewModel**: State management and business logic coordination (`lib/home/Home_viewmodel.dart`)

### Key Design Patterns

1. **Factory Pattern**: `ComponentFactory` creates widgets based on component type
2. **Observer Pattern**: ViewModel notifies View via callbacks
3. **Singleton Pattern**: Services are instantiated once
4. **Strategy Pattern**: Different rendering strategies for different component types

## Theming

The app supports both light and dark themes:

- **Light Theme**: White background with dark text
- **Dark Theme**: Dark background (#121212, #1E1E1E) with light text
- All components automatically adapt to the current theme
- Theme configuration is defined in `lib/core/models/app_theme.dart`

## Configuration

### Assets

The JSON schema file is located at `assets/page_schema.json` and is configured in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/page_schema.json
```

### Dependencies

Key dependencies include:
- `video_player`: Video playback functionality
- `chewie`: Video player UI controls
- `cached_network_image`: Efficient image loading and caching
- `carousel_slider`: Image carousel functionality
- `audio_session`: Audio session management

See `pubspec.yaml` for the complete list.

## Usage

1. **Modify JSON Schema**: Edit `assets/page_schema.json` to change the page layout
2. **Add Components**: Add new component objects to the `components` array
3. **Run App**: The app will automatically load and render the components

## Data Flow

1. **Application Startup**: `main.dart` → `app.dart` → `SplashScreen` → `HomeView`
2. **Data Loading**: `HomeView` → `HomeViewModel` → `JsonService` → Load JSON from assets
3. **Component Rendering**: `ComponentFactory` → Create appropriate widget → Render UI

## Error Handling

- **JSON Parsing Errors**: Caught and displayed with retry option
- **Image Loading Errors**: Fallback to placeholder icons
- **Video Errors**: Error widget with retry option
- **Network Errors**: Graceful degradation with error states

## Platform Support

- iOS
- Android
- Web (with limitations for video playback)
- macOS
- Windows
- Linux

## Future Enhancements

- API integration for dynamic JSON loading
- Persistent caching for offline support
- More component types
- Animation improvements
- Unit and widget tests
- Localization support
- Enhanced accessibility features

## License

This project is for demonstration purposes.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Documentation

For detailed architecture documentation, see [Architecture notes.md](Architecture%20notes.md).

---

**Built with using Flutter**
