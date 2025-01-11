# Stage 1: Build the Astro app
FROM node:18-alpine AS build

# Set working directory
WORKDIR /app

# Install dependencies
COPY package.json package-lock.json* ./
RUN npm install

# Copy the rest of the app's code
COPY . .

# Build the Astro app
RUN npm run build

# Stage 2: Serve the built app with a lightweight web server
FROM nginx:alpine

# Copy the Astro build output to NGINX's web root
COPY --from=build /app/dist /usr/share/nginx/html

# Add NGINX configuration
RUN echo 'events { worker_connections 1024; } \
http { \
    server { \
        listen 80; \
        server_name _; \
        root /usr/share/nginx/html; \
        index index.html; \
        location / { \
            try_files $uri $uri/ =404; \
        } \
        error_page 404 /404.html; \
    } \
}' > /etc/nginx/nginx.conf

# Expose the default NGINX HTTP port
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]
