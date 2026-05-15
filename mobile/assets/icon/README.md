# App Icon

Иконки лаунчера — **галочка в круге** в духе Material `task_alt`, как на splash / login / welcome.

## Файлы

1. **`app_icon.png`** — 1024×1024, фон **#2196F3**, по центру белая пиктограмма «галочка в круге».
2. **`app_icon_foreground.png`** — 1024×1024, прозрачный фон: только белая галочка в круге (для adaptive icon Android).

## В приложении

На экранах используется `Icon(Icons.task_alt, …)` (см. `splash_screen.dart`, `login_screen.dart`, `welcome_screen.dart`).

## После замены PNG

```bash
cd mobile
dart run flutter_launcher_icons
```
