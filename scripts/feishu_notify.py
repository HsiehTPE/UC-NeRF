#!/usr/bin/env python3
import base64
import hashlib
import hmac
import os
import sys
import time

import requests

WEBHOOK = os.environ.get("FEISHU_WEBHOOK")
SECRET = os.environ.get("FEISHU_SIGNING_SECRET")


def gen_sign(timestamp: str, secret: str) -> str:
    string_to_sign = f"{timestamp}\n{secret}".encode("utf-8")
    h = hmac.new(string_to_sign, digestmod=hashlib.sha256).digest()
    return base64.b64encode(h).decode("utf-8")


def send_text(text: str):
    if not WEBHOOK:
        raise RuntimeError("FEISHU_WEBHOOK is not set")

    payload = {
        "msg_type": "text",
        "content": {"text": text},
    }

    if SECRET:
        ts = str(int(time.time()))
        payload["timestamp"] = ts
        payload["sign"] = gen_sign(ts, SECRET)

    r = requests.post(WEBHOOK, json=payload, timeout=10)
    r.raise_for_status()
    print(r.text)


if __name__ == "__main__":
    msg = sys.argv[1] if len(sys.argv) > 1 else "👮‍♂️ 您提交的脚本已完成，请检查"
    send_text(msg)
