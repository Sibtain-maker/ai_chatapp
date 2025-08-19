# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**LuminAI** is an AI-powered productivity Flutter application that provides document scanning, editing, file conversion, and AI assistance capabilities. The app features a clean, modern interface with four main functional areas accessible from a central dashboard.
The complete plan for the project has been written to @plan.md


### Key Features
- **📄 Document Scanner**: Scan documents and ID cards using device camera with OCR text extraction
- **✏️ Document Editor**: Edit PDFs and images with annotation tools, signatures, and markup capabilities  
- **🔄 File Converter**: Convert between multiple formats (PDF, DOCX, JPG, TXT) with batch processing
- **🤖 AI Assistant**: Chat interface for document summarization, writing assistance, and content analysis

### Target Platforms
- Primary: iOS and Android mobile applications
- Secondary: Web application for basic features
- Future: Desktop applications (macOS, Windows, Linux)

### Current Status
- Supabase backend initialized and configured
- Project dependencies added for all core features
- Ready for folder structure implementation and feature development

## Development Commands

### Running the Application
- `flutter run` - Run on connected device/emulator
- `flutter run -d chrome` - Run on web browser
- `flutter run -d macos` - Run on macOS desktop
- `flutter run --hot` - Run with hot reload enabled
- `flutter run --profile` - Run in profile mode for performance testing

### Testing
- `flutter test` - Run all widget and unit tests
- `flutter test test/widget_test.dart` - Run specific test file
- `flutter test --coverage` - Run tests with coverage report

### Code Quality & Analysis  
- `flutter analyze` - Static analysis of Dart code
- `flutter doctor` - Check development environment setup
- `flutter doctor --android-licenses` - Accept Android licenses if needed

### Build Commands
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app (requires macOS/Xcode)
- `flutter build web` - Build web application
- `flutter build macos` - Build macOS desktop app

### Dependencies
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies
- `flutter pub outdated` - Check for newer package versions

## Project Architecture

LuminAI follows clean architecture principles with Riverpod for state management and Supabase for backend services:

### State Management - Riverpod
- Uses `flutter_riverpod: ^2.6.1` for reactive state management
- Providers should be defined for chat state, user authentication, and API calls
- Follow Riverpod patterns for dependency injection and state sharing

### Backend - Supabase
- Uses `supabase_flutter: ^2.9.1` for backend services
- Provides real-time database, authentication, and storage capabilities
- Supabase client should be initialized in main.dart before app launch
- Environment configuration needed for Supabase URL and API keys

### Current State
- Supabase backend initialized with URL and API key configuration
- All required dependencies added to pubspec.yaml (camera, PDF, file handling, AI features)
- Ready to implement folder structure and begin feature development

## Development Structure

### Key Directories
- `lib/` - Main Dart source code
- `test/` - Widget and unit tests  
- `android/`, `ios/`, `web/`, `macos/`, `windows/`, `linux/` - Platform-specific code
- `pubspec.yaml` - Dependencies and app configuration

### Expected Architecture Patterns
- **UI Layer**: Flutter widgets organized by feature (scanner, editor, converter, ai_chat)
- **State Layer**: Riverpod providers for business logic and state management
- **Data Layer**: Supabase client for authentication, file storage, and real-time data
- **Models**: Dart classes for documents, users, conversations, and file conversions

## Testing Strategy

- Widget tests in `test/` directory using `flutter_test` framework
- Test files should mirror the lib/ structure
- Use `WidgetTester` for UI component testing
- Mock Supabase calls for isolated testing

## Platform Support

This project supports all Flutter platforms:
- **Mobile**: iOS and Android with full native capabilities
- **Desktop**: macOS, Windows, Linux desktop applications  
- **Web**: Progressive web app with responsive design

## Development Workflow

### Hot Reload
- Save files to trigger hot reload during `flutter run`
- Use `r` in terminal to manually hot reload
- Use `R` for full hot restart when needed

### Debugging
- Use Flutter DevTools for debugging and performance profiling
- Add breakpoints in IDE or use `debugger()` statements
- `flutter logs` for viewing device logs

### Code Style
- Follows `flutter_lints: ^5.0.0` linting rules
- Analysis options configured in `analysis_options.yaml`
- Use `flutter format .` to auto-format code