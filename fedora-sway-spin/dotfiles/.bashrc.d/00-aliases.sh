alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
alias ap='ansible-playbook'

alias myip='printf "external: " && curl ifconfig.me && echo && printf "local: " && hostname -I'

alias google-chrome="/usr/bin/google-chrome --use-gl=angle --use-angle=gles-egl --disable-background-networking --ozone-platform=wayland --enable-wayland-ime --use-cmd-decoder=passthrough --ignore-gpu-blocklist --ignore-gpu-blacklist --enable-accelerated-video-decode --enable-features=VaapiVideoDecoder,VaapiVideoEncoder --gtk-version=4 --disable-gpu-memory-buffer-video-frames"
alias chromium="/usr/bin/chromium --use-gl=angle --use-angle=gles-egl --disable-background-networking --ozone-platform=wayland --enable-wayland-ime --use-cmd-decoder=passthrough --ignore-gpu-blocklist --ignore-gpu-blacklist --enable-accelerated-video-decode --enable-features=VaapiVideoDecoder,VaapiVideoEncoder --gtk-version=4 --disable-gpu-memory-buffer-video-frames"

# (gl=egl-angle,angle=opengl)
# (gl=egl-angle,angle=opengles)
# (gl=egl-angle,angle=vulkan)
# (gl=egl-angle,angle=swiftshader)
