FROM nginx:trixie
COPY Src/index.html /usr/share/nginx/html/index.html
COPY Src/dog.jpg /usr/share/nginx/html/dog.jpg
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

