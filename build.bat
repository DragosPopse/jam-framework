@echo off

if not exist build mkdir build
if not exist build\jam mkdir build\jam

odin build generator -debug -out:build\jam\jam.exe
