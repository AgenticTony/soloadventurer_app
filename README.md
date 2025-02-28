# SoloAdventurer

A mobile application for solo travelers to connect with like-minded adventurers, plan trips, and find travel companions.

## 🚀 Tech Stack

### 📊 Backend Infrastructure

- **Primary Database**: Amazon Aurora (PostgreSQL) + PostGIS
- **Search & Discovery**: Amazon OpenSearch (Elasticsearch)
- **Real-Time Features**: Redis + WebSockets (via AWS AppSync)
- **API Layer**: GraphQL (AWS AppSync) + REST (API Gateway + Lambda)
- **Serverless Compute**: AWS Lambda
- **Authentication**: AWS Cognito
- **File Storage**: Amazon S3
- **CDN**: Amazon CloudFront

### 📱 Frontend

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Maps & Geolocation**: Google Maps API / Flutter Map
- **Network**: GraphQL / HTTP / Dio

## 📁 Project Structure

```
lib/
├── main.dart                  # Application entry point
├── models/                    # Data models
│   ├── user.dart              # User model
│   ├── travel_preference.dart # Travel preferences model
│   └── trip.dart              # Trip model
├── providers/                 # Riverpod providers
│   └── auth_provider.dart     # Authentication provider
├── screens/                   # UI screens
├── services/                  # Services
│   ├── auth_service.dart      # Authentication service
│   ├── api_service.dart       # API service
│   └── graphql_queries.dart   # GraphQL queries
├── utils/                     # Utility functions
└── widgets/                   # Reusable widgets
```

## 🔧 Setup

1. Clone the repository
2. Install Flutter (version 3.5.4 or higher)
3. Run `flutter pub get` to install dependencies
4. Configure AWS Cognito credentials in `lib/services/auth_service.dart`
5. Configure API endpoints in `lib/services/api_service.dart`
6. Run the app with `flutter run`

## 📱 Features

- **User Authentication**: Sign up, sign in, and profile management
- **Travel Preferences**: Set and update travel preferences
- **Trip Planning**: Create and manage trips
- **Travel Matching**: Find compatible travel companions
- **Real-Time Messaging**: Connect with potential travel buddies
- **Location Sharing**: Share and view locations on a map

## 🧪 Testing

Run tests with:

```bash
flutter test
```

For code coverage:

```bash
flutter test --coverage
```

## 🔄 CI/CD

This project uses GitHub Actions for continuous integration and delivery:

- **Automated Testing**: All tests are run on every push and pull request
- **Code Coverage**: Test coverage reports are generated and uploaded to Codecov
- **Code Quality**: Linting and static analysis are performed automatically
- **Build Verification**: iOS and Android builds are created and verified

GitHub Actions workflows can be found in the `.github/workflows` directory.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
