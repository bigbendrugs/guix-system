;; This is an operating system configuration generated
;; by the graphical installer.

(use-modules (gnu))
(use-modules (nongnu packages linux))
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
                           "gvfs"
                           "vim"
                           "htop"
                           "mc"
                           "xfce4-whiskermenu-plugin"
                           "tmux"))
                     %base-packages))
  (services
    (append
      (list (service xfce-desktop-service-type)
            (service openssh-service-type
		     (openssh-configuration
                        (x11-forwarding? #t)))
	    (service docker-service-type)
	    (static-networking-service "enp8s0f3u2" "192.168.100.1")
            (set-xorg-configuration
              (xorg-configuration
                (keyboard-layout keyboard-layout))))
      %desktop-services)))
