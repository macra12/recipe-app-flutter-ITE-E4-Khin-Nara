# 🍳 Recipe Finder App

**Project by: Khin Nara (ITE-E4)**

A high-performance Flutter application for culinary discovery and real-time cooking assistance. This app integrates a REST API for global recipe data, local SQLite storage for offline favorites, and a custom "Smart Discovery" recommendation engine.

---

## 🚀 Extra Mile & Creativity (+2 Bonus Points)

This project exceeds the base requirements with the following specialized implementations:

* **Hero Suffix System**: A custom tag system (`-rec`, `-grid`, `-banner`) was implemented to prevent "Multiple Hero Tags" crashes, allowing the same meal to appear in multiple sections with smooth, realistic animations.
* **Interactive Cooking Checklist**: Transformed the static ingredient list into a functional tool where users can "check off" items as they cook to keep track of their progress.
* **Smart Discovery Logic**: The recommendation engine intelligently excludes recipes the user has already favorited to encourage the discovery of new meals.
* **Global Navigation Sync**: Clicking a category (like 🥩 Beef) or a flag (like 🇮🇹 Italian) on the Home screen automatically switches the tab and applies those filters on the Explore screen.
* **Native Social Sharing**: Integrated the `share_plus` package to allow users to instantly share recipe links and names with friends.

---

## 🌟 Key Features

### 1. High-Impact Discovery
* **Surprise Pick Banner**: A premium, large-scale banner at the top of the Home screen to highlight random global delicacies.
* **Visual Categories**: Interactive chips for Categories and Areas featuring food emojis and country flags for intuitive browsing (e.g., 🍰 Dessert, 🇺🇸 American).
* **Smart Suggestions**: A personalized horizontal scroll section that suggests meals based on your favorite categories.

### 2. Advanced Search & Filtering
* **Explore Tab**: Real-time search functionality and category filter chips to narrow down results from the database.
* **Seamless Transitions**: Professional **Hero animations** that transition recipe images fluidly between screens for a realistic app feel.

### 3. Detailed Recipe Insights
* **Multimedia Support**: One-tap access to YouTube video tutorials and original recipe sources via `url_launcher`.
* **Ingredient Management**: Detailed breakdown of ingredients with exact measurements and step-by-step instructions.

### 4. Personal Cookbook (Favorites)
* **SQLite Persistence**: Full integration with `sqflite` to ensure saved recipes are accessible even without an internet connection.
* **Reactive UI**: Using `Provider` to ensure the "Favorite" status is instantly updated across all screens.



---

## 🛠️ Technical Stack

* **Framework**: Flutter (Material 3)
* **State Management**: `Provider`
* **Local Database**: `sqflite` (SQLite)
* **Networking**: `http` for REST API consumption
* **Deep Linking**: `url_launcher` for external content

---

## ⚙️ Setup & Installation

1. **Clone the repository**:
   
   ```bash
   git clone https://github.com/macra12/recipe-app-flutter-ITE-E4-Khin-Nara.git
2. **Install dependencies**:
   
   ```bash
   flutter pub get
3. **Run the application**:
   
   ```bash
   flutter run
