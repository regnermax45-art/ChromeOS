# ChromeOS Build Script

🚀 **Enhanced ChromeOS build system with tablet optimization and modular features**

This repository provides two powerful build systems:

## 🖥️ Standard ChromeOS Build (`build.sh`)
Script to build generic ChromeOS image for amd64 devices with Google Play Store support.

## 📱 Tablet-Optimized ChromeOS Build (`tablet-build.sh`) - **NEW!**
Advanced tablet-optimized ChromeOS build system with:
- **Hardware Presets**: Optimized configurations for Samus, Rammus, and more
- **Custom Recovery Support**: Use any ChromeOS recovery image URL or file
- **Touch-Friendly UI**: Enhanced interface for tablet use
- **Stylus Support**: Advanced pen input with pressure sensitivity
- **Gesture Navigation**: Multi-touch gesture controls
- **Modular System**: Choose specific features to include
- **Auto Rotation**: Intelligent screen rotation management
- **Performance Optimizations**: Hardware-specific performance tuning

The generic ChromeOS flex do not support Google Play Store for running Android apps. These scripts will build a generic ChromeOS image with Google Play Store support for amd64 devices.

Both scripts download the latest stable recovery image from https://cros.tech/ for the given codename and latest brunch (https://github.com/sebanc/brunch) release. They then extract the recovery image and build a generic ChromeOS image for amd64 devices.

## Inputs

### `codename`

Codename for ChromeOS build. Choose one of the following options based on your processor:

#### Intel Processor

| Processor Generation | Codename |
|---------------------|----------|
| 3rd gen or older    | samus    |
| 4th and 5th gen     | leona    |
| 6th gen to 9th gen  | shyvana  |
| 10th gen            | jinlon   |
| 11th gen and newer  | voxel    |

#### AMD Processor

| Processor | Codename |
|-----------|----------|
| Ryzen     | gumboz   |

## Local Usage

You will need debian based linux distro to run the script. You can use Ubuntu in WSL on Windows.

### Standard ChromeOS Build

1. Clone this repository.
   ```shell
   git clone https://github.com/rabilrbl/ChromeOS.git
   ```
2. Switch to the repository directory.
   ```shell
   cd ChromeOS
   ```
3. Give execute permission to the script.
   ```shell
   chmod +x build.sh
   ```
4. Run the script.
   ```shell
    ./build.sh <code_name> # Replace <code_name> with the codename of the ChromeOS build you want to build.
    ```
5. Once the build is complete, the image will be available at `chromeos/chromeos.img`.
6. Use a tool like [Balena Etcher](https://www.balena.io/etcher/) to flash the image to a USB drive.

### Tablet-Optimized ChromeOS Build 🆕

1. Follow steps 1-2 above to clone and enter the repository.
2. Give execute permission to the tablet build script.
   ```shell
   chmod +x tablet-build.sh
   ```
3. Run the tablet build script with options:
   ```shell
   # Quick Rammus build with preset recovery image
   ./build-rammus-tablet.sh
   
   # Basic tablet build with Samus optimization
   ./tablet-build.sh --preset samus
   
   # Rammus build with preset configuration
   ./tablet-build.sh --preset rammus --modules all
   
   # Custom recovery image build
   ./tablet-build.sh --recovery-url "https://dl.google.com/.../recovery.bin.zip" --modules all
   
   # Full-featured tablet build with all modules
   ./tablet-build.sh --codename samus --tablet-mode --modules all
   ```
4. Once the build is complete, the image will be available at `tablet-build/chromeos/chromeos-tablet-*.img`.
5. Use a tool like [Balena Etcher](https://www.balena.io/etcher/) to flash the image to a USB drive.

For detailed tablet build documentation, see [README-TABLET.md](README-TABLET.md).

## GitHub Actions Usage

1. Fork this repository.
2. Goto your GitHub profile and click on the repository you forked.
3. Click on the `Actions` tab.
4. Click on the `Build ChromeOS` workflow.
5. Give the codename of the ChromeOS build you want to build.
6. Click on the `Run workflow` button.
7. Wait for the build to complete.
8. Download the zip from the artifacts section of the workflow.
9. Extract the zip and use a tool like [Balena Etcher](https://www.balena.io/etcher/) to flash the image to a USB drive.

## Credits

- [Techy Druid YouTube Channel](https://www.youtube.com/@TechyDruid) for the tutorial on building ChromeOS image. You can check their tutorial videos.
- [Brunch Project](https://github.com/sebanc/brunch) for supporting ChromeOS with Google Play Store.
- [cros.tech](https://cros.tech/) for providing ChromeOS images.
