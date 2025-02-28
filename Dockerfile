FROM quay.io/oauth2-proxy/oauth2-proxy AS base

# Use an intermediate image to install Python, pipx, and poetry
FROM python:3.11 AS builder

# Install dependencies
RUN apt update && apt install -y curl git build-essential libssl-dev zlib1g-dev \
    && curl https://pyenv.run | bash

# Set up pyenv environment
ENV PYENV_ROOT="/root/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
ENV PATH="/root/.local/bin:$PATH"

# Install Python based on .python-version
COPY .python-version /mkdocs/
WORKDIR /mkdocs
RUN pyenv install --skip-existing $(cat .python-version) \
    && pyenv global $(cat .python-version)

# Install pipx and poetry
RUN python -m pip install --upgrade pip \
    && pip install --user pipx \
    && pipx install poetry

# Set up MkDocs project
WORKDIR /mkdocs
COPY . ./
RUN poetry install

# Build site
RUN poetry run mkdocs build -d /site_output

# Final image
FROM base

# Copy generated site from the builder stage
COPY --from=builder /site_output /app/

# Copy email list configuration
COPY email_list.txt /site_config/

ENTRYPOINT ["/bin/oauth2-proxy", \
            "--provider", "github", \
            "--upstream", "file:///app/#/", \
            "--authenticated-emails-file", "/site_config/email_list.txt", \
            "--scope=user:email", \
            "--cookie-expire=0h0m30s", \
            "--skip-provider-button=true"]
