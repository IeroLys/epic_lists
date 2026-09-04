# Epic Lists

Простое приложение на Flutter для управления эпиками с пиксельными флагами и списками отображения.

## Стек
- Flutter + Dart
- Hive (локальное хранилище)
- Provider (стейт-менеджмент)
- flutter_colorpicker
- shared_preferences (тема)

## Функционал
- Создание / редактирование / удаление эпиков
- Пиксельный флаг с кастомным цветом + опциональный эмодзи
- Несколько списков отображения (табы)
- Добавление / удаление эпиков из списков (глобальный пул)
- Drag & Drop переупорядочивание
- Отметка «Выполнено» (зачёркивание + зелёный текст + дата)
- Фильтр: Активные / Выполненные / Все
- Переключатель темы (светлая / тёмная / системная)
- Создание эпика сразу с добавлением в текущий список

## Запуск

```bash
cd epic_lists
flutter pub get
flutter run
```

### Иконка приложения
Положи картинку `assets/app_icon.png` (рекомендуется 1024×1024) и выполни:

```bash
flutter pub run flutter_launcher_icons
```

Если файла нет — приложение всё равно запустится со стандартной иконкой Flutter.

### Если менял модели Hive
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Структура

```
lib/
├── main.dart
├── core/
│   ├── providers/
│   │   ├── app_provider.dart
│   │   └── theme_provider.dart
│   └── theme/app_theme.dart
├── data/
│   ├── models/
│   │   ├── epic.dart + epic.g.dart
│   │   └── display_list.dart + display_list.g.dart
│   └── repositories/
└── features/
    ├── home/home_screen.dart
    ├── epic/
    │   ├── epic_form_screen.dart
    │   └── pixel_flag.dart
    └── list/
        ├── manage_lists_screen.dart
        └── add_epics_to_list_screen.dart
```
