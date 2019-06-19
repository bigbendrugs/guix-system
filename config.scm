(use-modules (gnu)
             (nongnu packages linux)
             (srfi srfi-1))
(use-package-modules shells)
(use-service-modules desktop docker networking ssh xorg)

(operating-system
  (kernel linux)
  (firmware (list linux-firmware))
  (locale "ru_RU.utf8")
  (timezone "Asia/Yekaterinburg")
  (keyboard-layout (keyboard-layout "us" "dvp"))
  (bootloader
   (bootloader-configuration
    (bootloader grub-efi-bootloader)
    (target "/boot/efi")
    (keyboard-layout keyboard-layout)))
  (swap-devices (list "/dev/sda2"))
  (file-systems
   (cons* (file-system
            (mount-point "/boot/efi")
            (device (uuid "5CE5-668E" 'fat32))
            (type "vfat"))
          (file-system
            (mount-point "/")
            (device
             (uuid "c1b559c5-c6f3-4977-a8b0-5e064070352f"
                   'ext4))
            (type "ext4"))
          (file-system
            (mount-point "/home/igor/store")
            (device
             (uuid "fb10eadd-6f17-4c2e-a050-89c859c4c817"
                   'ext4))
            (type "ext4"))
          ;; %fuse-control-file-system
          %base-file-systems))
  (host-name "admin11")
  (users (cons* (user-account
                 (name "igor")
                 (comment "Igor Dryagalov")
                 (group "users")
                 (home-directory "/home/igor")
                 (supplementary-groups
                  '("wheel" "netdev" "audio" "video" "docker"))
                 (shell #~(string-append #$zsh "/bin/zsh")))
                %base-user-accounts))
  (packages (append (map specification->package
                         '("nss-certs"
                           "setxkbmap"
                           "zsh"
                           "iptables"
                           "gvfs"
                           "vim"
                           "htop"
                           "mc"
                           "xfce4-whiskermenu-plugin"
                           "tmux"))
                    %base-packages))
  (services (cons*
             (service xfce-desktop-service-type)
             (service openssh-service-type
                      (openssh-configuration
                       (x11-forwarding? #t)))
             (service docker-service-type)
             ;; (service dhcp-client-service-type)
             (static-networking-service "enp5s0" "192.168.105.214"
                                        #:netmask "255.255.255.0"
                                        #:gateway "192.168.105.254")
             (static-networking-service "enp8s0f3u2" "192.168.100.1"
                                        #:netmask "255.255.255.0")
             (service dhcpd-service-type
                      (dhcpd-configuration
                       (config-file (local-file "/etc/dhcp/dhcpd.conf"))
                       (interfaces '("enp8s0f3u2"))))
             (service iptables-service-type
                      (iptables-configuration
                       (ipv4-rules (plain-file "iptables.rules" "*nat
:INPUT ACCEPT
:POSTROUTING ACCEPT
:OUTPUT ACCEPT
-A POSTROUTING -o enp5s0 -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT
:FORWARD ACCEPT
:OUTPUT ACCEPT
-A FORWARD -i enp8s0f3u2 -j ACCEPT
-A FORWARD -o enp8s0f3u2 -j ACCEPT
COMMIT
"))))
             (set-xorg-configuration
              (xorg-configuration
               (keyboard-layout keyboard-layout)))
             (modify-services
                 (remove (lambda (service)
                           (member (service-kind service)
                                   (list network-manager-service-type)))
                         %desktop-services)))))

