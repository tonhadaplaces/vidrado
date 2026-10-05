# Validação do Vidrado

Ambiente: macOS 27.0 (26A428), Apple silicon, Swift 6.4, uma tela Retina de 1512 × 982 pontos. Validação realizada em 4 de outubro de 2026. A versão mínima declarada é macOS 14; outros macOS não estavam disponíveis para execução física.

## Preparação da release

Na repetição atual, os 13 testes XCTest passaram. O build universal contém arm64 e x86_64, com versão mínima macOS 14.0 em ambas as arquiteturas; assinatura ad hoc, DMG e checksum foram verificados. `actionlint` validou os workflows de CI e release; os 13 catálogos passaram em `plutil`.

As verificações nativas em debug e release passaram em 23 de 24 casos. A verificação da ordem do compositor falhou: o painel estava marcado como visível no AppKit, mas não apareceu na lista de janelas na tela. Essa verificação permanece pendente; não foi tratada como aprovação. A comparação do texto de pausa foi corrigida para usar a tradução do idioma atual.

Três prints reais das telas foram capturados. A automação não conseguiu acessar o Mission Control para criar uma nova área de trabalho; uma captura geral em um desktop novo permanece pendente.

## Histórico de validação

Após a renomeação para Vidrado, uma execução anterior de `./scripts/test.sh` passou integralmente em uma sessão desbloqueada: 13 testes XCTest e 24 verificações nativas em cada configuração, debug e release. O log local anterior está em `dist/test-results.log`. Os resultados abaixo descrevem essa execução anterior.

## Testes automatizados

Comando reproduzível: `./scripts/test.sh`, com o Vidrado encerrado e uma janela normal ativa em uma sessão gráfica. O teste verifica essa pré-condição: o Dock/desktop não tem janela ativa para validar a ordem entre processos.

**13 testes XCTest, sem falhas:**

- Os três modos, limites das intensidades, preferências inválidas e atalhos inválidos.
- Serialização e restauração dos presets e das preferências.
- Subtração de retângulos: sobreposição, bordas, áreas externas, cobertura completa e conservação da área. Inclui 150 casos determinísticos adicionais.
- Conversão de coordenadas em telas à esquerda e acima da tela principal.
- Partes visíveis dos aplicativos nítidos e janelas que os encobrem.
- Reconhecimento de pares lado a lado; rejeição de janelas comuns, sobrepostas e em monitores distintos.
- Tela cheia versus maximização, incluindo tela cheia com barra de menus visível.
- Desativação, ausência de janela, exclusões, sessão inativa, compartilhamento e retomada.
- Gesto de agitar: movimentos rápidos, rejeição de movimentos lentos e retos e intervalo entre alternâncias.

**24 verificações nativas, sem falhas, executadas em debug e release:**

- Disponibilidade das funções de desfoque, regiões, captura e Spaces.
- Aplicação e remoção de desfoque em uma NSPanel real.
- Aplicação de recorte e 500 atualizações consecutivas com liberação dos recursos C.
- Sobreposições não recebem cliques nem foco; desaparecem quando desativadas.
- Registro, remoção, novo registro e despacho do evento Carbon do atalho global.
- Preferências em domínio temporário; deduplicação e troca de regras; recuperação de preferências corrompidas.
- Leitura de metadados; criação de overlays nos displays conectados.
- Ordem confirmada na lista do compositor: janela ativa de outro processo acima da sobreposição.
- Desativação, exclusão do app ativo, retomada e encerramento com remoção dos overlays.

O script também monta o app de release, verifica sua assinatura ad hoc e valida o Info.plist. O empacotamento usa `hdiutil verify` e gera SHA-256 do DMG.

## Testes de interface e integração realizados

- Primeira abertura e abertura dos ajustes com ⌘,; aparência nativa no modo escuro, rótulos acessíveis e controles de intensidade.
- Alternância entre Desfoque, Escurecer e Ambos; habilitação correta dos sliders.
- Aplicação de presets, criação e remoção de um preset temporário, restauração de preferências ao reabrir.
- Gravação de um novo atalho pela interface e restauração para ⌥⌘B.
- Inclusão do Finder na lista de pausa. Com o Finder ativo, o compositor não listou nenhum overlay. Removida a regra, o overlay reapareceu imediatamente abaixo da janela ativa.
- Entrada do Finder em tela cheia: Space reconhecido e overlays ausentes. Saída: efeito retomado abaixo da janela ativa. O teste encontrou uma falha da detecção por tamanho, corrigida e coberta por regressão.
- Troca de janelas/aplicativos, fechamento dos ajustes e reabertura sem encerrar o processo.
- Popover real da barra de menus: renderização, alternância do foco, lista de presets e retorno aos ajustes.
- Início automático: registro e remoção pela interface na cópia instalada em `/Applications`. Deixado desligado.
- Instalação, assinatura e igualdade SHA-256 entre o executável testado e a cópia instalada.

O teste de execução também encontrou e corrigiu uma liberação dupla de regiões do WindowServer. Os handles agora são ponteiros C opacos; a regressão de 500 atualizações passa nas duas configurações.

## Renomeação para Vidrado

- Nome exibido, menus, painel Sobre, textos acessíveis, executável, módulos Swift, diretórios, scripts e documentação atualizados.
- Identificador do app e da assinatura: `app.vidrado.mac`; domínio isolado de testes: `app.vidrado.tests`.
- Projeto em `/Users/paulo/Projects/personal/vidrado`; aplicativo instalado em `/Applications/Vidrado.app`.
- Preferências locais e posição da janela migradas e verificadas, preservando intensidades, presets, regras e atalho. Início automático permanece desligado.
- Interface instalada verificada: título Vidrado, menus Sobre/Encerrar Vidrado, painel Sobre e textos de Comportamento. Valores preservados: desfoque 62%, escurecimento 22%, modo Ambos e atalho ⌥⌘B.
- A instalação anterior foi retirada de Aplicativos. Os artefatos atuais são `Vidrado.app`, `Vidrado.dmg` e `Vidrado.dmg.sha256`.

## Limites da validação

- Havia apenas um monitor físico. Geometria de vários monitores, incluindo coordenadas negativas e separação entre telas, foi testada automaticamente; conexão/desconexão física, diferentes escalas e configurações de Spaces entre monitores não foram exercitadas.
- A integração com o sinal de captura do WindowServer foi verificada, e a política de pausa foi testada com o sinal ligado/desligado. Não foi iniciada uma reunião, gravação contínua ou sessão remota de terceiros.
- O atalho foi validado por registro e despacho do evento Carbon. A automação de UI envia teclas ao aplicativo alvo e não passa pelo caminho de um teclado físico para atalhos globais. O gesto de agitar foi testado com trajetórias determinísticas.
- Não foi reiniciado o Mac para testar o login; o registro e a remoção do serviço nativo foram confirmados pela interface.
- Não foram alterados ajustes globais de aparência, permissões de tela/Acessibilidade ou proteções do macOS.

Esses limites são de ambiente e hardware. As funções correspondentes estão implementadas; não há mocks ou simulações substituindo o efeito no aplicativo distribuído.
