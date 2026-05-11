FROM ghcr.io/orcasecurity/orca-cli:1
USER root

RUN apk --no-cache --update add bash

WORKDIR /
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER orca
ENTRYPOINT ["/entrypoint.sh"]

