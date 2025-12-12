#!/usr/bin/env bash

# Stylus Support Module - Advanced stylus and pen input support
# Provides pressure sensitivity, palm rejection, and drawing capabilities

MODULE_NAME="stylus-support"
MODULE_VERSION="1.0.0"
MODULE_DESCRIPTION="Advanced stylus and pen input support with pressure sensitivity"

source "$(dirname "${BASH_SOURCE[0]}")/../tablet-build.sh"

apply_stylus_support() {
    local build_dir="$1"
    local chromeos_dir="$build_dir/chromeos"
    
    log_info "Applying stylus support optimizations..."
    
    # Create stylus configuration directory
    mkdir -p "$build_dir/tablet-mods/stylus"
    
    # Create stylus configuration file
    cat > "$build_dir/tablet-mods/stylus/stylus-config.json" << 'EOF'
{
    "stylus_settings": {
        "pressure_sensitivity": true,
        "tilt_support": true,
        "palm_rejection": true,
        "hover_detection": true,
        "button_support": true,
        "eraser_support": true
    },
    "pressure_curves": {
        "light": {
            "min_pressure": 0.1,
            "max_pressure": 0.7,
            "curve_type": "linear"
        },
        "medium": {
            "min_pressure": 0.2,
            "max_pressure": 0.8,
            "curve_type": "quadratic"
        },
        "firm": {
            "min_pressure": 0.3,
            "max_pressure": 1.0,
            "curve_type": "cubic"
        }
    },
    "palm_rejection": {
        "enabled": true,
        "sensitivity": "high",
        "timeout_ms": 100,
        "size_threshold": 15
    },
    "drawing_modes": {
        "precision": {
            "smoothing": 0.2,
            "prediction": true,
            "stabilization": true
        },
        "artistic": {
            "smoothing": 0.5,
            "prediction": false,
            "stabilization": false
        },
        "writing": {
            "smoothing": 0.1,
            "prediction": true,
            "stabilization": true
        }
    }
}
EOF

    # Create stylus driver configuration
    cat > "$build_dir/tablet-mods/stylus/stylus-driver.conf" << 'EOF'
# Stylus Driver Configuration for ChromeOS Tablets

# Input device settings
Section "InputDevice"
    Identifier "Stylus"
    Driver "wacom"
    Option "Type" "stylus"
    Option "Device" "/dev/input/wacom"
    Option "USB" "on"
    Option "Pressure" "on"
    Option "Tilt" "on"
    Option "Wheel" "on"
    Option "Touch" "off"
EndSection

Section "InputDevice"
    Identifier "Eraser"
    Driver "wacom"
    Option "Type" "eraser"
    Option "Device" "/dev/input/wacom"
    Option "USB" "on"
    Option "Pressure" "on"
    Option "Tilt" "on"
EndSection

Section "InputDevice"
    Identifier "Cursor"
    Driver "wacom"
    Option "Type" "cursor"
    Option "Device" "/dev/input/wacom"
    Option "USB" "on"
EndSection

# Pressure sensitivity settings
Section "InputClass"
    Identifier "Stylus Pressure"
    MatchProduct "Wacom|HUION|XP-Pen|Gaomon"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "PressureCurve" "0 10 90 100"
    Option "Threshold" "27"
    Option "Suppress" "2"
    Option "RawSample" "4"
EndSection

# Palm rejection settings
Section "InputClass"
    Identifier "Palm Rejection"
    MatchIsTouchscreen "on"
    Driver "libinput"
    Option "PalmDetection" "on"
    Option "PalmMinWidth" "8"
    Option "PalmMinZ" "100"
EndSection
EOF

    # Create stylus calibration script
    cat > "$build_dir/tablet-mods/stylus/calibrate-stylus.sh" << 'EOF'
#!/bin/bash

# Stylus Calibration Script for ChromeOS Tablets

STYLUS_CONFIG_DIR="/etc/stylus"
CALIBRATION_FILE="$STYLUS_CONFIG_DIR/calibration.conf"

# Create configuration directory
mkdir -p "$STYLUS_CONFIG_DIR"

# Detect stylus devices
detect_stylus_devices() {
    echo "Detecting stylus devices..."
    
    # Find Wacom devices
    WACOM_DEVICES=$(lsusb | grep -i wacom | wc -l)
    if [ $WACOM_DEVICES -gt 0 ]; then
        echo "Found Wacom stylus device(s)"
        STYLUS_TYPE="wacom"
    fi
    
    # Find other stylus devices
    HUION_DEVICES=$(lsusb | grep -i huion | wc -l)
    if [ $HUION_DEVICES -gt 0 ]; then
        echo "Found HUION stylus device(s)"
        STYLUS_TYPE="huion"
    fi
    
    # Find XP-Pen devices
    XPPEN_DEVICES=$(lsusb | grep -i "xp-pen\|pentablet" | wc -l)
    if [ $XPPEN_DEVICES -gt 0 ]; then
        echo "Found XP-Pen stylus device(s)"
        STYLUS_TYPE="xppen"
    fi
    
    if [ -z "$STYLUS_TYPE" ]; then
        echo "No supported stylus devices found"
        STYLUS_TYPE="generic"
    fi
}

# Configure stylus based on device type
configure_stylus() {
    echo "Configuring stylus for $STYLUS_TYPE..."
    
    case $STYLUS_TYPE in
        "wacom")
            configure_wacom_stylus
            ;;
        "huion")
            configure_huion_stylus
            ;;
        "xppen")
            configure_xppen_stylus
            ;;
        "generic")
            configure_generic_stylus
            ;;
    esac
}

