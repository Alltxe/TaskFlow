# App Icon

To generate app icons, you need to provide the following files:

1. `app_icon.png` - Main app icon (1024x1024 px recommended)
   - Should contain the task_alt icon (checkmark in circle) matching the splash screen
   - Background color: #2196F3 (Material Blue)
   - Icon should be centered and visible

2. `app_icon_foreground.png` - Foreground for adaptive icon (Android only)
   - 1024x1024 px with transparent background
   - Contains only the checkmark icon in white color
   - Used with adaptive_icon_background color for Android 8.0+

## How to create the icon:

### Option 1: Using an icon generator service
1. Go to https://icon.kitchen/ or https://www.appicon.co/
2. Upload a source image with the task_alt icon (checkmark in circle)
3. Set background color to #2196F3
4. Generate and download the icons
5. Place the generated files in this directory

### Option 2: Manual creation
1. Create a 1024x1024 px PNG image
2. Use blue background (#2196F3)
3. Add a white checkmark icon in the center (similar to Material Icons task_alt)
4. Save as `app_icon.png`
5. Create another version with transparent background and only the checkmark as `app_icon_foreground.png`

### Option 3: Use existing web icon
If you have a suitable icon in `web/icons/Icon-512.png`, you can copy it here as `app_icon.png`.

## After adding the icon files:

Run the following command to generate platform-specific icons:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes for Android and iOS.
