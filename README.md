Recipe Finder App (ITE-E4-Khin-Nara)
A comprehensive Flutter-based culinary discovery platform. This application allows users to explore global recipes via a REST API, manage a personalized cookbook with local SQLite persistence, and benefit from an intelligent recommendation engine.

🌟 Key Features
1. High-Impact Onboarding
Multi-stage Introduction: A 3-page interactive onboarding experience using PageView to familiarize users with the app's ecosystem.

Visual Polish: Custom animated page indicators and vibrant gradients for a premium first impression.

2. Intelligent Home Experience
Surprise Pick Banner: A large, high-visibility "Hero" banner at the top of the Home screen to drive user engagement.

Smart Discovery Engine: A logic-based system that analyzes user favorites to recommend new recipes within their top-liked categories.

Visual Categorization: Horizontal category and area lists enriched with localized emojis and flags (e.g., 🥩 Beef, 🇮🇹 Italian) for intuitive browsing.

3. Advanced Search & Navigation
Global Filter Synchronization: Navigation logic that allows users to tap a category on the Home screen and jump directly to the Explore tab with filters pre-applied.

Real-time Filtering: An Explore screen equipped with instant search and category chip filtering.

4. Professional Detail Views
Seamless Motion: Implementation of Hero Animations for smooth, high-end transitions of meal images across screens.

Multimedia Integration: Direct access to YouTube video tutorials and original recipe sources via url_launcher.

5. Local Data Management
SQLite Persistence: Complete integration of sqflite for a reliable offline "My Saved Recipes" experience.

State Management: Reactive UI updates using Provider to ensure the "Favorite" status is consistent across all tabs.

🚀 Extra Mile & Creativity (+2 Bonus Points)
This project implements several advanced features beyond the standard requirements:

Hero Suffix System: Developed a unique tag system (-rec, -grid, -banner) to prevent "Multiple Hero Tags" crashes when the same meal appears in multiple UI sections simultaneously.

Interactive Ingredient Checklist: Replaced static text lists with a functional IngredientChecklist widget, allowing users to track their cooking progress in real-time.

Native Social Sharing: Integrated the share_plus package to allow users to instantly share recipe names and links with friends.

Production-Ready Interaction: Added Pull-to-Refresh functionality on the Home screen to simulate a realistic, dynamic data environment.

Discovery Filtering: Optimized the recommendation logic to exclude recipes already saved by the user, ensuring the "Smart Suggestions" always offer new discoveries.

🛠️ Technical Implementation
State Management: Provider.

Database: sqflite (SQLite).

Networking: http for REST API integration.

Deep Linking: url_launcher for external video and source content.

⚙️ Setup Instructions
Clone the Project:

Bash

git clone https://github.com/macra12/recipe-app-flutter-ITE-E4-Khin-Nara.git
Fetch Dependencies:

Bash

flutter pub get
Run Application:

Bash

flutter run