configure_wacom_stylus() {
    cat > "$CALIBRATION_FILE" << 'WACOMEOF'
# Wacom Stylus Configuration
stylus_type=wacom
pressure_levels=8192
tilt_support=true
rotation_support=true
buttons=2
eraser_support=true

# Pressure curve (0-100 for each point)
pressure_curve="0 10 90 100"

# Area mapping (left top right bottom)
area_mapping="0 0 100 100"

# Button mapping
button1_action="right_click"
button2_action="middle_click"
WACOMEOF
}

configure_huion_stylus() {
    cat > "$CALIBRATION_FILE" << 'HUIONEOF'
# HUION Stylus Configuration
stylus_type=huion
pressure_levels=8192
tilt_support=true
rotation_support=false
buttons=2
eraser_support=true

# Pressure curve
pressure_curve="5 15 85 95"

# Area mapping
area_mapping="0 0 100 100"

# Button mapping
button1_action="right_click"
button2_action="eraser_toggle"
HUIONEOF
}

configure_xppen_stylus() {
    cat > "$CALIBRATION_FILE" << 'XPPENEOF'
# XP-Pen Stylus Configuration
stylus_type=xppen
pressure_levels=8192
tilt_support=true
rotation_support=false
buttons=2
eraser_support=true

# Pressure curve
pressure_curve="3 12 88 97"

# Area mapping
area_mapping="0 0 100 100"

# Button mapping
button1_action="right_click"
button2_action="middle_click"
XPPENEOF
}

configure_generic_stylus() {
    cat > "$CALIBRATION_FILE" << 'GENERICEOF'
# Generic Stylus Configuration
stylus_type=generic
pressure_levels=1024
tilt_support=false
rotation_support=false
buttons=1
eraser_support=false

# Pressure curve
pressure_curve="0 25 75 100"

# Area mapping
area_mapping="0 0 100 100"

# Button mapping
button1_action="right_click"
GENERICEOF
}

# Apply stylus settings
apply_stylus_settings() {
    echo "Applying stylus settings..."
    
    # Load configuration
    source "$CALIBRATION_FILE"
    
    # Set pressure curve if device supports it
    if command -v xsetwacom &> /dev/null; then
        STYLUS_ID=$(xsetwacom --list devices | grep -i stylus | head -1 | cut -d: -f2 | cut -d$'\t' -f1)
        if [ -n "$STYLUS_ID" ]; then
            xsetwacom --set "$STYLUS_ID" PressureCurve $pressure_curve
            echo "Pressure curve applied: $pressure_curve"
        fi
    fi
    
    # Configure palm rejection
    if command -v xinput &> /dev/null; then
        TOUCH_ID=$(xinput list | grep -i touch | head -1 | grep -o 'id=[0-9]*' | cut -d= -f2)
        if [ -n "$TOUCH_ID" ]; then
            xinput set-prop "$TOUCH_ID" "libinput Palm Detection Enabled" 1
            echo "Palm rejection enabled for touch device $TOUCH_ID"
        fi
    fi
}

