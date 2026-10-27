# GlucoTrack

Aplicación móvil Android (Flutter) en **español** para **registrar, consultar y visualizar mediciones de glucosa**. Es una herramienta de registro y apoyo educativo; **no es un dispositivo médico certificado** ni sustituye el criterio de un profesional sanitario.

## Funcionalidades

- Registro, inicio de sesión, recuperación de contraseña y cierre de sesión (Firebase Authentication).
- Perfil editable (nombre; el correo se gestiona con Firebase Auth).
- Registro manual de glucosa (mg/dL), contexto, fecha/hora y notas.
- Historial con filtros por fecha y contexto, búsqueda, detalle, edición y eliminación.
- Dashboard con última medición, gráfico y accesos rápidos.
- Estadísticas descriptivas (promedio, mínimo, máximo, cantidad), comparación con el periodo anterior cuando hay datos suficientes, y gráficos (`fl_chart`).
- Asistente informativo vía **servidor propio** (`backend/`), sin claves de IA en el cliente.
- Persistencia local (Hive) de preferencias y caché de lecturas recientes.
- Sincronización con Cloud Firestore mediante repositorios.
- Estados de carga, vacío, éxito y error en pantallas de datos.
- Datos de demostración (20 registros ficticios, marcados como `isDemo`).
- CI en GitHub Actions y compilación de APK en releases con etiqueta `v*`.

## Capturas

Ejecute la app en un emulador o dispositivo y tome capturas desde Android Studio o `adb exec-out screencap`. Pantallas recomendadas: bienvenida, dashboard, formulario de glucosa, historial y estadísticas.

## Arquitectura

Capas: **Pantallas → controladores GetX → repositorios/servicios → Firebase o Hive**.

Documentación ampliada: [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md).

## Estructura de carpetas (resumen)

```
lib/
  main.dart
  app/          # App, rutas, bindings, tema
  core/         # Constantes, errores, utilidades, widgets compartidos
  data/         # Modelos, providers, repositorios, demo
  services/     # Auth, IA, conectividad, preferencias
  modules/      # splash, auth, home, dashboard, glucose, history, ...
backend/        # API FastAPI del asistente
firestore.rules
.github/workflows/ci.yml
```

## Requisitos previos

