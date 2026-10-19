FROM i.anatase.org/base:rolling

RUN dnf -y --setopt=install_weak_deps=False install \
    niri \
    noctalia \
    kitty \
    xwayland-satellite \
    brightnessctl \
    playerctl \
    greetd \
    Thunar \
    thunar-media-tags-plugin \
    thunar-volman \
    tumbler \
    oo7-daemon \
    oo7-portal \
    pam_oo7 \
    gvfs \
    gvfs-afc \
    gvfs-fuse \
    gvfs-gphoto2 \
    gvfs-mtp \
    gvfs-smb \
    network-manager-applet \
    nm-connection-editor \
    nm-connection-editor-desktop \
    NetworkManager-libreswan-gnome \
    NetworkManager-openconnect-gnome \
    NetworkManager-openvpn-gnome \
    NetworkManager-ppp \
    NetworkManager-ssh-gnome \
    xdg-desktop-portal-gtk \
    xdg-user-dirs-gtk \
    && dnf clean all

RUN . /etc/os-release && \
    dnf -y copr enable lionheartp/Hyprland "fedora-${VERSION_ID}-$(arch)" && \
    dnf -y install noctalia-greeter-git && \
    dnf clean all

RUN systemctl enable greetd.service && \
    systemctl set-default graphical.target

// Copy and run Noctali-greeter to niri
COPY config/greetd/config.toml /etc/greetd/config.toml

// Creates a systemwide config for Niri and start Noctalia
COPY config/niri/config.kdl /etc/niri/config.kdl

# Cleanup (leave this here)
RUN rm -rf /var && \
    mkdir -p /var/tmp
