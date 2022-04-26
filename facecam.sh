#!/bin/bash

# The following lines re-establish the USB connection to the camera
# since occassionally the camera needs to be reconnected for ffmpeg
set -euo pipefail
IFS=$'\n\t'

# Replace it with your. check it by the following command
# ls /dev/v4l/by-id/
FACECAM="/dev/v4l/by-id/usb-Elgato_Elgato_Facecam_FW21K1A16088-video-index0"

# Placeholder video. replace it with yours.
# For some reason image wont not work
PLACEHOLDER="/home/fu2re/facecam/vhs.webm"

# Get these values from `lsusb`
VENDOR="0fd9" # Elgato Vendor
PRODUCT="0078" # Facecam ID

LABEL="Elagto FaceCam"
DEV=11
POLL_INTERVAL=1
TIMEOUT=5
INUSE=1
PATTERN="(ffmpeg.*-f v4l2)"

if ! [[ $(lsusb | grep $VENDOR:$PRODUCT) ]]; then
  exit 0
fi

function get_cam () {
  FACECAM_ID=$(ls /dev/v4l/by-id/ | grep -i -E "facecam.+index0")
  echo $FACECAM_ID
}

if ! [[ $(get_cam) ]]; then
  echo "Init camera seq"
  for DIR in $(find /sys/bus/usb/devices/ -maxdepth 1 -type l); do
    if [[ -f $DIR/idVendor && -f $DIR/idProduct &&
          $(cat $DIR/idVendor) == $VENDOR && $(cat $DIR/idProduct) == $PRODUCT ]]; then
      echo 0 | sudo tee -a $DIR/authorized > /dev/null
      sleep 0.5
      echo 1 | sudo tee -a $DIR/authorized > /dev/null
    fi
  done
fi

FACECAM=/dev/v4l/by-id/$(get_cam)

function stop () {
  if [[ $(ps aux | grep -E $PATTERN | grep -v grep) ]]; then
    ps aux | grep -E $PATTERN | grep -v grep | awk {'print $2'} | xargs kill
  fi
}


function unload_module () {
  while (( 1 == 1 ))
  do
    { # try
      sudo modprobe -r v4l2loopback
      break
    } || { # catch
      sleep 0.3
    }
  done
}


function reload_module () {
  stop
  unload_module
  sudo modprobe v4l2loopback video_nr=$DEV card_label=$LABEL exclusive_caps=1
  v4l2-ctl -d $FACECAM
}


# Check if nobody read stram for timeout - stop it.
while [[ $(echo 1) ]]
do
  sleep $POLL_INTERVAL
  if [[ $(lsof /dev/video$DEV | grep /dev/video$DEV | grep -v ffmpeg) ]]
  then
    if (( INUSE == 0 )); then
      echo "stream ON"
      reload_module
      ffmpeg -f v4l2 -input_format uyvy422 -framerate 60 -video_size 1920x1080 -i $FACECAM -pix_fmt yuyv422 -f v4l2 /dev/video$DEV -loglevel quiet &
      INUSE=1
    fi
  elif (( INUSE == 1 )); then
     sleep $TIMEOUT
     if ! [[ $(lsof /dev/video$DEV | grep /dev/video$DEV | grep -v ffmpeg) ]]; then
       echo "stream OFF"
       reload_module
       ffmpeg -stream_loop -1 -re -i $PLACEHOLDER -map 0:v -f v4l2 -input_format uyvy422 -framerate 60 -video_size 1920x1080 -pix_fmt yuyv422 /dev/video$DEV -loglevel quiet &
       INUSE=0
     fi
  fi
  sleep 1
done
