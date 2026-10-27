#!/bin/sh
# The repo lives under iCloud Documents. If Flutter recreates build/ as a real
# directory there, codesign fails with Finder metadata / resource-fork errors.
# Keep build/ as a symlink to a non-iCloud location before any compile.
set -e
project_root="${SRCROOT:-}/.."
if [ ! -d "${project_root}/ios" ]; then
  project_root="$(cd "$(dirname "$0")/../.." && pwd)"
fi
build_path="${project_root}/build"
external_build="${HOME}/Library/Developer/heraj-meem-ios/flutter-build"
mkdir -p "${external_build}"

if [ -L "${build_path}" ]; then
  target="$(readlink "${build_path}")"
  if [ "${target}" = "${external_build}" ]; then
    exit 0
  fi
  rm -f "${build_path}"
elif [ -d "${build_path}" ]; then
  /usr/bin/ditto --norsrc "${build_path}" "${external_build}"
  rm -rf "${build_path}"
elif [ -e "${build_path}" ]; then
  rm -rf "${build_path}"
fi

ln -s "${external_build}" "${build_path}"
