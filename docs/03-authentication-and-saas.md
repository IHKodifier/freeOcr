# Authentication & Paid SaaS Subscriptions Guide: freeOCR.me

This guide documents user authentication architecture, Firebase Auth integration, and paid subscription features (Post-MVP Phase 4).

---

## 1. Authentication Architecture

- **MVP Phase:** **Zero Login Barrier**. Users perform document conversions anonymously. Sessions and ad limit boosts are tracked via IP/session token in Redis (`ad_pass:{client_ip}`).
- **Post-MVP Phase (v1.1+):** **Firebase Authentication** (Email/Password, Google OAuth, SAML SSO).

---

## 2. API Authorization & Bearer Tokens

When authenticated, the Flutter Web client includes the Firebase Bearer JWT token in HTTP request headers:

```http
POST /api/v1/ocr/convert HTTP/1.1
Host: freeocr.me
Authorization: Bearer <FIREBASE_JWT_TOKEN>
Content-Type: multipart/form-data
```

### Token Validation Workflow
1. Client signs in via Firebase SDK in Flutter.
2. Firebase returns ID JWT token.
3. Backend FastAPI security middleware (`src/backend/app/core/security.py`) validates token against Firebase Admin SDK.
4. User record is resolved from `users` table via `firebase_uid`.

---

## 3. Subscription Tiers & Ad Suppression

| Tier Name | Ad Behavior | Max Pages / PDF | Max File MB | GCS Vault |
|-----------|-------------|-----------------|-------------|-----------|
| **Free (Anonymous)** | Rotating AdSense Banners + Rewarded Ad Stackable Boosts | `base_max_pages` (10, +15/ad) | `base_max_file_mb` (10MB, +20MB/ad) | ❌ (Ephemeral RAM only) |
| **Pro Paid (Subscribed)** | 100% Ad-Free (All display & rewarded ads suppressed) | Unlimited (up to 500 pages) | Unlimited (up to 500MB) | ✅ Opt-In GCS Vault |
