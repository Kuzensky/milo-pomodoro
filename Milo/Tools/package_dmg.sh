#!/bin/zsh
# Builds a universal Milo.app and wraps it in a drag-to-Applications disk image
# at dist/Milo.dmg. The website's download button expects this file as the
# "Milo.dmg" asset of the latest GitHub release.
set -euo pipefail
project_dir="${0:A:h:h}"
workspace_dir="${project_dir:h}"
dmg="$workspace_dir/dist/Milo.dmg"

mkdir -p "$workspace_dir/.build" "$workspace_dir/dist"
staging_dir="$(mktemp -d "$workspace_dir/.build/milo-dmg.XXXXXX")"
trap 'rm -rf "$staging_dir"' EXIT

zsh "$project_dir/Tools/build.sh" --universal --output "$staging_dir/Milo.app"
ln -s /Applications "$staging_dir/Applications"
hdiutil create -volname Milo -srcfolder "$staging_dir" -fs HFS+ -format UDZO -ov "$dmg" >/dev/null
hdiutil verify "$dmg" >/dev/null
print "Built $dmg ($(du -h "$dmg" | cut -f1 | tr -d ' '))"
