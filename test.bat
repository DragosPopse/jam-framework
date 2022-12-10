@echo off

if not exist build mkdir build
if not exist build\test mkdir build\test

.\build_test.bat
build\test\test.exe 