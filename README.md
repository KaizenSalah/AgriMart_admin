# AgriMart Admin

Flutter admin dashboard for managing AgriMart products, categories, promos, banners, coupons, and orders.

## Setup

1. Copy `.env.example` to `.env` and fill in your values:
   ```bash
   cp .env.example .env
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Deploy `firestore.rules` and `storage.rules` to your Firebase project.

## Environment Variables (`.env`)

| Variable | Description |
| --- | --- |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name for image uploads |
| `CLOUDINARY_API_KEY` | Cloudinary API key |
| `CLOUDINARY_SECRET_KEY` | Cloudinary API secret |
| `CLOUDINARY_UPLOAD_PRESET` | Cloudinary unsigned upload preset (optional) |
| `ADMIN_INVITE_CODE` | Required invite code for admin sign-up |
| `STRIPE_PUBLISH_KEY` | Stripe publishable key |

## Run & Test

```bash
flutter run
flutter test
```
