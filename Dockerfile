FROM archlinux:latest as repoctl
RUN pacman -Syu --noconfirm && pacman -S --noconfirm go-tools go git
RUN git clone https://github.com/cassava/repoctl.git && cd repoctl && go install

FROM archlinux:latest

WORKDIR /root/.config/repoctl
COPY --from=repoctl /root/go/bin/repoctl /usr/bin/repoctl
COPY config.toml .

WORKDIR /opt/arch-repo-builder
COPY pkglist .
COPY repo-builder.sh .
RUN mkdir -p /opt/arch-repo/ || true
CMD ["./repo-builder.sh"]
