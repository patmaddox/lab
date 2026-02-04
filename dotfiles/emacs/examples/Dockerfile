# Example Dockerfile

FROM freebsd:14.0

LABEL maintainer="alice@example.com"
LABEL description="Example container"

ENV APP_HOME=/app
ENV PATH="${APP_HOME}/bin:${PATH}"

WORKDIR ${APP_HOME}

RUN pkg update && pkg install -y \
    curl \
    git \
    && rm -rf /var/cache/pkg/*

COPY . .

RUN make build

EXPOSE 8080

USER nobody

CMD ["./bin/server", "--port", "8080"]
