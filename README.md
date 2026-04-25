# 🚑 Ambulance Smart Traffic Management System

A full-stack real-time ambulance tracking and hospital management system.

## System Architecture

```
┌───────────────────┐     ┌──────────────────┐     ┌───────────────┐
│   Flutter App     │     │    Firebase       │     │  React Web    │
│   (Driver Side)   │────▶│  (Firestore +    │◀────│  Dashboard    │
│                   │     │   Auth)           │     │  (Admin Side) │
└───────────────────┘     └──────────────────┘     └───────────────┘
                                  ▲
                                  │
                          ┌───────┴───────┐
                          │    ESP32      │
                          │  (reads data) │
                          └───────────────┘
```

---

## 📋 Prerequisites

- **Flutter SDK** (3.x or later) — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Node.js** (18.x or later) — [Install Node.js](https://nodejs.org/)
- **Firebase Project** — Already configured (Project ID: `tcma-9cb49`)
- **Google Maps API Key** — [Get a key](https://console.cloud.google.com/google/maps-apis)

---

## 🔥 Firebase Setup

### 1. Enable Authentication
1. Go to [Firebase Console](https://console.firebase.google.com/) → Project `tcma-9cb49`
2. Navigate to **Authentication** → **Sign-in method**
3. Enable **Email/Password** provider

### 2. Create Firestore Database
1. Go to **Firestore Database** → **Create Database**
2. Start in **test mode** (or apply rules below)
3. Choose your preferred region

### 3. Firestore Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /ambulance/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /hospital/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### 4. Seed Sample Hospital Data
Add documents to the `hospital` collection in Firestore:

**Document 1:**
```json
{
  "name": "City General Hospital",
  "availableBeds": 15,
  "ICUAvailable": true,
  "status": "READY",
  "location": { "lat": 17.6599, "lon": 75.9064 }
}
```

**Document 2:**
```json
{
  "name": "Solapur Medical Center",
  "availableBeds": 8,
  "ICUAvailable": true,
  "status": "READY",
  "location": { "lat": 17.6721, "lon": 75.9232 }
}
```

**Document 3:**
```json
{
  "name": "Emergency Care Hospital",
  "availableBeds": 3,
  "ICUAvailable": false,
  "status": "BUSY",
  "location": { "lat": 17.6480, "lon": 75.8950 }
}
```

---

## 📱 Flutter App (Driver Side)

### Setup

1. **Create the Flutter project scaffold:**
   ```bash
   cd ambulance_app
   flutter create . --org com.example --project-name ambulance_app
   ```
   > This generates the `android/`, `ios/`, `web/`, and other platform directories.

2. **Configure Firebase for Flutter:**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=tcma-9cb49
   ```
   > This auto-generates `firebase_options.dart` with platform-specific values.

3. **Install dependencies:**
   ```bash
   flutter pub get
   ```

4. **Add Google Maps API key:**

   **Android** — Edit `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <manifest ...>
     <application ...>
       <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
     </application>
   </manifest>
   ```

   **iOS** — Edit `ios/Runner/AppDelegate.swift`:
   ```swift
   import GoogleMaps

   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
   ```

5. **Add location permissions:**

   **Android** — Edit `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
   ```

   **iOS** — Edit `ios/Runner/Info.plist`:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>Ambulance needs location access for emergency routing</string>
   <key>NSLocationAlwaysUsageDescription</key>
   <string>Ambulance needs continuous location for emergency tracking</string>
   ```

### Run

```bash
flutter run
```

### Features
- ✅ Login / Signup with Firebase Auth
- ✅ Active/Inactive status toggle
- ✅ Hospital selection from Firestore
- ✅ Start/End emergency route
- ✅ Real-time GPS tracking (location sent every few seconds)
- ✅ Live ETA and distance calculation
- ✅ Speed display

---

## 💻 React Dashboard (Admin Side)

### Setup

1. **Install dependencies:**
   ```bash
   cd admin_dashboard
   npm install
   ```

2. **Add Google Maps API key:**
   Edit `src/components/LiveMap.jsx` and replace:
   ```js
   const GOOGLE_MAPS_API_KEY = 'YOUR_GOOGLE_MAPS_API_KEY'
   ```
   with your actual API key.

### Run

```bash
npm run dev
```

The dashboard opens at [http://localhost:3000](http://localhost:3000).

### Features
- ✅ Admin login with Firebase Auth
- ✅ Live map with ambulance marker (real-time updates)
- ✅ Hospital markers (green = READY, red = BUSY)
- ✅ Path drawn from ambulance to destination
- ✅ Info panel: status, speed, distance, ETA
- ✅ Hospital management (edit beds, ICU, status)
- ✅ Emergency alert banner
- ✅ Responsive design (mobile + desktop)
- ✅ Dark theme with glassmorphism

---

## 📐 Firestore Data Structure

### `ambulance` Collection
| Field | Type | Description |
|-------|------|-------------|
| status | string | `ACTIVE` or `INACTIVE` |
| latitude | number | Current GPS latitude |
| longitude | number | Current GPS longitude |
| speed | number | Current speed in km/h |
| destinationHospital | string | Hospital document ID |
| updatedAt | timestamp | Last update time |

### `hospital` Collection
| Field | Type | Description |
|-------|------|-------------|
| name | string | Hospital name |
| availableBeds | number | Available bed count |
| ICUAvailable | boolean | ICU availability |
| status | string | `READY` or `BUSY` |
| location | map | `{ lat: number, lon: number }` |

---

## 🎨 Color Codes
| Color | Usage | Hex |
|-------|-------|-----|
| 🔴 Red | Emergency / Active ambulance | `#EF4444` |
| 🟢 Green | Available / Ready | `#22C55E` |
| 🔵 Blue | Active ambulance marker | `#3B82F6` |
| 🟡 Amber | Warnings / ETA | `#F59E0B` |

---

## 🔄 Real-Time Data Flow

1. **Driver starts emergency** → Flutter app sets `ambulance.status = ACTIVE`
2. **GPS tracking begins** → Flutter sends coordinates every 2–3 seconds
3. **Dashboard updates instantly** → React listens via `onSnapshot`
4. **Alert banner appears** → "Ambulance en route – prepare emergency ward"
5. **Map marker moves** → Ambulance position updates on map in real-time
6. **Driver ends route** → Status → `INACTIVE`, tracking stops, alert hides
7. **ESP32 reads data** → ESP32 polls Firestore for traffic signal control

---

## 📁 Project Structure

```
database/
├── ambulance_app/                  # Flutter Mobile App
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart               # App entry point
│       ├── config/
│       │   └── firebase_options.dart
│       ├── models/
│       │   ├── ambulance_model.dart
│       │   └── hospital_model.dart
│       ├── services/
│       │   ├── auth_service.dart
│       │   ├── firestore_service.dart
│       │   └── location_service.dart
│       ├── providers/
│       │   ├── auth_provider.dart
│       │   ├── ambulance_provider.dart
│       │   └── hospital_provider.dart
│       └── screens/
│           ├── login_screen.dart
│           ├── signup_screen.dart
│           ├── home_screen.dart
│           └── hospital_selection_screen.dart
│
├── admin_dashboard/                # React Web Dashboard
│   ├── package.json
│   ├── vite.config.js
│   ├── index.html
│   └── src/
│       ├── main.jsx
│       ├── App.jsx
│       ├── index.css
│       ├── config/
│       │   └── firebase.js
│       ├── hooks/
│       │   ├── useAuth.js
│       │   ├── useAmbulance.js
│       │   └── useHospitals.js
│       └── components/
│           ├── LoginPage.jsx
│           ├── Dashboard.jsx
│           ├── Navbar.jsx
│           ├── AlertBanner.jsx
│           ├── LiveMap.jsx
│           ├── InfoPanel.jsx
│           └── HospitalManagement.jsx
│
└── README.md
```
