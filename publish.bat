@echo off
setlocal
set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.20.8-hotspot
set PATH=%JAVA_HOME%\bin;%PATH%
set ANDROID_HOME=C:\Users\DELL\AppData\Local\Android\Sdk
set PATH=%ANDROID_HOME%\cmdline-tools\latest\bin;%ANDROID_HOME%\platform-tools;%PATH%
cd /d "C:\Projects\Druvatara Andriod\android_native"
call "C:\Projects\Druvatara Andriod\apps\guardian_parent\android\gradlew.bat" :guardian_engine:publishToMavenLocal