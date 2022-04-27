# Elgato FaceCam for Linux
Elgato FaceCam on-demand driver for linux
Not a driver actually. It is a daemon which monitors activity on virtual camera. And switch camera ON and OFF accordingly

# Requirements
v4l2loopback and v4l2-ctl  should be installed. Please read the manual for v4l2loopback.

```
sudo apt install v4l-utils v4l2loopback-dkms

