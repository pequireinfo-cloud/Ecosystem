# Pequire Ecosystem

A comprehensive service-based application ecosystem including User, Provider, and Admin interfaces, powered by a Node.js backend.

## 📁 Repository Structure

The project follows a **Feature-First Architecture** for all client applications and a **Service-Oriented MVC** pattern for the backend.

### 📱 Applications
- **[User App](./User_app)**: Flutter-based mobile application for customers to request services.
- **[Provider App](./Provider_App)**: Flutter-based mobile application for service providers to manage jobs.
- **[Admin Panel](./Admin_Panel)**: Flutter Web-based dashboard for system administration.

### ⚙️ Backend
- **[Pequire Backend](./Pequire_Backend)**: Node.js/Express server using Firebase Admin SDK for data and notifications.

## 🛠️ Architecture Standards

### Flutter (Feature-First Clean Architecture)
Each feature is encapsulated in its own module under `lib/features/[feature_name]/`:
- `data/`: Data sources, models, and repository implementations.
- `domain/`: Entities, repository interfaces, and use cases.
- `presentation/`: Blocs/Cubits, pages, and widgets.
- `core/`: Global themes, utilities, and constants.

### Node.js Backend (Service Layer Pattern)
- `routes/`: Express route definitions.
- `controllers/`: Request/Response handling (thin layer).
- `services/`: Business logic and database operations (thick layer).
- `models/`: Database schemas.

## 🚀 Getting Started

1. **Backend**: 
   - `cd Pequire_Backend`
   - `npm install`
   - `npm run dev`
2. **Flutter Apps**:
   - `cd [App_Directory]`
   - `flutter pub get`
   - `flutter run`

## 🧪 Quality Tools
- **Linting**: Shared `analysis_options.yaml` across all Flutter apps.
- **Backend Linting**: ESLint (configured in `package.json`).
