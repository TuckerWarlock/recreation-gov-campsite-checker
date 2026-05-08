#!/usr/bin/env python3
"""
Send notifications when campsites are available.
Supports ntfy.sh (push) and Gmail SMTP (email).
Reads config from environment variables set by check.sh.
"""

import os
import smtplib
import sys
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText


def send_ntfy(topic, body):
    import urllib.request
    req = urllib.request.Request(
        f"https://ntfy.sh/{topic}",
        data=body.encode(),
        headers={"Title": "Campsites Available!"},
    )
    urllib.request.urlopen(req, timeout=10)
    print(f"ntfy notification sent to topic '{topic}'")


def send_email(address, password, to_email, body):
    msg = MIMEMultipart()
    msg["Subject"] = "🏕 Campsites Available!"
    msg["From"] = address
    msg["To"] = to_email
    msg.attach(MIMEText(body, "plain"))

    with smtplib.SMTP("smtp.gmail.com", 587) as smtp:
        smtp.starttls()
        smtp.login(address, password)
        smtp.sendmail(address, [to_email], msg.as_string())
    print(f"Email notification sent to {to_email}")


def main():
    ntfy_topic = os.environ.get("NTFY_TOPIC", "").strip()
    email_address = os.environ.get("EMAIL_ADDRESS", "").strip()
    email_password = os.environ.get("EMAIL_PASSWORD", "").strip()
    notify_email = os.environ.get("NOTIFY_EMAIL", "").strip()

    if not any([ntfy_topic, (email_address and email_password and notify_email)]):
        return  # Nothing configured — silently skip.

    body = sys.stdin.read().strip()
    if not body:
        return

    if ntfy_topic:
        try:
            send_ntfy(ntfy_topic, body)
        except Exception as e:
            print(f"Warning: ntfy notification failed: {e}", file=sys.stderr)

    if email_address and email_password and notify_email:
        try:
            send_email(email_address, email_password, notify_email, body)
        except Exception as e:
            print(f"Warning: email notification failed: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
