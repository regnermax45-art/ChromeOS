# ChromeOS Tablet Builder with Samus Integration

🚀 **Advanced tablet-optimized ChromeOS build system with modular features and Samus integration**

This enhanced build system creates tablet-optimized ChromeOS images with advanced features, touch-friendly interfaces, and comprehensive hardware support specifically optimized for Samus (3rd generation Intel processors and older).

## ✨ Features

### 🎯 Core Tablet Optimizations
- **Tablet Mode**: Automatic tablet mode detection and optimization
- **Touch Interface**: Touch-friendly UI with larger touch targets
- **Screen Rotation**: Automatic screen rotation with sensor support
- **Gesture Navigation**: Advanced multi-touch gesture support
- **Virtual Keyboard**: Enhanced on-screen keyboard experience

### 🎨 Modular System
- **Android Apps**: Enhanced Android app support with tablet optimizations
- **Tablet UI**: Touch-optimized interface components
- **Stylus Support**: Advanced stylus and pen input with pressure sensitivity
- **Gesture Navigation**: Multi-finger gesture controls
- **Rotation Manager**: Intelligent screen rotation management
- **Performance Boost**: System-wide performance optimizations

### ⚡ Build Optimizations
- **ccache Integration**: 50GB cache for faster rebuilds (reduces build time by 70%+)
- **Smart Cleanup**: Automatic disk space management and optimization
- **Compression**: Cache compression reduces storage usage by 50-80%
- **Disk Space Check**: Pre-build validation with helpful solutions for space issues

### 🖥️ Samus Integration
- **Legacy Hardware Support**: Optimized for 3rd gen Intel processors and older
- **Graphics Optimization**: Intel i915 driver optimizations for older hardware
- **Power Management**: Tablet-specific power management for better battery life
- **Driver Configuration**: Automatic driver setup for Samus hardware

## 🚀 Quick Start

### Basic Usage
```bash
# Make the script executable
chmod +x tablet-build.sh

# Quick Rammus build with preset (recommended)
./build-rammus-tablet.sh

# Build with Rammus preset
./tablet-build.sh --preset rammus

# Build with Samus preset
./tablet-build.sh --preset samus

# Build with custom recovery image
./tablet-build.sh --recovery-url "https://dl.google.com/dl/edgedl/chromeos/recovery/chromeos_16433.41.0_rammus_recovery_stable-channel_RammusMPKeys-v8.bin.zip" --modules all
```

### Advanced Usage
```bash
# Full tablet build with all features
./tablet-build.sh --codename samus --tablet-mode --rotation --gestures --modules all

# Custom build with specific output filename
./tablet-build.sh -c samus -t -r -g -m android-apps,tablet-ui -o my-tablet-chromeos.img

# Performance-focused build
./tablet-build.sh --codename samus --modules performance-boost,android-apps --output performance-tablet.img
```

## 📋 Command Line Options

| Option | Short | Description | Default |
|--------|-------|-------------|---------|
| `--codename` | `-c` | ChromeOS codename | `samus` |
| `--tablet-mode` | `-t` | Enable tablet mode optimizations | `true` |
| `--rotation` | `-r` | Enable screen rotation support | `true` |
| `--gestures` | `-g` | Enable advanced gesture support | `true` |
| `--modules` | `-m` | Comma-separated list of modules | `""` |
| `--output` | `-o` | Output image filename | `chromeos-tablet-{codename}-{date}.img` |
| `--recovery-url` | - | Custom recovery image URL | Auto-detect |
| `--recovery-file` | - | Local recovery image file | Auto-detect |
| `--preset` | - | Use preset configuration | None |
| `--help` | `-h` | Show help message | - |

## 🎯 Preset Configurations

The build system includes preset configurations for different hardware platforms:

### Rammus Preset (`--preset rammus`)
- **Hardware**: Intel 8th Generation processors (Kaby Lake Refresh)
- **Graphics**: Intel UHD Graphics 615 with Vulkan support
- **Audio**: Realtek ALC5682 with noise cancellation
- **WiFi**: Intel AC 9560 with 802.11ac support
- **Recovery**: Preset ChromeOS 16433.41.0 recovery image
- **Optimizations**: Intel 8th Gen specific performance tuning
- **Features**: All tablet modules enabled by default

