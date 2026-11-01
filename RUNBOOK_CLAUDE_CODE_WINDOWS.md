# Runbook para Claude Code local (Windows) — AutoSense / K2001N

Repositorio: `Tiomiguekenshin/hyundai-accent-rb-2017-diesel` · Rama única de trabajo: `work/k2001n-android15-audit`
Pega este documento como primer mensaje en Claude Code, abierto en la carpeta del repositorio.

## Reglas inamovibles (decisiones del propietario)
1. No usar ni pedir tokens personales de GitHub. Usar solo la autenticación ya configurada (`gh auth status`). No hacer `push` sin que el propietario lo autorice en ese momento.
2. Trabajar solo en `work/k2001n-android15-audit`. No tocar `main`, no hacer merge.
3. No hacer root, flasheo, cambios de MCU/CANBUS, recovery ni firmware. No desinstalar ni reemplazar el launcher original de la radio.
4. No instalar nada en la radio sin autorización expresa y puntual.
5. No suponer ABI, resolución, densidad, GPU ni arquitectura de la K2001N: están **sin verificar** (no hay ADB todavía).
6. No inventar un modelo 3D del Accent RB. Usar solo las fotos del propietario como referencia.
7. No declarar el proyecto terminado sin: compilación verificada, pruebas automatizadas ejecutadas y limitaciones de compatibilidad documentadas.

Al terminar cada etapa: resumir qué se hizo, qué se verificó (con salida real de comandos) y qué falta. Si un comando falla, mostrar el error y corregirlo; no marcar la etapa como hecha.

## Etapa 0 — Herramientas en Windows
- JDK 17 (Temurin): `winget install EclipseAdoptium.Temurin.17.JDK`. Verificar `java -version` → 17.
- Android SDK (solo línea de comandos): descargar *Command line tools* desde developer.android.com/studio, ubicarlas en `%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest`.
- Definir `ANDROID_HOME` y añadir `cmdline-tools\latest\bin` y `platform-tools` al `PATH`.
- Instalar: `sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"` (el proyecto usa compileSdk/targetSdk 34, AGP 8.5.2, Gradle 8.7, Kotlin 1.9.24).
- Las licencias (`sdkmanager --licenses`) las debe aceptar el propietario: mostrarle el prompt y esperar.

## Etapa 1 — Git, respaldo y parches
1. `git status`, `git branch --show-current`, `git fetch origin`. Debe estar limpio y en la rama de trabajo; si hay cambios sin confirmar, detenerse y avisar.
2. Punto de recuperación: `git branch backup/pre-audit-fixes` y `git tag pre-audit-fixes` en el HEAD actual (esperado: `682e277`).
3. Guardar `k2001n-audit.bundle` y `k2001n-audit-fixes.patch` en `docs/backup/` (o fuera del repo) y registrar su SHA-256 con `Get-FileHash -Algorithm SHA256`.
   - bundle: `36a835de109ccbef71f3cb385b9625467afda49b9bade525cf81a484bf5b0c3e`
   - patch: `e9a3064a7217b5c2c23011dc8f30e28c0f95c641487e92640efdae3c8ac5298f`
   - Si el hash difiere, detenerse.
4. `git bundle verify k2001n-audit.bundle` (requiere `682e277`; es incremental).
5. Comprobar duplicados: buscar `FOREGROUND_SERVICE_SPECIAL_USE`, `BLUETOOTH_CONNECT`, `RECEIVER_EXPORTED`, `MAX_FIX_AGE_NANOS` en el código. Si **no** aparecen y `git apply --check k2001n-audit-fixes.patch` pasa, continuar.
6. Aplicar la **serie completa** (7 commits, carpeta `series/`, en orden numérico): `git am series\*.patch`. Los dos primeros equivalen a `k2001n-audit-fixes.patch`; los demás quitan HOME, extraen la lógica pura, dejan la automatización desactivada por defecto, agregan pruebas y actualizan la documentación. Alternativa: `git fetch k2001n-work-series.bundle` (requiere `682e277`).
7. Verificar: `git log --oneline -8` y que el manifest no contenga `category.HOME`. Tras los dos primeros commits el árbol debe ser `d87d1a062f81f09a50612e4e936a249d64207535`; tras los 7, `b15e7cc115108100db3a8bec0d29d46a7125d130`. Los hashes de commit pueden diferir; los de árbol no.
8. Si `git am` falla: `git am --abort` y volver a `backup/pre-audit-fixes`.
9. SHA-256 del bundle de esta entrega: `a0aef3cbf00e78ad4cfef99b3c521ec460953afe6388371a939c56447bb8598a`. Ver `series/` para los siete parches individuales.

