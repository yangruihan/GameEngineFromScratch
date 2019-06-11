@echo off
git submodule update --init External\src\opengex
mkdir External\build\opengex
pushd External\build\opengex
rm -rf *
cmake -DCMAKE_INSTALL_PREFIX=..\..\ -G "Visual Studio 16 2019" -Thost=x64 ..\..\src\opengex
cmake --build . --config debug --target install
popd

