#!/usr/bin/env python3
"""
Send an email (or SMS via carrier gateway) when campsites are available.
Reads config from environment variables set by check.sh.
"""

import os
import smtplib
import sys
from email.message import EmailMessage


def main():
    gmail_address = os.environ.get("GMAIL_ADDRESS", "").strip()
    gmail_password = os.environ.get("GMAIL_APP_PASSWORD", "").strip()
    notify_email = os.environ.get("NOTIFY_EMAIL", "").strip()

    if not all([gmail_address, gmail_password, notify_email]):
        return  # Notifications not configured — silently skip.

    body = sys.stdin.read().strip()
    if not body:
        return

    msg = EmailMessage()
    msg["Subject"] = "🏕 Campsites Available!"
    msg["From"] = gmail_address
    msg["To"] = notify_email
    msg.set_content(body)

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as smtp:
            smtp.login(gmail_address, gmail_password)
            smtp.send_message(msg)
        print("Notification sent to {}".format(notify_email))
    except Exception as e:
        print("Warning: notification failed: {}".format(e), file=sys.stderr)


if __name__ == "__main__":
    main()
