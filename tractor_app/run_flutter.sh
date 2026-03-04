#!/bin/bash
export QT_QPA_PLATFORM=xcb
emulator -avd Medium_Phone -gpu host -memory 2048 &
sleep 30   # wait for emulator to boot
cd ~/IdeaProjects/final-year-project/tractor_app
flutter run -d emulator-5554
