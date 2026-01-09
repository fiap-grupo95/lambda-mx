import os
import json
import base64
import hmac
import hashlib
import time

SECRET = os.getenv("JWT_SECRET", "")
ALGO = os.getenv("JWT_ALGO", "HS256")


def _b64pad(s: str) -> str:
    # Ensure proper padding for urlsafe base64
    return s + "=" * (-len(s) % 4)


def verify_hs256(token: str, secret: str):
    try:
        parts = token.split(".")
        if len(parts) != 3:
            print("[AUTH] Invalid token format: parts!=3")
            return None
        header_b64, payload_b64, sig_b64 = parts
        signing_input = f"{header_b64}.{payload_b64}".encode()
        signature = base64.urlsafe_b64decode(_b64pad(sig_b64))
        expected = hmac.new(secret.encode(), signing_input, hashlib.sha256).digest()
        if not hmac.compare_digest(signature, expected):
            print("[AUTH] Signature mismatch")
            return None
        payload_json = base64.urlsafe_b64decode(_b64pad(payload_b64)).decode()
        payload = json.loads(payload_json)
        # exp check
        if "exp" in payload and int(payload["exp"]) < int(time.time()):
            print("[AUTH] Token expired")
            return None
        return payload
    except Exception:
        print(f"[AUTH] Exception verifying token: {e}")
        return None


def handler(event, context):
    # HTTP API v2: headers can be in different cases
    try:
        print("[AUTH] Event received")
        # Log minimal details useful for debugging
        route_arn = event.get("routeArn", "") if isinstance(event, dict) else ""
        route_key = event.get("routeKey", "") if isinstance(event, dict) else ""
        print(f"[AUTH] routeArn={route_arn} routeKey={route_key}")
    except Exception:
        pass
    auth = None
    if isinstance(event, dict) and "headers" in event and isinstance(event["headers"], dict):
        headers = event["headers"]
        auth = headers.get("authorization") or headers.get("Authorization")

    if not auth or not auth.lower().startswith("bearer "):
        print("[AUTH] Missing or invalid Authorization header")
        return {
            "isAuthorized": False,
            "context": {},
            "routeArn": event.get("routeArn", "")
        }

    token = auth.split(" ", 1)[1]
    claims = verify_hs256(token, SECRET) if ALGO == "HS256" else None
    if not claims:
        print("[AUTH] Claims verification failed")
        return {
            "isAuthorized": False,
            "context": {},
            "routeArn": event.get("routeArn", "")
        }

    # Optional context back to integration/backend
    context_map = {
        "sub": str(claims.get("sub", "")),
        "email": str(claims.get("email", "")),
        "roles": ",".join(claims.get("roles", [])) if isinstance(claims.get("roles"), list) else str(claims.get("roles", ""))
    }

    print("[AUTH] Authorization successful")
    return {
        "isAuthorized": True,
        "context": context_map,
        "routeArn": event.get("routeArn", "")
    }
