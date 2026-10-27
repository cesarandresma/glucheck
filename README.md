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

``

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


## Licencia y créditos

Proyecto educativo. Paquetes de terceros bajo sus licencias respectivas (Flutter, Firebase, GetX, etc.).

## Ayuda para agentes de código

Vea [AGENTS.md](AGENTS.md).
