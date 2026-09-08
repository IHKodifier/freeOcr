import logging
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from app.services.email_service import validate_email_address

logger = logging.getLogger(__name__)

router = APIRouter()


class ContactRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=100, description="Full name of contact")
    email: str = Field(..., min_length=3, max_length=255, description="Sender email address")
    category: str = Field(default="General Inquiry", max_length=100, description="Inquiry category")
    subject: str = Field(..., min_length=1, max_length=200, description="Subject line")
    message: str = Field(..., min_length=1, max_length=5000, description="Message body")


@router.post("", status_code=status.HTTP_200_OK)
async def submit_contact_form(payload: ContactRequest):
    """
    Submits a contact inquiry. Validates input and logs contact submission.
    """
    clean_name = payload.name.strip()
    clean_email = payload.email.strip()
    clean_subject = payload.subject.strip()
    clean_message = payload.message.strip()
    clean_category = payload.category.strip() if payload.category else "General Inquiry"

    if not clean_name:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Name cannot be empty."
        )
    if not validate_email_address(clean_email):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Invalid email address format."
        )
    if not clean_subject:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Subject cannot be empty."
        )
    if not clean_message:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Message cannot be empty."
        )

    logger.info(
        f"[Contact Form Received] From: {clean_name} <{clean_email}> | "
        f"Category: {clean_category} | Subject: {clean_subject}"
    )

    return {
        "status": "received",
        "message": "Thank you! Your message has been received. Our support team will reply within 24–48 hours.",
        "data": {
            "name": clean_name,
            "email": clean_email,
            "category": clean_category,
            "subject": clean_subject,
        }
    }