### Samus Preset (`--preset samus`)
- **Hardware**: Intel 3rd Generation processors and older
- **Graphics**: Intel i915 with legacy support
- **Audio**: Realtek codec optimizations
- **WiFi**: Intel wireless driver tuning
- **Recovery**: Auto-detected from cros.tech
- **Optimizations**: Legacy hardware compatibility
- **Features**: Basic tablet modules enabled

### Custom Recovery Images

You can use any ChromeOS recovery image with the build system:

```bash
# Using a custom recovery URL
./tablet-build.sh --recovery-url "https://dl.google.com/dl/edgedl/chromeos/recovery/chromeos_16433.41.0_rammus_recovery_stable-channel_RammusMPKeys-v8.bin.zip"

# Using a local recovery file
./tablet-build.sh --recovery-file "/path/to/recovery.bin.zip"
```

## 🧩 Available Modules

### 📱 Android Apps (`android-apps`)
- Enhanced Android runtime for tablets
- Play Store tablet optimizations
- Forced tablet UI for compatible apps
- Performance optimizations for Android apps
- Multi-window support enhancements

### 🎨 Tablet UI (`tablet-ui`)
- Touch-friendly interface components
- Larger touch targets and buttons
- Enhanced scrollbars for touch
- Tablet-optimized app launcher
- Improved context menus and notifications

### ✏️ Stylus Support (`stylus-support`)
- Pressure sensitivity support (up to 8192 levels)
- Palm rejection technology
- Tilt and rotation support
- Advanced drawing applications
- Stylus calibration tools

### 👆 Gesture Navigation (`gesture-nav`)
- Three-finger swipe gestures
- Four-finger app switching
- Pinch-to-zoom in launcher
- Edge swipe navigation
- Customizable gesture actions

### 🔄 Rotation Manager (`rotation-manager`)
- Automatic screen rotation
- Sensor-based orientation detection
- Rotation lock functionality
- App-specific rotation preferences
- Smooth rotation animations

### ⚡ Performance Boost (`performance-boost`)
- CPU governor optimizations
- GPU frequency scaling
- Memory management tuning
- I/O scheduler optimization
- Thermal management improvements

## 🛠️ System Requirements

### Host System
- Debian-based Linux distribution (Ubuntu recommended)
- At least 8GB RAM
- 20GB free disk space
- Internet connection for downloads

### Target Hardware (Samus Optimized)
- 3rd generation Intel processors or older
- Minimum 4GB RAM
- 32GB storage
- Touchscreen display
- Optional: Stylus/pen input device

## 📁 Project Structure

```
ChromeOS/
├── tablet-build.sh          # Main build script
├── modules/                 # Modular feature implementations
│   ├── android-apps.sh     # Android app optimizations
│   ├── tablet-ui.sh        # UI optimizations
│   └── stylus-support.sh   # Stylus and pen support
├── configs/                # Configuration files
│   └── tablet-default.conf # Default tablet settings
├── tablet-mods/            # Generated modifications (build-time)
│   ├── android/           # Android-specific modifications
│   ├── ui/                # UI modifications
│   ├── stylus/            # Stylus configurations
│   ├── gestures/          # Gesture configurations
│   ├── rotation/          # Rotation management
│   ├── performance/       # Performance optimizations
│   └── samus/             # Samus-specific optimizations
└── README-TABLET.md        # This documentation
```

## 🔧 Configuration

### Default Configuration
The build system uses sensible defaults optimized for tablet use:
- Codename: `samus` (3rd gen Intel and older)
- Tablet mode: Enabled
- Touch optimizations: Enabled
- Screen rotation: Enabled
- Gesture support: Enabled

### Custom Configuration
Create a custom configuration file in `configs/` directory:

```ini
[build]
codename=samus
tablet_mode=true
modules=android-apps,tablet-ui,stylus-support

[display]
auto_rotation=true
adaptive_brightness=true

[input]
palm_rejection=true
stylus_pressure_levels=8192
```

