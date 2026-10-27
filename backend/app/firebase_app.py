import os
from typing import Any

import firebase_admin
from firebase_admin import auth, credentials, firestore

from .config import settings

_initialized = False


def init_firebase() -> None:
    global _initialized
    if _initialized:
        return
    if settings.firebase_credentials_path and os.path.isfile(
        settings.firebase_credentials_path
    ):
        cred = credentials.Certificate(settings.firebase_credentials_path)
        firebase_admin.initialize_app(
            cred,
            {"projectId": settings.firebase_project_id or None},
        )
    else:
        # Permite pruebas locales con emulador si GOOGLE_APPLICATION_CREDENTIALS está definido
        if not firebase_admin._apps:
            firebase_admin.initialize_app()
    _initialized = True


def verify_id_token(token: str) -> dict[str, Any]:
    init_firebase()
    return auth.verify_id_token(token)


def user_readings_collection(uid: str):
    init_firebase()
    db = firestore.client()
    return db.collection("users").document(uid).collection("readings")
