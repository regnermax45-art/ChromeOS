#!/usr/bin/env bash

# Quick-start script for building Rammus tablet ChromeOS
# Uses the preset recovery image and optimizations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if tablet-build.sh exists
if [[ ! -f "$SCRIPT_DIR/tablet-build.sh" ]]; then
    log_error "tablet-build.sh not found in $SCRIPT_DIR"
    log_info "Please ensure you're running this script from the ChromeOS repository root"
    exit 1
fi

# Make sure tablet-build.sh is executable
chmod +x "$SCRIPT_DIR/tablet-build.sh"

log_info "🚀 Starting Rammus Tablet ChromeOS Build"
echo "========================================"
echo "This script will build a tablet-optimized ChromeOS image for Rammus devices"
echo "using the preset recovery image and Intel 8th Gen optimizations."
echo ""

# Display configuration
log_info "Build Configuration:"
echo "  • Device: Rammus (Intel 8th Gen)"
echo "  • Recovery: Preset ChromeOS 16433.41.0"
echo "  • Features: All tablet optimizations"
echo "  • Modules: Android apps, Tablet UI, Stylus support, Gestures, Performance boost"
echo "  • Hardware: Intel UHD Graphics 615, Realtek ALC5682 audio"
echo "  • ccache: 50GB cache for faster builds and disk space optimization"
echo ""

# Ask for confirmation
read -p "Do you want to proceed with the build? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Build cancelled by user"
    exit 0
fi

log_info "Starting build process..."

# Run the tablet build with Rammus preset
"$SCRIPT_DIR/tablet-build.sh" \
    --preset rammus \
    --tablet-mode \
    --rotation \
    --gestures \
    --modules all \
    --output "chromeos-rammus-tablet-$(date +%Y%m%d).img"

BUILD_EXIT_CODE=$?

if [[ $BUILD_EXIT_CODE -eq 0 ]]; then
    log_success "🎉 Rammus tablet ChromeOS build completed successfully!"
    echo ""
    log_info "Next steps:"
    echo "1. Navigate to the tablet-build/chromeos/ directory"
    echo "2. Find your chromeos-rammus-tablet-*.img file"
    echo "3. Use Balena Etcher or similar tool to flash to USB drive"
    echo "4. Boot your Rammus device from the USB drive"
    echo ""
    log_info "Features included in your build:"
    echo "  ✅ Touch-optimized interface"
    echo "  ✅ Screen rotation support"
    echo "  ✅ Advanced gesture navigation"
    echo "  ✅ Stylus support with pressure sensitivity"
    echo "  ✅ Enhanced Android app compatibility"
    echo "  ✅ Intel 8th Gen performance optimizations"
    echo "  ✅ Rammus hardware-specific drivers"
    echo ""
    log_success "Enjoy your tablet-optimized ChromeOS experience! 🎉"
else
    log_error "❌ Build failed with exit code $BUILD_EXIT_CODE"
    log_info "Check the build logs above for error details"
    exit $BUILD_EXIT_CODE
fi
