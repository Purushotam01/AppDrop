AppDrop – Dynamic Widget Rendering Engine

A Flutter application that dynamically renders complete UI screens from a JSON schema.
This assignment demonstrates modular architecture, scalable component handling, and clean MVVM implementation suitable for production-grade apps.

🚀 Overview

This project loads a page_schema.json file from assets and renders the UI dynamically using a component-driven architecture.
Each JSON object maps to a Flutter widget through a Component Factory, enabling extensibility and clean separation of concerns.

✨ Features
🎨 Dynamic UI Rendering

Entire screen rendered from JSON data

Supports multiple component types

Easily extendable for new components

🧩 Supported Components

Image Banner

Image Carousel

Image Grid

Video Player

Text Block

⚙️ Technical Features

MVVM architecture

Component Factory Pattern

Responsive layout

CachedNetworkImage for smooth loading

Shimmer placeholders

Full video lifecycle handling

Error states + retry handling

Custom gradient AppBar with curve

Smooth scrolling + optimized rebuilds

📦 Installation & Setup
git clone <repo-link>
cd app_drop
flutter pub get
flutter run

To build APK:
flutter build apk --release

📁 Project Structure

(Matches exactly your app folder structure)

```bash
lib/
├── app/
│   └── app.dart
│
├── core/
│   ├── models/
│   │   ├── app_theme.dart
│   │   ├── component.dart
│   │   └── page.dart
│   └── services/
│       └── json_service.dart
│
├── home/
│   ├── home_view.dart
│   └── home_viewmodel.dart
│
├── utils/
│   ├── audio_manager.dart
│   ├── network_image_builder.dart
│   └── responsive.dart
│
├── widgets/
│   ├── components/
│   │   ├── banner_widget.dart
│   │   ├── carousel_widget.dart
│   │   ├── fullscreen_video_page.dart
│   │   ├── grid_widget.dart
│   │   ├── text_widget.dart
│   │   └── video_widget.dart
│   ├── placeholder/
│   │   └── shimmer_placeholder.dart
│   ├── app_bar_painter.dart
│   └── component_factory.dart
│
├── splash_screen.dart
└── main.dart
```

🧩 Component Schema Examples
1. Banner Component
{
  "type": "banner",
  "image": "https://example.com/image.jpg",
  "height": 200,
  "padding": 16,
  "radius": 20
}

2. Carousel Component
{
  "type": "carousel",
  "images": ["url1", "url2"],
  "height": 240,
  "autoPlay": true,
  "padding": 16
}

3. Grid Component
{
  "type": "grid",
  "images": ["url1", "url2"],
  "columns": 2,
  "spacing": 12,
  "padding": 16
}

4. Video Component
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

5. Text Component
{
  "type": "text",
  "value": "Welcome to AppDrop",
  "size": 24,
  "weight": "bold",
  "align": "center",
  "padding": 24,
  "color": "#333333"
}

🧠 Architecture (MVVM)
Model

Data models for components

JSON parsing (Component, PageSchema)

JsonService for loading schema

View

HomeView + Widgets

Listens for updates from ViewModel

ViewModel

Loads schema

Holds UI state

Notifies view via callbacks

🔧 Design Patterns Used

Factory Pattern → ComponentFactory creates widgets based on type

Observer Pattern → ViewModel → View updates

Singleton Pattern → JsonService reused

Strategy Pattern → Each component renders through its own strategy

🎥 Video Player Features

Auto-pause on background

Looping support

Mute/unmute

Fullscreen mode

Stabilized scrolling (no re-init)

Error widget + retry

⚠️ Error Handling

JSON format errors → error UI + retry

Network image failures → placeholder fallback

Video load errors → error widget

Loader placeholders (Shimmer)

🖥️ Platform Support

Android

iOS

Web (limited video support)

macOS

Windows

Linux

🔮 Future Enhancements

Load JSON dynamically via API

Offline caching

New components (button, form fields, cards, etc.)

Animation improvements

Unit tests + widget tests

Localization

Accessibility improvements

📄 Assets Configuration

Add this to your pubspec.yaml:

flutter:
  assets:
    - assets/page_schema.json

📜 License

This project is built for assignment and demonstration purposes only.
