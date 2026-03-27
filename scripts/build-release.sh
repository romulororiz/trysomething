#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/build-release.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE not found."
  echo "Copy build-release.env.example to build-release.env and fill in your keys."
  exit 1
fi

# Source environment variables
set -a
source "$ENV_FILE"
set +a

# Validate required keys
for key in REVENUECAT_GOOGLE_KEY POSTHOG_API_KEY SENTRY_DSN GOOGLE_SERVER_CLIENT_ID; do
  if [ -z "${!key:-}" ]; then
    echo "ERROR: $key is not set in $ENV_FILE"
    exit 1
  fi
done

echo "Building release AAB with production keys..."
echo "  RevenueCat: ${REVENUECAT_GOOGLE_KEY:0:8}..."
echo "  PostHog:    ${POSTHOG_API_KEY:0:8}..."
echo "  Sentry:     ${SENTRY_DSN:0:20}..."
echo "  Google:     ${GOOGLE_SERVER_CLIENT_ID:0:20}..."

flutter build appbundle --release \
  --dart-define=REVENUECAT_GOOGLE_KEY="$REVENUECAT_GOOGLE_KEY" \
  --dart-define=POSTHOG_API_KEY="$POSTHOG_API_KEY" \
  --dart-define=SENTRY_DSN="$SENTRY_DSN" \
  --dart-define=GOOGLE_SERVER_CLIENT_ID="$GOOGLE_SERVER_CLIENT_ID"

echo ""
echo "Release AAB built successfully"
echo "  Output: build/app/outputs/bundle/release/app-release.aab"
ls -lh build/app/outputs/bundle/release/app-release.aab
