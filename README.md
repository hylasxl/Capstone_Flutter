# Flutter Social Networking App

## Overview

Flutter Social Networking App is a modern and feature-rich social media application built using Flutter and Firebase. It allows users to connect, share posts, like, comment, and interact in real time.

## Features

- **User Authentication**: Sign up, login, and logout functionality using Firebase Authentication.
- **Profile Management**: Users can update their profile, including avatar, bio, and other details.
- **Post Creation**: Users can create, edit, and delete posts with text, images, and videos.
- **Like & Comment**: Engage with posts by liking and commenting.
- **Real-Time Chat**: Private and group messaging with instant notifications.
- **Push Notifications**: Get notified about new likes, comments, and messages.
- **Follow System**: Follow/unfollow users to see their posts in the feed.
- **Search & Discover**: Search for users and explore trending posts.
- **Dark Mode Support**: Switch between light and dark themes.

## Technologies Used

- **Flutter** (Dart) - Frontend framework
- **Firebase Authentication** - User authentication
- **Firebase Firestore** - NoSQL database for storing user data
- **Firebase Storage** - For uploading images and videos
- **Firebase Cloud Messaging** - Push notifications
- **Provider/Riverpod** - State management

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/flutter-social-network.git
   cd flutter-social-network
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Set up Firebase:
   - Create a Firebase project
   - Enable Authentication (Email/Google Sign-in)
   - Set up Firestore and Storage
   - Download and place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in their respective directories.
4. Run the app:
   ```sh
   flutter run
   ```

## Folder Structure

```
lib/
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Firebase & API services
├── providers/      # State management
├── widgets/        # Reusable widgets
├── main.dart       # Entry point of the app
```

## Contributing

1. Fork the repository.
2. Create a new branch (`feature/your-feature`).
3. Commit your changes.
4. Push to the branch and create a pull request.

## License

This project is licensed under the MIT License.

## Contact

For any inquiries, contact [your email] or visit [your website].
