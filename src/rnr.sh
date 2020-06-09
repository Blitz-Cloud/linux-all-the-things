#!/bin/bash
#set -e

#echo "rnr $@" >>/tmp/rnr.log
#env >>/tmp/rnr.log

#echo "jakdajbirojekwlfnedkwanvdksapbnjiroe"

# Workaround for running as udev
export DISPLAY=:0
export XAUTHORITY=/home/david/.Xauthority

#xrandr 2>&1 >>/tmp/rnr.log

LAPTOP=eDP-1-1
THUNDERBOLT=DP-4
DISPLAYPORT=DP-3
HDMI=DP-1

SDDM=
DEBOUNCE=

function init()
{
    xrandr --newmode "3200x1800_60.00"  492.00  3200 3456 3800 4400  1800 1803 1808 1865 -hsync +vsync
    xrandr --addmode $LAPTOP 3200x1800_60.00

    xrandr --newmode "2880x1620_60.00"  396.25  2880 3096 3408 3936  1620 1623 1628 1679 -hsync +vsync
    xrandr --addmode $LAPTOP 2880x1620_60.00

    xrandr --newmode "2200x1234_60.00"  227.75  2200 2352 2584 2968  1234 1237 1247 1280 -hsync +vsync
    xrandr --addmode $LAPTOP 2200x1234_60.00
}

function nvidiaDisableAllTransforms()
{
    # Prevents RRSetScreenSize error later on
    xrandr \
        --output $THUNDERBOLT --transform none \
        --output $DISPLAYPORT --transform none \
        --output $HDMI --transform none \
        --output $LAPTOP --transform none || true
}

function nvidiaUHDMobileProfile()
{
    #nvidiaDisableAllTransforms

    echo "Before xrandr"
    #xrandr --fb 3840x2160 \
    xrandr \
        --output $THUNDERBOLT --off \
        --output $DISPLAYPORT --off \
        --output $HDMI --off \
        --output $LAPTOP --mode 3200x1800_60.00 --pos 0x0 --primary

    echo "After xrandr"
}

function nvidiaFHDMobileProfile()
{
    #nvidiaDisableAllTransforms

    for i in {1..3}; do
        xrandr --output $LAPTOP --mode 2200x1234_60.00 && break || sleep 5
    done

    for i in {1..3}; do
        xrandr \
            --output $THUNDERBOLT --off \
            --output $DISPLAYPORT --off \
            --output $HDMI --off \
            --output $LAPTOP --mode 2200x1234_60.00 --pos 0x0 --primary \
            && break || sleep 5
    done
}

