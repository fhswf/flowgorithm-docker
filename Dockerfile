FROM debian:trixie-20260918

LABEL org.opencontainers.image.source="https://github.com/fhswf/flowgorithm-docker"

ENV DISPLAY=:0.0
ENV DISPLAY_WIDTH=1920
ENV DISPLAY_HEIGHT=1080

RUN echo "deb http://deb.debian.org/debian trixie contrib non-free" >> /etc/apt/sources.list && \
    export DEBIAN_FRONTEND=noninteractive && \
    dpkg --add-architecture i386 && apt update && apt install -y \
    icoutils \
    novnc \
    openbox \
    supervisor \
    tint2 \
    websockify \
    wget \
    wine \
    winetricks \
    wine32:i386 \
    xvfb \
    x11vnc

COPY ./image_files/supervisord.conf /etc/
COPY ./image_files/wine-Flowgorithm.desktop /usr/share/applications/

RUN wget http://flowgorithm.org/flowgorithm.ico && \
    icotool -x -o /usr/share/icons/hicolor/256x256/apps/flowgorithm.png flowgorithm.ico && \
    rm flowgorithm.ico

RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

RUN useradd -m flowgorithm

USER flowgorithm

WORKDIR /home/flowgorithm

RUN mkdir Documents

VOLUME Documents

COPY ./image_files/autostart .config/openbox/
COPY ./image_files/rc.xml .config/openbox/
COPY ./image_files/tint2rc .config/tint2/

RUN xvfb-run winetricks -q dotnet48

RUN wget http://flowgorithm.org/download/files/Flowgorithm-exe-only.zip && \
    unzip Flowgorithm-exe-only.zip Flowgorithm.exe -d .wine/drive_c/Program\ Files/ && \
    rm Flowgorithm-exe-only.zip

CMD ["supervisord"]
