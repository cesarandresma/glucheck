# Instrucciones para agentes de código — GlucoTrack

## Contexto

App Flutter **glucotrack** (carpeta del repo: `glucocheck`). Android principal. Español. GetX + Firebase Auth/Firestore + Hive.

## Reglas de arquitectura

1. **Pantallas** no llaman a Firestore directamente; usan controladores GetX y repositorios.
2. **Rutas privadas:** `AuthMiddleware` / `GuestMiddleware` en `lib/app/routes/`.
3. **Errores:** `AppException` y subclases en `lib/core/errors/`.
4. **Modelos:** `GlucoseReading`, `UserProfile` en `lib/data/models/`.
5. **Demo:** `lib/data/demo/demo_glucose_data.dart` — solo importar con acción explícita del usuario (`SettingsController.importDemoData`).
6. **Borrado de cuenta:** `AuthService.deleteAccount` reautentica, borra lecturas y perfil, y luego elimina el usuario de Auth. No afirmar éxito si Firebase rechaza el borrado.

## Archivos sensibles

- No commitear `google-services.json` con proyectos reales si la política del equipo lo prohíbe; no commitear `serviceAccount.json`, `.env`, ni claves OpenAI.
- `lib/firebase_options.dart` puede ser placeholder hasta `flutterfire configure`.

## Comandos habituales

```bash
flutter pub get
dart format .
flutter analyze
flutter test
firebase deploy --only firestore:rules,firestore:indexes
```

Backend:

```bash
cd backend && pip install -r requirements.txt && python -m pytest
```

## Extensiones habituales

- Nueva pantalla: módulo en `lib/modules/`, ruta en `app_routes.dart` / `app_pages.dart`, binding si hace falta.
- Nuevo campo en lecturas: modelo, provider Firestore, reglas `firestore.rules`, validadores en `lib/core/utils/`.

## Medical disclaimer

No presentar la app como dispositivo médico. No diagnosticar ni recomendar cambios de medicación en UI o asistente.

## CI

`.github/workflows/ci.yml` — no romper `flutter test` ni el job `backend`.
