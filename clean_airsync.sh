#!/bin/bash

# Define the bundle identifier
BUNDLE_ID="com.sameerasw.airsync"
APP_NAME="AirSync"

echo "🧹 Cleaning data for $APP_NAME ($BUNDLE_ID)..."

# 1. Kill the app if it's running
echo "🛑 Closing $APP_NAME..."
pkill -x "$APP_NAME" 2>/dev/null
sleep 1

# 2. Reset UserDefaults
echo "📝 Resetting UserDefaults..."
defaults delete "$BUNDLE_ID" 2>/dev/null

# 3. Clear Caches
echo "📂 Clearing caches..."
rm -rf ~/Library/Caches/"$BUNDLE_ID"
rm -rf ~/Library/Caches/io.sentry/

# 4. Clear Application Support
echo "🗄️ Clearing Application Support..."
rm -rf ~/Library/Application\ Support/"$APP_NAME"

# 5. Reset Permissions (TCC)
echo "🔐 Resetting macOS permissions (Accessibility and Notifications)..."
tccutil reset All "$BUNDLE_ID" 2>/dev/null

echo "✅ Clean complete! Please restart the app and grant permissions when prompted."
