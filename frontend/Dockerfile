# syntax=docker/dockerfile:1.7

FROM node:22-alpine

LABEL org.opencontainers.image.title="NoteApp Frontend"
LABEL org.opencontainers.image.description="Professional Static Frontend"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.vendor="Jahid Islam"

ENV NODE_ENV=production

WORKDIR /app

# Install lightweight static file server
RUN npm install --global serve

# Copy application files
COPY . .

# Create a non-root user
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s \
             --timeout=5s \
             --start-period=10s \
             --retries=3 \
CMD wget --spider -q http://localhost:3000 || exit 1

CMD ["serve", "-s", ".", "-l", "3000"]