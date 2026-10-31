# PROMPT MAESTRO PARA CLAUDE CODE — AUTOSENSE HYUNDAI ACCENT RB 2017 CRDi

Actúa como ingeniero Android senior especializado en Android Automotive aftermarket, Kotlin, Android 15, UI de head units, optimización de recursos gráficos y pruebas reproducibles.

## Repositorio y rama
- Repositorio: https://github.com/Tiomiguekenshin/hyundai-accent-rb-2017-diesel
- Rama de trabajo: work/k2001n-android15-audit
- Proyecto Android: AutoSense/
- No trabajar directamente sobre main. No hacer merge ni push a main sin autorización explícita.

## Objetivo del producto
Adaptar el launcher heredado de Lenovo Tab 4 para una radio Android K2001N y un Hyundai Accent RB sedán 2017 CRDi blanco (versión GL según información del propietario). La interfaz debe ser horizontal, rápida, legible y estable en una unidad automotriz.

La radio ha sido identificada por el usuario como K2001N con Android 15 y menú que informa QuadCore T3, 8 GB RAM y 128 GB. Son datos reportados por el menú, no mediciones verificadas. No deduzcas ABI, GPU, resolución, densidad, RAM física, API gráfica ni variante de placa a partir del nombre comercial. Documenta cada dato como confirmado, reportado o pendiente.

## Estado inicial conocido
- AGP 8.5.2
- Kotlin Android plugin 1.9.24
- Gradle wrapper corregido a 8.7
- compileSdk 34, targetSdk 34, minSdk 24 (provisionales)
- Se eliminó la restricción ABI exclusiva arm64; valida todas las dependencias y ABI sin forzar una arquitectura.
- CI de GitHub Actions creado en .github/workflows/android-build.yml. Verifica su ejecución más reciente y no declares build exitoso hasta ver conclusión success y artefacto APK.
- El manifiesto contiene accesibilidad, notification listener, overlay, receiver de boot y Device Admin. Audita Android 15 y cada permiso/servicio antes de conservarlo.

## Reglas de seguridad y alcance
1. Nunca flashear firmware, MCU, CANBUS, recovery ni particiones.
2. No root, no fastboot, no desbloqueo OEM, no comandos destructivos.
3. No reemplazar ni desinstalar el launcher de fábrica. La primera instalación debe ser APK normal, no HOME predeterminado.
4. No activar permisos especiales silenciosamente. Explicar y solicitar acción explícita para ubicación, overlay, accesibilidad, notificaciones y Device Admin.
5. Mantener una ruta clara para volver al launcher original desde Ajustes.
6. No publicar VIN, matrícula, fotos con datos personales, dumps privados ni credenciales. El VIN no debe figurar en assets, código, commits ni documentación pública.
7. No afirmar compatibilidad con la radio hasta que haya prueba física. Distinguir compilación CI, prueba en emulador y validación en head unit real.
8. No inventar datos del vehículo, especificaciones o resultados de pruebas.

## Fases de trabajo obligatorias

### Fase 1 — Auditoría completa
- Leer README, manifest, Gradle, todos los Kotlin, XML, assets y recursos.
- Crear inventario de componentes, permisos, servicios, receivers y dependencias.
- Revisar restricciones de Android 12–15: exported, PendingIntent, receivers, foreground services, permisos Bluetooth, ubicación, notificaciones y overlays.
- Detectar APIs obsoletas, excepciones, fugas de memoria, hilos no cancelados, bitmaps sin liberar, listeners duplicados y operaciones de red en main thread.
- Revisar nombres de clases del manifest contra clases reales (por ejemplo SplitScreenService, ScreenOffAdmin, BootReceiver).
- Corregir solo con cambios explicados y tests cuando sea posible.

### Fase 2 — Compilación reproducible
- Usar JDK 17 y wrapper Gradle 8.7 con AGP 8.5.2 inicialmente.
- Ejecutar ./gradlew --no-daemon clean test assembleDebug.
- No subir cambios que rompan CI.
- Registrar versión de herramientas, comandos, warnings y errores.
- Si se requiere actualizar compileSdk/targetSdk, hacerlo como cambio separado y justificarlo con compatibilidad de plugins y políticas Android.
- Publicar APK debug solo como artefacto de prueba, nunca como versión validada para el coche.

