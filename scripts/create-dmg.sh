#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: $0 '/path/to/Calendar Widget.app' /path/to/CalendarWidget.dmg" >&2
  exit 64
fi

app_path="$1"
dmg_path="$2"

if [ ! -d "$app_path" ]; then
  echo "App bundle not found: $app_path" >&2
  exit 66
fi

app_name="$(basename "$app_path")"
volume_name="Calendar Widget"
staging_dir="$(mktemp -d)"

cleanup() {
  rm -rf "$staging_dir"
}
trap cleanup EXIT

mkdir -p "$(dirname "$dmg_path")"
rm -f "$dmg_path"

ditto "$app_path" "$staging_dir/$app_name"
ln -s /Applications "$staging_dir/Applications"

hdiutil create \
  -volname "$volume_name" \
  -srcfolder "$staging_dir" \
  -ov \
  -format UDZO \
  "$dmg_path"
