#!/bin/bash

#SOURCE="${SOURCE:-`pacmd list-sources | grep -E -i '\* index:' | sed -E 's/^[^0-9]*([0-9]*).*$/\1/'`}"
#SINK="${SINK:-`pacmd list-sinks | grep -E -i '\* index:' | sed -E 's/^[^0-9]*([0-9]*).*$/\1/'`}"

HEADSET_MIC=alsa_input.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.mono-fallback
HEADSET_OUT=alsa_output.usb-C-Media_Electronics_Inc._USB_Audio_Device-00.analog-stereo
SOURCE="${SOURCE:-$HEADSET_MIC}"
SINK="${SINK:-$HEADSET_OUT}"

WEBRTC_SINK=voice_webrtc
WEBRTC_SOURCE=voice_webrtc_source
GATE_SINK=voice_gate
GATE_SOURCE=voice_gate.monitor
FINAL_SINK=voice_final
FINAL_MONITOR=voice_final.monitor
FINAL_SOURCE=voice_final_source

function setup {
    pactl load-module module-echo-cancel \
        use_master_format=1 \
        source_master=$SOURCE \
        sink_master=$SINK \
        aec_method=webrtc \
        aec_args="analog_gain_control=0\ digital_gain_control=1" \
        source_name=$WEBRTC_SOURCE \
        sink_name=$WEBRTC_SINK \
        sink_properties='device.description="Voice\ WebRTC\ Speaker"' \
        source_properties='device.description="Voice\ WebRTC\ Mic"'

    pactl set-default-sink $WEBRTC_SINK

    pactl load-module module-null-sink \
        sink_name=$FINAL_SINK \
        sink_properties='device.description="Voice\ Final"'

    # Gate control parameters:
    # 0. LF key filter (Hz) - Controls the cutoff of the low frequency filter (highpass).
    # 1. HF key filter (Hz) - Controls the cutoff of the high frequency filter (lowpass).
    # 2. Threshold (dB) - Controls the level at which the gate will open.
    # 3. Attack (ms) - Controls the time the gate will take to open fully.
    # 4. Hold (ms) - Controls the minimum time the gate will stay open for.
    # 5. Decay (ms) - Controls the time the gate will take to close fully.
    # 6. Range (dB) - Controls the difference between the gate's open and closed state.
    # 7. Output select (-1 = key listen, 0 = gate, 1 = bypass) - Controls output monitor. -1 is the output of the key filters (so you can check what is being gated on). 0 is the normal, gated output. 1 is bypass mode. 
    pactl load-module module-ladspa-sink \
        sink_name=$GATE_SINK \
        sink_master=$FINAL_SINK \
        plugin=gate_1410 \
        label=gate \
        control=500,4000,-42,25,75,250,-90,0 \
        sink_properties='device.description="Voice\ Gate"'

    pactl load-module module-loopback \
        source=$WEBRTC_SOURCE \
        sink=$GATE_SINK \
        source_dont_move=true \
        sink_dont_move=true \
        latency_msec=1

    pactl load-module module-virtual-source \
        source_name=$FINAL_SOURCE \
        source_properties='device.description="Voice\ Final\ Mic"' \
        master=$FINAL_MONITOR

    pactl set-default-source $FINAL_SOURCE

    if [ "$MONITOR" == "1" ]; then
        pactl load-module module-loopback \
            source=$FINAL_SOURCE \
            sink=$SINK \
            source_dont_move=true \
            sink_dont_move=true \
            latency_msec=1
    fi
}

function cleanup {
    MODULES=$(pactl list short modules | grep -E '^[0-9]+\s+module-(echo-cancel|(null-sink|ladspa-sink|virtual-source)\s+(sink|source)_name=voice_)' | sed -E 's/^([0-9]+).*$/\1/')

    while read MODULE; do
        if [ "$MODULE" != "" ]; then
            pactl unload-module $MODULE
        fi
    done <<<"$MODULES"

    #pactl set-default-source $SOURCE
    #pactl set-default-sink $SINK
}

ACTION=$1
if [ "$ACTION" == "" ]; then
    ACTION=setup
fi

case $ACTION in

    setup)
        setup
        ;;

    cleanup)
        cleanup
        ;;

    *)
        echo "Unrecognized action: $ACTION" >&2
        exit 1
        ;;

esac