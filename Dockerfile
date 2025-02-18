FROM ubuntu:24.04 AS ubuntu2404_common_deps
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install -y \
    git \
    python3 \
    build-essential \
    xz-utils \
    wget

RUN wget -O - https://raw.githubusercontent.com/alec-chicherini/development-scripts/refs/heads/main/cmake/install_cmake.sh 2>/dev/null | bash

FROM ubuntu2404_common_deps AS i_am_production
ENV DEBIAN_FRONTEND=noninteractive

RUN USERVER_DEPS_FILE="https://raw.githubusercontent.com/userver-framework/userver/refs/heads/develop/scripts/docs/en/deps/ubuntu-24.04.md" && \
    apt install --allow-downgrades -y $(wget -q -O - ${USERVER_DEPS_FILE})

#RUN wget https://github.com/userver-framework/userver/releases/download/v2.7/ubuntu24.04-libuserver-all-dev_2.7_amd64.deb && \
#    dpkg -i ubuntu24.04-libuserver-all-dev_2.7_amd64.deb

FROM server-http-build AS server_http_build
COPY --from=server_http_build /result/*.deb /
RUN dpkg -i /*.deb

FROM site-repotest-ru-build AS site_repotest_ru_build
COPY --from=site_repotest_ru_build /result/ /var/www/repotest.ru/ 

FROM wordle-client-qt-build-wasm AS wordle_client_build_wasm
COPY --from=wordle_client_build_wasm /result/ /var/www/wordle-task.repotest.ru/

COPY ./configs/ /etc/http-server/

ENTRYPOINT ["server-http", "--config", "/etc/server-http/static_config.yaml"]