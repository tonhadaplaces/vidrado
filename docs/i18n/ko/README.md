# Vidrado

**차분한 데스크탑. 맑아지는 생각.**

Vidrado는 활성 창을 선명하게 유지하면서 배경 창을 흐리게 하거나 어둡게 만드는 macOS 네이티브 메뉴 막대 앱입니다. 모든 기능은 Mac 안에서 작동하며 계정, 구독, 추적, 화면 녹화가 없습니다.

[다운로드](https://github.com/tonhadaplaces/vidrado/releases) · [버그 신고](https://github.com/tonhadaplaces/vidrado/issues/new?template=bug_report.yml) · [기여하기](../../../AGENTS.md)

**언어:** [English](../../../README.md) · [中文](../zh/README.md) · [हिन्दी](../hi/README.md) · [Español](../es/README.md) · [العربية](../ar/README.md) · [Français](../fr/README.md) · [বাংলা](../bn/README.md) · [Português](../pt/README.md) · [Bahasa Indonesia](../id/README.md) · [اردو](../ur/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md) · [Русский](../ru/README.md)

## 작동 모습

![Vidrado 집중 제어](../../../docs/screenshots/focus.png)

| 앱별 규칙 | 환경설정 |
| --- | --- |
| ![실제 앱 아이콘을 회색조로 표시하는 앱별 규칙](../../../docs/screenshots/apps.png) | ![환경설정 및 자동 동작](../../../docs/screenshots/preferences.png) |

## 기능

- 배경 창에 실시간으로 흐림, 어둡게 하기 또는 두 효과를 함께 적용합니다. 간편한 강도 슬라이더와 가볍게, 균형 있게, 깊게 수준을 제공합니다.
- 앱과 Spaces를 전환해도 활성 창은 선명하게 유지됩니다.
- 앱별 규칙으로 배경 창을 자동으로 흐리게 하거나, 특정 앱을 선명하게 유지하거나, 해당 앱이 활성 상태일 때 집중을 일시 정지할 수 있습니다. 실제 앱 아이콘은 회색조로 표시됩니다.
- 모든 디스플레이 또는 활성 디스플레이에만 집중을 적용하고, 정렬된 창과 Split View를 유지합니다.
- 전체 화면, 화면 공유, 지속적인 캡처 또는 디스플레이 미러링 중에 선택적으로 일시 정지할 수 있습니다.
- 사용자 지정 가능한 전역 단축키, 선택적 커서 흔들기 동작, 로그인 시 실행을 지원합니다.
- 저장된 프리셋과 로컬 환경설정.
- 13개 인터페이스 언어를 지원합니다. Vidrado는 시스템의 기본 언어를 따르며, 지원하지 않는 언어에서는 영어를 사용합니다. 아랍어와 우르두어는 오른쪽에서 왼쪽으로 배치됩니다.

## 설치

**macOS 14 이상**이 필요합니다. [Releases](https://github.com/tonhadaplaces/vidrado/releases)에서 DMG를 다운로드한 뒤 열고, **Vidrado**를 **응용 프로그램**으로 드래그하세요.

현재 배포본은 **ad hoc 서명**을 사용하며 **Apple의 공증을 받지 않았습니다**. 이 저장소에서 다운로드한 Vidrado 앱의 실행을 macOS가 차단하면, 해당 앱에서만 격리 속성을 제거하세요.

```sh
xattr -dr com.apple.quarantine /Applications/Vidrado.app
```

그런 다음 Vidrado를 다시 여세요. 이 명령은 앱을 공증하거나 시스템 전체의 Gatekeeper 설정을 변경하지 않습니다. 원한다면 로컬에서 빌드할 수도 있습니다. 자동 릴리스의 DMG는 **Apple silicon과 Intel**을 지원합니다.

## 사용법

메뉴 막대의 겹친 창 아이콘을 클릭하면 집중 제어가 열립니다. **⌥⌘B**로 어디서나 집중을 켜거나 끌 수 있습니다. 메뉴 막대 아이콘을 오른쪽 클릭하거나 Option 키를 누른 채 클릭해도 전환됩니다.

슬라이더 버튼 또는 **⌘,**로 환경설정을 여세요. **일부 앱을 선명하게 유지**에서 앱을 선택하세요. 추가 효과 슬라이더, 프리셋, 커서 동작은 **추가 옵션**에 있습니다. **⌘W**로 설정 창을 닫아도 Vidrado는 메뉴 막대에서 계속 실행됩니다. **⌘Q**는 앱을 종료합니다.

## 빌드 및 테스트

Swift 5.9 이상이 포함된 Xcode 또는 Command Line Tools를 사용하세요.

```sh
git clone git@github.com:tonhadaplaces/vidrado.git
cd vidrado
swift run Vidrado --settings
./scripts/build.sh
swift test
./scripts/test.sh
./scripts/package.sh
```

`build.sh`는 `dist/Vidrado.app`을 빌드하고 서명합니다. `package.sh`는 `dist/Vidrado.dmg`와 SHA-256 체크섬을 생성합니다. 기본 빌드는 해당 Mac의 아키텍처를 대상으로 합니다. Apple silicon과 Intel용으로 빌드하려면 `VIDRADO_UNIVERSAL=1 ./scripts/package.sh`를 사용하세요.

`swift test`는 코어 XCTest 테스트를 실행합니다. 전체 테스트 스크립트는 debug와 release 구성에서 네이티브 검사도 실행합니다. 이 검사에는 잠금이 해제된 그래픽 세션, 전면의 일반 창, 종료된 Vidrado가 필요합니다. GitHub CI는 코어 테스트를 실행하고 앱 빌드를 검증하며, 그래픽 검사는 로컬에서 실행합니다.

기여하기 전에 [저장소 지침](../../../AGENTS.md)과 [검증 참고 사항](../../../TESTING.md)을 읽으세요. 풀 리퀘스트를 사용하세요. `main`에는 최소 1개의 승인, CI 통과, 리뷰 대화 해결이 필요합니다.

## 자동 릴리스

리뷰를 마친 변경 사항이 `main`에 병합되면 `Resources/Info.plist`의 `CFBundleShortVersionString`과 `CFBundleVersion`을 새 버전으로 업데이트하고, 이에 맞는 태그를 푸시하세요.

```sh
git switch main
git pull --ff-only origin main
git tag v1.0.0
git push origin v1.0.0
```

`1.0.0`을 릴리스할 버전으로 바꾸세요. GitHub Actions는 코드를 테스트하고 유니버설 앱을 빌드한 뒤, 서명된 번들과 DMG를 검증하고 DMG와 SHA-256 체크섬을 게시합니다. 워크플로는 태그가 `main`에 있고 앱 버전과 일치하는지 확인합니다. 유료 Apple Developer 계정의 자격 증명은 필요하지 않으며, 릴리스에는 위에서 설명한 ad hoc 서명의 제약이 그대로 적용됩니다.

## 개인정보 보호 및 기술적 제약

Vidrado는 창 메타데이터를 읽고 활성 창 아래에 상호작용하지 않는 오버레이를 배치합니다. macOS 컴포지터가 배경 콘텐츠에 실시간으로 효과를 적용합니다. 앱은 문서를 읽거나 화면 프레임을 캡처하거나 네트워크로 데이터를 전송하지 않으며, 손쉬운 사용 권한도 필요하지 않습니다.

흐림, 클리핑, 공유 감지, Spaces 메타데이터에는 실행 중에 동적으로 찾는 비공개 SkyLight 함수를 사용합니다. macOS 업데이트에 따라 사용 가능 여부가 달라질 수 있으며, 이 구현은 Mac App Store에 적합하지 않습니다. 타일로 배치된 창은 기하학적 정보로 감지합니다. 이 효과는 시각적인 효과이며, 녹화에서 민감한 콘텐츠를 숨기는 수단이 아닙니다.

## 라이선스 및 크레딧

[GNU AGPL-3.0](../../../LICENSE). Swift, SwiftUI, AppKit으로 개발했으며 외부 런타임 의존성이 없습니다. Inter는 [SIL Open Font License](../../../Sources/VidradoCore/Resources/Brand/Inter-OFL.txt)에 따라 배포됩니다. Lucide 디자인 아이콘은 ISC 라이선스를 사용합니다. [서드파티 고지](../../../THIRD_PARTY_NOTICES.md)를 참고하세요.

[Defocus](https://defocus.me/)에서 영감을 받았습니다. Vidrado는 독립적인 구현이며 Defocus 소스 코드를 사용하지 않습니다. 인터페이스 소스 파일은 [`design.pen`](../../../design.pen)으로 저장소에 포함되어 있습니다.
