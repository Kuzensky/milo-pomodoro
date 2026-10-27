#!/bin/zsh
set -euo pipefail
project_dir="${0:A:h:h}"
workspace_dir="${project_dir:h}"
build_dir="$workspace_dir/.build/milo"
destination="$workspace_dir/Milo.app"

python3 "$project_dir/Design/tools/build_assets.py"
python3 "$project_dir/Tools/generate_vectors.py"
swift build --package-path "$project_dir" --scratch-path "$build_dir" -c release
binary_dir="$(swift build --package-path "$project_dir" --scratch-path "$build_dir" -c release --show-bin-path)"
staging_dir="$(mktemp -d "$workspace_dir/.build/milo-package.XXXXXX")"
app_dir="$staging_dir/Milo.app"
trap 'if [[ -d "$staging_dir/previous-Milo.app" && ! -e "$destination" ]]; then mv "$staging_dir/previous-Milo.app" "$destination"; fi; rm -rf "$staging_dir"' EXIT
mkdir -p "$app_dir/Contents/MacOS" "$app_dir/Contents/Resources"
cp "$binary_dir/Milo" "$app_dir/Contents/MacOS/Milo"
cp "$project_dir/Info.plist" "$app_dir/Contents/Info.plist"
"$binary_dir/Milo" --export-icon "$project_dir/Build/Milo.iconset"
iconutil -c icns "$project_dir/Build/Milo.iconset" -o "$app_dir/Contents/Resources/Milo.icns"
codesign --force --sign - --identifier local.milo.personal "$app_dir"
codesign --verify --deep --strict "$app_dir"
if [[ -e "$destination" ]]; then mv "$destination" "$staging_dir/previous-Milo.app"; fi
mv "$app_dir" "$destination"
print "Built $destination"
