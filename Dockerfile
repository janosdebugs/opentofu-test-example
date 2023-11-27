FROM nginx

RUN echo 'Hello world!' >/usr/share/nginx/html/index.html

HEALTHCHECK --interval=5s --timeout=3s --retries=3 \
  CMD curl -f http://localhost/

EXPOSE 80
