# syntax=docker/dockerfile:1.7

##############################
# Builder Stage
##############################

FROM python:3.12-slim AS builder

LABEL stage=builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /build

COPY requirements.txt .

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install \
    --prefix=/install \
    --no-warn-script-location \
    --no-cache-dir \
    -r requirements.txt


##############################
# Runtime Stage
##############################

FROM python:3.12-slim

LABEL org.opencontainers.image.title="NoteApp Backend"
LABEL org.opencontainers.image.description="Professional Flask Backend"
LABEL org.opencontainers.image.version="1.0.0"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN groupadd --system appgroup && \
    useradd --system \
    --gid appgroup \
    --create-home \
    appuser

WORKDIR /app

COPY --from=builder /install /usr/local

COPY . .

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s \
             --timeout=5s \
             --start-period=10s \
             --retries=3 \
CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

CMD ["python", "app.py"]