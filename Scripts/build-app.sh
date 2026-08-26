#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
configuration=${CONFIGURATION:-release}
app_dir="$project_dir/build/MatteScreen.app"
contents_dir="$app_dir/Contents"
binary_dir="$contents_dir/MacOS"
resources_dir="$contents_dir/Resources"

cd "$project_dir"
swift build -c "$configuration"
binary_path=$(swift build -c "$configuration" --show-bin-path)/MatteScreen

rm -rf "$app_dir"
mkdir -p "$binary_dir" "$resources_dir"
cp "$binary_path" "$binary_dir/MatteScreen"
cp "$project_dir/App/Info.plist" "$contents_dir/Info.plist"
for texture in "$project_dir"/Sources/MatteScreen/Resources/*.png; do
    cp "$texture" "$resources_dir/"
done

codesign --force --sign - "$app_dir"
echo "$app_dir"
