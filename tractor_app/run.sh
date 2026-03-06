#!/bin/bash

export QT_QPA_PLATFORM=xcb

echo "Starting emulator..."

emulator -avd Medium_Phone -gpu host -no-boot-anim -no-snapshot -memory 1536 &

echo "Waiting for emulator..."

adb wait-for-device

until adb shell getprop sys.boot_completed | grep -m 1 "1"; do
  sleep 2
done

echo "Emulator booted!"

cd ~/IdeaProjects/final-year-project/tractor_app
flutter run -d emulator-5554
