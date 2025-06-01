FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1

WORKDIR /srv/root

RUN apt update && apt install --no-install-recommends -y \
    git curl build-essential=12.9 \
    && rm -rf /var/lib/apt/lists/*
    
RUN curl https://sh.rustup.rs -sSf -o rustup-init.sh && \
    sh rustup-init.sh -y --default-toolchain stable && \
    rm rustup-init.sh
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustc --version && cargo --version


COPY pyproject.toml poetry.lock ./
RUN pip install -U pip poetry
RUN poetry config virtualenvs.create false
RUN poetry install --no-root

RUN apt update && \
    apt install -y default-mysql-client redis-tools

# NOTE: done last to avoid re-run of previous steps
COPY . .

ENTRYPOINT [ "scripts/start_server.sh" ]
