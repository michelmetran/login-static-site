FROM quay.io/oauth2-proxy/oauth2-proxy

# Copy generated site from the gh-pages branch
COPY site /app/

# Copy email list configuration
COPY github_users.txt /site_config/

# Read the list from the file and convert it to a comma-separated string
RUN GITHUB_USERS=$(cat /site_config/github_users.txt | tr '\n' ',') && \
    echo "GITHUB_USERS=\"$GITHUB_USERS\"" >> /app/env.sh

ENTRYPOINT ["/bin/sh", "-c", "source /app/env.sh && exec /bin/oauth2-proxy \
  --provider github \
  --upstream file:///app/#/ \
  --email-domain=* \
  --github-user=$GITHUB_USERS \
  --cookie-expire=0h0m30s \
  --skip-provider-button=true"]