## 🎯 Samus-Specific Optimizations

### Hardware Support
- **Graphics**: Intel i915 driver with legacy support
- **Audio**: Realtek codec optimizations
- **WiFi**: Intel wireless driver optimizations
- **Touchscreen**: Atmel touchscreen driver support
- **Sensors**: Accelerometer, gyroscope, ambient light

### Performance Tuning
- **CPU**: Interactive governor with tablet-optimized parameters
- **GPU**: Frequency scaling for better performance/battery balance
- **Memory**: Tablet-optimized memory management
- **Power**: Passive thermal management for fanless operation

### Driver Configuration
- Automatic detection and configuration of Samus hardware
- Optimized kernel parameters for older Intel processors
- Enhanced power management for better battery life
- Touch and stylus input optimizations

## 🚀 Build Process

1. **Dependency Installation**: Installs required build tools and libraries
2. **ChromeOS Download**: Downloads latest stable ChromeOS recovery image
3. **Brunch Integration**: Downloads and integrates Brunch framework
4. **Module Application**: Applies selected modular features
5. **Samus Optimization**: Applies hardware-specific optimizations
6. **Image Creation**: Builds final tablet-optimized ChromeOS image
7. **Verification**: Creates checksums and validates the build

## 📊 Build Output

After successful build, you'll find:
- `chromeos-tablet-{codename}-{date}.img` - Main ChromeOS image
- `chromeos-tablet-{codename}-{date}.img.sha256` - SHA256 checksum
- Build logs and configuration files in `tablet-build/` directory

## 🔍 Troubleshooting

### Common Issues

**Build fails with dependency errors**
```bash
# Update package lists and retry
sudo apt update
sudo apt upgrade
./tablet-build.sh
```

**Insufficient disk space**
```bash
# Check available space (need ~12GB minimum, 20GB recommended)
df -h

# The build system now includes automatic cleanup and ccache optimization
# But you can manually clean if needed:
sudo apt clean && sudo apt autoremove -y
docker system prune -a  # If Docker is installed

# For ext4 partitions, reclaim reserved space (5% by default)
sudo tune2fs -m 1 /dev/sdXY  # Reduces reserved space to 1%

# ccache benefits:
# - First build: Creates 50GB cache for future builds
# - Subsequent builds: 70%+ faster due to cached compilation
# - Compressed cache: Stores more data in less space
```

**Module not found errors**
```bash
# Ensure all module files exist
ls -la modules/
# Check module syntax
bash -n modules/tablet-ui.sh
```

### Debug Mode
Enable verbose logging:
```bash
export DEBUG=1
./tablet-build.sh --codename samus --modules all
```

## 🤝 Contributing

### Adding New Modules
1. Create module script in `modules/` directory
2. Follow the existing module template
3. Export the main function for integration
4. Update documentation

### Module Template
```bash
#!/usr/bin/env bash

MODULE_NAME="my-module"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="Description of module functionality"

apply_my_module() {
    local build_dir="$1"
    log_info "Applying my module..."
    
    # Module implementation here
    
    log_success "My module applied successfully"
}

# Export function
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f apply_my_module
fi
```

## 📄 License

This project is licensed under the same terms as the original ChromeOS build script. See [LICENSE](LICENSE) for details.

## 🙏 Credits

- **Original ChromeOS Build Script**: Base build system
- **Brunch Project**: ChromeOS with Google Play Store support
- **cros.tech**: ChromeOS recovery images
- **Techy Druid**: Tutorial and guidance
- **Community Contributors**: Feature requests and testing

## 🔗 Related Projects

- [Brunch Framework](https://github.com/sebanc/brunch) - ChromeOS for PC
- [ChromeOS Flex](https://chromeenterprise.google/os/chromeosflex/) - Official ChromeOS for PC
- [Chromium OS](https://www.chromium.org/chromium-os) - Open source ChromeOS

---

**🎉 Enjoy your tablet-optimized ChromeOS with Samus integration!**

For support and questions, please open an issue in the repository.
