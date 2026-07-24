#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

_default_sdk="${HOME}/Android/Sdk"
if [ -z "${ANDROID_HOME:-}" ]; then
    if [ -d "${_default_sdk}/platform-tools" ] || [ -d "${_default_sdk}/licenses" ]; then
        export ANDROID_HOME="${_default_sdk}"
        export ANDROID_SDK_ROOT="$ANDROID_HOME"
    fi
fi

if [ -n "${ANDROID_HOME:-}" ]; then
    _prepend=""
    [ -d "${ANDROID_HOME}/cmdline-tools/latest/bin" ] && _prepend="${ANDROID_HOME}/cmdline-tools/latest/bin:${_prepend}"
    [ -d "${ANDROID_HOME}/platform-tools" ] && _prepend="${ANDROID_HOME}/platform-tools:${_prepend}"
    if [ -n "${_prepend}" ]; then
        export PATH="${_prepend}${PATH}"
    fi
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_LOCAL_PROPS="${ROOT_DIR}/android/local.properties"
_sdk_for_props="${ANDROID_HOME:-}"
if [ -z "${_sdk_for_props}" ] && [ -d "${_default_sdk}" ]; then
    _sdk_for_props="${_default_sdk}"
fi
if [ -n "${_sdk_for_props}" ] && [ -f "$ANDROID_LOCAL_PROPS" ]; then
    if grep -q '^sdk.dir=' "$ANDROID_LOCAL_PROPS"; then
        sed -i "s|^sdk.dir=.*|sdk.dir=${_sdk_for_props}|" "$ANDROID_LOCAL_PROPS"
    else
        printf '\nsdk.dir=%s\n' "$_sdk_for_props" >> "$ANDROID_LOCAL_PROPS"
    fi
fi

echo -e "${YELLOW}Установка Chat Volc...${NC}\n"
if [ -n "${ANDROID_HOME:-}" ]; then
    echo -e "Android SDK: ${GREEN}${ANDROID_HOME}${NC}\n"
fi

if ! command -v flutter &> /dev/null; then
    echo "Flutter не установлен!"
    exit 1
fi

if [ -n "${ANDROID_HOME:-}" ]; then
    flutter config --android-sdk "$ANDROID_HOME" >/dev/null
fi

flutter doctor
flutter clean
flutter pub get

# API по умолчанию: эмулятор → хост:8080
API_BASE_URL="${API_BASE_URL:-http://10.0.2.2:8080}"
DART_DEFINES=(--dart-define="API_BASE_URL=${API_BASE_URL}")
echo -e "API: ${GREEN}${API_BASE_URL}${NC}"

if [ -n "${YANDEX_CLIENT_ID:-}" ]; then
    DART_DEFINES+=(--dart-define="YANDEX_CLIENT_ID=${YANDEX_CLIENT_ID}")
fi
if [ -n "${VK_CLIENT_ID:-}" ]; then
    DART_DEFINES+=(--dart-define="VK_CLIENT_ID=${VK_CLIENT_ID}")
fi

flutter analyze
flutter build apk "${DART_DEFINES[@]}"

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}Готово.${NC}"
    echo -e "Запуск: ${YELLOW}flutter run --dart-define=API_BASE_URL=${API_BASE_URL}${NC}"
    echo -e "APK: ${YELLOW}build/app/outputs/flutter-apk/app-release.apk${NC}"
else
    echo -e "\nОшибка сборки."
fi
