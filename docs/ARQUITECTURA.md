# Arquitectura técnica — GlucoTrack

## Visión general

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────────┐
│   Views     │────▶│ GetX Controllers │────▶│ Repositories        │
│  (modules/) │     │                  │     │ Glucose / Profile   │
└─────────────┘     └──────────────────┘     └──────────┬──────────┘
                                                        │
                        ┌───────────────────────────────┼───────────────────────────────┐
                        ▼                               ▼                               ▼
              GlucoseFirestoreProvider      UserProfileFirestoreProvider      LocalStorageProvider (Hive)
                        │                               │
                        └───────────────┬───────────────┘
                                        ▼
                              Cloud Firestore / Auth
```

## Flujo de autenticación

1. `SplashController` observa `AuthService.authState`.
2. Usuario autenticado → `AppRoutes.home` (`HomeView` con navegación inferior).
3. Invitado → `AppRoutes.welcome`.
4. `AuthService` crea/actualiza perfil en `users/{uid}` al registrarse.

## Datos de glucosa

- Ruta Firestore: `users/{userId}/readings/{readingId}` (ver `firestore_paths.dart`).
- `GlucoseRepository`:
  - Online: lee remoto, actualiza caché Hive por usuario.
  - Offline: sirve caché si existe; escrituras requieren red.
- Cada documento incluye `userId` validado en reglas.

## Persistencia local

- **Hive:** caja `preferences` y cajas `readings_cache_{uid}`.
- **flutter_secure_storage:** datos que `AuthService` necesite persistir de forma segura (no contraseñas).
- **Logout:** `clearAllUserLocalData(uid)` para evitar fugas entre cuentas.

## Asistente

- Cliente: `AiService` envía `POST /assistant` con ID token de Firebase.
- Servidor: `backend/app/auth.py` verifica token; `assistant_logic.py` resume lecturas y opcionalmente llama a OpenAI.

## Seguridad Firestore

Reglas en `firestore.rules`:

- Lectura/escritura de perfil y lecturas solo si `request.auth.uid == userId`.
- En create/update de lecturas, `userId` inmutable y acorde al path.
- Validación de tipos y rangos (`valueMgDl` 20–600).

Despliegue obligatorio para entornos reales.

## Pruebas

- Unitarias: modelos, validadores, `StatisticsCalculator`, repositorios con `fake_cloud_firestore` y mocks.
- Widgets: login, historial vacío, bienvenida.
- Backend: `TestClient` sin credenciales reales para rutas públicas y validación de token.

## Navegación principal

`HomeView` aloja pestañas: Dashboard, Historial, Estadísticas, Asistente, Perfil/Ajustes. Formulario de glucosa en rutas nombradas (`addGlucose`, `editGlucose`).
