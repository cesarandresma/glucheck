# GlucoTrack

Aplicación móvil Android (Flutter) en **español** para **registrar, consultar y visualizar mediciones de glucosa**. Es una herramienta de registro y apoyo educativo; **no es un dispositivo médico certificado** ni sustituye el criterio de un profesional sanitario.

## Funcionalidades

- Registro, inicio de sesión, recuperación de contraseña y cierre de sesión (Firebase Authentication).
- Perfil editable (nombre; el correo se gestiona con Firebase Auth).
- Registro manual de glucosa (mg/dL), contexto, fecha/hora y notas.
- Historial con filtros por fecha y contexto, búsqueda, detalle, edición y eliminación.
- Dashboard con última medición, gráfico y accesos rápidos.
- Estadísticas descriptivas (promedio, mínimo, máximo, cantidad), comparación con el periodo anterior cuando hay datos suficientes, y gráficos.
- Persistencia local (Hive) de preferencias y caché de lecturas recientes.
- Sincronización con Cloud Firestore mediante repositorios.
- Estados de carga, vacío, éxito y error en pantallas de datos.

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
## Licencia y créditos

Proyecto educativo. Paquetes de terceros bajo sus licencias respectivas (Flutter, Firebase, GetX, etc.).

