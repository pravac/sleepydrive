from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
from typing import Any

import jwt
from fastapi import HTTPException
from jwt import PyJWKClient


_FIREBASE_CERTS_URL = (
    "https://www.googleapis.com/service_accounts/v1/jwk/"
    "securetoken@system.gserviceaccount.com"
)


@dataclass(frozen=True)
class AuthUser:
    uid: str
    email: str | None = None
    name: str | None = None


@lru_cache(maxsize=1)
def _jwk_client() -> PyJWKClient:
    return PyJWKClient(_FIREBASE_CERTS_URL)


def require_firebase_user(
    *,
    authorization: str | None,
    project_id: str,
) -> AuthUser:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing Firebase ID token")

    token = authorization[7:].strip()
    if not token:
        raise HTTPException(status_code=401, detail="Missing Firebase ID token")

    try:
        signing_key = _jwk_client().get_signing_key_from_jwt(token)
        payload: dict[str, Any] = jwt.decode(
            token,
            signing_key.key,
            algorithms=["RS256"],
            audience=project_id,
            issuer=f"https://securetoken.google.com/{project_id}",
        )
    except Exception as exc:
        raise HTTPException(status_code=401, detail="Invalid Firebase ID token") from exc

    uid = payload.get("user_id") or payload.get("sub")
    if not isinstance(uid, str) or not uid:
        raise HTTPException(status_code=401, detail="Invalid Firebase ID token")

    email = payload.get("email")
    name = payload.get("name")
    return AuthUser(
        uid=uid,
        email=email if isinstance(email, str) else None,
        name=name if isinstance(name, str) else None,
    )
