# Recipe Finder App
**Student Name:** Khin Nara  
**Class:** ITE-E4  
**Lab Assignment:** Lab 3 - Recipe Finder App

---

## 📖 Project Overview
A high-performance Flutter application built for an immersive culinary experience. This app consumes a simplified JSON SERVER API to allow users to browse, search, and save global recipes. It features a cinematic UI, offline persistence, and native hardware integration.

---

## 🚀 "Extra Mile" & Creativity
This project exceeds the base requirements with professional-grade implementations:

* **Shake-to-Discover Sensor**: Integrated `sensors_plus` to detect physical device movement. Users can shake their phone on the Home screen to trigger a "Surprise Pick" meal update with haptic feedback.
* **Persistent Image Storage (Disk Caching)**: Implemented `cached_network_image` to ensure that once a recipe image is downloaded, it is stored locally.This saves user data and enables a full offline experience.
* **Edge-to-Edge Immersive UI**: Utilized `SystemUiMode.edgeToEdge` to allow background images to flow behind the status bar and home indicator for a modern, cinematic look.
* **Hero Suffix Animation System**: Developed a custom tag system (`-rec`, `-grid`, `-banner`) to prevent "Duplicate Hero Tag" crashes, enabling smooth motion transitions across multiple UI sections.
* **Smart Recommendation Engine**: Custom logic in `FavoriteProvider` analyzes saved recipes to calculate the user's "Top Category" and suggest new meals they haven't favorited yet.
* **Interactive Ingredient Checklist**: Transformed the static ingredient list into a functional tool where users can "check off" items as they cook to track their progress.

---

## 🌟 Core Features (Lab Requirements)

### 1. Onboarding Experience
* A cinematic three-stage introduction using full-screen cached images and smooth page transitions.

### 2. Home Screen 
* **Surprise Pick Banner**: High-impact banner displaying random food suggestions.
* **Category & Area Chips**: Interactive cards with food emojis and country flags for quick navigation.
* **Bottom Navigation**: Seamless switching between Home, Explore, and Favourite sections.

### 3. Explore & Search
* **Filter Chips**: Real-time filtering by categories.
* **Debounced Search**: A 300ms debounce timer ensures lag-free filtering as the user types.
* **Global Sync**: Selecting a category on Home automatically updates the Explore filters.

### 4. Meal Details & Persistence 
* **Rich Details**: Displays ingredients, instructions, and multimedia links (YouTube/Source).
* **Offline Favorites**: Integrated with `sqflite` (SQLite) to ensure saved recipes are accessible without internet.
* **Native Sharing**: Integrated `share_plus` to allow users to share recipes instantly.

---

## 🛠️ Technical Implementation
* **Language**: Dart
* **UI Framework**: Flutter (Material 3) 
* **State Management**: `Provider` (Multi-provider architecture) 
* **Asynchronous Logic**: Comprehensive use of `async/await` for API and Database operations.
* **API Integration**: Consumes REST API with unique `X-DB-NAME` GUID headers.
* **Local Storage**: `sqflite` for favorites and `SharedPreferences` for full-database JSON caching.

---

## ⚙️ Setup & Installation
1.  **Clone the repository**:
   
    ```bash
    git clone https://github.com/macra12/recipe-app-flutter-ITE-E4-Khin-Nara.git
    ```
   
2.  **Install dependencies**:
   
    ```bash
    flutter pub get
    ```
    
3.  **Run the application**:
   
    ```bash
    flutter run
    ```
