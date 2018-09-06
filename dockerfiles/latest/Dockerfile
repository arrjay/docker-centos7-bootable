FROM centos:7

MAINTAINER RJ Bergeron <rbergero@gmail.com>

ADD yum.repos.d /etc/yum.repos.d

ADD rpm-gpg /etc/pki/rpm-gpg

# install packages
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-centos7-mactel && \
    yum -y install hostname parted lvm2 cryptsetup mdadm xfsprogs \
                   grub grub2-tools grub2 grub2-efi grub2-efi-modules \
                   grub2-efi-ia32 grub2-efi-ia32-modules \
                   shim efibootmgr \
                   augeas \
                   selinux-policy-targeted \
                   openssh-server openssh-clients cloud-init \
                   sudo extendroot passwd authconfig epel-release chrony \
                   audit \
                   systemd-networkd systemd-resolved \
                   smartmontools ethtool lm_sensors usbutils \
                   vim-minimal \
                   tboot \
                   kernel \
                   terminus-fonts-console fbset \
                   tmux vim-enhanced mc w3m ncftp s3cmd \
                   bsdtar \
                   kmod-hfsplus mactel-boot \
                   && \
    yum clean all && rm -rf /var/cache/yum &&\
    find / -type d \( -name proc -o -name sys \) -prune -o -iname \*.rpmnew -exec rm {} \;

# install intel microcode
ADD sha512sums /tmp/sha512sums
RUN curl -L -o /tmp/microcode.tgz https://downloadmirror.intel.com/28087/eng/microcode-20180807a.tgz && \
    sha512sum -c /tmp/sha512sums/microcode && \
    tar xf /tmp/microcode.tgz -C /lib/firmware && \
    rm /tmp/microcode.tgz && \
    rm -rf /tmp/sha512sums

# add grub bits
ADD default-grub /etc/default/grub

# add vconsole config
ADD vconsole.conf /etc/vconsole.conf

# additional color elements
ADD mc-skins /usr/share/mc/skins
RUN ln -sf /etc/DIR_COLORS.lightbgcolor /etc/skel/.dir_colors && \
    ln -sf /etc/DIR_COLORS.lightbgcolor /root/.dir_colors

# *any* profile.d stuff
ADD profile.d /etc/profile.d

# add user
RUN groupadd -g 1024 ejusdem && \
    useradd --uid 1024 --gid 1024 ejusdem && \
    usermod -G wheel ejusdem

# reconfigure sudo
RUN bash -c 'autosudo=$(mktemp) && \
    printf \#\!/bin/bash\\nsed\ -i\ -e\ \"s@^%%wheel.*@%%wheel\ ALL=\(ALL:ALL\)\ NOPASSWD:\ ALL@\"\ \${2} > "${autosudo}" && \
    chmod +x "${autosudo}" && \
    env EDITOR="${autosudo}" visudo && \
    rm "${autosudo}"'

# when/if we run grub-install
ADD grub.d/* /etc/grub.d/

# add drivers to initramfs
RUN echo 'add_drivers+=" nouveau vfio-pci "' >> /etc/dracut.conf

# reconfigure cloud-init
RUN sed -i -e '/ - locale/d' /etc/cloud/cloud.cfg
ADD /cloud.cfg.d /etc/cloud/cloud.cfg.d

# systemd-networkd for network config please
RUN ln -sf /lib/systemd/system/systemd-networkd.service "/etc/systemd/system/multi-user.target.wants/systemd-networkd.service" && \
    mkdir -p "/etc/systemd/system/sockets.target.wants" && \
    ln -sf /lib/systemd/system/systemd-networkd.socket  "/etc/systemd/system/sockets.target.wants/systemd-networkd.service" && \
    ln -sf /dev/null "/etc/systemd/system/dhcpcd.service" && \
    ln -sf /dev/null "/etc/systemd/system/NetworkManager.service" && \
    ln -sf /dev/null "/etc/systemd/system/networking.service" && \
    ln -sf /dev/null "/etc/systemd/system/NetworkManager-wait-online.service" && \
    rm -f "/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service" && \
    rm -f "/etc/systemd/system/multi-user.target.wants/NetworkManager.service" && \
    rm -f "/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service" && \
    mkdir -p "/etc/systemd/network"
ADD /systemd-network /etc/systemd/network
RUN find /etc/systemd/network -type f -exec chmod a+r {} \;

# custom script to dump platform info to a directory for systemd hooks
ADD platform-info/platform-info.service /etc/systemd/system/platform-info.service
ADD platform-info/platform-info.sh      /usr/local/sbin/platform-info.sh
RUN ln -sf /etc/systemd/system/platform-info.service "/etc/systemd/system/multi-user.target.wants/platform-info.service"

# disable smartd on virtual hosts
ADD smartd.service.d /etc/systemd/system/smartd.service.d

# service to start console if we find a hvc0 console *shrug*
ADD hvc0-console.service /etc/systemd/system/hvc0-console.service

# image installation scripts
ADD /scripts /scripts
