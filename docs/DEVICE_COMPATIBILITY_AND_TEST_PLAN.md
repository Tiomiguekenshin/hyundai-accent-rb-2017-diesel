# AutoSense — plan de adaptación K2001N / Hyundai Accent RB 2017 CRDi

## Objetivo
Adaptar el launcher heredado de Lenovo Tab 4 a una unidad Android automotriz K2001N con Android 15, para un Hyundai Accent RB sedán 2017 CRDi blanco (identificación aportada por el propietario). La radio reporta plataforma QuadCore-T3, 8 GB RAM y 128 GB almacenamiento; estos datos de pantalla todavía deben verificarse mediante Android y no se asumen como capacidad física confirmada.

## Estado de esta rama
- Rama de trabajo: `work/k2001n-android15-audit`.
- El repositorio original y la rama `main` se mantienen separados.
- Se ajustó el wrapper a Gradle 8.7, pareja prevista para Android Gradle Plugin 8.5.2.
- Se eliminó el filtro exclusivo ARM64: la compilación debe incluir las ABI soportadas por dependencias y toolchain, sin asumir la ABI de la radio.
- Se mantiene compileSdk/targetSdk 34 de forma provisional para no mezclar una actualización de plataforma con la adaptación inicial. Debe probarse en Android 15 y actualizarse de forma deliberada.
- No se afirma que exista ya un APK validado en la K2001N.

## Dispositivo objetivo y límites
- Unidad: K2001N.
- Android reportado por pantalla: 15.
- SoC reportado por menú de la unidad: QuadCore-T3. El nombre comercial no basta para inferir arquitectura, GPU, API gráfica o rendimiento.
- Vehículo: Hyundai Accent RB sedán 2017 CRDi, blanco.
- No usar el VIN, patente, fotos con matrícula ni dumps que contengan identificadores personales en recursos públicos del repositorio.
- La aplicación no debe escribir en MCU, CANBUS, particiones, firmware, recovery ni configuración de fábrica.

## Auditoría técnica obligatoria
1. Revisar todas las llamadas Android obsoletas/restringidas y permisos runtime.
2. Revisar foreground services, receivers y restricciones de Android 12–15.
3. Revisar accesibilidad, notification listener, overlay y Device Admin: cada capacidad debe ser opcional, explicada y activada por el usuario; no asumir que la unidad lo permite.
4. Revisar permisos Bluetooth: usar permisos modernos en Android 12+ y compatibilidad condicional en versiones anteriores.
5. Revisar orientación, resolución, densidad, barras del sistema, modo inmersivo y tamaños de ventana.
6. Revisar acceso a ubicación/GPS y mostrar estado “sin señal” en vez de inventar velocidad.
7. Revisar consumo de memoria: cargar imágenes bajo demanda, limitar caché y liberar Bitmaps al destruir vistas.
8. Comprobar que volver al launcher de fábrica siempre sea posible; AutoSense no debe autoasignarse como HOME.

## Estrategia de recursos del vehículo
- Las fotos del propietario sirven como referencia visual de carrocería, color blanco, frontal, perfil y trasera.
- No se debe afirmar que se generó un modelo CAD/3D exacto a partir de fotos. Las imágenes 360 actuales son fotogramas pre-renderizados, no geometría 3D interactiva.
- Sustituir el arte heredado por recursos originales/legítimos de un Accent RB 2017 blanco. Preferir render 3D encargado/generado con vistas consistentes; documentar que es una representación visual, no un escaneo exacto del vehículo.
- Mantener 24 o 36 fotogramas con fondo transparente, encuadre y escala constantes. Verificar que el orden de nombres coincide con el sentido de giro que espera `CarTurntableView`.
- Crear vistas frontal 3/4, lateral, trasera 3/4 y rueda solo si se pueden producir con coherencia geométrica. No mezclar generaciones incompatibles.

## Puertas de calidad
### Puerta A — compilación
- JDK 17.
- Gradle wrapper reproducible.
- `./gradlew --no-daemon clean test assembleDebug`.
- Sin errores de compilación; registrar warnings conocidos.
- APK debug generado por CI y hash SHA-256 publicado como artefacto de workflow.

### Puerta B — prueba en emulador
- Instalar y abrir sin crash.
- Rotación horizontal, pantallas pequeñas/grandes y densidades variadas.
- Conceder/denegar ubicación y probar ausencia de GPS.
- Sin conexión y con conexión de red.
- Sin Waze/Maps instalado.
- Probar reproducción multimedia sin sesión activa.
- Verificar navegación de vuelta y que no se bloquee el sistema.

### Puerta C — prueba en K2001N
Solo después de conocer ABI, resolución, densidad, GPU/OpenGL ES y fabricante/firmware exactos:
- Instalar como aplicación normal, no seleccionar HOME.
- Probar apertura/cierre, GPS, audio, Wi-Fi, Bluetooth y controles de pantalla.
- Medir fluidez, memoria, temperatura y estabilidad durante al menos 30 minutos.
- Desinstalar y comprobar que la radio conserva su launcher original.
- Solo considerar HOME predeterminado tras una prueba reversible y aprobación explícita del propietario.

## Criterios de no-go
- No flashear firmware ni MCU.
- No root, fastboot, recovery ni comandos de particionado.
- No activar silenciosamente accesibilidad, administrador del dispositivo, notificaciones u overlays.
- No publicar APK como “compatible/validado” hasta pasar Puerta C.
- No mostrar velocidad real si la fuente GPS no es válida.
- No incluir VIN, matrícula, credenciales ni datos privados en commits.

## Resultado esperado
Un launcher Android compilable y adaptable, con documentación honesta de compatibilidad, recursos visuales consistentes del Accent RB blanco y un APK debug reproducible. La validación física de la radio será una etapa separada y explícita.
