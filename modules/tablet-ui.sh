#!/usr/bin/env bash

# Tablet UI Module - Enhanced tablet interface optimizations
# Provides touch-friendly UI components and layouts

MODULE_NAME="tablet-ui"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="Tablet-optimized UI components and layouts"

source "$(dirname "${BASH_SOURCE[0]}")/../tablet-build.sh"

apply_tablet_ui() {
    local build_dir="$1"
    local chromeos_dir="$build_dir/chromeos"
    
    log_info "Applying tablet UI optimizations..."
    
    # Create tablet UI configuration
    cat > "$build_dir/tablet-ui-config.json" << 'EOF'
{
    "tablet_mode": {
        "auto_rotation": true,
        "touch_friendly_buttons": true,
        "larger_touch_targets": true,
        "gesture_navigation": true,
        "virtual_keyboard_improvements": true
    },
    "ui_scaling": {
        "base_scale": 1.25,
        "touch_target_min_size": 44,
        "icon_scaling": 1.5
    },
    "layout_optimizations": {
        "shelf_auto_hide": true,
        "maximize_apps_default": true,
        "split_screen_enhanced": true
    }
}
EOF

    # Create tablet-specific CSS overrides
    mkdir -p "$build_dir/tablet-mods/ui"
    cat > "$build_dir/tablet-mods/ui/tablet-styles.css" << 'EOF'
/* Tablet UI Optimizations */
.tablet-mode {
    --touch-target-size: 44px;
    --button-padding: 12px 16px;
    --icon-size: 24px;
}

/* Enhanced touch targets */
button, .button, input[type="button"] {
    min-height: var(--touch-target-size);
    min-width: var(--touch-target-size);
    padding: var(--button-padding);
    border-radius: 8px;
    transition: all 0.2s ease;
}

/* Improved scrollbars for touch */
::-webkit-scrollbar {
    width: 12px;
    height: 12px;
}

::-webkit-scrollbar-thumb {
    background: rgba(0,0,0,0.3);
    border-radius: 6px;
    min-height: 40px;
}

/* Enhanced app launcher for tablets */
.app-launcher {
    grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
    gap: 16px;
    padding: 20px;
}

.app-icon {
    width: 64px;
    height: 64px;
    border-radius: 12px;
}

/* Tablet-friendly context menus */
.context-menu {
    min-width: 200px;
    padding: 8px 0;
    border-radius: 12px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.2);
}

.context-menu-item {
    padding: 12px 20px;
    min-height: 44px;
    display: flex;
    align-items: center;
}

/* Enhanced virtual keyboard area */
.virtual-keyboard-container {
    background: rgba(255,255,255,0.95);
    backdrop-filter: blur(10px);
    border-radius: 12px 12px 0 0;
    padding: 8px;
}

/* Tablet-optimized notifications */
.notification {
    min-height: 60px;
    border-radius: 12px;
    padding: 16px;
    margin: 8px;
}

/* Split-screen enhancements */
.split-screen-divider {
    width: 8px;
    background: rgba(0,0,0,0.1);
    cursor: col-resize;
    transition: background 0.2s ease;
}

.split-screen-divider:hover {
    background: rgba(0,0,0,0.2);
}

/* Gesture indicators */
.gesture-indicator {
    position: fixed;
    pointer-events: none;
    border-radius: 50%;
    background: rgba(66, 133, 244, 0.3);
    transform: scale(0);
    transition: transform 0.2s ease;
}

.gesture-indicator.active {
    transform: scale(1);
}
EOF

    # Create tablet gesture configuration
    cat > "$build_dir/tablet-mods/ui/gesture-config.js" << 'EOF'
// Tablet Gesture Configuration
const TabletGestures = {
    // Three-finger swipe up for overview
    threeFingerUp: {
        action: 'showOverview',
        threshold: 100,
        enabled: true
    },
    
    // Three-finger swipe down to minimize
    threeFingerDown: {
        action: 'minimizeAll',
        threshold: 100,
        enabled: true
    },
    
    // Four-finger swipe left/right for app switching
    fourFingerSwipe: {
        action: 'switchApp',
        threshold: 80,
        enabled: true
    },
    
    // Pinch to zoom in launcher
    pinchZoom: {
        action: 'zoomLauncher',
        enabled: true,
        minScale: 0.8,
        maxScale: 1.5
    },
    
    // Edge swipes for back navigation
    edgeSwipe: {
        action: 'navigateBack',
        edgeThreshold: 20,
        enabled: true
    }
};

// Initialize gesture recognition
function initTabletGestures() {
    const gestureHandler = new GestureHandler(TabletGestures);
    gestureHandler.enable();
    
    // Add visual feedback for gestures
    document.addEventListener('gesturestart', showGestureIndicator);
    document.addEventListener('gestureend', hideGestureIndicator);
}

function showGestureIndicator(event) {
    const indicator = document.createElement('div');
    indicator.className = 'gesture-indicator active';
    indicator.style.left = event.clientX + 'px';
    indicator.style.top = event.clientY + 'px';
    document.body.appendChild(indicator);
    
    setTimeout(() => {
        indicator.remove();
    }, 500);
}

// Auto-initialize when DOM is ready
document.addEventListener('DOMContentLoaded', initTabletGestures);
EOF

    # Create tablet-specific system configurations
    mkdir -p "$build_dir/tablet-mods/system"
    cat > "$build_dir/tablet-mods/system/tablet-system.conf" << 'EOF'
# Tablet System Configuration

# Touch and input settings
touch.pressure_threshold=0.3
touch.gesture_sensitivity=1.2
touch.palm_rejection=true

# Display settings
display.auto_rotation=true
display.rotation_lock_timeout=5000
display.brightness_auto_adjust=true

# Performance settings
cpu.tablet_mode_governor=interactive
gpu.tablet_mode_freq=high
memory.tablet_mode_swappiness=10

# Battery optimization
power.tablet_mode_profile=balanced
power.screen_timeout_tablet=300
power.cpu_scaling_tablet=ondemand

# Audio settings
audio.tablet_speakers_boost=1.2
audio.headphone_detection=enhanced

# Network settings
wifi.tablet_mode_scan_interval=30
bluetooth.tablet_mode_discovery=enhanced
EOF

    log_success "Tablet UI module applied successfully"
}

# Export function for use by main build script
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f apply_tablet_ui
fi