# Test stylus functionality
test_stylus() {
    echo "Testing stylus functionality..."
    
    # Create a simple test script
    cat > /tmp/stylus-test.py << 'TESTEOF'
#!/usr/bin/env python3
import tkinter as tk
from tkinter import Canvas
import sys

class StylusTest:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Stylus Test - Draw to test pressure and palm rejection")
        self.root.geometry("800x600")
        
        self.canvas = Canvas(self.root, bg='white', width=800, height=600)
        self.canvas.pack()
        
        self.canvas.bind('<Button-1>', self.start_draw)
        self.canvas.bind('<B1-Motion>', self.draw)
        self.canvas.bind('<ButtonRelease-1>', self.stop_draw)
        
        self.last_x = None
        self.last_y = None
        
        # Instructions
        instructions = tk.Label(self.root, text="Draw with your stylus. Test pressure sensitivity and palm rejection.")
        instructions.pack()
        
        quit_btn = tk.Button(self.root, text="Quit", command=self.root.quit)
        quit_btn.pack()
    
    def start_draw(self, event):
        self.last_x = event.x
        self.last_y = event.y
    
    def draw(self, event):
        if self.last_x and self.last_y:
            # Simulate pressure-based line width (would need actual pressure data)
            width = 3
            self.canvas.create_line(self.last_x, self.last_y, event.x, event.y, 
                                  width=width, fill='black', capstyle=tk.ROUND, smooth=tk.TRUE)
        self.last_x = event.x
        self.last_y = event.y
    
    def stop_draw(self, event):
        self.last_x = None
        self.last_y = None
    
    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    test = StylusTest()
    test.run()
TESTEOF

    python3 /tmp/stylus-test.py &
    echo "Stylus test application launched. Draw to test functionality."
}

# Main execution
main() {
    echo "Starting stylus calibration and configuration..."
    detect_stylus_devices
    configure_stylus
    apply_stylus_settings
    
    echo "Stylus configuration completed!"
    echo "Configuration saved to: $CALIBRATION_FILE"
    echo ""
    echo "To test your stylus, run: $0 test"
}

# Handle command line arguments
case "${1:-}" in
    "test")
        test_stylus
        ;;
    *)
        main
        ;;
esac
EOF

    chmod +x "$build_dir/tablet-mods/stylus/calibrate-stylus.sh"
    
    # Create stylus-aware drawing application
    cat > "$build_dir/tablet-mods/stylus/drawing-app.py" << 'EOF'
#!/usr/bin/env python3

"""
Advanced Drawing Application with Stylus Support
Demonstrates pressure sensitivity, tilt, and palm rejection
"""

import tkinter as tk
from tkinter import ttk, colorchooser, filedialog, messagebox
import json
import math
import os

