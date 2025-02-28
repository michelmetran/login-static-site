FROM quay.io/oauth2-proxy/oauth2-proxy AS base

# Use an intermediate image to install Python, pipx, and poetry
FROM python:3.11 AS builder

# Install pipx and poetry
RUN python -m pip install --upgrade pip \
    && pip install --user pipx \
    && python -m pipx ensurepath \
    && pipx install poetry

# Set up MkDocs project
WORKDIR /mkdocs
COPY pyproject.toml poetry.lock ./
RUN poetry install --no-dev

# Copy MkDocs source and build site
COPY docs/ docs/
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
