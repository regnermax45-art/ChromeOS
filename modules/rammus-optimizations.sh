#!/usr/bin/env bash

# Rammus Optimizations Module - Intel 8th Gen processor optimizations
# Provides hardware-specific optimizations for Rammus devices

MODULE_NAME="rammus-optimizations"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="Hardware-specific optimizations for Rammus (Intel 8th Gen) devices"

source "$(dirname "${BASH_SOURCE[0]}")/../tablet-build.sh"

apply_rammus_optimizations() {
    local build_dir="$1"
    local chromeos_dir="$build_dir/chromeos"
    
    log_info "Applying Rammus-specific optimizations..."
    
    # Create Rammus optimization directory
    mkdir -p "$build_dir/tablet-mods/rammus"
    
    # Rammus hardware configuration
    cat > "$build_dir/tablet-mods/rammus/hardware.conf" << 'EOF'
# Rammus Hardware Configuration
# Optimized for Intel 8th Generation processors (Kaby Lake Refresh)

[Graphics]
driver=i915
generation=8
architecture=kaby_lake_refresh
acceleration=enabled
memory_allocation=512MB
vulkan_support=true

[Audio]
driver=snd_hda_intel
codec=realtek_alc5682
enhanced_processing=true
noise_cancellation=true
speaker_boost=true

[WiFi]
driver=iwlwifi
chip=intel_ac9560
power_save=2
scan_passive_dwell=20
11ac_support=true

[Bluetooth]
driver=btusb
version=5.0
power_management=enabled
le_support=true

[Touchscreen]
driver=atmel_mxt_ts
multitouch=true
palm_rejection=enabled
stylus_support=true
precision_touchpad=true

[Sensors]
accelerometer=enabled
gyroscope=enabled
ambient_light=enabled
proximity=enabled
magnetometer=enabled

[Power]
profile=convertible
cpu_scaling=powersave
gpu_scaling=auto
thermal_management=active
battery_capacity=50.4Wh

[Display]
resolution=1920x1080
refresh_rate=60
brightness_levels=16
adaptive_brightness=true
night_light=true

[Keyboard]
backlight=true
function_keys=enabled
media_keys=enabled
EOF

    # Create Rammus-specific driver configurations
    cat > "$build_dir/tablet-mods/rammus/drivers.sh" << 'EOF'
#!/bin/bash

# Rammus Driver Configuration Script

configure_rammus_drivers() {
    echo "Configuring Rammus-specific drivers..."
    
    # Graphics driver configuration for Intel UHD Graphics 615
    cat >> /etc/modprobe.d/i915.conf << 'I915EOF'
# Rammus i915 configuration for Intel UHD Graphics 615
options i915 modeset=1 enable_rc6=1 enable_fbc=1 enable_psr=1
options i915 enable_guc=2 enable_huc=1 nuclear_pageflip=1
options i915 fastboot=1 enable_dp_mst=1
I915EOF

    # Audio driver configuration for Realtek ALC5682
    cat >> /etc/modprobe.d/snd-hda-intel.conf << 'AUDIOEOF'
# Rammus audio configuration for Realtek ALC5682
options snd-hda-intel model=alc5682-dmic enable_msi=1
options snd-hda-intel power_save=1 power_save_controller=Y
options snd-hda-intel beep_mode=0
AUDIOEOF

    # Touchscreen driver configuration
    cat >> /etc/modprobe.d/atmel_mxt_ts.conf << 'TOUCHEOF'
# Rammus touchscreen configuration
options atmel_mxt_ts debug=0 palm_rejection=1
TOUCHEOF

    # WiFi driver configuration for Intel AC 9560
    cat >> /etc/modprobe.d/iwlwifi.conf << 'WIFIEOF'
# Rammus WiFi configuration for Intel AC 9560
options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0
options iwlwifi 11n_disable=0 amsdu_size_8K=1 fw_restart=1
options iwlwifi antenna_coupling=1 bt_coex_active=1
WIFIEOF

    # Bluetooth configuration
    cat >> /etc/modprobe.d/btusb.conf << 'BTEOF'
# Rammus Bluetooth configuration
options btusb enable_autosuspend=1 reset=1
BTEOF

    echo "Rammus driver configuration completed"
}

# Apply Rammus-specific kernel parameters
apply_rammus_kernel_params() {
    echo "Applying Rammus kernel parameters..."
    
    # Add to kernel command line
    KERNEL_PARAMS="i915.modeset=1 i915.enable_rc6=1 i915.enable_fbc=1 i915.enable_psr=1"
    KERNEL_PARAMS="$KERNEL_PARAMS intel_pstate=active processor.max_cstate=2"
    KERNEL_PARAMS="$KERNEL_PARAMS usbhid.mousepoll=1 psmouse.rate=200"
    KERNEL_PARAMS="$KERNEL_PARAMS i915.enable_guc=2 i915.enable_huc=1"
    
    echo "Kernel parameters: $KERNEL_PARAMS"
    # These would be applied during the image build process
}

# Configure Rammus power management
configure_rammus_power() {
    echo "Configuring Rammus power management..."
    
    cat > /etc/laptop-mode/conf.d/rammus-power.conf << 'POWEREOF'
# Rammus Power Management Configuration

# CPU frequency scaling for Intel 8th Gen
CONTROL_CPU_FREQUENCY=1
LM_AC_CPU_FREQ=2
LM_BATT_CPU_FREQ=1

# Intel P-State driver settings
INTEL_PSTATE_CTRL=1
INTEL_PSTATE_PERF_MIN_PERF=15
INTEL_PSTATE_PERF_MAX_PERF=100

# Graphics power management for UHD Graphics 615
CONTROL_INTEL_GPU_POWER=1
INTEL_GPU_MIN_FREQ=300
INTEL_GPU_MAX_FREQ=1050

# USB power management
CONTROL_USB_AUTOSUSPEND=1
AUTOSUSPEND_USB_TIMEOUT=2

# SATA power management
CONTROL_HD_POWERMGMT=1
LM_AC_HD_POWERMGMT=254
LM_BATT_HD_POWERMGMT=128

# WiFi power management
CONTROL_WIFI_POWER=1
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

# Bluetooth power management
CONTROL_BLUETOOTH_POWER=1
BLUETOOTH_PWR_ON_AC=1
BLUETOOTH_PWR_ON_BAT=1
POWEREOF

    echo "Rammus power management configured"
}

# Configure Rammus thermal management
configure_rammus_thermal() {
    echo "Configuring Rammus thermal management..."
    
    cat > /etc/thermald/thermal-conf.xml << 'THERMALEOF'
<?xml version="1.0"?>
<ThermalConfiguration>
    <Platform>
        <Name>Rammus</Name>
        <ProductName>Rammus</ProductName>
        <Preference>QUIET</Preference>
        <ThermalZones>
            <ThermalZone>
                <Type>cpu</Type>
                <TripPoints>
                    <TripPoint>
                        <SensorType>cpu</SensorType>
                        <Temperature>70000</Temperature>
                        <type>passive</type>
                        <CoolingDevice>
                            <index>1</index>
                            <type>intel_pstate</type>
                            <influence>100</influence>
                            <SamplingPeriod>1</SamplingPeriod>
                        </CoolingDevice>
                    </TripPoint>
                    <TripPoint>
                        <SensorType>cpu</SensorType>
                        <Temperature>85000</Temperature>
                        <type>critical</type>
                    </TripPoint>
                </TripPoints>
            </ThermalZone>
        </ThermalZones>
    </Platform>
</ThermalConfiguration>
THERMALEOF

    echo "Rammus thermal management configured"
}

# Configure Rammus display settings
configure_rammus_display() {
    echo "Configuring Rammus display settings..."
    
    cat > /etc/X11/xorg.conf.d/20-rammus-intel.conf << 'DISPLAYEOF'
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
    Option "Backlight" "intel_backlight"
    Option "AccelMethod" "sna"
    Option "TearFree" "true"
    Option "DRI" "3"
    Option "TripleBuffer" "true"
EndSection

Section "Screen"
    Identifier "Screen0"
    Device "Intel Graphics"
    DefaultDepth 24
    SubSection "Display"
        Depth 24
        Modes "1920x1080"
    EndSubSection
EndSection
DISPLAYEOF

    echo "Rammus display configuration completed"
}

# Configure Rammus input devices
configure_rammus_input() {
    echo "Configuring Rammus input devices..."
    
    # Touchscreen configuration
    cat > /etc/X11/xorg.conf.d/40-rammus-touchscreen.conf << 'TOUCHEOF'
Section "InputClass"
    Identifier "Rammus Touchscreen"
    MatchIsTouchscreen "on"
    Driver "libinput"
    Option "Calibration" "0 1920 0 1080"
    Option "SwapAxes" "0"
    Option "InvertX" "0"
    Option "InvertY" "0"
    Option "TransformationMatrix" "1 0 0 0 1 0 0 0 1"
EndSection
TOUCHEOF

    # Precision touchpad configuration
    cat > /etc/X11/xorg.conf.d/30-rammus-touchpad.conf << 'TOUCHPADEOF'
Section "InputClass"
    Identifier "Rammus Precision Touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "TappingDrag" "on"
    Option "DisableWhileTyping" "on"
    Option "AccelProfile" "adaptive"
    Option "NaturalScrolling" "true"
    Option "ScrollMethod" "twofinger"
    Option "ClickMethod" "clickfinger"
EndSection
TOUCHPADEOF

    echo "Rammus input device configuration completed"
}

# Main Rammus configuration
configure_rammus_drivers
apply_rammus_kernel_params
configure_rammus_power
configure_rammus_thermal
configure_rammus_display
configure_rammus_input
EOF

    chmod +x "$build_dir/tablet-mods/rammus/drivers.sh"
    
    # Create Rammus-specific system optimizations
    cat > "$build_dir/tablet-mods/rammus/system-optimizations.sh" << 'EOF'
#!/bin/bash

# Rammus System Optimizations

optimize_rammus_performance() {
    echo "Optimizing Rammus performance..."
    
    # CPU performance optimization
    echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    
    # Set CPU frequency limits for Intel 8th Gen
    echo "1600000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
    echo "3400000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
    
    # GPU performance optimization for UHD Graphics 615
    echo "1050" > /sys/class/drm/card0/gt_max_freq_mhz
    echo "300" > /sys/class/drm/card0/gt_min_freq_mhz
    
    # Memory optimization for 8GB RAM
    echo "5" > /proc/sys/vm/swappiness
    echo "40" > /proc/sys/vm/vfs_cache_pressure
    echo "10" > /proc/sys/vm/dirty_ratio
    echo "3" > /proc/sys/vm/dirty_background_ratio
    
    # I/O optimization for NVMe SSD
    echo "mq-deadline" > /sys/block/nvme0n1/queue/scheduler
    echo "256" > /sys/block/nvme0n1/queue/read_ahead_kb
    
    echo "Rammus performance optimization completed"
}

optimize_rammus_battery() {
    echo "Optimizing Rammus battery life..."
    
    # CPU power saving
    echo "powersave" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    
    # GPU power saving
    echo "auto" > /sys/bus/pci/devices/0000:00:02.0/power/control
    
    # USB power saving
    for usb in /sys/bus/usb/devices/*/power/control; do
        echo "auto" > "$usb" 2>/dev/null
    done
    
    # WiFi power saving
    iw dev wlan0 set power_save on 2>/dev/null
    
    # Audio power saving
    echo "1" > /sys/module/snd_hda_intel/parameters/power_save
    
    echo "Rammus battery optimization completed"
}

# Apply optimizations based on power state
if [ -f /sys/class/power_supply/AC/online ] && [ "$(cat /sys/class/power_supply/AC/online)" = "1" ]; then
    optimize_rammus_performance
else
    optimize_rammus_battery
fi
EOF

    chmod +x "$build_dir/tablet-mods/rammus/system-optimizations.sh"
    
    log_success "Rammus optimizations module applied successfully"
}

# Export function for use by main build script
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f apply_rammus_optimizations
fi

