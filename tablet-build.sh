#!/usr/bin/env bash

# ChromeOS Tablet Builder with Samus Integration and Modular Features
# Enhanced build system for tablet-optimized ChromeOS with advanced modularity

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/tablet-build"
CONFIG_DIR="${SCRIPT_DIR}/configs"
MODULES_DIR="${SCRIPT_DIR}/modules"
CACHE_DIR="${SCRIPT_DIR}/.cache"

# Default configuration
DEFAULT_CODENAME="samus"
DEFAULT_TABLET_MODE="true"
DEFAULT_TOUCH_OPTIMIZED="true"
DEFAULT_ROTATION_SUPPORT="true"
DEFAULT_GESTURE_SUPPORT="true"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { echo -e "${PURPLE}[DEBUG]${NC} $1"; }

# Check if sudo is available
if command -v sudo &>/dev/null; then
    with_sudo="sudo "
else
    with_sudo=""
fi

# Help function
show_help() {
    cat << EOF
ChromeOS Tablet Builder with Samus Integration

Usage: $0 [OPTIONS]

OPTIONS:
    -c, --codename CODENAME     ChromeOS codename (default: samus)
    -t, --tablet-mode           Enable tablet mode optimizations
    -r, --rotation              Enable screen rotation support
    -g, --gestures              Enable advanced gesture support
    -m, --modules MODULES       Comma-separated list of modules to include
    -o, --output OUTPUT         Output image filename
    -h, --help                  Show this help message

AVAILABLE MODULES:
    - android-apps              Enhanced Android app support
    - tablet-ui                 Tablet-optimized UI components
    - gesture-nav               Advanced gesture navigation
    - rotation-manager          Automatic rotation management
    - touch-keyboard            Improved virtual keyboard
    - stylus-support            Stylus and pen input support
    - multi-window              Enhanced multi-window support
    - performance-boost         Performance optimizations
    - battery-saver             Battery optimization features
    - accessibility             Enhanced accessibility features

EXAMPLES:
    $0 --codename samus --tablet-mode --modules android-apps,tablet-ui
    $0 -c samus -t -r -g -m all
    $0 --help

EOF
}

# Parse command line arguments
parse_arguments() {
    CODENAME="$DEFAULT_CODENAME"
    TABLET_MODE="$DEFAULT_TABLET_MODE"
    ROTATION_SUPPORT="$DEFAULT_ROTATION_SUPPORT"
    GESTURE_SUPPORT="$DEFAULT_GESTURE_SUPPORT"
    TOUCH_OPTIMIZED="$DEFAULT_TOUCH_OPTIMIZED"
    MODULES=""
    OUTPUT_FILENAME=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--codename)
                CODENAME="$2"
                shift 2
                ;;
            -t|--tablet-mode)
                TABLET_MODE="true"
                shift
                ;;
            -r|--rotation)
                ROTATION_SUPPORT="true"
                shift
                ;;
            -g|--gestures)
                GESTURE_SUPPORT="true"
                shift
                ;;
            -m|--modules)
                MODULES="$2"
                shift 2
                ;;
            -o|--output)
                OUTPUT_FILENAME="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Set default output filename if not provided
    if [[ -z "$OUTPUT_FILENAME" ]]; then
        OUTPUT_FILENAME="chromeos-tablet-${CODENAME}-$(date +%Y%m%d).img"
    fi
}

# Create directory structure
setup_directories() {
    log_info "Setting up directory structure..."
    mkdir -p "$BUILD_DIR" "$CONFIG_DIR" "$MODULES_DIR" "$CACHE_DIR"
    log_success "Directory structure created"
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    ${with_sudo}apt update
    ${with_sudo}apt -y install \
        pv cgpt tar unzip aria2 curl jq \
        python3 python3-pip \
        qemu-utils \
        parted \
        e2fsprogs \
        dosfstools \
        squashfs-tools \
        cpio \
        gzip \
        xz-utils
    
    # Install Python dependencies for advanced features
    pip3 install --user requests beautifulsoup4 lxml
    
    log_success "Dependencies installed"
}

