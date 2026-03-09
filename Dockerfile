# Build stage
FROM debian:stable-slim AS build

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release

# Serve stage
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 10000

CMD ["nginx", "-g", "daemon off;"]