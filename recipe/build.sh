#!/usr/bin/env bash
set -euxo pipefail

./configure -installdir "${PREFIX}/lib/ocaml"

make -j1
make install

# In-tree tests cannot find libgmp on macOS: test executables carry an
# @executable_path/../lib rpath ($SRC_DIR/lib from tests/), and the bytecode
# test loads dllzarith.so through the build env's ocamlrun. The installed
# dllzarith.so gets its rpath from rattler-build's relinking.
if [[ "${target_platform}" == osx-* ]]; then
  ln -s "${PREFIX}/lib" lib
  "${INSTALL_NAME_TOOL}" -add_rpath "${PREFIX}/lib" dllzarith.so
fi
make tests
