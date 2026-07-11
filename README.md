# What Not To Eat

A production-ready mobile application that analyzes food ingredient lists from images using the Gemini Vision API. It provides a healthiness score, categorizes ingredients (Green/Yellow/Red), and offers personalized health advice based on the user's profile.

## Architecture

- **Frontend**: Flutter, Riverpod, GoRouter, Dio, Material 3
- **Backend**: Node.js, Express, MongoDB (Mongoose), Twilio Verify, jsonwebtoken
- **AI**: Google Generative AI (Gemini 1.5 Pro)
- **Auth**: Twilio SMS OTP + JWT

## Project Structure

- `frontend/`: Contains the Flutter application. Uses Clean Architecture (Presentation, Domain, Data).
- `backend/`: Contains the Node.js Express server.

## Setup Instructions

### Prerequisites
1. **Node.js** (v18+)
2. **Flutter SDK** (stable)
3. **MongoDB** instance (local or Atlas)
4. **Twilio Account** with Verify Service enabled.
5. **Gemini API Key** from Google AI Studio.

### 1. Twilio Configuration

1. Create a Twilio account at [twilio.com](https://www.twilio.com/).
2. Get your `Account SID` and `Auth Token` from the Twilio Console.
3. Go to Verify > Services and create a new Verify Service to get the `Service SID`.
4. Add these values to your backend `.env` variables.

### 2. Backend Setup

```bash
cd backend
npm install
```

Create a `.env` file in the `backend` directory (see `.env.example`):
```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/what_not_to_eat
GEMINI_API_KEY=your_gemini_api_key_here
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_VERIFY_SERVICE_SID=your_verify_service_sid
JWT_SECRET=your_super_secret_jwt_key
```

Start the server:
```bash
npm run dev
```

### 3. Frontend Setup

```bash
cd frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Create a `.env` file in the `frontend` directory (see `.env.example`):
```env
API_BASE_URL=http://10.0.2.2:3000 # Use your machine's IP if testing on physical device
```

Run the app:
```bash
flutter run
```

## API Documentation

- `POST /auth/send-otp`: Sends a 6-digit OTP to the provided phone number.
- `POST /auth/verify-otp`: Verifies the OTP and returns a JWT token.
- `GET /profile`: Returns user profile (requires Bearer token).
- `PUT /profile`: Updates user profile (`age`, `height`, `weight`) (requires Bearer token).
- `POST /scan`: Accepts `multipart/form-data` with an `image` file. Returns Gemini JSON analysis (requires Bearer token).
- `GET /history`: Returns a list of past scans for the authenticated user (requires Bearer token).

## Features

- **Auth**: Twilio SMS OTP with JWT persistent sessions.
- **Profile**: Store age, height, and weight to personalize Gemini analysis.
- **Scanning**: Take a photo or upload from gallery. Image is analyzed entirely by Gemini Vision.
- **Results**: Beautiful circular progress indicators, expandable categorized lists (Good, Neutral, Bad), and detailed reasoning per ingredient.
- **History**: View past scans and overall health scores.