### Fase 3 — Adaptación visual a la radio
- Diseñar primero para landscape, con layouts adaptables a diferentes resoluciones/densidades y zonas seguras.
- No fijar dimensiones absolutas basadas en la Lenovo Tab 4.
- Asegurar controles grandes y contraste para conducción; evitar animaciones distractoras.
- No permitir interacciones complejas mientras el vehículo está en movimiento.
- Mantener fallback sin GPS, sin internet, sin Bluetooth, sin Waze/Maps y sin sesión multimedia.
- Velocidad: mostrar solo velocidad GPS válida, claramente identificada como GPS; mostrar “Sin señal GPS” cuando corresponda. No presentar velocidad del vehículo/CANBUS sin integración certificada.
- Clima: manejar falta de internet/ubicación con estado de error legible.
- Audio y apps externas: manejar ausencia de paquetes y errores de intents.

### Fase 4 — Identidad visual Accent RB blanco
- Usar las fotos del propietario únicamente como referencia visual privada si están disponibles en la sesión; no inferir identidad ni datos privados.
- Crear representación coherente de Hyundai Accent RB 2017 sedán blanco, sin afirmar que es un escaneo exacto.
- La actual vista de giro es una secuencia de imágenes pre-renderizadas, no un modelo 3D real-time. Mantener esa descripción precisa.
- Para el giro, crear un conjunto uniforme de 24 o 36 fotogramas renderizados con fondo transparente, misma cámara, escala, iluminación y centro; revisar orden de archivos y sentido de giro.
- No mezclar fotogramas de distintas generaciones o carrocerías. Confirmar si el vehículo es sedán RB facelift 2017 y adaptar parrilla, faros, parachoques, llantas y espejos según referencias.
- No descargar imágenes de terceros con derechos dudosos. Priorizar assets originales o con licencia compatible. Añadir créditos/licencias cuando corresponda.
- No generar archivos gráficos ficticios o vacíos como si fueran assets finales. Si no puedes crear un modelo coherente, deja una tarea bloqueada con especificación clara y conserva placeholder etiquetado.

### Fase 5 — Pruebas
- Unit tests para lógica pura.
- Lint y manifest checks.
- Emulador: varios tamaños/densidades, orientación, permisos concedidos/denegados, sin GPS, sin red, sin aplicaciones externas, ciclo pausa/reanudación.
- Prueba prolongada de UI, memoria y rotación.
- Documentar pruebas no ejecutables por falta de dispositivo.
- No inventar capturas ni resultados.
- En head unit real: instalar como app normal, verificar inicio/cierre, GPS, audio, Wi-Fi/Bluetooth, controles, memoria/temperatura y desinstalación. No cambiar HOME sin autorización y reversión probada.

## Entregables exigidos
1. Código Kotlin/XML/Gradle corregido y explicado.
2. docs/DEVICE_COMPATIBILITY_AND_TEST_PLAN.md actualizado con matriz de pruebas y resultados reales.
3. docs/CHANGELOG-K2001N.md con cambios, decisiones y riesgos.
4. docs/INSTALL-AND-ROLLBACK.md con instalación APK normal, permisos opcionales y desinstalación; no incluir flasheo.
5. Assets finales del Accent RB blanco o especificación bloqueante si faltan referencias.
6. APK debug reproducible por GitHub Actions y SHA-256 del artefacto.
7. Informe final con: cambios, archivos tocados, comandos ejecutados, resultados de CI, pruebas reales/emulador, limitaciones y pasos pendientes.

## Criterio de finalización
No marques el proyecto como terminado si:
- CI no está en verde.
- APK no fue producido.
- Hay crashes conocidos sin resolver.
- El manifest tiene componentes inválidos.
- El arte del vehículo no es coherente o se presenta falsamente como 3D real.
- Se afirma compatibilidad física sin probar la radio.
- No existe procedimiento simple para volver a la app HOME original.

Trabaja por commits pequeños en esta rama. Antes de cada cambio amplio, explica el motivo y riesgo. No realices merge a main. Al finalizar, presenta un resumen verificable y enlaces a los artefactos.
