#!/usr/bin/env bash
# Локальный LLVM toolchain: в системе нет ld в /usr/lib/llvm-18/bin (пакет lld-18).
set -euo pipefail
TOOL_ROOT="${HOME}/.local/toolchains/llvm-18"
TOOL_BIN="${TOOL_ROOT}/bin"

if [[ ! -x "${TOOL_BIN}/clang" ]]; then
  mkdir -p "${TOOL_BIN}"
  cp -a /usr/lib/llvm-18/bin/clang "${TOOL_BIN}/clang"
  if [[ -L /usr/lib/llvm-18/bin/clang++ ]]; then
    ln -sf clang "${TOOL_BIN}/clang++"
  else
    cp -a /usr/lib/llvm-18/bin/clang++ "${TOOL_BIN}/clang++"
  fi
  ln -sfn /usr/lib/llvm-18/lib "${TOOL_ROOT}/lib"
  for t in clang-cpp llc opt llvm-ar llvm-nm llvm-objcopy llvm-objdump llvm-readelf llvm-strip; do
    [[ -e "/usr/lib/llvm-18/bin/$t" ]] && cp -a "/usr/lib/llvm-18/bin/$t" "${TOOL_BIN}/$t"
  done
  ln -sf /usr/bin/ld "${TOOL_BIN}/ld"
  ln -sf /usr/bin/ld "${TOOL_BIN}/ld.lld"
  ln -sf /usr/bin/ar "${TOOL_BIN}/ar"
  ln -sf /usr/bin/nm "${TOOL_BIN}/nm"
  ln -sf /usr/bin/objcopy "${TOOL_BIN}/objcopy"
  ln -sf /usr/bin/objdump "${TOOL_BIN}/objdump"
  ln -sf /usr/bin/ranlib "${TOOL_BIN}/ranlib"
  ln -sf /usr/bin/strip "${TOOL_BIN}/strip"
  [[ -e "${TOOL_BIN}/llvm-ar" ]] || ln -sf ar "${TOOL_BIN}/llvm-ar"
fi

export PATH="${HOME}/flutter/bin:${TOOL_BIN}:${PATH}"
export CC="${TOOL_BIN}/clang"
export CXX="${TOOL_BIN}/clang++"

cd "$(dirname "$0")"
exec flutter "$@"
