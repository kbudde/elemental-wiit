# run `make build` to build local/elemental-toolkit image
ARG ELEMENTAL_TOOLKIT
ARG VERSION
ARG OS_IMAGE=registry.opensuse.org/opensuse/tumbleweed
ARG OS_VERSION=latest

FROM ${ELEMENTAL_TOOLKIT} AS toolkit

# OS base image of our choice
FROM ${OS_IMAGE}:${OS_VERSION} AS os
ARG REPO
ARG VERSION
ENV REPO=${REPO}
ENV VERSION=${VERSION}

# Install kernel, systemd, dracut, grub2 and other required tools
RUN ARCH=$(uname -m); \
    if [[ "${ARCH}" != "riscv64" ]]; then \
      ADD_PKGS+=" shim"; \
      [[ "${ARCH}" == "aarch64" ]] && ARCH="arm64"; \
    fi; \
    zypper --non-interactive removerepo repo-update || true; \
    zypper --non-interactive --gpg-auto-import-keys install --no-recommends -- \
      kernel-default \
      device-mapper \
      dracut \
      grub2 \
      grub2-${ARCH}-efi \
      haveged \
      systemd \
      NetworkManager \
      openssh-server \
      openssh-clients \
      timezone \
      parted \
      e2fsprogs \
      dosfstools \
      mtools \
      xorriso \
      findutils \
      gptfdisk \
      rsync \
      squashfs \
      lvm2 \
      tar \
      gzip \
      vim \
      which \
      less \
      sudo \
      curl \
      sed \
      iproute2 \
      podman \
      audit \
      patterns-microos-selinux \
      btrfsprogs \
      btrfsmaintenance \
      snapper \
      xterm-resize \
      ${ADD_PKGS} \
      nmap \
      tcpdump \
      wget \
      podman \
      openvswitch \
      NetworkManager-ovs && \
    zypper clean --all

# Just add the elemental cli
COPY --from=toolkit /usr/bin/elemental /usr/bin/elemental

# Enable essential services
RUN systemctl enable NetworkManager.service && \
    systemctl enable sshd.service && \
    systemctl enable openvswitch.service


# Workaround to make sure there are no pending sysusers to be created (boo#1231244)
RUN systemd-sysusers

# This is for automatic testing purposes, do not do this in production.
RUN echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/rootlogin.conf

# SELinux in enforce mode
#RUN sed -i "s|SELINUX=.*|SELINUX=enforcing|g" /etc/selinux/config

# Add a bunch of system files
COPY files/ /


# Generate initrd with required elemental services
RUN elemental --debug init --force boot-assessment cloud-config-defaults cloud-config-essentials dracut-config elemental-rootfs elemental-setup elemental-sysroot grub-config

# Update os-release file with some metadata
RUN echo IMAGE_REPO=\"${REPO}\"             >> /etc/os-release && \
    echo IMAGE_TAG=\"${VERSION}\"           >> /etc/os-release && \
    echo IMAGE=\"${REPO}:${VERSION}\"       >> /etc/os-release && \
    echo TIMESTAMP="`date +'%Y%m%d%H%M%S'`" >> /etc/os-release && \
    echo GRUB_ENTRY_NAME=\"Elemental\"      >> /etc/os-release

# Good for validation after the build
CMD ["/bin/bash"]
