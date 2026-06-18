# SimplePhotoEditor

SimplePhotoEditor - тестовое iOS-приложение на SwiftUI для авторизации пользователя и базового редактирования фотографий.

## Что умеет приложение

### Авторизация

- Вход по email и паролю через Firebase Auth.
- Регистрация по email и паролю.
- Валидация email и минимальной длины пароля до отправки формы.
- Проверка занятости email выполняется на стороне Firebase при регистрации.
- Подтверждение email: после регистрации пользователю отправляется письмо со ссылкой.
- Вход разрешается только после подтверждения email.
- Восстановление пароля через email из отдельного модального окна.
- Вход через Google Sign-In SDK.
- Состояние сессии хранится в `SessionStore` и управляет переходом между auth-flow и редактором.

### Редактор фотографий

- Импорт изображения из фотобиблиотеки через `PhotosPicker`.
- Импорт изображения с камеры через `UIImagePickerController`.
- Отображение выбранного изображения в рабочей области редактора.
- Масштабирование и поворот изображения.
- Горизонтальное отражение изображения.
- Рисование поверх изображения через PencilKit.
- Добавление текстовых слоев.
- Редактирование текста, размера, цвета и шрифта.
- Применение Core Image фильтров.
- Сброс состояния редактора при выборе нового изображения.
- Сохранение результата в фотопоток через Photos Framework.
- Экспорт результата через Share Sheet в PNG или JPEG.

## Технологии

- Swift
- SwiftUI
- Combine
- Firebase Auth
- Google Sign-In SDK
- Core Image
- PencilKit
- PhotosUI
- Photos Framework
- MVVM

## Требования

- Xcode с поддержкой текущего iOS SDK проекта.
- Firebase-проект с включенными провайдерами `Email/Password` и `Google`.
- Локальный файл `SimplePhotoEditor/GoogleService-Info.plist`, скачанный из Firebase Console.
- Настроенный URL scheme для Google Sign-In.

Deployment target приложения задается в `SimplePhotoEditor.xcodeproj`. На момент актуализации документации app target настроен на iOS 26.0.

## Быстрый запуск

1. Открыть `SimplePhotoEditor.xcodeproj` в Xcode.
2. Скачать `GoogleService-Info.plist` из Firebase Console и положить его в папку `SimplePhotoEditor/`.
   Файл игнорируется Git, потому что содержит project-specific Google/Firebase configuration.
3. Проверить настройки Firebase Auth:
   - включен `Email/Password`;
   - включен `Google`;
   - bundle id совпадает с настройками Firebase.
4. Проверить URL scheme Google Sign-In в `SimplePhotoEditor/App/Info.plist`.
5. Выбрать симулятор или устройство.
6. Запустить приложение через `Cmd+R`.

Для проверки из терминала:

```bash
xcodebuild -project SimplePhotoEditor.xcodeproj -scheme SimplePhotoEditor -destination 'generic/platform=iOS Simulator' build
```

## Структура проекта

```text
SimplePhotoEditor/
  App/                         Настройка приложения, Firebase, зависимости
  Navigation/                  Корневой роутинг между auth и editor flow
  Core/
    Models/                    Общие модели домена
    Services/
      Auth/                    Firebase Auth и контракты авторизации
      Camera/                  Обертка над системной камерой
      ImportExport/            Импорт, Share Sheet, сохранение в Photos
      Processing/              Core Image pipeline и рендер финального изображения
    State/                     SessionStore
    Utilities/                 Валидаторы, расширения, ViewModifiers
  Features/
    Auth/                      Login, Registration, Reset Password и ViewModels
    Editor/                    Экран редактора, панели инструментов, ViewModels
```

## Архитектура

Проект построен вокруг MVVM:

- `View` отвечает за SwiftUI-разметку и пользовательские события.
- `ViewModel` хранит состояние экрана, валидирует ввод и запускает async-операции.
- `Service` инкапсулирует интеграции с Firebase, Google Sign-In, Photos, Core Image и системными API.
- `DependencyContainer` собирает зависимости приложения.
- `SessionStore` подписывается на Firebase Auth state и определяет, какой flow показывать пользователю.

