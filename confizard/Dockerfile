FROM ubuntu:25.04 AS final

RUN apt update && \
    apt install -y \
        software-properties-common=0.111 \
        curl=8.12.1-3ubuntu1 \
        gnupg=2.4.4-2ubuntu23 \
        apt-transport-https=3.0.0 \
        ca-certificates=20241223

RUN curl -fsSL https://get.opentofu.org/opentofu.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/opentofu.gpg
RUN curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | gpg --dearmor -o /etc/apt/trusted.gpg.d/tofu.gpg
RUN echo "deb https://packages.opentofu.org/opentofu/tofu/any/ any main" | tee /etc/apt/sources.list.d/opentofu.list
RUN apt update

RUN apt install -y \
    git=1:2.48.1-0ubuntu1 \
    ansible=11.2.0+dfsg-1 \
    tofu=1.9.1 \
    sshpass=1.10-0.1

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
