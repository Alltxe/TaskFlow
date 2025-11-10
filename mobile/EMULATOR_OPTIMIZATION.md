# Оптимизация Android Эмулятора для Flutter

## 🚀 Настройка GPU ускорения

### Способ 1: Через Android Studio AVD Manager (РЕКОМЕНДУЕТСЯ)

1. **Откройте Android Studio**
2. **Tools → Device Manager** (или AVD Manager)
3. **Нажмите ✏️ (Edit)** на вашем эмуляторе
4. **Нажмите "Show Advanced Settings"**
5. **В разделе "Emulated Performance"**:
   - **Graphics**: выберите **Hardware - GLES 2.0** (вместо Automatic или Software)
   - **Boot option**: выберите **Cold boot** (для первого запуска)
6. **Нажмите "Finish"**

### Способ 2: Редактирование config.ini напрямую

Найдите файл конфигурации эмулятора:
```
C:\Users\Altxe\.android\avd\<имя_эмулятора>.avd\config.ini
```

Откройте в текстовом редакторе и добавьте/измените:
```ini
hw.gpu.enabled = yes
hw.gpu.mode = host
```

### Способ 3: Запуск эмулятора с флагами (через командную строку)

```powershell
# Список доступных эмуляторов
emulator -list-avds

# Запуск с GPU ускорением
emulator -avd <имя_эмулятора> -gpu host -no-snapshot-load
```

---

## ⚡ Дополнительные настройки для максимальной производительности

### 1. Увеличить RAM и CPU эмулятора

В AVD Manager → Edit → Advanced Settings:
- **RAM**: минимум 2048 MB (рекомендуется 4096 MB)
- **VM heap**: 512 MB
- **Internal Storage**: 2048 MB
- **CPU cores**: 4 ядра (если у вас есть)

### 2. Включить Intel HAXM (если процессор Intel)

```powershell
# Проверить установлен ли HAXM
sc query intelhaxm

# Если не установлен, скачайте и установите:
# https://github.com/intel/haxm/releases
```

### 3. Включить Hyper-V (для AMD процессоров или современных Intel)

**Windows 11/10 Pro**:
1. **Панель управления → Программы → Включение или отключение компонентов Windows**
2. Включите:
   - ☑️ **Hyper-V**
   - ☑️ **Платформа виртуальной машины**
   - ☑️ **Windows Hypervisor Platform**
3. Перезагрузите компьютер

### 4. Настроить Flutter для быстрого запуска

В `android/gradle.properties` добавьте:
```properties
# Gradle optimization
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configureondemand=true

# Android optimization
android.enableJetifier=true
android.useAndroidX=true
android.enableD8=true
```

---

## 🎯 Рекомендуемая конфигурация эмулятора для Flutter

### Создание оптимального эмулятора:

1. **Device**: Pixel 6 или Pixel 7
2. **System Image**: 
   - API Level 33 (Android 13) или 34 (Android 14)
   - **ABI**: x86_64 (НЕ ARM!)
   - С Google Play (опционально)
3. **RAM**: 4096 MB
4. **VM Heap**: 512 MB
5. **Internal Storage**: 2048 MB
6. **Graphics**: Hardware - GLES 2.0
7. **CPU cores**: 4

---

## 🔧 Команды для быстрого запуска

### Создать alias для быстрого запуска (PowerShell)

Добавьте в ваш PowerShell профиль (`notepad $PROFILE`):

```powershell
function Start-FlutterEmulator {
    param(
        [string]$name = "Pixel_6_API_33"  # Замените на имя вашего эмулятора
    )
    Start-Process emulator -ArgumentList "-avd $name -gpu host -no-snapshot-load"
    Start-Sleep -Seconds 10
    flutter run
}

# Использование:
# Start-FlutterEmulator
# или сокращенно создайте alias:
Set-Alias fem Start-FlutterEmulator
```

---

## 📊 Сравнение режимов GPU

| Режим | Скорость | Совместимость | Использование |
|-------|----------|---------------|---------------|
| **host** | ⚡⚡⚡ Самый быстрый | Требует GPU драйверы | **РЕКОМЕНДУЕТСЯ** |
| **swiftshader_indirect** | ⚡⚡ Средняя | Хорошая | Fallback если host не работает |
| **angle_indirect** | ⚡⚡ Средняя | Хорошая | Для Windows |
| **software** | ⚡ Медленная | Максимальная | НЕ рекомендуется |

---

## 🐛 Решение проблем

### Проблема: "GPU emulation is disabled"

**Решение**:
```powershell
# Проверить поддержку виртуализации
systeminfo | findstr /C:"Virtualization"

# Должно быть: "Virtualization Enabled in Firmware: Yes"
# Если "No", включите VT-x/AMD-V в BIOS
```

### Проблема: Эмулятор всё равно медленный

**Попробуйте**:
1. Используйте x86_64 образ (НЕ ARM64)
2. Уменьшите разрешение эмулятора (720p вместо 1080p)
3. Отключите анимации в эмуляторе:
   - Settings → Developer Options
   - Window animation scale: **Animation off**
   - Transition animation scale: **Animation off**
   - Animator duration scale: **Animation off**

### Проблема: "HAXM is not installed"

**Решение**:
```powershell
# Скачайте HAXM installer
# https://github.com/intel/haxm/releases

# Или через Android SDK Manager:
# Android Studio → SDK Manager → SDK Tools → Intel x86 Emulator Accelerator (HAXM)
```

---

## 🌐 Альтернатива: Тестирование на Web (НАМНОГО БЫСТРЕЕ!)

Как мы уже настроили ранее:

```powershell
# Запуск в Chrome (мгновенный запуск, hot reload работает моментально)
flutter run -d chrome --web-port=8080
```

**Преимущества Web для разработки**:
- ⚡ Запуск за 5-10 секунд (вместо 1-2 минут на эмуляторе)
- 🔄 Hot Reload работает мгновенно
- 🛠️ Chrome DevTools для отладки
- 💾 Не нагружает систему

**Когда использовать эмулятор**:
- Тестирование нативных функций (камера, уведомления, GPS)
- Проверка производительности на реальном устройстве
- Финальное тестирование перед релизом

---

## 🎮 Проверка текущих настроек эмулятора

```powershell
# Список эмуляторов
emulator -list-avds

# Запустить с выводом информации
emulator -avd <имя> -verbose -gpu host

# Проверить какой GPU используется
# В запущенном эмуляторе: Settings → About emulated device → OpenGL ES version
```

---

## ✅ Быстрый чеклист оптимизации

- [ ] GPU mode = **host** (в AVD Manager)
- [ ] RAM >= 4096 MB
- [ ] CPU cores = 4
- [ ] System Image = x86_64 (НЕ ARM)
- [ ] HAXM установлен (Intel) или Hyper-V включен (AMD)
- [ ] Анимации отключены в Developer Options
- [ ] Gradle оптимизирован (gradle.properties)
- [ ] Для разработки UI используете Web версию

---

**Итог**: 
- 🌐 **Для быстрой разработки UI** → используйте `flutter run -d chrome`
- 📱 **Для тестирования нативных функций** → оптимизированный эмулятор с GPU host
- 🚀 **Для максимальной скорости** → реальное устройство через USB debugging
