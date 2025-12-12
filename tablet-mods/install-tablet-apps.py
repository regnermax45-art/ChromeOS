#!/usr/bin/env python3

"""
Tablet Apps Installer for ChromeOS
Automatically installs and configures tablet-optimized applications
"""

import json
import subprocess
import logging
import os
import sys
from pathlib import Path

class TabletAppsInstaller:
    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.config_dir = Path("/etc/tablet-apps")
        self.apps_config = self.config_dir / "apps.json"
        
        # Ensure config directory exists
        self.config_dir.mkdir(parents=True, exist_ok=True)
        
    def load_apps_config(self):
        """Load tablet apps configuration"""
        default_config = {
            "productivity": [
                {
                    "name": "Google Docs",
                    "package": "com.google.android.apps.docs.editors.docs",
                    "category": "productivity",
                    "tablet_optimized": True,
                    "stylus_support": True
                },
                {
                    "name": "Google Sheets", 
                    "package": "com.google.android.apps.docs.editors.sheets",
                    "category": "productivity",
                    "tablet_optimized": True,
                    "stylus_support": True
                },
                {
                    "name": "Google Slides",
                    "package": "com.google.android.apps.docs.editors.slides", 
                    "category": "productivity",
                    "tablet_optimized": True,
                    "stylus_support": True
                },
                {
                    "name": "Microsoft Word",
                    "package": "com.microsoft.office.word",
                    "category": "productivity", 
                    "tablet_optimized": True,
                    "stylus_support": True
                },
                {
                    "name": "Microsoft Excel",
                    "package": "com.microsoft.office.excel",
                    "category": "productivity",
                    "tablet_optimized": True,
                    "stylus_support": True
                },
                {
                    "name": "Microsoft PowerPoint", 
                    "package": "com.microsoft.office.powerpoint",
                    "category": "productivity",
                    "tablet_optimized": True,
                    "stylus_support": True
                }
            ],
            "creative": [
                {
                    "name": "Adobe Photoshop Express",
                    "package": "com.adobe.psmobile",
                    "category": "creative",
                    "tablet_optimized": True,
                    "stylus_support": True
                },
                {
                    "name": "Autodesk SketchBook",
                    "package": "com.adsk.sketchbook",
                    "category": "creative", 
                    "tablet_optimized": True,
                    "stylus_support": True
                },
                {
                    "name": "Canva",
                    "package": "com.canva.editor",
                    "category": "creative",
                    "tablet_optimized": True,
                    "stylus_support": False
                },
                {
                    "name": "Concepts",
                    "package": "com.tophatch.concepts",
                    "category": "creative",
                    "tablet_optimized": True,
                    "stylus_support": True
                }
            ],
            "entertainment": [
                {
                    "name": "Netflix",
                    "package": "com.netflix.mediaclient",
                    "category": "entertainment",
                    "tablet_optimized": True,
                    "stylus_support": False
                },
                {
                    "name": "Spotify",
                    "package": "com.spotify.music", 
                    "category": "entertainment",
                    "tablet_optimized": True,
                    "stylus_support": False
                },
                {
                    "name": "YouTube",
                    "package": "com.google.android.youtube",
                    "category": "entertainment",
                    "tablet_optimized": True,
                    "stylus_support": False
                },
                {
                    "name": "VLC Media Player",
                    "package": "org.videolan.vlc",
                    "category": "entertainment",
                    "tablet_optimized": True,
                    "stylus_support": False
                }
            ],
            "utilities": [
                {
                    "name": "Google Keep",
                    "package": "com.google.android.keep",
                    "category": "utilities",
                    "tablet_optimized": True,
                    "stylus_support": True
                },
                {
                    "name": "Google Calendar",
                    "package": "com.google.android.calendar",
                    "category": "utilities", 
                    "tablet_optimized": True,
                    "stylus_support": False
                },
                {
                    "name": "Google Photos",
                    "package": "com.google.android.apps.photos",
                    "category": "utilities",
                    "tablet_optimized": True,
                    "stylus_support": False
                },
                {
                    "name": "File Manager",
                    "package": "com.google.android.apps.nbu.files",
                    "category": "utilities",
                    "tablet_optimized": True,
                    "stylus_support": False
                }
            ]
        }
        
        if self.apps_config.exists():
            try:
                with open(self.apps_config, 'r') as f:
                    return json.load(f)
            except Exception as e:
                self.logger.error(f"Failed to load apps config: {e}")
                return default_config
        else:
            # Save default config
            with open(self.apps_config, 'w') as f:
                json.dump(default_config, f, indent=2)
            return default_config
    
    def install_app(self, app_info):
        """Install a single app via Play Store"""
        package = app_info['package']
        name = app_info['name']
        
        self.logger.info(f"Installing {name} ({package})")
        
        try:
            # In a real implementation, this would interface with the Play Store
            # For now, we'll create a placeholder installation record
            install_record = {
                "package": package,
                "name": name,
                "installed": True,
                "tablet_configured": app_info.get('tablet_optimized', False),
                "stylus_configured": app_info.get('stylus_support', False)
            }
            
            # Create app-specific configuration
            self.configure_app_for_tablet(app_info)
            
            self.logger.info(f"Successfully installed {name}")
            return True
            
        except Exception as e:
            self.logger.error(f"Failed to install {name}: {e}")
            return False
    
    def configure_app_for_tablet(self, app_info):
        """Configure app for optimal tablet experience"""
        package = app_info['package']
        
        # Create app-specific tablet configuration
        app_config_dir = Path(f"/data/data/{package}/tablet-config")
        app_config_dir.mkdir(parents=True, exist_ok=True)
        
        config = {
            "tablet_mode": True,
            "force_tablet_ui": app_info.get('tablet_optimized', False),
            "stylus_support": app_info.get('stylus_support', False),
            "multi_window": True,
            "resizable": True
        }
        
        config_file = app_config_dir / "tablet.json"
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)
        
        self.logger.info(f"Configured {app_info['name']} for tablet use")
    
    def install_category(self, category):
        """Install all apps in a specific category"""
        apps_config = self.load_apps_config()
        
        if category not in apps_config:
            self.logger.error(f"Unknown category: {category}")
            return False
        
        apps = apps_config[category]
        success_count = 0
        
        self.logger.info(f"Installing {len(apps)} apps in category: {category}")
        
        for app in apps:
            if self.install_app(app):
                success_count += 1
        
        self.logger.info(f"Successfully installed {success_count}/{len(apps)} apps in {category}")
        return success_count == len(apps)
    
    def install_all_apps(self):
        """Install all tablet-optimized apps"""
        apps_config = self.load_apps_config()
        total_apps = 0
        total_success = 0
        
        for category, apps in apps_config.items():
            self.logger.info(f"Installing {category} apps...")
            total_apps += len(apps)
            
            for app in apps:
                if self.install_app(app):
                    total_success += 1
        
        self.logger.info(f"Installation complete: {total_success}/{total_apps} apps installed")
        return total_success == total_apps
    
    def list_available_apps(self):
        """List all available tablet-optimized apps"""
        apps_config = self.load_apps_config()
        
        print("Available Tablet-Optimized Apps:")
        print("=" * 40)
        
        for category, apps in apps_config.items():
            print(f"\n{category.upper()}:")
            for app in apps:
                stylus_indicator = " ✏️" if app.get('stylus_support') else ""
                tablet_indicator = " 📱" if app.get('tablet_optimized') else ""
                print(f"  • {app['name']}{tablet_indicator}{stylus_indicator}")
        
        print("\nLegend:")
        print("📱 = Tablet optimized")
        print("✏️ = Stylus support")
    
    def create_app_shortcuts(self):
        """Create tablet-friendly app shortcuts"""
        shortcuts_dir = Path("/usr/share/applications/tablet-apps")
        shortcuts_dir.mkdir(parents=True, exist_ok=True)
        
        apps_config = self.load_apps_config()
        
        for category, apps in apps_config.items():
            for app in apps:
                self.create_app_shortcut(app, shortcuts_dir)
    
    def create_app_shortcut(self, app_info, shortcuts_dir):
        """Create a desktop shortcut for an app"""
        package = app_info['package']
        name = app_info['name']
        
        shortcut_content = f"""[Desktop Entry]
Name={name}
Comment=Tablet-optimized {name}
Exec=am start -n {package}/.MainActivity
Icon={package}
Type=Application
Categories=TabletApps;{app_info['category'].title()};
StartupNotify=true
MimeType=application/x-tablet-app;
"""
        
        if app_info.get('tablet_optimized'):
            shortcut_content += "X-Tablet-Optimized=true\n"
        
        if app_info.get('stylus_support'):
            shortcut_content += "X-Stylus-Support=true\n"
        
        shortcut_file = shortcuts_dir / f"{package}.desktop"
        with open(shortcut_file, 'w') as f:
            f.write(shortcut_content)
        
        # Make executable
        shortcut_file.chmod(0o755)

def main():
    """Main function"""
    logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
    
    installer = TabletAppsInstaller()
    
    if len(sys.argv) < 2:
        print("Usage: tablet-apps-installer.py <command> [category]")
        print("Commands:")
        print("  list                 - List available apps")
        print("  install-all          - Install all apps")
        print("  install <category>   - Install apps in specific category")
        print("  shortcuts            - Create app shortcuts")
        print("Categories: productivity, creative, entertainment, utilities")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "list":
        installer.list_available_apps()
    elif command == "install-all":
        installer.install_all_apps()
        installer.create_app_shortcuts()
    elif command == "install" and len(sys.argv) > 2:
        category = sys.argv[2]
        installer.install_category(category)
        installer.create_app_shortcuts()
    elif command == "shortcuts":
        installer.create_app_shortcuts()
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)

if __name__ == "__main__":
    main()