function nvidiaUHDWorkProfile()
{
    #nvidiaDisableAllTransforms

    # 4/3 scaling, combined with 200% global DPI equals 150%
    #xrandr --fb 10240x5040 \
    #    --output $THUNDERBOLT --mode 3840x2160 --scale-from 5120x2880 --pos 0x0 --panning 5120x2880+0+0 \
    #    --output $DISPLAYPORT --mode 3840x2160 --scale-from 5120x2880 --pos 5120x0 --panning 5120x2880+5120+0 --primary \
    #    --output $LAPTOP --mode 3840x2160 --transform none --pos 3200x2880 || true
    #xrandr --fb 10240x5040 \
    #    --output $THUNDERBOLT --mode 3840x2160 --scale-from 5120x2880 --pos 0x0 \
    #    --output $DISPLAYPORT --mode 3840x2160 --scale-from 5120x2880 --pos 5120x0 --primary \
    #    --output $LAPTOP --mode 3840x2160 --transform none --pos 3200x2880 || true

    # 3/4 scaling of laptop monitor (2880x1620)
    #xrandr --fb 7680x3780 \
    #xrandr \
    #    --output $THUNDERBOLT --mode 3840x2160 --pos 0x0 \
    #    --output $DISPLAYPORT --mode 3840x2160 --pos 3840x0 --primary \
    #    --output $LAPTOP --mode 2880x1620 --pos 2400x2160 || true

    if [ "$SDDM" == "1" ]; then
        for i in {1..3}; do
            xrandr \
                --output $THUNDERBOLT --mode 3840x2160 --pos 0x0 \
                --output $DISPLAYPORT --mode 3840x2160 --pos 0x0 --primary \
                --output $LAPTOP --mode 3840x2160 --transform none --pos 0x0 \
                --output $HDMI --off \
                && break || sleep 5
        done
    else
        #for i in {1..3}; do
        #    xrandr \
        #        --output $THUNDERBOLT --mode 3840x2160 --pos 0x0 --panning 3840x2160+0+0 --primary \
        #        --output $LAPTOP --off \
        #        --output $DISPLAYPORT --off \
        #        --output $HDMI --off \
        #        && break || sleep 5
        #done
        #sleep 5
        #for i in {1..3}; do
        #    xrandr \
        #        --output $DISPLAYPORT --mode 3840x2160 --pos 3840x0 --panning 3840x2160+3840+0 \
        #        && break || sleep 5
        #done
        #sleep 5
        #for i in {1..3}; do
        #    xrandr \
        #        --output $DISPLAYPORT --primary \
        #        && break || sleep 5
        #done
        #sleep 5
        #for i in {1..3}; do
        #    xrandr \
        #        --output $LAPTOP --mode 2880x1620_60.00 --pos 2400x2160 \
        #        && break || sleep 5
        #done
        for i in {1..3}; do
            xrandr \
                --output $THUNDERBOLT --mode 3840x2160 --pos 0x0 --panning 3840x2160+0+0 \
                --output $DISPLAYPORT --mode 3840x2160 --pos 3840x0 --panning 3840x2160+3840+0 --primary \
                --output $LAPTOP --off \
                --output $HDMI --off \
                && break || sleep 5
        done
        sleep 5
        for i in {1..3}; do
            xrandr \
                --output $THUNDERBOLT --mode 3840x2160 --pos 0x0 --panning 3840x2160+0+0 \
                --output $DISPLAYPORT --mode 3840x2160 --pos 3840x0 --panning 3840x2160+3840+0 --primary \
                --output $LAPTOP --mode 2880x1620_60.00 --pos 2400x2160 \
                --output $HDMI --off \
                && break || sleep 5
        done
    fi

    #kquitapp5 plasmashell >/dev/null 2>&1
    #sleep 3
    #kstart5 plasmashell >/dev/null 2>&1
}

function nvidiaWorkNotScaledProfile()
{
    xrandr \
        --output $THUNDERBOLT --mode 3840x2160 --transform none --pos 0x0 \
        --output $DISPLAYPORT --mode 3840x2160 --transform none --pos 3840x0 --primary \
        --output $LAPTOP --mode 3840x2160 --transform none --pos 1920x2160 \
        --output $HDMI --off
}

function nvidiaHomeNotScaledProfile()
{
    xrandr \
        --output $DISPLAYPORT --mode 1920x1200 --transform none --pos 0x0 \
        --output $HDMI --mode 1920x1200 --transform none --pos 1920x0 --primary \
        --output $LAPTOP --mode 3840x2160 --transform none --pos 0x1200 \
        --output $THUNDERBOLT --off
}

function nvidiaHomeProfile()
{
    xrandr \
        --output $DISPLAYPORT --mode 1920x1200 --scale-from 3840x2400 --pos 0x0 \
        --output $HDMI --mode 1920x1200 --scale-from 3840x2400 --pos 3840x0 --primary \
        --output $LAPTOP --mode 2880x1620 --transform none --pos 2400x2400 \
        --output $THUNDERBOLT --off
}

