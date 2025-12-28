# 🍳 Recipe Finder App: Professional Edition
**Project by: Khin Nara (ITE-E4)**

A high-performance Flutter application designed for an immersive culinary experience. This project goes beyond basic requirements by integrating **native hardware sensors**, **advanced persistent caching**, and a **cinematic edge-to-edge UI**.

---

## 🚀 "Extra Mile" & Technical Achievements (+Bonus Ready)
This project exceeds standard lab requirements with the following professional-grade implementations:

* **Shake-to-Discover Sensor Logic**: Integrated the `sensors_plus` package to detect physical device movement. Users can shake their phone on the Home screen to trigger a "Surprise Pick" meal update, complete with haptic feedback for a tactile experience.
* **Persistent Image Storage (Disk Caching)**: Implemented `cached_network_image` to ensure that once a recipe image is downloaded, it is stored locally on the device disk. This saves user data and allows images to load instantly even in offline mode.
* **Edge-to-Edge Immersive UI**: Utilized `SystemUiMode.edgeToEdge` and a transparent status bar configuration to allow background images to flow behind the camera notch and home indicator. This provides a truly modern, cinematic feel.
* **Hero Suffix Animation System**: Developed a custom tag system (`-rec`, `-grid`, `-banner`) to prevent "Duplicate Hero Tag" crashes. This enables smooth motion transitions even when the same recipe appears in multiple sections of the UI.
* **Smart Recommendation Engine**: Created custom logic that analyzes a user's saved recipes to calculate their "Top Category". The app then suggests new meals from that category while intelligently excluding recipes the user has already favorited.



---

## 🌟 Key Features

### 1. Cinematic Onboarding & Discovery
* **Immersive Onboarding**: A high-impact three-stage entry experience using full-screen cached images and smooth page transitions.
* **Surprise Pick Banner**: A persistent banner on the Home screen that uses state management to prevent visual flickering during scrolls or updates.
* **Global Navigation Sync**: Selecting a category emoji (🥩) or area flag (🇮🇹) on the Home screen instantly navigates the user to the Explore tab with those filters pre-applied.

### 2. Advanced Search & Cooking Tools
* **Debounced Search**: The Explore screen features a 300ms debounce timer to ensure smooth, lag-free filtering as the user types.
* **Interactive Ingredient Checklist**: Transformed static ingredient lists into a functional tool where users can "check off" items as they cook.
* **Multimedia Integration**: Instant access to YouTube video tutorials and original recipe sources via deep-linking.
* **Native Social Sharing**: Integrated `share_plus` to allow users to share recipe names and links with a single tap.

### 3. Local Persistence & Offline Mode
* **SQLite Favorites**: Full integration with `sqflite` ensures saved recipes are persisted locally and available without an internet connection.
* **JSON Cache Layer**: The main recipe database is cached as a JSON string using `SharedPreferences`, allowing the app to boot up and display data immediately while offline.



---

## 🛠️ Technical Stack
* **Framework**: Flutter (Material 3)
* **State Management**: `Provider` (Multi-provider architecture)
* **Local Database**: `sqflite` (SQLite)
* **Persistence**: `SharedPreferences`
* **Hardware Interaction**: `sensors_plus` (Accelerometer)
* **UI/UX Enhancements**: `cached_network_image`, `lottie` animations, and `AnimatedSwitcher`

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
