# Mobile Development 2 

**Student Name:** Khin Nara  
**Class:** ITE-E4  
**Lecturer:** Hang Sopheak  
**Lab Assignment:** Lab 3 - Recipe Finder App (Flutter)

---

## Demo Video

Here is a 2-minute video walkthrough demonstrating all the required features of the app.

**https://youtu.be/X8BCFBhL7YQ**

---

## 📖 Project Overview
A high-performance Flutter application built for an immersive culinary experience. This app consumes a simplified JSON SERVER API to allow users to browse, search, and save global recipes. It features a cinematic **Deep Charcoal & Amber** UI, high-end animations, and native hardware integration.

---

## 🚀 "Extra Mile" & Creativity
This project exceeds the base requirements with professional-grade implementations:

* **Shake-to-Discover Sensor**: Integrated `sensors_plus` to detect physical movement. Users can shake their phone on the Home screen to trigger a "Surprise Pick" meal update with haptic feedback.
* **Haptic Navigation System**: Utilized `HapticFeedback` to provide tactile vibrations when navigating the floating bottom bar.
* **Staggered Animation Suite**: Implemented `flutter_staggered_animations` to ensure meal cards and list items "flow" onto the screen smoothly rather than appearing static.
* **Smart Recommendation Engine**: Custom logic in `FavoriteProvider` analyzes saved recipes to calculate the user's "Top Category" and suggest new meals based on their taste.
* **YouTube & Source Integration**: Integrated `url_launcher` to allow users to watch video tutorials or view original blog sources directly from the app.
* **Hero Suffix Animation System**: Developed a custom tag system (`-grid`, `-explore`, `-banner`) to prevent "Duplicate Hero Tag" crashes, enabling cinematic motion transitions.
* **Premium Shimmer Loading**: Replaced standard spinners with skeleton "Shimmer" effects to provide a better perceived loading speed.

---

## 🌟 Core Features

### 1. Immersive Onboarding
* A cinematic three-stage introduction using full-screen cached images and smooth page transitions.
* Uses a custom high-contrast gradient overlay to ensure text readability over any background.

### 2. Intelligent Home Screen
* **Dynamic Banner**: Displays random or shaken suggestions using a high-impact visual style.
* **Categorized Exploration**: Quick-access chips with emojis for global cuisines.
* **Personalized Suggestions**: A horizontal list of meals suggested by the Smart Recommendation Engine.

### 3. Advanced Explore & Search
* **Debounced Search**: A 300ms debounce timer prevents unnecessary API processing and UI lag as the user types.
* **Advanced Filter Modal**: A professional "Filter Search" bottom sheet that matches the application's dark theme.

### 4. Meal Details & Offline Cookbook
* **Step-by-Step Flow**: Instructions are split into numbered cards for easy reading while cooking.
* **Offline Favorites**: Powered by `sqflite` (SQLite), saved recipes remain available even without an internet connection.
* **Native Sharing**: Integrated `share_plus` to allow instant recipe sharing with friends and family.

### 5. Personalized Favourite Screen
* **Animated Recipe Collection**: Utilizes a staggered list animation suite to slide and fade saved recipes into view, providing a premium and fluid user experience.
* **Swipe-to-Remove Gestures**: Integrated `Dismissible` widgets with a custom red-accent delete background, allowing users to effortlessly unsave recipes with a single horizontal swipe.
* **Intelligent Empty State**: Features an interactive Lottie animation ("empty_cook.json") and a clear call-to-action button that guides users back to discovery when their cookbook is empty.
* **Offline Recipe Access**: Leverages `sqflite` (SQLite) to ensure that your personal cookbook is always accessible, allowing you to view saved ingredients and names without an internet connection.
* **Visual Hierarchy & Hero Motion**: Each saved recipe card features a vibrant category badge and shares a synchronized Hero tag for seamless motion transitions between the list and the details view.

---

## 🛠️ Technical Stack
* **Language**: Dart
* **UI Framework**: Flutter (Material 3)
* **State Management**: `Riverpod` (StateNotifierProvider architecture).
* **Persistence**: `sqflite` (Local DB) and `SharedPreferences` (JSON Caching).
* **API Integration**: REST API with custom `X-DB-NAME` security headers.

---

## ⚙️ Setup & Installation
1.  **Clone the repository**:
    
    ```bash
    git clone [https://github.com/macra12/recipe-app-flutter-ITE-E4-Khin-Nara.git](https://github.com/macra12/recipe-app-flutter-ITE-E4-Khin-Nara.git)
    ```
    
2.  **Install dependencies**:
    
    ```bash
    flutter pub get
    ```
    
3.  **Run the application**:
    
    ```bash
    flutter run
    ```

---

## 📁 Project Structure Highlights
* `lib/providers/`: Global state management using Riverpod.
* `lib/services/`: API communication and SQLite database helpers.
* `lib/widgets/`: Reusable UI components like the premium `MealCard`.
* `lib/screens/`: Feature-specific screens (Onboarding, Home, Explore, Saved).