Verificado en entorno de prueba (clon limpio de `682e277`): la serie aplica sin conflictos, no duplica nada y las 20 pruebas JVM pasan. **No** está compilada con Gradle.

## Etapa 2 — Compilar y probar
```powershell
cd AutoSense
.\gradlew.bat --no-daemon clean test assembleDebug
Get-FileHash app\build\outputs\apk\debug\app-debug.apk -Algorithm SHA256
```
- La serie ya incluye `app/src/test` con **20 pruebas JVM** (GPS, ubicación del clima, valor por defecto de la automatización y decisiones del manifest). Debe verse `BUILD SUCCESSFUL` y 20 pruebas ejecutadas, 0 fallos (`app\build\test-results\testDebugUnitTest`). Si el número es distinto, investigar.
- **Aún no compilado con Gradle:** `Dashboard.kt`, `ForecastWeather.kt`, `CarPower.kt`, `PowerMenu.kt` y `AutoStart.kt` solo pasaron revisión de sintaxis. Puede aparecer algún error real de compilación; corregirlo mínimamente, un commit por corrección, y registrarlo.
- Ejecutar también `.\gradlew.bat lintDebug` y registrar errores y avisos.
- Completar la sección "Registro local" de `docs/TEST_RESULTS.md` con las salidas reales y el SHA-256.

## Etapa 3 — Adaptación sin suposiciones
- No añadir `abiFilters` ni resoluciones/densidades fijas. Layouts adaptables (`dp`, `ConstraintLayout`/pesos); el proyecto ya tiene capturas en distintos anchos en `docs/screenshots/`.
- **Arranque automático:** ya queda **desactivado por defecto** (commit 0005), con interruptor en el menú ⏻. Es la única decisión aplicada sin confirmación expresa del propietario (se interpretó "continuar con todo" como aceptar esta propuesta). Si prefiere lo contrario, revertir ese commit.
- Memoria: `car360` (36) + `car_drive` (24) fotogramas 720×328 ≈ 57 MB decodificados. Cargar bajo demanda, cancelar hilos y liberar bitmaps. RAM de la radio **sin verificar**.
- Clima: ya no se usa Ciudad de México por defecto (commit 0004); sin ubicación no se descarga el pronóstico.
- Servicios opcionales (accesibilidad, listener de notificaciones, overlay, Device Admin, `WRITE_SETTINGS`): confirmar que cada uno solo se activa por acción explícita.
- `AutoSenseCompanion` no está cubierto por el workflow de CI: documentarlo, no modificarlo salvo necesidad.

## Etapa 4 — Arte del vehículo
- Pedir al propietario que deje las 3 fotos en una carpeta local (p. ej. `docs/reference-photos/`; no subirlas al repo sin su OK) y trabajar con ellas.
- Los fotogramas actuales son arte heredado: no se sabe si corresponden a un Accent RB sedán 2017 blanco. Documentar las diferencias contra las fotos (carrocería, frontal, luces, parrilla, llantas, trasera).
- Si no hay herramientas para reproducir el auto fielmente, **no inventarlo**: conservar el arte actual y dejar documentadas las diferencias.

## Etapa 5 — Parámetros pendientes de verificar en la K2001N
| Parámetro | Estado | Cómo se verificará |
|---|---|---|
| ABI | sin verificar | `adb shell getprop ro.product.cpu.abilist` (cuando haya ADB) |
| Resolución / densidad | sin verificar | `adb shell wm size` / `wm density` |
| GPU / OpenGL ES | sin verificar | `adb shell dumpsys SurfaceFlinger` / `getprop ro.hardware.egl` |
| RAM | sin verificar | `adb shell cat /proc/meminfo` |
| Paquete del launcher original | sin anotar | `adb shell cmd package resolve-activity -a android.intent.action.MAIN -c android.intent.category.HOME` (solo lectura) |
Usar `tools/backup-k2001n-readonly.ps1` solo en modo lectura.

## Entregables finales (carpeta `entrega/`)
Código fuente completo (commit/tag), `app-debug.apk` + SHA-256, documentación técnica, `TEST_RESULTS.md`, `INSTALL-AND-ROLLBACK.md` (instalación, desinstalación, recuperación), lista de limitaciones. Incluir el estado de cada puerta: A compilación, B emulador, C radio física (esta última **no ejecutada** hasta tener ADB y autorización).
