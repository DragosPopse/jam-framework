@echo off

if not exist build mkdir build
if not exist build\test mkdir build\test

xcopy test\lua542.dll build\test\lua542.dll /Y
xcopy %ODIN_ROOT%\vendor\sdl2\SDL2.dll build\test\SDL2.dll /Y
odin build test -debug -ignore-unknown-attributes -subsystem:console -out:build\test\test.exe