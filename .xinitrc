# export XDG_RUNTIME_DIR=/run/user/$(id -u)
# mkdir -p $XDG_RUNTIME_DIR
# chmod 700 $XDG_RUNTIME_DIR

xrandr --newmode "1920x1080_60.00" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync
xrandr --addmode Virtual-1 "1920x1080_60.00"
xrandr --output Virtual-1 --mode "1920x1080_60.00" --dpi 112

exec dbus-run-session awesome

