FROM golang:latest AS go-build

WORKDIR /src
COPY go.mod /src
COPY go.sum /src
RUN go mod download

COPY . /src
RUN go build -o repo ./main.go

FROM cirrusci/flutter AS flutter-build

WORKDIR /src
COPY pubspec.yaml /src
RUN flutter pub get

COPY . /src
RUN flutter clean
RUN flutter build web

FROM archlinux/archlinux:base-devel

LABEL maintainer="Dancheg97 <dancheg97@fmnx.io>"

RUN pacman -Syu --needed --noconfirm git pacman-contrib wget

ARG user=makepkg
RUN useradd --system --create-home $user
RUN echo "$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
USER $user
WORKDIR /home/$user

RUN git clone https://aur.archlinux.org/yay.git
RUN cd yay && makepkg -sri --needed --noconfirm && sudo  mv *.pkg.tar.zst /var/cache/pacman/pkg
RUN cd && rm -rf .cache yay

COPY --from=go-build /src/repo .
COPY --from=flutter-build /src/build/web /web
RUN sudo chmod a+rwx -R /web

ENTRYPOINT ["./repo"]
CMD ["run"]