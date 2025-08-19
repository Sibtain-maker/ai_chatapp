# Nixtio - AI Productivity App Development Plan

## 📱 App Overview
A Flutter productivity app with AI features including document scanning, editing, file conversion, and AI assistance.

## 🎯 Core Features

### Main Dashboard
- Personalized greeting: "Hi Nixtio, How can I help you today?"
- Help icon (top-left) and notification bell with badge (top-right)
- **Four Feature Cards:**
  1. **📄 Scan** - Documents & ID cards
  2. **✏️ Edit** - Sign, annotate, markup documents  
  3. **🔄 Convert** - PDF, DOCX, JPG, TXT conversion
  4. **🤖 Ask AI** - Summarize, write, analyze
- Search bar with voice input
- Bottom navigation with profile and add buttons

## 🏗️ Technical Stack

### Dependencies
```yaml
# Core
flutter_riverpod: ^2.6.1    # State management
supabase_flutter: ^2.9.1    # Backend
go_router: ^14.2.7          # Navigation

# Features
image_picker: ^1.0.7        # Photo selection
camera: ^0.10.5+9           # Camera access
pdf: ^3.10.8                # PDF handling
file_picker: ^8.0.0+1       # File selection
speech_to_text: ^6.6.2      # Voice input

# UI
flutter_svg: ^2.0.10+1      # Icons
flutter_staggered_animations: ^1.1.1  # Animations
```

### Folder Structure
```
lib/
├── main.dart
├── app/
│   ├── app.dart              # Main app widget
│   ├── router.dart           # Route configuration
│   └── theme.dart            # App theming
├── features/
│   ├── auth/                 # Authentication
│   ├── home/                 # Dashboard
│   ├── scanner/              # Document scanning
│   ├── editor/               # Document editing
│   ├── converter/            # File conversion
│   └── ai_chat/              # AI assistance
├── shared/
│   ├── providers/            # Global providers
│   ├── widgets/              # Reusable widgets
│   └── utils/                # Helper functions
└── core/
    ├── services/             # External services
    └── models/               # Data models
```

## 🗄️ Supabase Backend

### Database Tables
```sql
-- User profiles
users (id, email, name, avatar_url, created_at)

-- Document storage
documents (id, user_id, title, file_path, file_type, file_size, created_at)

-- AI chat history
ai_conversations (id, user_id, conversation_id, message, response, created_at)

-- File conversion tracking
file_conversions (id, user_id, original_file_path, converted_file_path, 
                 from_format, to_format, status, created_at)
```

### Storage Buckets
- `documents` - Scanned/uploaded files
- `converted_files` - Converted documents
- `avatars` - User profile pictures

## 🚀 Development Phases

### Phase 1: Foundation Setup
- [x] Configure Supabase project (auth, database, storage) ✅ **COMPLETED**
- [x] Create Flutter folder structure ✅ **COMPLETED**
- [ ] Setup app theme and routing
- [ ] Initialize core services

### Phase 2: Authentication
- [ ] Login/signup screens
- [ ] Password reset functionality
- [ ] User profile management
- [ ] Session handling with Riverpod

### Phase 3: Main Dashboard
- [ ] Home screen layout with greeting
- [ ] Four feature cards with icons
- [ ] Search bar with voice input
- [ ] Bottom navigation setup

### Phase 4: Core Features

#### 📄 Scanner
- [ ] Camera integration for document scanning
- [ ] Image enhancement and cropping
- [ ] OCR text extraction
- [ ] ID card detection and parsing

#### ✏️ Editor
- [ ] PDF viewer and annotation tools
- [ ] Digital signature functionality
- [ ] Text overlay and markup
- [ ] Basic image editing

#### 🔄 Converter
- [ ] File format conversion engine
- [ ] Batch processing support
- [ ] Conversion queue and progress tracking
- [ ] Download management

#### 🤖 Ask AI
- [ ] Real-time chat interface
- [ ] Document analysis and summarization
- [ ] Writing assistance features
- [ ] File attachment support

### Phase 5: Polish & Optimization
- [ ] Voice commands integration
- [ ] Offline support with sync
- [ ] Performance optimization
- [ ] Comprehensive testing

## 🎨 Design Guidelines

### Colors
- Background: `#F5F5F7` (Light gray)
- Cards: White with subtle shadows
- Text: `#1D1D1F` (Dark) / `#6E6E73` (Gray)
- Accent: `#FF6B35` (Orange for notifications)

### Layout
- Card-based design with rounded corners
- Consistent 16px padding
- 2x2 grid for feature cards
- Floating bottom navigation

## ✅ Development Checklist

### Setup Tasks
- [x] Initialize Supabase project ✅ **COMPLETED**
- [ ] Configure authentication providers
- [ ] Create database schema
- [ ] Setup storage buckets
- [ ] Configure environment variables

### Core Implementation
- [ ] Implement authentication flow
- [ ] Build main dashboard UI
- [ ] Create feature navigation
- [ ] Integrate camera functionality
- [ ] Setup file handling system

### Advanced Features
- [ ] Implement AI chat with backend
- [ ] Add voice recognition
- [ ] Create conversion pipeline
- [ ] Setup document editing tools
- [ ] Add notification system

### Testing & Deployment
- [ ] Write unit tests
- [ ] Create widget tests
- [ ] Performance testing
- [ ] App store preparation
- [ ] Deploy to production

## 📋 Next Steps

1. **Start with Phase 1**: Setup Supabase and basic Flutter structure
2. **Focus on MVP**: Dashboard + one working feature (Scanner)
3. **Iterate quickly**: Get user feedback early
4. **Scale gradually**: Add features based on usage

---

This plan provides a clear roadmap for building the Nixtio app with modern Flutter practices and Supabase backend integration.