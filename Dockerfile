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

ENV PORT=10000

EXPOSE 10000

CMD ["nginx", "-g", "daemon off;"]
