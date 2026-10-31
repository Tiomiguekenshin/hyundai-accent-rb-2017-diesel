# Auditoría inicial y plan de respaldo seguro — K2001N

Fecha: 2026-10-31  
Rama: `work/k2001n-android15-audit`  
Proyecto: Hyundai Accent RB 2017 CRDi White Edition

## Estado
Esta rama contiene inicialmente una copia del proyecto original. Todavía no se ha instalado ni ejecutado código en la radio. No se ha generado un APK validado para el equipo físico.

## Hallazgos preliminares del proyecto Android
- `compileSdk = 34`, `targetSdk = 34`, `minSdk = 24`.
- Android Gradle Plugin: 8.5.2.
- Kotlin Gradle Plugin: 1.9.24.
- Gradle Wrapper declara `gradle-9.6.0-bin.zip`. Esta combinación requiere verificación: AGP 8.5.x fue diseñado para Gradle 8.7; no se debe asumir compatibilidad con Gradle 9.x.
- El módulo fija `abiFilters += "arm64-v8a"`. No se debe conservar esta restricción hasta leer `ro.product.cpu.abilist`, `ro.product.cpu.abi` y comprobar las ABI reales de la radio.
- El manifiesto declara servicios de accesibilidad, listener de notificaciones, receiver de arranque, Device Admin, overlay y permisos heredados de Bluetooth. Cada permiso/servicio necesita revisión en Android 15.
- El proyecto original documenta pruebas en Lenovo Tab 4 10 / Android 8.1 / 1280x800. No es evidencia de compatibilidad con la radio K2001N.

## Respaldo preventivo antes de cualquier instalación
**No se debe instalar el launcher personalizado ni seleccionarlo como HOME predeterminado hasta completar y revisar el respaldo.**

### A. Inventario y diagnóstico ADB (solo lectura)
Con la radio encendida, depuración USB habilitada y el computador autorizado:
```bash
adb devices
adb shell getprop > k2001n-getprop.txt
adb shell wm size > k2001n-display-size.txt
adb shell wm density > k2001n-display-density.txt
adb shell cat /proc/cpuinfo > k2001n-cpuinfo.txt
adb shell df -h > k2001n-storage.txt
adb shell pm list packages -3 > k2001n-third-party-packages.txt
adb shell pm list packages -s > k2001n-system-packages.txt
adb shell dumpsys package > k2001n-package-dump.txt
adb shell dumpsys activity activities > k2001n-activities.txt
adb shell dumpsys window > k2001n-window.txt
adb shell settings get secure enabled_accessibility_services > k2001n-accessibility.txt
adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME > k2001n-current-home.txt
```
Guardar los resultados fuera de la radio, en una carpeta de respaldo fechada. Revisar y redactar cualquier dato personal antes de compartirlos.

### B. Respaldar el launcher original (si el paquete y permisos lo permiten)
1. Identificar el launcher HOME actual usando el inventario y el comando resolve-activity.
2. Ejecutar `adb shell pm path NOMBRE.DEL.PAQUETE`.
3. Para cada ruta devuelta, ejecutar `adb pull RUTA_LOCAL CARPETA_RESPALDO/`.
4. Guardar el nombre del paquete, versión, rutas, hashes SHA-256 y capturas de los ajustes HOME.
5. Si Android impide leer el APK o hay APK divididos, registrar la limitación; no intentar root ni bypass.

### C. Respaldo de configuración del equipo
- Fotografiar ajustes de fábrica visibles: resolución, cámara, audio, radio, Bluetooth, Wi-Fi, navegación, CANBUS y asignación de botones.
- Registrar versión Android, número de compilación, MCU, plataforma y configuración CANBUS tal como aparecen en Ajustes > Acerca del dispositivo.
- No cambiar esos parámetros durante el proyecto.
- Guardar una copia de los datos personales importantes mediante los mecanismos normales del fabricante.

### D. Límites importantes
- Un respaldo ADB de inventario y APK **no equivale** a una imagen completa del firmware ni a una copia de particiones.
- Android moderno no permite respaldar libremente los datos privados de todas las aplicaciones mediante ADB sin privilegios especiales.
- No ejecutar comandos de flasheo, fastboot, recovery, root, borrado de particiones, modificación MCU/CANBUS ni herramientas de actualización desconocidas.
- Un respaldo completo de firmware solo es posible si el fabricante/proveedor proporciona el paquete exacto y el procedimiento de recuperación para esta placa/MCU. No se debe improvisar.
- Antes de cambiar el launcher HOME, verificar que el launcher de fábrica siga instalado y que se pueda volver a seleccionar desde Ajustes o mediante ADB.

## Puerta de seguridad para instalar
No instalar en el dispositivo hasta:
1. Tener inventario ADB completo.
2. Conservar APK del launcher original cuando sea accesible.
3. Conservar capturas y datos de versión/MCU/CANBUS.
4. Verificar ABI, resolución, densidad, GPU y OpenGL ES.
5. Compilar un APK debug sin errores en un entorno reproducible.
6. Probar primero en emulador/dispositivo de prueba y después en la radio sin cambiar HOME.
7. Confirmar una ruta de reversión probada.

## Datos aún necesarios del dispositivo
- Salida completa de `getprop`.
- ABI soportadas.
- Resolución y densidad reales.
- GPU y versión OpenGL ES.
- Fabricante/modelo de placa y versión MCU mostrados por Ajustes.
- Paquete del launcher HOME original y si su APK se puede extraer.

## Regla de publicación
No subir VIN, patente, fotos privadas originales, dumps de configuración con datos personales ni credenciales. Mantener los archivos sensibles solo en una copia local privada.