- Flutter **3.47.x** (stable) y Dart **3.13.x** (ver `flutter --version`).
- Android SDK para compilar/ejecutar en Android.
- Cuenta y proyecto en [Firebase Console](https://console.firebase.google.com/).
- Para el asistente en local: **Python 3.11 o 3.12** (el job de CI usa 3.11) y credenciales de cuenta de servicio de Firebase (solo en el servidor). Python 3.14 no puede instalar `pydantic==2.10.6` porque no hay rueda de `pydantic-core` compatible.

## Instalación y ejecución (Flutter)

```bash
cd glucocheck   # carpeta del repositorio
flutter pub get
flutter run
```

Con Firebase ya configurado mediante FlutterFire:

```bash
flutter run --dart-define=FIREBASE_CONFIGURED=true
```

Sin `firebase_options.dart` real, el proyecto compila pero **Authentication y Firestore no funcionarán** hasta completar la configuración.

## Configuración de Firebase (paso a paso)

1. Cree un proyecto en Firebase Console.
2. Active **Authentication → Correo/contraseña**.
3. Cree una base de datos **Cloud Firestore** (modo producción; luego despliegue reglas).
4. Instale FlutterFire CLI y configure Android:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Esto genera `lib/firebase_options.dart` y descarga `google-services.json` en `android/app/`.
5. Ejecute con `--dart-define=FIREBASE_CONFIGURED=true` si usa el marcador de configuración del repositorio.
6. (Opcional) Active **App Check** en la consola para Android (Play Integrity / debug).
7. Despliegue reglas e índices:
   ```bash
   firebase login
   firebase use <su-project-id>
   firebase deploy --only firestore:rules,firestore:indexes
   ```
8. Despliegue también la configuración de Authentication (correo y contraseña) definida en `firebase.json`:
   ```bash
   firebase deploy --only auth
   ```
9. **Importante:** la seguridad de datos **no está activa** hasta que `firestore.rules` esté desplegada en su proyecto. No se ha desplegado contra un proyecto real en este repositorio.

### Emuladores Firebase

```bash
firebase emulators:start --only auth,firestore
```

Configure el emulador en la app según la [documentación de FlutterFire](https://firebase.flutter.dev/docs/emulator-suite) si desea desarrollo sin nube.

## Backend del asistente

Ubicación: `backend/`.

```bash
cd backend
cp .env.example .env
# Edite .env: FIREBASE_PROJECT_ID, FIREBASE_CREDENTIALS_PATH, opcionalmente OPENAI_API_KEY
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- `POST /assistant` — requiere `Authorization: Bearer <Firebase ID token>`.
- Sin `OPENAI_API_KEY`, responde con un **resumen automático local** (identificado como tal, no como IA generativa).
- La clave del proveedor de IA **solo** debe existir en el entorno del servidor.

En la app: **Ajustes → URL del asistente** (por ejemplo `http://10.0.2.2:8000` en emulador Android).

Variables: ver `backend/.env.example` y `.env.example` en la raíz.

## Datos de demostración

Hay **20 plantillas** en `lib/data/demo/demo_glucose_data.dart`, todas con `isDemo: true`.

**No se importan automáticamente.** En la app: **Ajustes → Cargar datos de demostración** (acción explícita con confirmación). No mezcle estos datos con mediciones reales en análisis clínico.

## Pruebas

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Backend (con Python instalado):

```bash
cd backend
pip install -r requirements.txt
python -m pytest
```

En este entorno de desarrollo, `python` no estaba disponible en PATH; use el comando anterior en su máquina o en CI (job `backend` en `.github/workflows/ci.yml`).

## Compilar APK

```bash
flutter build apk --release --dart-define=FIREBASE_CONFIGURED=true
```

Salida: `build/app/outputs/flutter-apk/app-release.apk`.

Instalar en emulador:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## CI y releases

- **CI:** push/PR en `main`, `master`, `develop` — formato, análisis y pruebas Flutter + pytest del backend.
- **APK en Release:** al publicar una etiqueta `v1.0.0`, se compila el APK y se adjunta al GitHub Release (sin secretos de Firebase en el workflow de ejemplo).

## Decisiones técnicas

| Área | Elección |
|------|----------|
| Estado y rutas | GetX |
| Remoto | Firebase Auth + Firestore |
| Local | Hive (caché de lecturas y preferencias) |
| Secretos de sesión en cliente | `flutter_secure_storage` (no contraseñas) |
| Gráficos | `fl_chart` |
| IA | FastAPI + verificación de ID token; OpenAI opcional en servidor |

## Limitaciones conocidas

- Escritura de mediciones requiere conexión (no hay cola offline de sincronización).
- La eliminación de cuenta está en **Ajustes → Eliminar cuenta y datos** y exige la contraseña actual. Si Firebase rechaza la operación, el mensaje de la app indica el motivo; no se afirma el borrado hasta que Authentication confirme `user.delete()`.
- iOS no está configurado por defecto en `firebase_options.dart`.
- El asistente no diagnostica ni prescribe; solo resume datos educativamente.
- Sin despliegue de reglas, Firestore puede rechazar operaciones o quedar inseguro si usa reglas por defecto de la consola.

## Seguridad y privacidad

- Reglas en `firestore.rules`: acceso por UID, validación de campos, sin lectura global.
- No incluya cuentas de servicio ni `OPENAI_API_KEY` en el repositorio.
- Cierre de sesión limpia caché local del usuario (`LocalStorageProvider.clearAllUserLocalData`).
- Las API keys de configuración de Firebase en el cliente son identificadores públicos; la protección depende de Auth y Rules.

## Licencia y créditos

Proyecto educativo. Paquetes de terceros bajo sus licencias respectivas (Flutter, Firebase, GetX, etc.).

## Ayuda para agentes de código

Vea [AGENTS.md](AGENTS.md).
