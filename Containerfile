FROM i.anatase.org/base:rolling

# Niri + Noctalia
RUN . /etc/os-release && \
    dnf -y copr enable lionheartp/Hyprland "fedora-${VERSION_ID}-$(arch)"

RUN dnf -y --setopt=install_weak_deps=False install \
    niri \
    noctalia \
    kitty \
    xwayland-satellite \
    brightnessctl \
    playerctl \
    greetd \
    noctalia-greeter-git \
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

# Niri defaults adapted for Noctalia + Kitty
RUN install -d /etc/niri \
    && cp /usr/share/doc/niri/default-config.kdl /etc/niri/config.kdl \
    && sed -i \
        -e 's/spawn-at-startup "waybar"/spawn-at-startup "noctalia"/' \
        -e 's/Open a Terminal: alacritty/Open a Terminal: kitty/' \
        -e 's/spawn "alacritty"/spawn "kitty"/' \
        -e 's/Run an Application: fuzzel/Run Noctalia Launcher/' \
        -e 's/spawn "fuzzel"/spawn "noctalia" "msg" "panel-toggle" "launcher"/' \
        -e 's/Lock the Screen: swaylock/Lock the Screen: Noctalia/' \
        -e 's/spawn "swaylock"/spawn "noctalia" "msg" "session" "lock"/' \
        /etc/niri/config.kdl

# Lightweight login screen that starts Niri
RUN cat > /etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
command = "/usr/bin/noctalia-greeter-session -- --session niri"
user = "greetd"
EOF

RUN systemctl enable greetd.service \
    && systemctl set-default graphical.target

# Niri + Noctalia welcome guide
RUN install -d /usr/local/share/niri-anatase \
    && cat > /usr/local/share/niri-anatase/welcome <<'EOF'
#!/usr/bin/env bash

cat <<'WELCOME'

  NIRI + NOCTALIA — ANATASE
  =========================

  Welcome! Niri is your Wayland compositor.
  Noctalia provides the desktop shell and settings interface.

  GETTING STARTED
  ---------------

  1. Open Noctalia Settings to customize the panel,
     appearance, wallpaper, and available widgets.

  2. Niri's system configuration:
       /etc/niri/config.kdl

     Your optional personal configuration:
       ~/.config/niri/config.kdl

     If you already have a personal config, back it up
     before adapting it to this template.

  3. List monitor names and supported modes:
       niri msg outputs

  4. Explore Niri IPC commands:
       niri msg --help

  5. Explore Noctalia commands:
       noctalia msg --help

  LAPTOP DISPLAY
  --------------

  Start with scale 1.0. Try 1.15 or 1.25 if the UI
  appears too small. Use the exact output name reported
  by "niri msg outputs".

  IMMUTABLE SYSTEM
  ----------------

  Keep personal settings in your home directory.
  Change system packages in the Containerfile, then
  rebuild and deploy the updated image.

  Back up configuration files before major changes.

WELCOME
EOF

# Kitty-only interactive Zsh welcome hook for new accounts
RUN install -d /etc/skel \
    && cat >> /etc/skel/.zshrc <<'EOF'

# Niri + Noctalia welcome guide in Kitty
if [[ -o interactive && -n "${KITTY_WINDOW_ID:-}" ]]; then
    if [[ -r /usr/local/share/niri-anatase/welcome ]]; then
        bash /usr/local/share/niri-anatase/welcome
    fi
fi
EOF

# Cleanup (leave this here)
RUN rm -rf /var && \
    mkdir -p /var/tmp
