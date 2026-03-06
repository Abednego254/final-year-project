#!/bin/bash

export QT_QPA_PLATFORM=xcb
export PATH=$HOME/Android/Sdk/platform-tools:$PATH

echo "Starting emulator..."

emulator -avd Medium_Phone -gpu host -no-boot-anim -memory 1536 &

echo "Waiting for emulator..."

adb wait-for-device

while [[ "$(adb shell getprop sys.boot_completed | tr -d '\r')" != "1" ]]; do
  sleep 2
done

echo "Emulator booted!"

cd ~/IdeaProjects/final-year-project/tractor_app
flutter run -d emulator-5554
