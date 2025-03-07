# Protecting an MkDocs Static Site with OAuth2 Proxy

This repository provides an example of how to protect an MkDocs Material static site behind a login page using [OAuth2 Proxy](https://oauth2-proxy.github.io/oauth2-proxy/).
The main goal is to help users who need authentication for their static documentation sites[^1].

## Notes

- This example repository is public for demonstration purposes only.
- Since the static site will be protected by login, I recommend keeping your repository private.
- This example uses [GitHub](https://github.com/meadapt/login-static-site/blob/d05929e78e072117c978eb018f2e1f693a7c9d40/Dockerfile#L10) as the [Oauth provider](https://oauth2-proxy.github.io/oauth2-proxy/configuration/providers/github).
- The pages will be secure with an email whitelist.
- The authorized GitHub users' emails must be included in the [`email_list.txt`](https://github.com/meadapt/login-static-site/blob/main/email_list.txt) file.
- This project uses [Poetry](https://python-poetry.org/) for dependency management, but you can use any package management tool you prefer.
- Make sure to update your `mkdocs.yml` and OAuth2 Proxy configuration to fit your specific needs.

## How It Works

1. The static site is built using [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) (my favorite theme and static site generator).
1. A GitHub Actions workflow automatically built the static files of our site to a branch called `render-pages`.
1. The OAuth2 Proxy is used to add authentication in front of the static site.
1. I suggest the [Render](https://render.com/) web service to handle the authentication and serve the protected content[^2].

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/meadapt/login-static-site.git
cd login-static-site

# Poetry
poetry install
```

### 2. Create Your Static Site

Place your MkDocs content inside the `docs/` folder and configure `mkdocs.yml` accordingly.
Once ready, commit and push your changes to the `main` branch:

```bash
# Using Poetry to view your site locally
poetry run task serve


git add .
git commit -m "Add my documentation"
git push origin main
```

This push will trigger the [`publish_render_pages`](https://github.com/meadapt/login-static-site/blob/main/.github/workflows/publish_render_pages.yaml) GitHub Actions workflow that builds the site and pushes the generated static files to the `render-pages` branch.

### 3. Set Up an OAuth App on GitHub

To enable authentication, you need to create an OAuth App on GitHub:

1. Go to [GitHub Developer Settings](https://github.com/settings/developers).
1. Click on **OAuth Apps** > **New OAuth App**.
1. Fill in the details:
   - **Application Name**: Your app name.
   - **Homepage URL**: Use the URL provided by Render after deployment (you could update it later).
   - **Authorization Callback URL**: `<your_render_url>/oauth2/callback`
1. Click **Register Application**.
1. Copy the **Client ID** and **Client Secret** for later use.

### 4. Deploy the Web Service on Render

1. Go to [Render](https://render.com/) and create a new **Blueprint** instance.
1. Connect it to your GitHub repository.
1. Select the `render-pages` branch.
1. Set up the environment variables:
   - `OAUTH2_PROXY_CLIENT_ID=<your_github_client_id>`.
   - `OAUTH2_PROXY_CLIENT_SECRET=<your_github_client_secret>`.
   - `OAUTH2_PROXY_COOKIE_SECRET=<random_32_byte_secret>` (Generate one using `openssl rand -base64 32`)[^3].
1. Deploy your service.

Once deployed, your site will be protected, requiring a GitHub login to access it.


## License
This project is for educational purposes and does not provide any warranty or guarantees.

[^1]: Issues like [this](https://github.com/squidfunk/mkdocs-material/discussions/5050) and [this](https://github.com/squidfunk/mkdocs-material/issues/3854) were studied before this solution.
[^2]: [This](https://github.com/hamelsmu/oauth-tutorial/blob/main/simple/README.md) tutorial was my main inspiration content.
[^3]: [Generating a Cookie Secret](https://oauth2-proxy.github.io/oauth2-proxy/configuration/overview?_highlight=cooki#generating-a-cookie-secret).
