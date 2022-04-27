# Elgato FaceCam for Linux
Elgato FaceCam on-demand driver for linux.

Not a driver actually. 

It is a daemon which monitors activity on virtual camera. And switch camera ON and OFF accordingly

# Requirements
v4l2loopback and v4l2-ctl  should be installed. Please read the manual for v4l2loopback.

```
sudo apt install v4l-utils v4l2loopback-dkms
```

Also you need to have some placeholder video: *placeholder.mp4*. For example you can create one using ffmpeg
```
ffmpeg -f lavfi -i color=size=1280x720:rate=25:color=black -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -t 10 output.mp4
ffmpeg -i output.mp4 -map 0:v -c copy placeholder.mp4
```