function nvidiaFHDHomeProfile()
{
    if [ "$SDDM" == "1" ]; then
        for i in {1..3}; do
            xrandr \
                --output $DISPLAYPORT --mode 1920x1200 --pos 0x0 \
                --output $HDMI --mode 1920x1200 --pos 0x0 --primary \
                --output $LAPTOP --mode 1920x1080 --transform none --pos 0x120 \
                --output $THUNDERBOLT --off \
                && break || sleep 5
        done
    else
        for i in {1..3}; do
            xrandr \
                --output $DISPLAYPORT --mode 1920x1200 --pos 0x0 \
                --output $HDMI --mode 1920x1200 --pos 1920x0 --primary \
                --output $LAPTOP --mode 1440x810 --rate 60 --transform none --pos 1200x1200 \
                --output $THUNDERBOLT --off \
                && break || sleep 5
        done
    fi

    #for i in {1..3}; do
    #    xrandr \
    #        --output $DISPLAYPORT --mode 1920x1200 --pos 0x0 \
    #        --output $LAPTOP --off \
    #        --output $HDMI --off \
    #        --output $THUNDERBOLT --off \
    #        && break || sleep 5
    #done
    #sleep 5
    #for i in {1..3}; do
    #    xrandr \
    #        --output $HDMI --mode 1920x1200 --pos 1920x0 --primary \
    #        && break || sleep 5
    #done
    #sleep 5
    #for i in {1..3}; do
    #    xrandr \
    #        --output $LAPTOP --mode 1440x810 --rate 60 --pos 1200x1200 \
    #        && break || sleep 5
    #done
}

# If running from udev rule, fork and run in separate process
if [ "$HOTPLUG" == "1" ]; then
    if [ ! -e /tmp/rnr.lock ]; then
        touch /tmp/rnr.lock
        #( ( HOTPLUG= "${BASH_SOURCE[0]}" debounce ) >>/tmp/rnr.log 2>&1 ) &
        #disown
        #HOTPLUG= "${BASH_SOURCE[0]}" debounce >>/tmp/rnr.log 2>&1

        #setsid bash -c "HOTPLUG= \"${BASH_SOURCE[0]}\" debounce >>/tmp/rnr.log 2>&1" &
    fi
    exit
fi

PROFILE=$1

if [ "$PROFILE" == "" ]; then
    PROFILE=auto
fi

if [ "$PROFILE" == "debounce" ]; then
    DEBOUNCE=1
    PROFILE=auto
fi

if [ "$PROFILE" == "sddm" ]; then
    SDDM=1
    PROFILE=auto
fi

if [ "$PROFILE" == "auto" ]; then
    PROFILE=
    MONITORS=$(xrandr --query | grep '\bconnected\b' | awk '{print $1}')
    NL=$'\n'
    if [ "$MONITORS" == "$LAPTOP" ]; then PROFILE=mobile; fi
    if [ "$MONITORS" == "$HDMI$NL$DISPLAYPORT$NL$LAPTOP" ]; then PROFILE=home; fi
    if [ "$MONITORS" == "$DISPLAYPORT$NL$THUNDERBOLT$NL$LAPTOP" ]; then PROFILE=home; fi

    if [ "$PROFILE" == "" ]; then
        echo "Could not detect profile!"
    else
        echo "Detected profile: $PROFILE"

        if [ "$DEBOUNCE" == "1" ]; then
            echo "Debouncing"
            sleep 5
        fi
    fi
fi

case $PROFILE in

    init)
        init
        ;;

    mobile)
        #nvidiaFHDMobileProfile
        nvidiaUHDMobileProfile
        ;;

    work)
        #echo "Not supported yet for FHD!"
        nvidiaUHDWorkProfile
        ;;

    home)
        #nvidiaFHDHomeProfile
        nvidiaUHDWorkProfile
        ;;

esac

if [ "$DEBOUNCE" == "1" ]; then
    if [ "$PROFILE" != "" ]; then
        sleep 5
        echo "Debounced"
    fi
    rm -f /tmp/rnr.lock
fi
