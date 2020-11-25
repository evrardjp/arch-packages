FROM archlinux:latest as repoctl
RUN pacman -Syu --noconfirm && pacman -S --noconfirm go-tools go git
RUN git clone https://github.com/cassava/repoctl.git && cd repoctl && go install

FROM archlinux:latest

RUN useradd -ms /bin/bash -G wheel builder && echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER builder
# Setting up base folders
RUN mkdir -p /home/builder/{.config/repoctl,arch-repo,arch-repo-builder}

COPY --from=repoctl /root/go/bin/repoctl /usr/bin/repoctl
COPY config.toml /home/builder/.config/repoctl/config.toml

WORKDIR /home/builder/arch-repo-builder
COPY repo-builder.sh .
COPY repo.sh .
ENTRYPOINT ["./repo.sh"]
