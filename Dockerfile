FROM node:22-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

ARG PUBLIC_ORGANIZATION=lemoncode
ENV PUBLIC_ORGANIZATION=$PUBLIC_ORGANIZATION

RUN npm run build

FROM nginx:1.27-alpine

COPY nginx.conf.template /etc/nginx/templates/default.conf.template
COPY --from=build /app/dist /usr/share/nginx/html

# App Service enruta al puerto 80. WEBSITES_PORT, si existe, tiene prioridad.
ENV PORT=80
EXPOSE 80

RUN printf '%s\n' \
    '#!/bin/sh' \
    'set -e' \
    'if [ -n "$WEBSITES_PORT" ]; then export PORT="$WEBSITES_PORT"; fi' \
    'exec /docker-entrypoint.sh nginx -g "daemon off;"' \
    > /azure-entrypoint.sh \
    && chmod +x /azure-entrypoint.sh

ENTRYPOINT ["/azure-entrypoint.sh"]
