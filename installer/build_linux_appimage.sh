#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${ROOT_DIR}"

VERSION=$(grep 'version:' pubspec.yaml | head -n 1 | awk '{print $2}' | cut -d'+' -f1)
if [ -z "$VERSION" ]; then
  VERSION="3.5.5"
fi

echo "Building AppImage for Prisma v${VERSION}..."

BUNDLE_DIR="${ROOT_DIR}/build/linux/x64/release/bundle"
if [ ! -f "${BUNDLE_DIR}/gel_rule_app" ]; then
  echo "Release bundle not found. Running 'flutter build linux --release'..."
  flutter build linux --release
fi

APP_DIR="${ROOT_DIR}/build/AppDir"
OUTPUT_DIR="${ROOT_DIR}/build"
APPIMAGE_NAME="Prisma-v${VERSION}-linux-x86_64.AppImage"
OUTPUT_APPIMAGE="${OUTPUT_DIR}/${APPIMAGE_NAME}"

# Ensure appimagetool is available
APPIMAGETOOL=""
if command -v appimagetool >/dev/null 2>&1; then
  APPIMAGETOOL="appimagetool"
elif [ -f "${ROOT_DIR}/build/tools/appimagetool" ]; then
  APPIMAGETOOL="${ROOT_DIR}/build/tools/appimagetool"
else
  echo "Downloading appimagetool..."
  mkdir -p "${ROOT_DIR}/build/tools"
  curl -fsSL https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage -o "${ROOT_DIR}/build/tools/appimagetool"
  chmod +x "${ROOT_DIR}/build/tools/appimagetool"
  APPIMAGETOOL="${ROOT_DIR}/build/tools/appimagetool"
fi

echo "Preparing AppDir at ${APP_DIR}..."
rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}"

# Copy bundle contents
cp -r "${BUNDLE_DIR}"/* "${APP_DIR}/"

# AppRun script
cat << 'EOF' > "${APP_DIR}/AppRun"
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/lib:${HERE}/usr/lib:${LD_LIBRARY_PATH}"
exec "${HERE}/gel_rule_app" "$@"
EOF
chmod +x "${APP_DIR}/AppRun"

# Desktop file
cat << 'EOF' > "${APP_DIR}/prisma.desktop"
[Desktop Entry]
Name=Prisma
GenericName=Booru Client
Comment=Prisma - Modern Booru & Art Client
Exec=gel_rule_app %u
Icon=prisma
Terminal=false
Type=Application
Categories=Network;Graphics;
StartupWMClass=com.example.gel_rule_app
EOF

mkdir -p "${APP_DIR}/usr/share/applications"
cp "${APP_DIR}/prisma.desktop" "${APP_DIR}/usr/share/applications/prisma.desktop"

# Icons
ICON_SRC="${ROOT_DIR}/macos/Runner/Assets.xcassets/AppIcon.appiconset"
if [ -d "${ICON_SRC}" ]; then
  for size in 16 32 64 128 256 512 1024; do
    if [ -f "${ICON_SRC}/app_icon_${size}.png" ]; then
      mkdir -p "${APP_DIR}/usr/share/icons/hicolor/${size}x${size}/apps"
      cp "${ICON_SRC}/app_icon_${size}.png" "${APP_DIR}/usr/share/icons/hicolor/${size}x${size}/apps/prisma.png"
    fi
  done
  cp "${ICON_SRC}/app_icon_512.png" "${APP_DIR}/prisma.png"
fi

# Build AppImage
echo "Generating AppImage with ${APPIMAGETOOL}..."
ARCH=x86_64 "${APPIMAGETOOL}" -n "${APP_DIR}" "${OUTPUT_APPIMAGE}"

echo "AppImage created successfully: ${OUTPUT_APPIMAGE}"
ls -lh "${OUTPUT_APPIMAGE}"
