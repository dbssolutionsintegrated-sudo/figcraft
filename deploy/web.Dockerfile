# Static build of the FigCraft web app. `trunk build --release` writes the site
# to dist/web with relative URLs (Trunk.toml: public_url = "./"), so it works
# behind any host or path prefix.
FROM nginx:1.27-alpine
COPY dist/web /usr/share/nginx/html
RUN printf 'server {\n  listen 8080;\n  root /usr/share/nginx/html;\n  index index.html;\n  location / { try_files $uri $uri/ /index.html; }\n  types { application/wasm wasm; }\n  add_header Cross-Origin-Opener-Policy "same-origin";\n  add_header Cross-Origin-Embedder-Policy "require-corp";\n  gzip on; gzip_types application/wasm application/javascript text/css;\n}\n' > /etc/nginx/conf.d/default.conf
EXPOSE 8080
