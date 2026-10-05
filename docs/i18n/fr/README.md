# Vidrado

**Un bureau plus calme. Un esprit plus clair.**

Vidrado est une app native pour la barre des menus de macOS qui floute et assombrit les fenêtres en arrière-plan tout en gardant la fenêtre active nette. Elle fonctionne entièrement sur votre Mac, sans compte, abonnement, suivi ni enregistrement d’écran.

[Télécharger](https://github.com/tonhadaplaces/vidrado/releases) · [Signaler un bug](https://github.com/tonhadaplaces/vidrado/issues/new?template=bug_report.yml) · [Contribuer](../../../AGENTS.md)

**Langues :** [English](../../../README.md) · [中文](../zh/README.md) · [हिन्दी](../hi/README.md) · [Español](../es/README.md) · [العربية](../ar/README.md) · [Français](../fr/README.md) · [বাংলা](../bn/README.md) · [Português](../pt/README.md) · [Bahasa Indonesia](../id/README.md) · [اردو](../ur/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md) · [Русский](../ru/README.md)

## Découvrez l’app en action

![Commandes de concentration de Vidrado](../../../docs/screenshots/focus.png)

| Règles par app | Préférences |
| --- | --- |
| ![Règles par application avec de vraies icônes en niveaux de gris](../../../docs/screenshots/apps.png) | ![Préférences et comportement automatique](../../../docs/screenshots/preferences.png) |

## Fonctionnalités

- Flou, assombrissement ou les deux en temps réel sur les fenêtres en arrière-plan, avec un curseur d’intensité rapide et les niveaux Léger, Équilibré et Profond.
- La fenêtre active reste nette lorsque vous passez d’une app à l’autre et entre les Spaces.
- Règles par app : adoucissez automatiquement les fenêtres en arrière-plan, gardez une app nette ou mettez la concentration en pause lorsqu’elle est active. Les véritables icônes des apps s’affichent en niveaux de gris.
- Appliquez la concentration à tous les écrans ou seulement à l’écran actif ; préservez les fenêtres alignées et Split View.
- Pauses facultatives en plein écran, lors du partage d’écran, d’une capture continue ou de la recopie vidéo.
- Raccourci global personnalisable, geste facultatif consistant à secouer le curseur et lancement à l’ouverture de session.
- Préréglages enregistrés et préférences locales.
- Treize langues d’interface. Vidrado suit la langue principale du système et utilise l’anglais pour les langues non prises en charge. L’arabe et l’ourdou utilisent une disposition de droite à gauche.

## Installation

Nécessite **macOS 14 ou une version ultérieure**. Téléchargez le DMG depuis [Releases](https://github.com/tonhadaplaces/vidrado/releases), ouvrez-le et faites glisser **Vidrado** dans **Applications**.

La distribution actuelle utilise une **signature ad hoc** et **n’est pas notariée par Apple**. Si macOS empêche l’ouverture de l’app Vidrado téléchargée depuis ce dépôt, supprimez l’attribut de quarantaine de cette app uniquement :

```sh
xattr -dr com.apple.quarantine /Applications/Vidrado.app
```

Ouvrez ensuite Vidrado à nouveau. Cette commande ne notarie pas l’app et ne modifie pas les réglages de Gatekeeper à l’échelle du système. Vous pouvez aussi compiler l’app localement. Les DMG des releases automatiques prennent en charge **Apple silicon et Intel**.

## Utilisation

Cliquez sur l’icône de fenêtres superposées dans la barre des menus pour ouvrir les commandes de concentration. **⌥⌘B** active ou désactive la concentration depuis n’importe où. Un clic droit ou un clic avec Option sur l’icône de la barre des menus permet également de la basculer.

Ouvrez les préférences avec le bouton de curseurs ou **⌘,**. Choisissez les apps sous **Garder certaines apps nettes**. Les curseurs d’effets supplémentaires, les préréglages et le geste du curseur se trouvent sous **Plus d’options**. Fermez la fenêtre des réglages avec **⌘W** ; Vidrado continue de fonctionner dans la barre des menus. **⌘Q** quitte l’app.

## Compilation et tests

Utilisez Xcode ou Command Line Tools avec Swift 5.9 ou une version ultérieure :

```sh
git clone git@github.com:tonhadaplaces/vidrado.git
cd vidrado
swift run Vidrado --settings
./scripts/build.sh
swift test
./scripts/test.sh
./scripts/package.sh
```

`build.sh` compile et signe `dist/Vidrado.app`. `package.sh` produit `dist/Vidrado.dmg` et sa somme de contrôle SHA-256. Par défaut, la compilation cible l’architecture du Mac. Utilisez `VIDRADO_UNIVERSAL=1 ./scripts/package.sh` pour compiler pour Apple silicon et Intel.

`swift test` exécute les tests XCTest du cœur de l’app. Le script complet de tests exécute aussi des vérifications natives dans les configurations debug et release. Ces vérifications nécessitent une session graphique déverrouillée, une fenêtre normale au premier plan et Vidrado fermé. La CI de GitHub exécute les tests du cœur et vérifie la compilation de l’app ; les vérifications graphiques s’exécutent localement.

Lisez les [Consignes du dépôt](../../../AGENTS.md) et les [Notes de validation](../../../TESTING.md) avant de contribuer. Passez par une pull request : `main` exige au moins une approbation, une CI réussie et des discussions de revue résolues.

## Releases automatiques

Une fois les modifications revues et fusionnées dans `main`, mettez à jour `CFBundleShortVersionString` et `CFBundleVersion` dans `Resources/Info.plist` pour la nouvelle version, puis poussez un tag correspondant :

```sh
git switch main
git pull --ff-only origin main
git tag v1.0.0
git push origin v1.0.0
```

Remplacez `1.0.0` par la version à publier. GitHub Actions teste le code, compile une app universelle, vérifie le bundle signé et le DMG, puis publie le DMG avec sa somme de contrôle SHA-256. Le workflow vérifie que le tag est sur `main` et correspond à la version de l’app. Aucun identifiant Apple Developer payant n’est nécessaire ; les releases conservent les limites de la signature ad hoc décrites ci-dessus.

## Confidentialité et limites techniques

Vidrado lit les métadonnées des fenêtres et place des superpositions non interactives sous la fenêtre active. Le compositeur de macOS applique l’effet au contenu en arrière-plan en temps réel. L’app ne lit pas vos documents, ne capture pas d’images de l’écran, n’envoie pas de données sur le réseau et ne nécessite pas d’autorisation d’Accessibilité.

Le flou, le découpage, la détection du partage et les métadonnées de Spaces utilisent des fonctions privées de SkyLight résolues à l’exécution. Leur disponibilité peut changer avec les mises à jour de macOS, et cette implémentation ne convient pas au Mac App Store. La détection des fenêtres disposées en mosaïque repose sur la géométrie. L’effet est visuel et ne permet pas de dissimuler du contenu sensible dans les enregistrements.

## Licence et crédits

[GNU AGPL-3.0](../../../LICENSE). Développé avec Swift, SwiftUI et AppKit ; aucune dépendance externe à l’exécution. Inter est distribué sous la [SIL Open Font License](../../../Sources/VidradoCore/Resources/Brand/Inter-OFL.txt). Les icônes de design Lucide utilisent la licence ISC ; consultez les [Mentions relatives aux composants tiers](../../../THIRD_PARTY_NOTICES.md).

Inspiré de [Defocus](https://defocus.me/). Vidrado est une implémentation indépendante et n’utilise pas le code source de Defocus. Le fichier source de l’interface est inclus dans le dépôt sous le nom [`design.pen`](../../../design.pen).
