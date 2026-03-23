# Pequire Provider App

A Flutter-based mobile application for service providers (Electricians, Plumbers, Carpenters, Laundry professionals) to manage jobs, earnings, and their professional profile.

## 🏗️ Architecture

```
lib/
├── main.dart                  # App entry point, router, theme
├── core/
│   ├── constants/
│   │   ├── app_colors.dart    # Brand color palette
│   │   └── app_typography.dart # Font styles (Plus Jakarta Sans + Inter)
│   ├── providers/
│   │   └── kyc_provider.dart  # KYC state management (Riverpod)
│   └── theme/
│       └── app_theme.dart     # Material theme configuration
├── features/
│   ├── auth/
│   │   └── screens/
│   │       ├── login_screen.dart           # Phone number login
│   │       ├── otp_screen.dart             # 4-digit OTP verification
│   │       ├── service_selection_screen.dart # Service type selection (Step 1 of 4)
│   │       └── kyc_screen.dart             # KYC document upload
│   ├── onboarding/
│   │   └── screens/
│   │       └── onboarding_screen.dart      # App introduction slides
│   ├── home/
│   │   └── screens/
│   │       └── home_screen.dart            # Main dashboard (online toggle, earnings, jobs)
│   ├── earnings/
│   │   └── screens/
│   │       └── earnings_screen.dart        # Earnings & payout history
│   ├── history/
│   │   └── screens/
│   │       └── booking_history_screen.dart  # Active/Upcoming/Completed bookings
│   ├── reviews/
│   │   └── screens/
│   │       └── reviews_screen.dart         # Reviews & ratings
│   ├── profile/
│   │   └── screens/
│   │       ├── profile_screen.dart         # Provider profile view
│   │       └── edit_profile_screen.dart    # Edit profile form
│   ├── settings/
│   │   └── screens/
│   │       └── settings_screen.dart        # App settings & preferences
│   ├── notifications/
│   │   └── screens/
│   │       └── notifications_screen.dart   # Notification timeline
│   └── help/
│       └── screens/
│           └── help_screen.dart            # FAQ & contact support
└── shared/
    └── widgets/
        ├── pequire_app_bar.dart    # Reusable app bar
        ├── pequire_button.dart     # Reusable button component
        ├── pequire_input.dart      # Reusable input field
        ├── drawer/
        │   └── pequire_drawer.dart # Navigation drawer
        └── maps/
            └── pequire_map_view.dart # Map integration
```

## 🎨 Design System

- **Primary Font:** Plus Jakarta Sans
- **Secondary Font:** Inter
- **Primary Color:** `#025EF3` (Blue)
- **Background:** `#F8FAFC` (Light Slate)
- **Dark Text:** `#0F172A` (Ink)
- **Muted Text:** `#64748B` / `#94A3B8`

## 🔧 Services Supported

1. ⚡ **Electrical** — Wiring, repairs & installation
2. 🔧 **Plumbing** — Pipe fitting, leaks & taps
3. 🪑 **Carpentry** — Furniture, fitting & woodwork
4. 🧺 **Laundry** — Washing, ironing & dry clean

## 📱 Key Screens & User Flow

```
Onboarding → Login (Phone) → OTP Verification → Service Selection → Home Dashboard
                                                                      ├── Online/Offline Toggle
                                                                      ├── Today's Earnings
                                                                      ├── Quick Actions
                                                                      ├── Upcoming Jobs
                                                                      └── Drawer Menu
                                                                           ├── Profile
                                                                           ├── Bookings
                                                                           ├── Earnings
                                                                           ├── Reviews
                                                                           ├── Help Centre
                                                                           └── Settings
```

## 🔑 State Management

- **Riverpod** (`flutter_riverpod`) for global state
- `kycProvider` — Manages KYC verification states: `unverified`, `pending`, `verified`, `rejected`

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Declarative routing |
| `flutter_svg` | SVG rendering |
| `flutter_map` | Map integration |
| `geolocator` | Location services |

## 🚀 Getting Started

```bash
# Clone the repository
git clone <repo-url>
cd pequire_provider_app

# Install dependencies
flutter pub get

# Run on connected device
flutter run
```

## 🔌 Backend Integration Points

The following areas require backend API integration:

1. **Authentication** — Phone OTP send/verify endpoints
2. **KYC Verification** — Document upload & status polling
3. **Job Management** — Real-time job requests, accept/decline, job history
4. **Earnings** — Transaction history, payout requests, balance
5. **Profile** — CRUD operations for provider profile
6. **Reviews** — Fetch ratings and review data
7. **Notifications** — Push notification integration
8. **Location** — Real-time provider location updates

## 📝 Notes for Backend Developer

- All screens currently use **mock/static data** — replace with API calls
- The `kycProvider` state needs to be synced with backend KYC status
- Job request simulation (debug FAB on Home Screen) shows expected data shape
- Navigation uses `go_router` — routes are defined in `main.dart`
- The app targets **Android** primarily (tested on Moto G54 5G)
