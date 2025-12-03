# Architecture Notes

## Overview

**AppDrop** is a Flutter application that implements a dynamic widget rendering engine. The app renders UI components dynamically from JSON schemas, supporting multiple component types with a clean, extensible MVVM (Model-View-ViewModel) architecture.

## Architecture Pattern

### MVVM (Model-View-ViewModel)

The application follows the **MVVM (Model-View-ViewModel)** architectural pattern:

- **Model**: Data models and business logic (`lib/core/models/`, `lib/core/services/`)
- **View**: UI components and screens (`lib/home/home_view.dart`, `lib/widgets/`)
- **ViewModel**: State management and business logic coordination (`lib/home/Home_viewmodel.dart`)

### Key Principles

1. **Separation of Concerns**: Clear separation between UI, business logic, and data
2. **Single Responsibility**: Each class/component has a single, well-defined purpose
3. **Dependency Injection**: Services are injected into ViewModels
4. **Reactive State Management**: ViewModels manage state and notify Views via callbacks

## Project Structure

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
│   │   ├── banner_widget.dart
│   │   ├── carousel_widget.dart
│   │   ├── grid_widget.dart
│   │   ├── text_widget.dart
│   │   └── video_widget.dart
│   ├── placeholder/        # Loading placeholders
│   │   └── shimmer_placeholder.dart
│   ├── app_bar_painter.dart # Custom app bar painter
│   ├── component_factory.dart # Factory for creating components
│   └── splash_screen.dart  # Splash screen widget
│
└── main.dart               # Application entry point
```

## Key Components

### 1. Entry Point (`main.dart`)

**Responsibilities:**
- Initialize Flutter bindings
- Configure audio session for video playback
- Set device orientation preferences
- Configure global error handling
- Initialize and run the app

**Key Features:**
- Zone-based error handling with `runZonedGuarded`
- Global error suppression for known third-party package issues
- Audio session configuration for proper media playback

### 2. App Configuration (`app/app.dart`)

**Responsibilities:**
- MaterialApp configuration
- Theme management (light/dark mode)
- Navigation setup
- Splash screen integration

**Theme System:**
- Light and dark themes defined in `AppTheme`
- Theme mode switching capability
- Consistent color scheme across the app

### 3. Home Module (`home/`)

#### HomeView (`home_view.dart`)
**Responsibilities:**
- Display UI based on ViewModel state
- Handle user interactions
- Responsive layout (portrait/landscape)
- Custom app bar with gradient and curved design

**State Management:**
- Listens to ViewModel state changes via callbacks
- Updates UI reactively when state changes
- Handles loading, error, empty, and loaded states

#### HomeViewModel (`Home_viewmodel.dart`)
**Responsibilities:**
- Manage application state
- Coordinate data loading from services
- Handle error states
- Provide retry functionality

**State Flow:**
```
initial → loading → loaded/error/empty
```

### 4. Core Models (`core/models/`)

#### Component Model (`component.dart`)
- Defines component types (banner, carousel, grid, video, text)
- Parses JSON to Component objects
- Contains component properties

#### PageSchema Model (`component.dart`)
- Represents a page with multiple components
- Parses page JSON structure
- Contains list of components

#### AppTheme Model (`app_theme.dart`)
- Defines light and dark theme configurations
- Provides consistent styling across the app
- Includes gradients, shadows, and text themes

### 5. Services (`core/services/`)

#### JsonService (`json_service.dart`)
**Responsibilities:**
- Load and parse JSON schema
- Convert JSON to PageSchema model
- Handle JSON parsing errors

**Current Implementation:**
- Uses hardcoded JSON string (can be replaced with API call)
- Simulates network delay
- Returns PageSchema with components

### 6. Component Factory (`widgets/component_factory.dart`)

**Design Pattern:** Factory Pattern

**Responsibilities:**
- Create appropriate widget based on component type
- Apply consistent styling to all components
- Handle component type mapping

**Component Types Supported:**
1. **Banner** - Single image display
2. **Carousel** - Image carousel with auto-play
3. **Grid** - Grid layout for multiple images
4. **Video** - Video player with controls
5. **Text** - Text display with styling options

### 7. Component Widgets (`widgets/components/`)

All component widgets follow a consistent pattern:

#### Common Structure:
```dart
class ComponentWidget extends StatelessWidget/StatefulWidget {
  // Properties from JSON
  final PropertyType property;
  
  // Factory constructor from Component
  factory ComponentWidget.fromComponent(Component component) {
    // Parse properties from component.properties
  }
  
  @override
  Widget build(BuildContext context) {
    // Render widget
  }
}
```

#### Special Features:

**VideoWidget:**
- Uses `video_player` and `chewie` for playback
- Implements `AutomaticKeepAliveClientMixin` to prevent reload on scroll
- Handles app lifecycle (pauses when app goes to background)
- Manages video controller disposal properly

**GridWidget:**
- Uses `GridImageWidget` (StatefulWidget) for individual images
- Implements fallback mechanism for image loading
- Handles image errors gracefully

**BannerWidget:**
- Uses `CachedNetworkImage` for efficient image loading
- Includes gradient overlay
- Error handling with placeholder

## Data Flow

### 1. Application Startup
```
main.dart
  ↓
DynamicWidgetRendererApp (app.dart)
  ↓
SplashScreen
  ↓
HomeView
```

### 2. Data Loading Flow
```
HomeView.initState()
  ↓
HomeViewModel.loadPageData()
  ↓
JsonService.loadPageSchema()
  ↓
