FROM quay.io/oauth2-proxy/oauth2-proxy

# Copy generated site from the gh-pages branch
COPY site /app/

# Copy email list configuration
COPY github_users.txt /site_config/

ENTRYPOINT ["/bin/bash", "-c", "GITHUB_USERS=$(paste -sd, /site_config/github_users.txt) && \
    exec /bin/oauth2-proxy \
    --provider github \
    --upstream file:///app/#/ \
    --email-domain=* \
    --github-user=$GITHUB_USERS \
    --cookie-expire=0h0m30s \
    --skip-provider-button=true"]
