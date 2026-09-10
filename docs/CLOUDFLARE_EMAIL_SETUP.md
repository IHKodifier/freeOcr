# Cloudflare Email Routing & Outbound SMTP Setup Guide for freeOCR.me

This guide provides step-by-step instructions to:
1. **Receive emails** sent to `support@freeocr.me` and `privacy@freeocr.me` directly in your personal Gmail inbox for free using **Cloudflare Email Routing**.
2. **Reply and compose emails as** `support@freeocr.me` directly from your personal Gmail inbox using a free **Outbound SMTP Relay** (e.g. Brevo or Resend).
3. **Connect website contact inquiries** so user submissions from the "Contact Us" page are automatically forwarded to your inbox.

---

## Part 1: Inbound Email Setup (Cloudflare Email Routing)

Cloudflare Email Routing is 100% free and forwards emails sent to your custom domain addresses to your personal Gmail.

### Step 1: Enable Email Routing in Cloudflare
1. Log in to the [Cloudflare Dashboard](https://dash.cloudflare.com/) and select your domain: **`freeocr.me`**.
2. In the left navigation menu, click on **Email** $\rightarrow$ **Email Routing**.
3. Click **Get Started** / **Enable Email Routing**.

### Step 2: Add and Verify Your Destination Address
1. Go to the **Destination addresses** tab.
2. Click **Add destination address**.
3. Enter your personal Gmail address (e.g., `yourname@gmail.com`).
4. Cloudflare will send a verification email to your Gmail account. Open that email and click **Verify email address**.

### Step 3: Create Custom Routing Rules
In the **Routing rules** tab, click **Create address**:
- **Rule 1**:
  - Custom address: `support` @ `freeocr.me`
  - Action: `Send to`
  - Destination: `yourname@gmail.com`
- **Rule 2**:
  - Custom address: `privacy` @ `freeocr.me`
  - Action: `Send to`
  - Destination: `yourname@gmail.com`

### Step 4: Automatic DNS Records
Cloudflare will prompt you to automatically add the required DNS records (`MX` and `TXT` for SPF). Click **Add records automatically**.

> [!TIP]
> Once active, any email sent to `support@freeocr.me` or `privacy@freeocr.me` will immediately arrive in your personal Gmail inbox!

---

## Part 2: Outbound Email Setup (Send & Reply from Gmail as support@freeocr.me)

Because Cloudflare Email Routing is inbound-only, you need a free SMTP relay to authorize Gmail to send emails with `support@freeocr.me` in the "From" header without getting marked as spam.

### Option A: Brevo (Recommended — 300 Free Emails/Day Forever)
1. Sign up for a free account at [brevo.com](https://www.brevo.com/).
2. Go to **Settings** $\rightarrow$ **Senders & IP** $\rightarrow$ **Domains** $\rightarrow$ Add `freeocr.me`.
3. Add the DNS TXT (DKIM/SPF) verification records provided by Brevo to your Cloudflare DNS table.
4. Go to **Settings** $\rightarrow$ **SMTP & API** $\rightarrow$ Click **Generate a new SMTP key**.
5. Note the SMTP credentials:
   - **SMTP Server:** `smtp-relay.brevo.com`
   - **Port:** `587`
   - **Login / Username:** Your Brevo account email
   - **Password / Key:** Your generated SMTP master key

### Option B: Resend (Alternative — 100 Free Emails/Day / 3,000/Month)
1. Sign up at [resend.com](https://resend.com/).
2. Add and verify your domain `freeocr.me` with the provided DNS records.
3. Generate an API key or SMTP credentials from the Resend settings tab.

---

## Part 3: Connect Outbound SMTP to Your Gmail Account

1. Open your personal **Gmail** inbox on desktop.
2. Click the gear icon (top right) $\rightarrow$ **See all settings**.
3. Go to the **Accounts and Import** tab.
4. In the **Send mail as:** section, click **Add another email address**.
5. In the pop-up window:
   - **Name:** `freeOCR.me Support`
   - **Email address:** `support@freeocr.me`
   - **Uncheck** *"Treat as an alias"*
   - Click **Next Step**.
6. Enter the SMTP server details from Part 2:
   - **SMTP Server:** `smtp-relay.brevo.com`
   - **Port:** `587`
   - **Username:** Your SMTP login username
   - **Password:** Your SMTP password / API key
   - **Secured connection using:** `TLS` (recommended)
   - Click **Add Account**.
7. Gmail will send a confirmation code to `support@freeocr.me` (which Cloudflare will forward directly to your Gmail inbox within seconds!). Copy the code from the email, paste it into the verification box, and click **Verify**.

> [!NOTE]
> When composing a new email or replying to an incoming support message in Gmail, you can now simply click the **"From"** dropdown and select `support@freeocr.me`!

---

## Part 4: Backend Website Contact Form Configuration (Cloud Run)

The freeOCR backend automatically dispatches submitted inquiries from the "Contact Us" form to `support@freeocr.me`.

To enable live email dispatch on the Cloud Run backend (`freeocr-api`), update your Cloud Run environment variables with your chosen SMTP or Resend credentials:

```powershell
gcloud run services update freeocr-api `
  --region us-central1 `
  --project freeocr-staging-app `
  --update-env-vars "SMTP_HOST=smtp-relay.brevo.com,SMTP_PORT=587,SMTP_USER=your-smtp-user,SMTP_PASSWORD=your-smtp-password,SUPPORT_EMAIL_INBOX=support@freeocr.me"
```

If credentials are not yet configured, the backend logs the inquiry safely to Google Cloud Logging (`logger.info`) and returns HTTP 200 to the user with a confirmation receipt.
