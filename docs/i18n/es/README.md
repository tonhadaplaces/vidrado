# Vidrado

**Un escritorio más tranquilo. Una mente más despejada.**

Vidrado es una app nativa para la barra de menús de macOS que desenfoca y atenúa las ventanas en segundo plano, manteniendo nítida la ventana activa. Funciona íntegramente en tu Mac, sin cuentas, suscripciones, seguimiento ni grabaciones de pantalla.

[Descargar](https://github.com/tonhadaplaces/vidrado/releases) · [Informar de un error](https://github.com/tonhadaplaces/vidrado/issues/new?template=bug_report.yml) · [Contribuir](../../../AGENTS.md)

**Idiomas:** [English](../../../README.md) · [中文](../zh/README.md) · [हिन्दी](../hi/README.md) · [Español](../es/README.md) · [العربية](../ar/README.md) · [Français](../fr/README.md) · [বাংলা](../bn/README.md) · [Português](../pt/README.md) · [Bahasa Indonesia](../id/README.md) · [اردو](../ur/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md) · [Русский](../ru/README.md)

## Mira cómo funciona

![Controles de enfoque de Vidrado](../../../docs/screenshots/focus.png)

| Reglas por app | Preferencias |
| --- | --- |
| ![Reglas por aplicación con iconos reales en escala de grises](../../../docs/screenshots/apps.png) | ![Preferencias y comportamiento automático](../../../docs/screenshots/preferences.png) |

## Funciones

- Desenfoque, atenuación o ambos en tiempo real en las ventanas en segundo plano, con un control rápido de intensidad y los niveles Ligero, Equilibrado y Profundo.
- La ventana activa se mantiene nítida al cambiar entre apps y Spaces.
- Reglas por app: suaviza automáticamente las ventanas en segundo plano, mantén una app nítida o pausa el enfoque mientras esté activa. Los iconos reales de las apps se muestran en escala de grises.
- Aplica el enfoque en todas las pantallas o solo en la activa; conserva las ventanas alineadas y Split View.
- Pausas opcionales durante el uso de pantalla completa, el uso compartido de pantalla, la captura continua o la duplicación de pantallas.
- Atajo global personalizable, gesto opcional de sacudir el cursor e inicio al iniciar sesión.
- Preajustes guardados y preferencias locales.
- Trece idiomas de interfaz. Vidrado sigue el idioma principal del sistema y usa el inglés para los idiomas no compatibles. El árabe y el urdu utilizan una disposición de derecha a izquierda.

## Instalación

Requiere **macOS 14 o posterior**. Descarga el DMG desde [Releases](https://github.com/tonhadaplaces/vidrado/releases), ábrelo y arrastra **Vidrado** a **Aplicaciones**.

La distribución actual utiliza una **firma ad hoc** y **no está notarizada por Apple**. Si macOS impide abrir la app Vidrado que descargaste de este repositorio, elimina el atributo de cuarentena únicamente de esa app:

```sh
xattr -dr com.apple.quarantine /Applications/Vidrado.app
```

Después, abre Vidrado de nuevo. Este comando no notariza la app ni modifica los ajustes de Gatekeeper para todo el sistema. Si lo prefieres, compila la app localmente. Los DMG de los releases automáticos son compatibles con **Apple silicon e Intel**.

## Uso

Haz clic en el icono de ventanas superpuestas de la barra de menús para abrir los controles de enfoque. **⌥⌘B** activa o desactiva el enfoque desde cualquier lugar. También puedes alternarlo haciendo clic con el botón derecho o con Option pulsado en el icono de la barra de menús.

Abre las preferencias con el botón de controles deslizantes o con **⌘,**. Elige las apps en **Mantener algunas apps nítidas**. Los controles adicionales de efectos, los preajustes y el gesto del cursor están en **Más opciones**. Cierra la ventana de ajustes con **⌘W**; Vidrado sigue funcionando en la barra de menús. **⌘Q** cierra la app.

## Compilación y pruebas

Usa Xcode o Command Line Tools con Swift 5.9 o posterior:

```sh
git clone git@github.com:tonhadaplaces/vidrado.git
cd vidrado
swift run Vidrado --settings
./scripts/build.sh
swift test
./scripts/test.sh
./scripts/package.sh
```

`build.sh` compila y firma `dist/Vidrado.app`. `package.sh` genera `dist/Vidrado.dmg` y su suma de comprobación SHA-256. La compilación predeterminada usa la arquitectura del Mac. Usa `VIDRADO_UNIVERSAL=1 ./scripts/package.sh` para compilar para Apple silicon e Intel.

`swift test` ejecuta las pruebas XCTest del núcleo. El script completo de pruebas también ejecuta comprobaciones nativas en las configuraciones debug y release. Estas comprobaciones requieren una sesión gráfica desbloqueada, una ventana normal en primer plano y Vidrado cerrado. La CI de GitHub ejecuta las pruebas del núcleo y verifica la compilación de la app; las comprobaciones gráficas se ejecutan localmente.

Lee las [Directrices del repositorio](../../../AGENTS.md) y las [Notas de validación](../../../TESTING.md) antes de contribuir. Envía un pull request: `main` requiere al menos una aprobación, CI satisfactoria y conversaciones de revisión resueltas.

## Releases automáticos

Una vez que los cambios revisados se hayan integrado en `main`, actualiza `CFBundleShortVersionString` y `CFBundleVersion` en `Resources/Info.plist` para la nueva versión y envía una etiqueta correspondiente:

```sh
git switch main
git pull --ff-only origin main
git tag v1.0.0
git push origin v1.0.0
```

Sustituye `1.0.0` por la versión que se va a publicar. GitHub Actions prueba el código, compila una app universal, verifica el paquete firmado y el DMG, y publica el DMG junto con su suma de comprobación SHA-256. El workflow comprueba que la etiqueta esté en `main` y coincida con la versión de la app. No se necesitan credenciales de una cuenta de pago de Apple Developer; los releases conservan las limitaciones de la firma ad hoc descritas arriba.

## Privacidad y limitaciones técnicas

Vidrado lee metadatos de ventanas y coloca superposiciones no interactivas debajo de la ventana activa. El compositor de macOS aplica el efecto al contenido en segundo plano en tiempo real. La app no lee tus documentos, no captura fotogramas de la pantalla, no envía datos por la red y no requiere permiso de Accesibilidad.

El desenfoque, el recorte, la detección de uso compartido y los metadatos de Spaces utilizan funciones privadas de SkyLight resueltas en tiempo de ejecución. Su disponibilidad puede cambiar con las actualizaciones de macOS, y esta implementación no es adecuada para la Mac App Store. La detección de ventanas en mosaico utiliza geometría. El efecto es visual y no sirve para ocultar contenido sensible en grabaciones.

## Licencia y créditos

[GNU AGPL-3.0](../../../LICENSE). Desarrollado con Swift, SwiftUI y AppKit; sin dependencias externas en tiempo de ejecución. Inter se distribuye bajo la [SIL Open Font License](../../../Sources/VidradoCore/Resources/Brand/Inter-OFL.txt). Los iconos de diseño de Lucide utilizan la licencia ISC; consulta los [Avisos de terceros](../../../THIRD_PARTY_NOTICES.md).

Inspirado en [Defocus](https://defocus.me/). Vidrado es una implementación independiente y no utiliza el código fuente de Defocus. El archivo fuente de la interfaz está incluido en el repositorio como [`design.pen`](../../../design.pen).