Combine используется там, где состояние удобно связывать с реактивными вычислениями, например для `canRegister` и `canLogin`.

### Dependency Container

`AppDependencyContainer` является composition root приложения: в нем создаются сервисы и фабрики ViewModel. Такой ручной DI-подход подходит для небольшого и среднего iOS-приложения, потому что зависимости остаются явными, а проект не требует отдельного DI-фреймворка.

Контейнер отвечает за:

- создание production-реализаций сервисов;
- передачу одного экземпляра `AuthService` в `SessionStore` и auth ViewModel;
- сборку `ImagePipeline` из сервисов декодирования, трансформаций, фильтров и оверлеев;
- создание ViewModel через factory-методы;
- изоляцию экранов от деталей Firebase, Google Sign-In, Photos и Core Image.

В текущей реализации ViewModel не создают сервисы самостоятельно. Они получают зависимости через initializer injection, что упрощает замену реализаций в тестах и снижает связанность между UI и инфраструктурой.

При дальнейшем росте проекта контейнер можно разделить по feature-зонам, например на `AuthDependencyContainer` и `EditorDependencyContainer`, либо расширить initializer контейнера, чтобы подменять не только `AuthService`, но и `GoogleSignInCoordinator`, `ImagePipeline`, `ExportService` и `ImageImportService`.

## Подсчет строк

Swift-код:

```bash
git ls-files -z -- '*.swift' | xargs -0 wc -l
```

Все файлы в рабочей директории без `.git`:

```bash
find . -path './.git' -prune -o -type f -print0 | xargs -0 wc -l
```

Важно использовать `-z` и `xargs -0`, потому что в проекте есть пути с пробелами, например папка локализаций.

## Основные сценарии

### Регистрация

1. Пользователь вводит email и пароль.
2. `RegistrationViewModel` валидирует email и длину пароля.
3. Firebase создает пользователя или возвращает ошибку, если email уже занят.
4. Приложение отправляет письмо подтверждения.
5. До подтверждения email вход блокируется.

### Вход

1. Пользователь входит через email/password или Google.
2. `SessionStore` получает авторизованного пользователя.
3. Приложение показывает редактор.

### Редактирование и экспорт

1. Пользователь выбирает изображение из библиотеки или камеры.
2. `EditorViewModel` сбрасывает transient-состояние редактора для нового изображения.
3. Пользователь применяет фильтры, рисует, добавляет текст и трансформации.
4. Финальное изображение собирается через pipeline обработки и оверлеи.
5. Результат можно сохранить в Photos или экспортировать через Share Sheet.

## Локализация

Строки интерфейса хранятся в `Localizable.xcstrings`. Сейчас поддерживаются русский и английский варианты для пользовательских текстов приложения.

## Соответствие ТЗ

- Авторизация через email реализована.
- Восстановление пароля реализовано.
- Регистрация и email verification реализованы.
- Google Sign-In реализован.
- UI написан на SwiftUI с переиспользуемыми стилями и состояниями загрузки/ошибок.
- Загрузка фото из библиотеки и камеры реализована.
- Масштабирование, поворот и отражение изображения реализованы.
- PencilKit-рисование реализовано.
- Текстовые слои с настройками реализованы.
- Core Image фильтры реализованы.
- Сохранение в фотопоток реализовано отдельным действием.
- Share Sheet экспорт реализован для PNG/JPEG.
- Основная структура следует MVVM.

## Проверка

Последняя проверка перед обновлением документации:

```bash
xcodebuild -project SimplePhotoEditor.xcodeproj -scheme SimplePhotoEditor -destination 'generic/platform=iOS Simulator' build
```

Unit-тесты:

```bash
xcodebuild test -project SimplePhotoEditor.xcodeproj -scheme SimplePhotoEditor -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Автоматизированные тесты покрывают валидацию email и ключевые состояния auth ViewModel. Сценарии редактора с Photos, Camera, PencilKit и Share Sheet проверяются ручным smoke-тестом, потому что они завязаны на системный UI и разрешения.
