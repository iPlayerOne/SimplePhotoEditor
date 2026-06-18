# SimplePhotoEditor

iOS-приложение на SwiftUI, выполненное в рамках тестового задания: авторизация пользователя и редактирование фотографий.

## Задание

Разработать приложение с авторизацией через email/password и Google, а также экраном редактирования фотографий. Пользователь должен иметь возможность загрузить изображение, применить базовые инструменты редактирования, сохранить результат в фотопоток или экспортировать его.

## Описание

Приложение содержит два основных сценария:

- авторизация, регистрация и восстановление пароля;
- редактор фотографий с фильтрами, рисованием, текстом и экспортом.

Для работы с авторизацией используется Firebase Auth. Для входа через Google подключен Google Sign-In SDK. Редактор построен на Core Image, PencilKit, PhotosUI и Photos Framework.

## Стек

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

## Архитектура

Проект разделен на несколько слоев:

- `App` - настройка приложения, Firebase и dependency container;
- `Navigation` - корневая навигация между авторизацией и редактором;
- `Core/Models` - общие модели данных;
- `Core/Services` - авторизация, камера, импорт/экспорт и обработка изображений;
- `Core/State` - состояние пользовательской сессии;
- `Core/Utilities` - валидаторы, модификаторы и вспомогательные утилиты;
- `Features/Auth` - экраны и ViewModel для авторизации;
- `Features/Editor` - экран редактора, инструменты и ViewModel.

## Возможности

- Регистрация и вход по email/password через Firebase Auth.
- Восстановление пароля по email.
- Email verification после регистрации.
- Вход через Google Sign-In.
- Импорт фото из галереи и камеры.
- Фильтры Core Image.
- Поворот, отражение и масштабирование изображения.
- Рисование поверх изображения через PencilKit.
- Текстовые слои с настройкой шрифта, цвета и размера.
- Сохранение результата в Photos.
- Экспорт PNG/JPEG через Share Sheet.
- Сброс состояния редактора при выборе нового изображения.

## Запуск

1. Открыть `SimplePhotoEditor.xcodeproj` в Xcode.
2. Скачать `GoogleService-Info.plist` из Firebase Console.
3. Положить файл в папку `SimplePhotoEditor/`.
4. В Firebase включить провайдеры `Email/Password` и `Google`.
5. Проверить URL scheme для Google Sign-In в `SimplePhotoEditor/App/Info.plist`.
6. Запустить приложение.

`GoogleService-Info.plist` не хранится в репозитории. Для примера структуры добавлен `GoogleService-Info.example.plist`.

## Тесты

Unit-тесты покрывают валидацию email и основные состояния ViewModel авторизации.

```bash
xcodebuild test -project SimplePhotoEditor.xcodeproj -scheme SimplePhotoEditor -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```
