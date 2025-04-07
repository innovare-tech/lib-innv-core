# 🚀 innovare_core

**`innovare_core`** é o package oficial da [Innovare - Soluções Tecnológicas](https://innv.dev), com componentes, utilitários e estilos reutilizáveis que seguem o padrão visual da marca.

Use este pacote para manter seus apps com a identidade visual da Innovare de forma consistente, prática e escalável.

---

## ✨ Features

- ✅ Logotipo oficial com CustomPainter (`InnovareLogo`)
- ✅ Suporte a modo claro/escuro
- ✅ Tipagem simples e elegante com enum para variações
- 🚧 (Em breve) Tipografia padrão da marca
- 🚧 (Em breve) Paleta de cores oficial como extensão do ThemeData
- 🚧 (Em breve) Componentes visuais (botões, inputs, etc)

---

## ⚙️ Instalação

Adicione o pacote ao seu `pubspec.yaml`:

```yaml
dependencies:
  innovare_core:
    git:
      url: git@github.com:innovare-tech/lib-innv-core.git
      ref: main
```

Depois de adicionar o pacote, execute o comando abaixo para instalar as dependências:

```bash
flutter pub get
```

## 🛠️ Uso
Para usar o `innovare_core`, importe o pacote no seu arquivo Dart:

```dart
import 'package:innovare_core/innovare_core.dart';
```

### Exemplo de uso do logotipo

```dart
import 'package:innovare_core/innovare_logo/innovare_logo.dart';
const InnovareLogo()
```

```dart
import 'package:innovare_core/innovare_logo/innovare_logo.dart';
const InnovareLogo(size: 100)
```

```dart
import 'package:innovare_core/innovare_logo/innovare_logo.dart';
const InnovareLogo(type: InnovareLogoType.completeName)
```