class AdvancedDrawingApp:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("ChromeOS Tablet Drawing App")
        self.root.geometry("1200x800")
        
        # Drawing state
        self.drawing = False
        self.last_x = None
        self.last_y = None
        self.current_tool = "brush"
        self.brush_size = 5
        self.brush_color = "#000000"
        self.pressure_sensitivity = True
        self.palm_rejection = True
        
        # Stylus state
        self.stylus_pressure = 1.0
        self.stylus_tilt_x = 0.0
        self.stylus_tilt_y = 0.0
        
        self.setup_ui()
        self.setup_bindings()
        
    def setup_ui(self):
        # Main frame
        main_frame = ttk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Toolbar
        toolbar = ttk.Frame(main_frame)
        toolbar.pack(side=tk.TOP, fill=tk.X, padx=5, pady=5)
        
        # Tool buttons
        ttk.Button(toolbar, text="Brush", command=lambda: self.set_tool("brush")).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Pen", command=lambda: self.set_tool("pen")).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Pencil", command=lambda: self.set_tool("pencil")).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Eraser", command=lambda: self.set_tool("eraser")).pack(side=tk.LEFT, padx=2)
        
        ttk.Separator(toolbar, orient=tk.VERTICAL).pack(side=tk.LEFT, padx=10, fill=tk.Y)
        
        # Size control
        ttk.Label(toolbar, text="Size:").pack(side=tk.LEFT, padx=2)
        self.size_var = tk.IntVar(value=self.brush_size)
        size_scale = ttk.Scale(toolbar, from_=1, to=50, variable=self.size_var, 
                              orient=tk.HORIZONTAL, length=100,
                              command=self.update_brush_size)
        size_scale.pack(side=tk.LEFT, padx=2)
        
        # Color button
        self.color_btn = tk.Button(toolbar, text="Color", bg=self.brush_color,
                                  command=self.choose_color, width=8)
        self.color_btn.pack(side=tk.LEFT, padx=5)
        
        ttk.Separator(toolbar, orient=tk.VERTICAL).pack(side=tk.LEFT, padx=10, fill=tk.Y)
        
        # Stylus options
        self.pressure_var = tk.BooleanVar(value=self.pressure_sensitivity)
        ttk.Checkbutton(toolbar, text="Pressure", variable=self.pressure_var,
                       command=self.toggle_pressure).pack(side=tk.LEFT, padx=2)
        
        self.palm_var = tk.BooleanVar(value=self.palm_rejection)
        ttk.Checkbutton(toolbar, text="Palm Rejection", variable=self.palm_var,
                       command=self.toggle_palm_rejection).pack(side=tk.LEFT, padx=2)
        
        ttk.Separator(toolbar, orient=tk.VERTICAL).pack(side=tk.LEFT, padx=10, fill=tk.Y)
        
        # File operations
        ttk.Button(toolbar, text="Clear", command=self.clear_canvas).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Save", command=self.save_drawing).pack(side=tk.LEFT, padx=2)
        ttk.Button(toolbar, text="Load", command=self.load_drawing).pack(side=tk.LEFT, padx=2)
        
        # Canvas frame
        canvas_frame = ttk.Frame(main_frame)
        canvas_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Canvas with scrollbars
        self.canvas = tk.Canvas(canvas_frame, bg='white', cursor='crosshair')
        
        v_scrollbar = ttk.Scrollbar(canvas_frame, orient=tk.VERTICAL, command=self.canvas.yview)
        h_scrollbar = ttk.Scrollbar(canvas_frame, orient=tk.HORIZONTAL, command=self.canvas.xview)
        
        self.canvas.configure(yscrollcommand=v_scrollbar.set, xscrollcommand=h_scrollbar.set)
        self.canvas.configure(scrollregion=self.canvas.bbox("all"))
        
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        v_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        h_scrollbar.pack(side=tk.BOTTOM, fill=tk.X)
        
        # Status bar
        self.status_bar = ttk.Label(main_frame, text="Ready - Use stylus to draw")
        self.status_bar.pack(side=tk.BOTTOM, fill=tk.X, padx=5, pady=2)
        
    def setup_bindings(self):
        self.canvas.bind('<Button-1>', self.start_draw)
        self.canvas.bind('<B1-Motion>', self.draw)
        self.canvas.bind('<ButtonRelease-1>', self.stop_draw)
        self.canvas.bind('<Motion>', self.update_cursor_info)
        
        # Stylus-specific bindings (if supported)
        self.canvas.bind('<Button-2>', self.eraser_mode)  # Middle click for eraser
        self.canvas.bind('<Button-3>', self.context_menu)  # Right click for menu
        
    def set_tool(self, tool):
        self.current_tool = tool
        cursor_map = {
            "brush": "dotbox",
            "pen": "pencil",
            "pencil": "pencil",
            "eraser": "dotbox"
        }
        self.canvas.configure(cursor=cursor_map.get(tool, "crosshair"))
        self.status_bar.configure(text=f"Tool: {tool.title()}")
        
    def update_brush_size(self, value):
        self.brush_size = int(float(value))
        
    def choose_color(self):
        color = colorchooser.askcolor(color=self.brush_color)[1]
        if color:
            self.brush_color = color
            self.color_btn.configure(bg=color)
            
    def toggle_pressure(self):
        self.pressure_sensitivity = self.pressure_var.get()
        
    def toggle_palm_rejection(self):
        self.palm_rejection = self.palm_var.get()
        
    def start_draw(self, event):
        if self.palm_rejection and self.is_palm_touch(event):
            return
            
        self.drawing = True
        self.last_x = event.x
        self.last_y = event.y
        
    def draw(self, event):
        if not self.drawing or (self.palm_rejection and self.is_palm_touch(event)):
            return
            
        if self.last_x and self.last_y:
            # Calculate pressure-based line width
            if self.pressure_sensitivity:
                # Simulate pressure (in real implementation, get from stylus)
                pressure = self.get_stylus_pressure(event)
                line_width = max(1, int(self.brush_size * pressure))
            else:
                line_width = self.brush_size
                
            # Draw based on current tool
            if self.current_tool == "eraser":
                self.canvas.create_line(self.last_x, self.last_y, event.x, event.y,
                                      width=line_width * 2, fill=self.canvas['bg'],
                                      capstyle=tk.ROUND, smooth=tk.TRUE)
            else:
                color = self.brush_color
                if self.current_tool == "pencil":
                    # Pencil has variable opacity based on pressure
                    alpha = int(255 * (pressure if self.pressure_sensitivity else 0.7))
                    
                self.canvas.create_line(self.last_x, self.last_y, event.x, event.y,
                                      width=line_width, fill=color,
                                      capstyle=tk.ROUND, smooth=tk.TRUE)
                
        self.last_x = event.x
        self.last_y = event.y
        
    def stop_draw(self, event):
        self.drawing = False
        self.last_x = None
        self.last_y = None
        
    def is_palm_touch(self, event):
        # Simple palm rejection based on touch size (placeholder)
        # In real implementation, use actual touch data
        return False
        
    def get_stylus_pressure(self, event):
        # Placeholder for actual stylus pressure detection
        # In real implementation, get pressure from stylus input
        return 1.0
        
    def update_cursor_info(self, event):
        self.status_bar.configure(text=f"Tool: {self.current_tool.title()} | "
                                      f"Position: ({event.x}, {event.y}) | "
                                      f"Size: {self.brush_size}")
        
    def eraser_mode(self, event):
        self.set_tool("eraser")
        
    def context_menu(self, event):
        # Create context menu
        menu = tk.Menu(self.root, tearoff=0)
        menu.add_command(label="Brush", command=lambda: self.set_tool("brush"))
        menu.add_command(label="Pen", command=lambda: self.set_tool("pen"))
        menu.add_command(label="Pencil", command=lambda: self.set_tool("pencil"))
        menu.add_command(label="Eraser", command=lambda: self.set_tool("eraser"))
        menu.add_separator()
        menu.add_command(label="Clear Canvas", command=self.clear_canvas)
        
        try:
            menu.tk_popup(event.x_root, event.y_root)
        finally:
            menu.grab_release()
            
    def clear_canvas(self):
        if messagebox.askyesno("Clear Canvas", "Are you sure you want to clear the canvas?"):
            self.canvas.delete("all")
            
    def save_drawing(self):
        filename = filedialog.asksaveasfilename(
            defaultextension=".ps",
            filetypes=[("PostScript files", "*.ps"), ("All files", "*.*")]
        )
        if filename:
            self.canvas.postscript(file=filename)
            messagebox.showinfo("Saved", f"Drawing saved as {filename}")
            
    def load_drawing(self):
        # Placeholder for loading functionality
        messagebox.showinfo("Load", "Load functionality not implemented yet")
        
    def run(self):
        self.root.mainloop()

if __name__ == "__main__":
    app = AdvancedDrawingApp()
    app.run()
EOF

    chmod +x "$build_dir/tablet-mods/stylus/drawing-app.py"
    
    log_success "Stylus support module applied successfully"
}

# Export function for use by main build script
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f apply_stylus_support
fi