Parse JSON → PageSchema
  ↓
HomeViewModel updates state
  ↓
HomeView rebuilds with components
  ↓
ComponentFactory.createComponent()
  ↓
Render appropriate widget
```

### 3. Component Rendering Flow
```
PageSchema.components
  ↓
ComponentFactory.createComponent()
  ↓
Switch on ComponentType
  ↓
Create specific widget (BannerWidget, CarouselWidget, etc.)
  ↓
Widget.fromComponent() parses properties
  ↓
Widget.build() renders UI
```

## Design Patterns

### 1. Factory Pattern
- **ComponentFactory**: Creates widgets based on component type
- Centralizes widget creation logic
- Easy to extend with new component types

### 2. MVVM Pattern
- **Model**: Component, PageSchema, AppTheme
- **View**: HomeView, Component widgets
- **ViewModel**: HomeViewModel
- Clear separation of concerns

### 3. Observer Pattern
- ViewModel notifies View via callbacks
- View reacts to state changes

### 4. Singleton Pattern (Implicit)
- JsonService instance in ViewModel
- AudioManager static methods

### 5. Strategy Pattern
- Different rendering strategies for different component types
- Implemented via switch statement in ComponentFactory

## State Management

### Current Approach: Callback-based

**ViewModel → View Communication:**
```dart
_viewModel.loadPageData(onStateChanged: _updateState);

void _updateState() {
  if (mounted) {
    setState(() {});
  }
}
```

**Benefits:**
- Simple and lightweight
- No external dependencies for state management
- Direct control over when UI updates

**Alternative Consideration:**
- Provider package is included but not actively used
- Could be migrated to Provider/ChangeNotifier for more complex state

## Error Handling

### Global Error Handling (`main.dart`)
- `FlutterError.onError` for framework errors
- `runZonedGuarded` for uncaught exceptions
- Suppresses known third-party package errors (Chewie disposal issues)

### Component-Level Error Handling
- Image loading errors: Fallback to placeholder icons
- Video errors: Error widget with retry option
- JSON parsing errors: Caught and displayed in error state

### State-Based Error Handling
- HomeViewModel manages error state
- HomeView displays error UI with retry option
- User-friendly error messages

## Performance Optimizations

### 1. Image Caching
- `CachedNetworkImage` for efficient image loading
- Disk and memory caching
- Placeholder and error widgets

### 2. Video Memory Management
- `AutomaticKeepAliveClientMixin` prevents video reload on scroll
- Proper controller disposal
- Lifecycle-aware pausing

### 3. Widget Optimization
- StatelessWidget where possible
- StatefulWidget only when needed (GridImageWidget, VideoWidget)
- Efficient rebuilds with proper keys

### 4. Lazy Loading
- ListView.builder for efficient list rendering
- Components loaded only when visible

## Responsive Design

### Orientation Handling
- Portrait and landscape layouts
- Different app bar layouts for each orientation
- MediaQuery for responsive sizing

### Dark Mode Support
- Complete theme system with light/dark modes
- All components adapt to theme
- Consistent color scheme

## Dependencies

### Core Dependencies
- **flutter**: SDK
- **provider**: State management (included but not actively used)

### UI Components
- **carousel_slider**: Image carousel functionality
- **shimmer**: Loading placeholder effects
- **cached_network_image**: Efficient image loading and caching

### Media
- **video_player**: Video playback functionality
- **chewie**: Video player UI controls
- **audio_session**: Audio session management
- **just_audio**: Audio playback (included but not actively used)

## Extension Points

### Adding New Component Types

1. **Add ComponentType enum** (`core/models/component.dart`):
```dart
enum ComponentType {
  // ... existing types
  newComponent,
}
```

2. **Update Component parsing** (`component.dart`):
```dart
case 'newComponent':
  return ComponentType.newComponent;
```

3. **Create widget** (`widgets/components/new_component_widget.dart`):
```dart
class NewComponentWidget extends StatelessWidget {
  factory NewComponentWidget.fromComponent(Component component) {
    // Parse properties
  }
}
```

4. **Register in factory** (`widgets/component_factory.dart`):
```dart
case ComponentType.newComponent:
  return NewComponentWidget.fromComponent(component);
```

### Adding New Services

1. Create service class in `core/services/`
2. Inject into ViewModel
3. Use in ViewModel methods
4. Handle errors appropriately

## Best Practices

### 1. Code Organization
- Clear folder structure by feature/type
- Consistent naming conventions
- Separation of concerns

### 2. Error Handling
- Graceful degradation
- User-friendly error messages
- Retry mechanisms

### 3. Performance
- Efficient widget rebuilds
- Proper memory management
- Caching strategies

### 4. Maintainability
- Clear documentation
- Consistent patterns
- Easy to extend

### 5. Testing Considerations
- ViewModels are testable (no UI dependencies)
- Services can be mocked
- Components can be tested in isolation

## Future Enhancements

### Potential Improvements
1. **State Management**: Migrate to Provider/Riverpod for complex state
2. **API Integration**: Replace hardcoded JSON with API calls
3. **Caching**: Implement persistent caching for page schemas
4. **Offline Support**: Cache components for offline viewing
5. **Animation**: Add more sophisticated animations
6. **Testing**: Add unit and widget tests
7. **Localization**: Support multiple languages
8. **Accessibility**: Improve accessibility features

## Notes

- The app uses a custom `AppBarPainter` for curved app bar design
- Video widgets implement lifecycle awareness for proper resource management
- All components support dark mode through theme system
- The architecture is designed to be easily extensible

