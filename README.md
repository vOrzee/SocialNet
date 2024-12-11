# SocialNet iOS App

**SocialNet** — это приложение для социальных сетей, разработанное с использованием **SwiftUI** и **SwiftData**. Оно включает функционал постов, комментариев, сохранённых записей, а также входа с использованием **Face ID**.

## Скриншоты

<div style="display: flex; overflow-x: scroll; gap: 10px;">
    <img src="https://github.com/user-attachments/assets/a4d4596a-3fad-4141-a9e6-e4b1748b02f3" alt="Главный экран" style="height: 500px; width: auto;">
    <img src="https://github.com/user-attachments/assets/89d4a6d7-73c6-4aa7-a22e-97d5e24e9060" alt="Собственный профиль пользователя" style="height: 500px; width: auto;">
    <img src="https://github.com/user-attachments/assets/91d88419-022e-4ad0-82a7-07aa86d71073" alt="Профиль другого пользователя" style="height: 500px; width: auto;">
    <img src="https://github.com/user-attachments/assets/2d26203a-9e70-4e9f-bc44-0a2b4ce57a06" alt="Экран добавления поста" style="height: 500px; width: auto;">
    <img src="https://github.com/user-attachments/assets/1f7bf147-43d8-4e38-a3f6-124919ac34e4" alt="Экран действий с постом" style="height: 500px; width: auto;">
    <img src="https://github.com/user-attachments/assets/a5b8c1fd-6127-4ea3-850b-3b88cc3917ee" alt="Экран с меткой на карте" style="height: 500px; width: auto;">
    <img src="https://github.com/user-attachments/assets/74360429-95f9-47d7-ab25-96a3a2b34821" alt="Экран добавления метки на карте" style="height: 500px; width: auto;">
    <img src="https://github.com/user-attachments/assets/b174bef1-806f-453f-9dc4-cf287b3b8982" alt="Комментарии" style="height: 500px; width: auto;">
    <img src="https://github.com/user-attachments/assets/fb330b04-f6b8-40f0-ac1b-33a7c4c0da86" alt="Сохранённые посты" style="height: 500px; width: auto;">
    <img src="https://github.com/user-attachments/assets/8d4fafee-6ddb-4927-a18f-b4bb901adf12" alt="Вход Face ID" style="height: 500px; width: auto;">
    <img src="https://github.com/user-attachments/assets/4120aace-157d-4186-bd07-6f7f621c54ed" alt="Экран настроек" style="height: 500px; width: auto;">
    <img src="https://github.com/user-attachments/assets/e74a032a-7938-4984-af70-690ca3dacf56" alt="API-Key" style="height: 500px; width: auto;">
    <img src="https://github.com/user-attachments/assets/d0af4893-adc1-46e3-8c62-e670e6218cb5" alt="Экран загрузки" style="height: 500px; width: auto;">
</div>

## Основные функции
1. **Публикация постов** — добавляйте и редактируйте свои посты.
2. **Комментарии** — просматривайте и добавляйте комментарии к постам.
3. **Сохранённые записи** — сохраняйте понравившиеся посты.
4. **Темы интерфейса** — выбирайте светлый или тёмный режим.
5. **Face ID** — вход с использованием биометрической аутентификации.

## Установка
1. Скачайте проект и откройте его в Xcode.
2. Убедитесь, что подключены зависимости **SwiftData** и **Face ID**.
3. Убедитесь, что добавлены соответствующие разрешения в Info.plist:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSExceptionDomains</key>
        <dict>
            <key>94.228.125.136</key>
            <dict>
                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                <true/>
            </dict>
        </dict>
    </dict>
    <key>NSFaceIDUsageDescription</key>
    <string>Приложение использует Face ID для аутентификации и входа в систему.</string>
    <key>NSCameraUsageDescription</key>
    <string>Приложение требует доступ к камере для загрузки аватаров пользователей.</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Приложение использует доступ к фотогалерее для загрузки изображений.</string>
</dict>
</plist>
```

---

## Структура проекта

Проект реализован на основе архитектуры MVVM.

### Основные компоненты
1. **MainView**  
   - Отображает главную страницу с постами и строкой поиска.  
   - Включает аватарки пользователей и список постов.  

2. **UserView**  
   - Экран профиля пользователя с возможностью редактирования настроек.  
   - Отображает публикации текущего пользователя.  

3. **SavedPostsView**  
   - Список постов, которые были сохранены пользователем.  

4. **SettingsView**  
   - Экран настроек, где можно включить тёмный режим и активировать Face ID.

5. **LoginView**  
   - Экран для входа и регистрации с поддержкой Face ID.

6. **FaceIDViewModel**  
   - Класс для управления логикой Face ID.  
   - Реализует проверку доступности биометрической аутентификации.  

7. **PostsViewModel**  
   - Управляет данными постов, такими как загрузка, лайки и добавление постов.  

8. **SavedPost**  
   - Модель сохранённых постов с использованием **SwiftData**.

---

## Особенности реализации
1. **SwiftData для сохранённых постов**  
   Сохранение записей реализовано с помощью `ModelContainer`.

2. **Face ID**  
   - Поддержка биометрической аутентификации через Face ID.  
   - Реализована проверка и обработка ошибок для обеспечения безопасного входа.

3. **Интерактивный интерфейс**  
   - Элементы интерфейса обновляются в реальном времени благодаря использованию **@StateObject** и **@ObservedObject**.  
   - Например, при добавлении поста он сразу отображается в списке.

4. **Поддержка тёмной темы**  
   - Пользователь может переключать темы в реальном времени.  
   - Выбор сохраняется в **UserDefaults**.

---

Разработано с ❤️ и SwiftUI!
