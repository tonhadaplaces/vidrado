# Vidrado

**Uma área de trabalho mais tranquila. Uma mente mais clara.**

Vidrado é um app nativo para a barra de menus do macOS que desfoca e escurece as janelas em segundo plano, mantendo a janela ativa nítida. Ele funciona inteiramente no seu Mac, sem conta, assinatura, rastreamento ou gravações de tela.

[Baixar](https://github.com/tonhadaplaces/vidrado/releases) · [Relatar um bug](https://github.com/tonhadaplaces/vidrado/issues/new?template=bug_report.yml) · [Contribuir](../../../AGENTS.md)

**Idiomas:** [English](../../../README.md) · [中文](../zh/README.md) · [हिन्दी](../hi/README.md) · [Español](../es/README.md) · [العربية](../ar/README.md) · [Français](../fr/README.md) · [বাংলা](../bn/README.md) · [Português](../pt/README.md) · [Bahasa Indonesia](../id/README.md) · [اردو](../ur/README.md) · [日本語](../ja/README.md) · [한국어](../ko/README.md) · [Русский](../ru/README.md)

## Veja em ação

![Controles de foco do Vidrado](../../../docs/screenshots/focus.png)

| Regras por app | Preferências |
| --- | --- |
| ![Regras por aplicativo com ícones reais em escala de cinza](../../../docs/screenshots/apps.png) | ![Preferências e comportamento automático](../../../docs/screenshots/preferences.png) |

## Recursos

- Desfoque, escurecimento ou ambos em tempo real nas janelas em segundo plano, com um controle rápido de intensidade e os níveis Leve, Equilibrado e Profundo.
- A janela ativa permanece nítida enquanto você alterna entre apps e Spaces.
- Regras por app: suavize automaticamente as janelas em segundo plano, mantenha um app nítido ou pause o foco enquanto ele estiver ativo. Os ícones reais dos apps aparecem em escala de cinza.
- Aplique o foco em todas as telas ou apenas na tela ativa; preserve janelas alinhadas e o Split View.
- Pausas opcionais durante o uso de tela cheia, compartilhamento de tela, captura contínua ou espelhamento de telas.
- Atalho global personalizável, gesto opcional de sacudir o cursor e inicialização ao iniciar a sessão.
- Predefinições salvas e preferências locais.
- Treze idiomas de interface. O Vidrado acompanha o idioma principal do sistema e usa o inglês como alternativa para idiomas não compatíveis. Árabe e urdu usam um layout da direita para a esquerda.

## Instalação

Requer **macOS 14 ou posterior**. Baixe o DMG em [Releases](https://github.com/tonhadaplaces/vidrado/releases), abra-o e arraste **Vidrado** para **Aplicativos**.

A distribuição atual usa uma **assinatura ad hoc** e **não é notarizada pela Apple**. Se o macOS impedir a abertura do app Vidrado que você baixou deste repositório, remova o atributo de quarentena apenas desse app:

```sh
xattr -dr com.apple.quarantine /Applications/Vidrado.app
```

Depois, abra o Vidrado novamente. Esse comando não notariza o app nem altera os ajustes do Gatekeeper para todo o sistema. Compile localmente se preferir. Os DMGs dos releases automáticos são compatíveis com **Apple silicon e Intel**.

## Uso

Clique no ícone de janelas sobrepostas na barra de menus para abrir os controles de foco. **⌥⌘B** ativa ou desativa o foco em qualquer lugar. Clicar com o botão direito ou com Option pressionado no ícone da barra de menus também alterna o foco.

Abra as preferências pelo botão de controles deslizantes ou com **⌘,**. Escolha os apps em **Manter alguns apps nítidos**. Os controles adicionais de efeitos, as predefinições e o gesto do cursor ficam em **Mais opções**. Feche a janela de ajustes com **⌘W**; o Vidrado continua funcionando na barra de menus. **⌘Q** encerra o app.

## Compilação e testes

Use Xcode ou Command Line Tools com Swift 5.9 ou mais recente:

```sh
git clone git@github.com:tonhadaplaces/vidrado.git
cd vidrado
swift run Vidrado --settings
./scripts/build.sh
swift test
./scripts/test.sh
./scripts/package.sh
```

`build.sh` compila e assina `dist/Vidrado.app`. `package.sh` gera `dist/Vidrado.dmg` e seu checksum SHA-256. Por padrão, a compilação usa a arquitetura do Mac. Use `VIDRADO_UNIVERSAL=1 ./scripts/package.sh` para compilar para Apple silicon e Intel.

`swift test` executa os testes XCTest do núcleo. O script completo de testes também executa verificações nativas nas configurações debug e release. Essas verificações exigem uma sessão gráfica desbloqueada, uma janela normal em primeiro plano e o Vidrado encerrado. A CI do GitHub executa os testes do núcleo e verifica a compilação do app; as verificações gráficas são executadas localmente.

Leia as [Diretrizes do repositório](../../../AGENTS.md) e as [Notas de validação](../../../TESTING.md) antes de contribuir. Envie um pull request: `main` exige pelo menos uma aprovação, CI aprovada e conversas de revisão resolvidas.

## Releases automáticos

Inclua as alterações de versão (`CFBundleShortVersionString` e `CFBundleVersion` em `Resources/Info.plist`) em um pull request. Após a aprovação e o merge na `main`, crie uma tag nesse commit:

```sh
git switch main
git pull --ff-only origin main
git tag v1.0.0
git push origin v1.0.0
```

Substitua `1.0.0` pela versão que será lançada. O GitHub Actions testa o código, compila um app universal, verifica o pacote assinado e o DMG e publica o DMG com seu checksum SHA-256. O workflow verifica se a tag está na `main` e corresponde à versão do app. Não são necessárias credenciais de uma conta paga do Apple Developer; os releases mantêm as limitações da assinatura ad hoc descritas acima.

## Privacidade e limitações técnicas

O Vidrado lê metadados de janelas e posiciona sobreposições não interativas abaixo da janela ativa. O compositor do macOS aplica o efeito ao conteúdo em segundo plano em tempo real. O app não lê seus documentos, não captura quadros da tela, não envia dados pela rede e não exige permissão de Acessibilidade.

O desfoque, o recorte, a detecção de compartilhamento e os metadados de Spaces usam funções privadas do SkyLight resolvidas em tempo de execução. A disponibilidade pode mudar com atualizações do macOS, e esta implementação não é adequada para a Mac App Store. A detecção de janelas lado a lado usa geometria. O efeito é visual e não serve para ocultar conteúdo sensível em gravações.

## Licença e créditos

[GNU AGPL-3.0](../../../LICENSE). Desenvolvido com Swift, SwiftUI e AppKit; sem dependências externas em tempo de execução. A fonte Inter é distribuída sob a [SIL Open Font License](../../../Sources/VidradoCore/Resources/Brand/Inter-OFL.txt). Os ícones de design do Lucide usam a licença ISC; consulte os [Avisos de terceiros](../../../THIRD_PARTY_NOTICES.md).

Inspirado no [Defocus](https://defocus.me/). O Vidrado é uma implementação independente e não usa o código-fonte do Defocus. O arquivo-fonte da interface está incluído no repositório como [`design.pen`](../../../design.pen).
