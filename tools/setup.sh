#!/usr/bin/env bash
set -e

echo "Creating Flutter project..."
flutter create assaf_arma_reports
cd assaf_arma_reports

echo "Copying template..."
rsync -av ../lib ./
rsync -av ../assets ./
cp -f ../pubspec.yaml ./

echo "Installing packages..."
flutter pub get

echo "Generating icons & splash (optional)"
flutter pub run flutter_launcher_icons || true
dart run flutter_native_splash:create || true

echo "Done. Next steps:"
echo " - flutter run"
echo " - flutter build apk --debug"