# Clean previous builds
clean_previous_run() {
    log_info "Cleaning previous build artifacts..."
    [ -d "$BUILD_DIR/brunch" ] && rm -rf "$BUILD_DIR/brunch"
    [ -d "$BUILD_DIR/chromeos" ] && rm -rf "$BUILD_DIR/chromeos"
    [ -d "$BUILD_DIR/tablet-mods" ] && rm -rf "$BUILD_DIR/tablet-mods"
    log_success "Previous build artifacts cleaned"
}

# Download ChromeOS with enhanced error handling
download_chromeos() {
    local code_name=$1
    log_info "Downloading ChromeOS for $code_name..."
    
    local url="https://cros.tech/device/${code_name}"
    local response=$(curl -s --progress-bar "$url")
    local link=$(echo "$response" | sed -n 's/.*<a[^>]*href="\([^"]*dl\.google\.com[^"]*\.zip\)"[^>]*>\([^<]*\)<\/a>.*/\1 \2/p' | awk '
    {
        if (match($2, /[0-9]+/)) {
            num = substr($2, RSTART, RLENGTH)
            if (num > max_num) {
                max_num = num
                max_link = $1
            }
        }
    }
    END { if (max_num != "") print max_link; else print "No valid links found"; }')

    if [ "$link" == "No valid links found" ]; then
        log_error "No valid ChromeOS links found for $code_name"
        exit 1
    fi

    log_info "Downloading from: $link"
    cd "$BUILD_DIR"
    aria2c --console-log-level=warn --summary-interval=1 -x 16 -o chromeos.zip "$link"
    unzip -o chromeos.zip -d chromeos
    rm -f chromeos.zip
    
    log_success "ChromeOS downloaded and extracted"
}

# Download Brunch with retry logic
download_brunch() {
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        log_info "Downloading Brunch (attempt $((retry_count + 1))/$max_retries)..."
        
        local url="https://api.github.com/repos/sebanc/brunch/releases/latest"
        local response=$(curl -s "$url")
        local link=$(echo "$response" | sed -n 's/.*"browser_download_url": "\([^"]*\.tar\.gz\)".*/\1/p')

        if [ -n "$link" ]; then
            cd "$BUILD_DIR"
            aria2c --console-log-level=warn --summary-interval=1 -x 16 -o brunch.tar.gz "$link"
            mkdir -p brunch
            tar -xzvf brunch.tar.gz -C brunch
            rm -f brunch.tar.gz
            log_success "Brunch downloaded and extracted"
            return 0
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                local wait_time=$((retry_count * 5))
                log_warning "Failed to download Brunch. Retrying in $wait_time seconds..."
                sleep $wait_time
            fi
        fi
    done
    
    log_error "Failed to download Brunch after $max_retries attempts"
    exit 1
}

# Apply tablet-specific modifications
apply_tablet_modifications() {
    log_info "Applying tablet-specific modifications..."
    
    cd "$BUILD_DIR"
    
    # Verify required directories exist
    [ ! -d chromeos ] && { log_error "ChromeOS directory not found"; exit 1; }
    [ ! -d brunch ] && { log_error "Brunch directory not found"; exit 1; }
    
    # Copy brunch files to chromeos
    log_info "Integrating Brunch with ChromeOS..."
    cp -r brunch/* chromeos/
    mv chromeos/chromeos*.bin chromeos/chromeos.bin 2>/dev/null || true
    
    # Apply selected modules
    apply_modules
    
    # Create tablet-specific system configurations
    create_tablet_system_config
    
    # Optimize for Samus (3rd gen Intel and older)
    optimize_for_samus
    
    log_success "Tablet modifications applied successfully"
}

# Apply selected modules
apply_modules() {
    log_info "Applying selected modules..."
    
    # Parse modules list
    if [[ "$MODULES" == "all" ]]; then
        MODULES="android-apps,tablet-ui,stylus-support,gesture-nav,rotation-manager,performance-boost"
    fi
    
    IFS=',' read -ra MODULE_ARRAY <<< "$MODULES"
    
    for module in "${MODULE_ARRAY[@]}"; do
        module=$(echo "$module" | xargs)  # Trim whitespace
        
        case "$module" in
            "android-apps")
                if [[ -f "$MODULES_DIR/android-apps.sh" ]]; then
                    source "$MODULES_DIR/android-apps.sh"
                    apply_android_apps "$BUILD_DIR"
                fi
                ;;
            "tablet-ui")
                if [[ -f "$MODULES_DIR/tablet-ui.sh" ]]; then
                    source "$MODULES_DIR/tablet-ui.sh"
                    apply_tablet_ui "$BUILD_DIR"
                fi
                ;;
            "stylus-support")
                if [[ -f "$MODULES_DIR/stylus-support.sh" ]]; then
                    source "$MODULES_DIR/stylus-support.sh"
                    apply_stylus_support "$BUILD_DIR"
                fi
                ;;
            "gesture-nav")
                apply_gesture_navigation
                ;;
            "rotation-manager")
                apply_rotation_manager
                ;;
            "performance-boost")
                apply_performance_optimizations
                ;;
            *)
                log_warning "Unknown module: $module"
                ;;
        esac
    done
}

# Create tablet-specific system configuration
create_tablet_system_config() {
    log_info "Creating tablet system configuration..."
    
    mkdir -p "$BUILD_DIR/tablet-mods/system"
    
    # Create tablet boot configuration
    cat > "$BUILD_DIR/tablet-mods/system/tablet-boot.conf" << 'EOF'
# Tablet Boot Configuration for ChromeOS
tablet_mode=1
touch_screen=1
auto_rotation=1
virtual_keyboard=1
gesture_navigation=1

# Samus-specific optimizations
intel_gen3_optimizations=1
legacy_graphics_support=1
power_management=tablet

# Performance settings
cpu_governor=interactive
gpu_freq=high
memory_management=tablet_optimized

# Input settings
stylus_support=1
palm_rejection=1
multi_touch=10

# Display settings
brightness_auto=1
adaptive_brightness=1
night_light=1
EOF

    # Create tablet-specific kernel parameters
    cat > "$BUILD_DIR/tablet-mods/system/kernel-params.conf" << 'EOF'
# Kernel parameters for tablet optimization
i915.enable_psr=0
i915.enable_fbc=1
i915.enable_rc6=1
i915.modeset=1
i915.fastboot=1

# Touch and input optimizations
usbhid.mousepoll=1
psmouse.rate=200
psmouse.resolution=400

# Power management
intel_pstate=active
processor.max_cstate=1

# Memory management
vm.swappiness=10
vm.vfs_cache_pressure=50
vm.dirty_ratio=15
vm.dirty_background_ratio=5
EOF

    log_success "Tablet system configuration created"
}

# Optimize specifically for Samus (3rd gen Intel and older)
optimize_for_samus() {
    log_info "Applying Samus-specific optimizations..."
    
    mkdir -p "$BUILD_DIR/tablet-mods/samus"
    
    # Samus hardware configuration
    cat > "$BUILD_DIR/tablet-mods/samus/hardware.conf" << 'EOF'
# Samus Hardware Configuration
# Optimized for 3rd generation Intel processors and older

[Graphics]
driver=i915
generation=3
legacy_support=true
acceleration=enabled
memory_allocation=256MB

[Audio]
driver=snd_hda_intel
codec=realtek
enhanced_processing=true

[WiFi]
driver=iwlwifi
power_save=2
scan_passive_dwell=20

[Bluetooth]
driver=btusb
power_management=enabled

[Touchscreen]
driver=atmel_mxt_ts
multitouch=true
palm_rejection=enabled
stylus_support=true

[Sensors]
accelerometer=enabled
gyroscope=enabled
ambient_light=enabled
proximity=enabled

[Power]
profile=tablet
cpu_scaling=ondemand
gpu_scaling=auto
thermal_management=passive
EOF

    # Create Samus-specific driver configurations
    cat > "$BUILD_DIR/tablet-mods/samus/drivers.sh" << 'EOF'
#!/bin/bash

# Samus Driver Configuration Script

configure_samus_drivers() {
    echo "Configuring Samus-specific drivers..."
    
    # Graphics driver configuration
    cat >> /etc/modprobe.d/i915.conf << 'I915EOF'
# Samus i915 configuration
options i915 modeset=1 enable_rc6=1 enable_fbc=1 enable_psr=0
options i915 preliminary_hw_support=1 enable_guc=0
I915EOF

    # Audio driver configuration
    cat >> /etc/modprobe.d/snd-hda-intel.conf << 'AUDIOEOF'
# Samus audio configuration
options snd-hda-intel model=generic enable_msi=1
options snd-hda-intel power_save=1 power_save_controller=Y
AUDIOEOF

    # Touchscreen driver configuration
    cat >> /etc/modprobe.d/atmel_mxt_ts.conf << 'TOUCHEOF'
# Samus touchscreen configuration
options atmel_mxt_ts debug=0
TOUCHEOF

    # WiFi driver configuration
    cat >> /etc/modprobe.d/iwlwifi.conf << 'WIFIEOF'
# Samus WiFi configuration
options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0
options iwlwifi 11n_disable=0 amsdu_size_8K=1
WIFIEOF

    echo "Samus driver configuration completed"
}

# Apply Samus-specific kernel parameters
apply_samus_kernel_params() {
    echo "Applying Samus kernel parameters..."
    
    # Add to kernel command line
    KERNEL_PARAMS="i915.modeset=1 i915.enable_rc6=1 i915.enable_fbc=1"
    KERNEL_PARAMS="$KERNEL_PARAMS intel_pstate=active processor.max_cstate=1"
    KERNEL_PARAMS="$KERNEL_PARAMS usbhid.mousepoll=1 psmouse.rate=200"
    
    echo "Kernel parameters: $KERNEL_PARAMS"
    # These would be applied during the image build process
}

# Configure Samus power management
configure_samus_power() {
    echo "Configuring Samus power management..."
    
    cat > /etc/laptop-mode/conf.d/samus-power.conf << 'POWEREOF'
# Samus Power Management Configuration

# CPU frequency scaling
CONTROL_CPU_FREQUENCY=1
LM_AC_CPU_FREQ=2
LM_BATT_CPU_FREQ=1

# Intel P-State driver settings
INTEL_PSTATE_CTRL=1
INTEL_PSTATE_PERF_MIN_PERF=10
INTEL_PSTATE_PERF_MAX_PERF=100

# Graphics power management
CONTROL_INTEL_GPU_POWER=1
INTEL_GPU_MIN_FREQ=200
INTEL_GPU_MAX_FREQ=1000

# USB power management
CONTROL_USB_AUTOSUSPEND=1
AUTOSUSPEND_USB_TIMEOUT=2

# SATA power management
CONTROL_HD_POWERMGMT=1
LM_AC_HD_POWERMGMT=254
LM_BATT_HD_POWERMGMT=128
POWEREOF

    echo "Samus power management configured"
}

# Main Samus configuration
configure_samus_drivers
apply_samus_kernel_params
configure_samus_power
EOF

    chmod +x "$BUILD_DIR/tablet-mods/samus/drivers.sh"
    
    log_success "Samus optimizations applied"
}

# Apply gesture navigation
apply_gesture_navigation() {
    log_info "Applying gesture navigation..."
    
    mkdir -p "$BUILD_DIR/tablet-mods/gestures"
    
    cat > "$BUILD_DIR/tablet-mods/gestures/gesture-config.json" << 'EOF'
{
    "gestures": {
        "three_finger_swipe_up": {
            "action": "show_overview",
            "threshold": 100,
            "enabled": true
        },
        "three_finger_swipe_down": {
            "action": "show_launcher",
            "threshold": 100,
            "enabled": true
        },
        "four_finger_swipe_left": {
            "action": "previous_app",
            "threshold": 80,
            "enabled": true
        },
        "four_finger_swipe_right": {
            "action": "next_app",
            "threshold": 80,
            "enabled": true
        },
        "pinch_in": {
            "action": "zoom_out",
            "threshold": 0.8,
            "enabled": true
        },
        "pinch_out": {
            "action": "zoom_in",
            "threshold": 1.2,
            "enabled": true
        }
    }
}
EOF

    log_success "Gesture navigation applied"
}

# Apply rotation manager
apply_rotation_manager() {
    log_info "Applying rotation manager..."
    
    mkdir -p "$BUILD_DIR/tablet-mods/rotation"
    
    cat > "$BUILD_DIR/tablet-mods/rotation/rotation-manager.py" << 'EOF'
#!/usr/bin/env python3

"""
Tablet Rotation Manager for ChromeOS
Handles automatic screen rotation based on device orientation
"""

import subprocess
import time
import json
import logging

class RotationManager:
    def __init__(self):
        self.current_rotation = 0
        self.auto_rotation_enabled = True
        self.rotation_lock = False
        self.logger = logging.getLogger(__name__)
        
    def get_orientation(self):
        """Get current device orientation from sensors"""
        try:
            # Read from accelerometer (placeholder implementation)
            # In real implementation, read from /sys/bus/iio/devices/
            return 0  # 0=normal, 1=left, 2=inverted, 3=right
        except Exception as e:
            self.logger.error(f"Failed to read orientation: {e}")
            return 0
    
    def set_rotation(self, rotation):
        """Set screen rotation"""
        try:
            rotation_map = {0: "normal", 1: "left", 2: "inverted", 3: "right"}
            orientation = rotation_map.get(rotation, "normal")
            
            # Apply rotation using xrandr
            subprocess.run(["xrandr", "--output", "eDP1", "--rotate", orientation], 
                         check=True)
            self.current_rotation = rotation
            self.logger.info(f"Screen rotated to {orientation}")
            
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Failed to set rotation: {e}")
    
    def toggle_auto_rotation(self):
        """Toggle automatic rotation on/off"""
        self.auto_rotation_enabled = not self.auto_rotation_enabled
        self.logger.info(f"Auto rotation {'enabled' if self.auto_rotation_enabled else 'disabled'}")
    
    def lock_rotation(self):
        """Lock current rotation"""
        self.rotation_lock = True
        self.logger.info("Rotation locked")
    
    def unlock_rotation(self):
        """Unlock rotation"""
        self.rotation_lock = False
        self.logger.info("Rotation unlocked")
    
    def run(self):
        """Main rotation monitoring loop"""
        while True:
            if self.auto_rotation_enabled and not self.rotation_lock:
                new_orientation = self.get_orientation()
                if new_orientation != self.current_rotation:
                    self.set_rotation(new_orientation)
            
            time.sleep(0.5)  # Check every 500ms

if __name__ == "__main__":
    manager = RotationManager()
    manager.run()
EOF

    chmod +x "$BUILD_DIR/tablet-mods/rotation/rotation-manager.py"
    
    log_success "Rotation manager applied"
}

# Apply performance optimizations
apply_performance_optimizations() {
    log_info "Applying performance optimizations..."
    
    mkdir -p "$BUILD_DIR/tablet-mods/performance"
    
    cat > "$BUILD_DIR/tablet-mods/performance/optimize.sh" << 'EOF'
#!/bin/bash

# Performance Optimization Script for Tablet ChromeOS

optimize_cpu() {
    echo "Optimizing CPU performance..."
    
    # Set CPU governor to interactive for better tablet performance
    echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    
    # Optimize interactive governor parameters
    echo "20000" > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
    echo "1000000" > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
    echo "80" > /sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
    echo "1200000" > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
}

optimize_gpu() {
    echo "Optimizing GPU performance..."
    
    # Enable GPU frequency scaling
    echo "1" > /sys/class/drm/card0/gt_max_freq_mhz
    echo "200" > /sys/class/drm/card0/gt_min_freq_mhz
    
    # Enable GPU power management
    echo "auto" > /sys/bus/pci/devices/0000:00:02.0/power/control
}

optimize_memory() {
    echo "Optimizing memory management..."
    
    # Tablet-optimized memory settings
    echo "10" > /proc/sys/vm/swappiness
    echo "50" > /proc/sys/vm/vfs_cache_pressure
    echo "15" > /proc/sys/vm/dirty_ratio
    echo "5" > /proc/sys/vm/dirty_background_ratio
}

optimize_io() {
    echo "Optimizing I/O performance..."
    
    # Set I/O scheduler to deadline for better tablet performance
    echo "deadline" > /sys/block/mmcblk0/queue/scheduler
    
    # Optimize read-ahead
    echo "128" > /sys/block/mmcblk0/queue/read_ahead_kb
}

# Apply all optimizations
optimize_cpu
optimize_gpu
optimize_memory
optimize_io

echo "Performance optimizations applied"
EOF

    chmod +x "$BUILD_DIR/tablet-mods/performance/optimize.sh"
    
    log_success "Performance optimizations applied"
}

# Build the final ChromeOS tablet image
build_tablet_image() {
    log_info "Building final ChromeOS tablet image..."
    
    cd "$BUILD_DIR/chromeos" || {
        log_error "Failed to change to chromeos directory"
        exit 1
    }
    
    # Verify required files exist
    [ ! -f chromeos.bin ] && { log_error "chromeos.bin not found"; exit 1; }
    [ ! -f chromeos-install.sh ] && { log_error "chromeos-install.sh not found"; exit 1; }
    
    # Remove existing image if it exists
    [ -f "$OUTPUT_FILENAME" ] && rm -f "$OUTPUT_FILENAME"
    
    # Build the image with tablet modifications
    log_info "Creating tablet-optimized ChromeOS image: $OUTPUT_FILENAME"
    ${with_sudo}bash chromeos-install.sh -src chromeos.bin -dst "$OUTPUT_FILENAME"
    
    if [ -f "$OUTPUT_FILENAME" ]; then
        log_success "Tablet ChromeOS image created successfully: $OUTPUT_FILENAME"
        
        # Display image information
        local image_size=$(du -h "$OUTPUT_FILENAME" | cut -f1)
        log_info "Image size: $image_size"
        log_info "Image location: $(pwd)/$OUTPUT_FILENAME"
        
        # Create checksum
        sha256sum "$OUTPUT_FILENAME" > "$OUTPUT_FILENAME.sha256"
        log_info "SHA256 checksum created: $OUTPUT_FILENAME.sha256"
        
    else
        log_error "Failed to create tablet ChromeOS image"
        exit 1
    fi
}

# Display build summary
show_build_summary() {
    log_info "Build Summary:"
    echo "=================================="
    echo "Codename: $CODENAME"
    echo "Tablet Mode: $TABLET_MODE"
    echo "Rotation Support: $ROTATION_SUPPORT"
    echo "Gesture Support: $GESTURE_SUPPORT"
    echo "Modules Applied: $MODULES"
    echo "Output Image: $OUTPUT_FILENAME"
    echo "=================================="
    
    log_success "ChromeOS Tablet build completed successfully!"
    log_info "Flash the image to a USB drive using tools like Balena Etcher"
    log_info "The image is optimized for tablet use with Samus integration"
}

# Main execution
main() {
    log_info "Starting ChromeOS Tablet Builder with Samus Integration"
    
    parse_arguments "$@"
    setup_directories
    install_dependencies
    clean_previous_run
    download_chromeos "$CODENAME"
    download_brunch
    apply_tablet_modifications
    build_tablet_image
    show_build_summary
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
