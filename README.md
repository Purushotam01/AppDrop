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
lib/
├── app/
│   └── app.dart                     # App root, Themes & routing
│
├── core/
│   ├── constants/                   # App constants
│   ├── models/
│   │   ├── app_theme.dart           # Light/Dark theme config
│   │   ├── component.dart           # Schema models
│   │   └── page.dart                # Page schema
│   └── services/
│       └── json_service.dart        # Loads + parses JSON
│
├── home/
│   ├── home_view.dart               # View
│   └── home_viewmodel.dart          # ViewModel (logic/state)
│
├── utils/
│   ├── audio_manager.dart
│   ├── network_image_builder.dart
│   └── responsive.dart
│
├── widgets/
│   ├── components/                  # Dynamic components
│   │   ├── banner_widget.dart
│   │   ├── carousel_widget.dart
│   │   ├── grid_widget.dart
│   │   ├── text_widget.dart
│   │   └── video_widget.dart
│   ├── placeholder/                 # Shimmer loaders
│   ├── app_bar_painter.dart
│   └── component_factory.dart       # Creates components dynamically
│
├── splash_screen.dart
└── main.dart

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

🧠 Architecture

This project follows the MVVM architecture:

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
Factory Pattern

ComponentFactory → Creates widgets based on type

Observer Pattern

ViewModel → View callbacks

Singleton Pattern

JsonService instance reused

Strategy Pattern

Each component uses its own render strategy

🎥 Video Player Features

Auto-pause on background

Looping

Mute/unmute

Fullscreen mode

Stabilized scrolling (no re-init)

Error widget + retry

⚠️ Error Handling

JSON format errors → error UI with retry

Network image failures → placeholder

Video load errors → error message

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

Accessibility enhancements

📄 Assets Configuration

Add this to pubspec.yaml:

flutter:
  assets:
    - assets/page_schema.json

📜 License

This project is built for assignment and demonstration purposes only.

🙋 Author

Purushotam Kumar
Flutter Developer | Dynamic UI Rendering | MVVM | Scalable Architecture

If you want, I can also generate:

✅ Assignment-friendly screenshots layout
✅ A demo GIF
✅ A project badge header
Just tell me!

You said:
jo mere app me structure h wahi do bs
ChatGPT said:

Got it Purushotam —
Ab main README सिर्फ aur सिर्फ tumhare actual project ki folder structure ke hisaab se likh raha hoon.
Koi extra folder, koi extra file, koi assumption — nothing.
Exactly your structure from the screenshot.

✅ FINAL README (Exactly Matching Your Project Structure)

Copy–paste this directly.

AppDrop – Dynamic Widget Rendering Engine

A Flutter application that renders full UI screens dynamically from a JSON schema.
The app uses a clean MVVM architecture and a component-based rendering engine.

📁 Project Structure (Exactly as in your code)
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
│   ├── component_factory.dart
│   └── splash_screen.dart
│
└── main.dart


This is 100% identical to your workspace structure. ✔

🚀 Overview

UI is generated dynamically from assets/page_schema.json

Each JSON object corresponds to a UI component

ComponentFactory converts schema → widget

MVVM ensures clean separation of UI & business logic

🧩 Supported Components
1. Banner
{
  "type": "banner",
  "image": "URL",
  "height": 200,
  "padding": 16,
  "radius": 20
}

2. Carousel
{
  "type": "carousel",
  "images": ["URL1", "URL2"],
  "height": 240,
  "autoPlay": true
}

3. Grid
{
  "type": "grid",
  "images": ["URL1","URL2"],
  "columns": 2,
  "spacing": 12
}

4. Video
{
  "type": "video",
  "url": "VIDEO_URL",
  "height": 220,
  "autoPlay": false,
  "loop": false,
  "showControls": true
}

5. Text
{
  "type": "text",
  "value": "Hello",
  "size": 24,
  "weight": "bold",
  "align": "center"
}

🧠 Architecture (Matches Your Code)
Model (core/models)

component.dart → JSON → Component model

page.dart → Page schema

app_theme.dart → Theme handling

View (home/home_view.dart)

Builds UI

Listens for ViewModel updates

Renders dynamic components

ViewModel (home/home_viewmodel.dart)

Loads JSON

Notifies UI

Maintains state

Services

json_service.dart → Reads + parses JSON schema

Component Rendering Engine

component_factory.dart → Selects correct widget type

Components inside widgets/components/

🎥 Video Handling Features (Your Code)

Fullscreen mode (fullscreen_video_page.dart)

Auto-pause when screen changes

Looping + mute support

Error safe rendering

Does not reinitialize on scroll

⚠️ Error & Loading Handling
Loading:

shimmer_placeholder.dart

Errors:

Invalid JSON → message + retry

Failed image loads → cached builder fallback

Video errors → fallback UI

📦 Installation
flutter pub get
flutter run


Build APK:

flutter build apk --release

📄 Assets Configuration

Add this in pubspec.yaml:

flutter:
  assets:
    - assets/page_schema.json

🌐 Platform Support

Android

iOS

Web (video limited)

🔮 Future Enhancements (Optional for Assignment)

Load JSON from API

More component types (Button, Card, Form)

Offline caching

Animations

Unit tests

✍️ Author

Purushotam Kumar
Flutter Developer
