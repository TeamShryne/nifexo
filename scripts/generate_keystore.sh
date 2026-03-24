#!/bin/bash

# Configuration
KEYSTORE_NAME="release.keystore"
KEY_ALIAS="nifexo_alias"
KEYSTORE_PASS=$(openssl rand -base64 12)
KEY_PASS=$KEYSTORE_PASS

echo "--- Nifexo Keystore Generator ---"
echo "This script will generate a new Android signing keystore."
echo ""

# Generate the keystore using keytool (part of JDK)
keytool -genkey -v \
  -keystore "$KEYSTORE_NAME" \
  -alias "$KEY_ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass "$KEYSTORE_PASS" \
  -keypass "$KEY_PASS" \
  -dname "CN=Nifexo User, OU=Nifexo, O=Nifexo, L=Unknown, S=Unknown, C=Unknown"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Success! Keystore generated: $KEYSTORE_NAME"
    echo ""
    echo "--- GitHub Secrets Setup ---"
    echo "Add the following secrets to your GitHub repository (Settings > Secrets > Actions):"
    echo ""
    echo "1. KEYSTORE_BASE64: (Copy the string below)"
    base64 -w 0 "$KEYSTORE_NAME"
    echo ""
    echo ""
    echo "2. KEYSTORE_PASSWORD: $KEYSTORE_PASS"
    echo "3. KEY_ALIAS: $KEY_ALIAS"
    echo "4. KEY_PASSWORD: $KEY_PASS"
    echo ""
    echo "⚠️ IMPORTANT: Keep this file ($KEYSTORE_NAME) safe. If you lose it, you cannot update your app on the Play Store."
    echo "Do NOT commit the .keystore file to git."
else
    echo "❌ Error generating keystore. Make sure 'keytool' is installed (part of Java JDK)."
fi
