FROM debian:trixie-20260918

ENV DISPLAY=:0.0
ENV DISPLAY_WIDTH=1920
ENV DISPLAY_HEIGHT=1080

RUN echo "deb http://deb.debian.org/debian trixie contrib non-free" >> /etc/apt/sources.list && \
    export DEBIAN_FRONTEND=noninteractive && \
    dpkg --add-architecture i386 && apt update && apt install -y \
    novnc \
    openbox \
    supervisor \
    websockify \
    wget \
    wine \
    winetricks \
    wine32:i386 \
    xvfb \
    x11vnc

COPY ./image_files/supervisord.conf /etc/supervisord.conf
COPY ./image_files/wine-Flowgorithm.desktop /usr/share/applications/

RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

RUN useradd -m flowgorithm

USER flowgorithm

WORKDIR /home/flowgorithm

RUN mkdir Documents

VOLUME Documents

COPY ./image_files/autostart .config/openbox/

RUN xvfb-run winetricks -q dotnet48

RUN wget http://flowgorithm.org/download/files/Flowgorithm-exe-only.zip && \
    unzip Flowgorithm-exe-only.zip Flowgorithm.exe -d .wine/drive_c/Program\ Files/ && \
    rm Flowgorithm-exe-only.zip

CMD ["supervisord"]
