# syntax=docker/dockerfile:1.7

FROM node:22-alpine

ENV NODE_ENV=production \
    PORT=3001

RUN apk upgrade --no-cache

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY api.js auth.js ./

RUN mkdir -p /app/uploads \
 && addgroup -S app \
 && adduser  -S app -G app \
 && chown -R app:app /app

USER app

EXPOSE 3001

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3001)+'/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "api.js"]
