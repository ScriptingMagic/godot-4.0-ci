FROM ubuntu:22.04
LABEL author="https://github.com/aBARICHELLO/godot-ci/graphs/contributors"

USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    gnupg

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y \
    xvfb \
    libdbus-1-dev \
    dotnet6 \
    ca-certificates \
    git \
    git-lfs \
    python-is-python3 \
    python3-openssl \
    unzip \
    wget \
    zip \
    rsync \
    yarn \
    build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev \
    libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev yasm \
    && rm -rf /var/lib/apt/lists/*

# When in doubt see the downloads page
# https://downloads.tuxfamily.org/godotengine/
ARG GODOT_VERSION="4.0"

# Example values: stable, beta3, rc1, alpha2, etc.
# Also change the SUBDIR property when NOT using stable
ARG RELEASE_NAME="beta3"

# This is only needed for non-stable builds (alpha, beta, RC)
# e.g. SUBDIR "/beta3"
# Use an empty string "" when the RELEASE_NAME is "stable"
ARG SUBDIR="beta3"


RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/${SUBDIR}/mono/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_linux_x86_64.zip \
    && wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/${SUBDIR}/mono/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_export_templates.tpz

RUN mkdir ~/.cache \
    && mkdir -p ~/.config/godot \
    && mkdir -p ~/.local/share/godot/templates/${GODOT_VERSION}.${RELEASE_NAME}.mono \
    && unzip Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_linux_x86_64.zip \
    && mv Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_linux_x86_64/Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_linux.x86_64 /usr/local/bin/godot \
    && mv Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_linux_x86_64/GodotSharp /usr/local/bin/GodotSharp \
    && unzip Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_export_templates.tpz \
    && mv templates/* ~/.local/share/godot/templates/${GODOT_VERSION}.${RELEASE_NAME}.mono \
    && rm -f Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_export_templates.tpz Godot_v${GODOT_VERSION}-${RELEASE_NAME}_mono_linux_x86_64.zip

RUN wget https://github.com/facebookincubator/FBX2glTF/releases/download/v0.9.7/FBX2glTF-linux-x64 \
    && mv FBX2glTF-linux-x64 /usr/local/bin/FBX2glTF \
    && chmod +x /usr/local/bin/FBX2glTF

COPY editor_settings-4.tres /root/.config/godot/editor_settings-4.tres

ADD getbutler.sh /opt/butler/getbutler.sh
RUN bash /opt/butler/getbutler.sh
RUN /opt/butler/bin/butler -V

ENV PATH="/opt/butler/bin:${PATH}"

RUN mkdir -p /usr/local/lib

RUN wget https://github.com/godotengine/godot/files/6215523/libvk_swiftshader.so.tar.gz \
    && tar -xvf libvk_swiftshader.so.tar.gz \
    && mv libvk_swiftshader.so /usr/local/lib/libvk_swiftshader.so \
    && rm -f libvk_swiftshader.so.tar.gz

COPY vk_swiftshader_icd.json /root

