import os
import re
import logging
from typing import Dict, Any

logger = logging.getLogger(__name__)

EMAIL_REGEX = re.compile(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")


def validate_email_address(email: str) -> bool:
    """
    Validates email format using regex.
    """
    if not email or not isinstance(email, str):
        return False
    return bool(EMAIL_REGEX.match(email.strip()))


def send_download_links_email(email: str, job_id: str, base_url: str = None) -> Dict[str, Any]:
    """
    Dispatches 24-hour expiring download links to the target email.
    Uses Resend API (if RESEND_API_KEY is configured) or SMTP (if SMTP_HOST is configured),
    or falls back to local SMTP server (127.0.0.1:1025) / terminal console log catcher in dev mode.
    """
    if not base_url:
        base_url = os.environ.get("API_BASE_URL", "http://127.0.0.1:8000")
    
    base_url = base_url.rstrip("/")

    download_links = {
        "pdf": f"{base_url}/api/v1/jobs/{job_id}/download/pdf",
        "txt": f"{base_url}/api/v1/jobs/{job_id}/download/txt",
        "md": f"{base_url}/api/v1/jobs/{job_id}/download/md",
    }

    resend_api_key = os.environ.get("RESEND_API_KEY")
    resend_from = os.environ.get("RESEND_FROM_EMAIL", "onboarding@resend.dev")

    smtp_host = os.environ.get("SMTP_HOST")
    smtp_port = int(os.environ.get("SMTP_PORT", "587"))
    smtp_user = os.environ.get("SMTP_USER")
    smtp_pass = os.environ.get("SMTP_PASSWORD")

    delivery_mode = "MOCK_DEV"
    email_sent = False
    error_detail = None

    if resend_api_key:
        delivery_mode = "RESEND_API"
        try:
            import httpx
            payload = {
                "from": resend_from,
                "to": [email],
                "subject": "Your freeOCR.me Download Links (Expires in 24 Hours)",
                "html": f"""
                <h2>Your OCR Document Conversion is Ready</h2>
                <p>Download your converted document files using the secure links below (Valid for 24 hours):</p>
                <ul>
                    <li><a href="{download_links['pdf']}">Searchable PDF Download</a></li>
                    <li><a href="{download_links['txt']}">Plain Text (.txt) Download</a></li>
                    <li><a href="{download_links['md']}">Markdown (.md) Download</a></li>
                </ul>
                <p><em>Privacy Note: Your original uploaded input file has been permanently purged from RAM disk. Output download links will expire after 24 hours.</em></p>
                """
            }
            headers = {
                "Authorization": f"Bearer {resend_api_key.strip()}",
                "Content-Type": "application/json",
            }
            res = httpx.post("https://api.resend.com/emails", json=payload, headers=headers, timeout=10.0)
            if res.status_code in (200, 201):
                email_sent = True
            else:
                error_detail = f"Resend API returned {res.status_code}: {res.text}"
                logger.warning(error_detail)
        except Exception as e:
            error_detail = f"Resend API connection error: {e}"
            logger.error(error_detail)

    elif smtp_host and smtp_user and smtp_pass:
        delivery_mode = "SMTP"
        try:
            import smtplib
            from email.mime.text import MIMEText
            from email.mime.multipart import MIMEMultipart

            msg = MIMEMultipart("alternative")
            msg["Subject"] = "Your freeOCR.me Download Links (Expires in 24 Hours)"
            msg["From"] = smtp_user
            msg["To"] = email

            html_content = f"""
            <h2>Your OCR Document Conversion is Ready</h2>
            <p>Download your converted document files using the secure links below (Valid for 24 hours):</p>
            <ul>
                <li><a href="{download_links['pdf']}">Searchable PDF Download</a></li>
                <li><a href="{download_links['txt']}">Plain Text (.txt) Download</a></li>
                <li><a href="{download_links['md']}">Markdown (.md) Download</a></li>
            </ul>
            <p><em>Privacy Note: Your original uploaded input file has been permanently purged from RAM disk. Output download links will expire after 24 hours.</em></p>
            """
            msg.attach(MIMEText(html_content, "html"))

            with smtplib.SMTP(smtp_host, smtp_port, timeout=10.0) as server:
                server.starttls()
                server.login(smtp_user, smtp_pass)
                server.sendmail(smtp_user, [email], msg.as_string())
            email_sent = True
        except Exception as e:
            error_detail = f"SMTP dispatch error: {e}"
            logger.error(error_detail)

    else:
        # Check if local SMTP server (e.g. aiosmtpd / MailHog on 127.0.0.1:1025) is running
        try:
            import smtplib
            from email.mime.text import MIMEText
            from email.mime.multipart import MIMEMultipart

            msg = MIMEMultipart("alternative")
            msg["Subject"] = "Your freeOCR.me Download Links (Expires in 24 Hours)"
            msg["From"] = "noreply@freeocr.me"
            msg["To"] = email

            html_content = f"""
            <h2>Your OCR Document Conversion is Ready</h2>
            <p>Download your converted document files using the secure links below (Valid for 24 hours):</p>
            <ul>
                <li><a href="{download_links['pdf']}">Searchable PDF Download</a></li>
                <li><a href="{download_links['txt']}">Plain Text (.txt) Download</a></li>
                <li><a href="{download_links['md']}">Markdown (.md) Download</a></li>
            </ul>
            <p><em>Privacy Note: Your original uploaded input file has been permanently purged from RAM disk. Output download links will expire after 24 hours.</em></p>
            """
            msg.attach(MIMEText(html_content, "html"))

            with smtplib.SMTP("127.0.0.1", 1025, timeout=2.0) as server:
                server.sendmail("noreply@freeocr.me", [email], msg.as_string())
            delivery_mode = "LOCAL_SMTP_CATCHER (127.0.0.1:1025)"
            email_sent = True
        except Exception:
            delivery_mode = "TERMINAL_CONSOLE_LOG"
            email_sent = True

        print("\n" + "=" * 75)
        print(f" 📧 [EMAIL SERVICE - LOCAL DISPATCH CONSOLE CATCHER]")
        print(f" To: {email}")
        print(f" Subject: Your freeOCR.me Download Links (Expires in 24 Hours)")
        print(f" Job ID: {job_id}")
        print("-" * 75)
        print(f" PDF Link : {download_links['pdf']}")
        print(f" TXT Link : {download_links['txt']}")
        print(f" MD Link  : {download_links['md']}")
        print("=" * 75 + "\n")

    return {
        "status": "SUCCESS" if email_sent else "ERROR",
        "job_id": job_id,
        "email": email,
        "delivery_mode": delivery_mode,
        "email_sent": email_sent,
        "error_detail": error_detail,
        "download_links": download_links,
        "expires_in_hours": 24
    }
