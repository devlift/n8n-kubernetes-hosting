# Custom n8n Docker image
FROM n8nio/n8n:1.103.2

# Switch to root to install packages
USER root

# Install additional packages if needed
# RUN apk add --no-cache your-package-here

# Copy custom nodes or modifications
# COPY ./custom-nodes /home/node/.n8n/custom/
# COPY ./custom-code /home/node/custom-code/

# Install custom npm packages
# RUN npm install -g your-custom-package

# Switch back to node user
USER node

# Set custom environment variables if needed
# ENV N8N_CUSTOM_EXTENSIONS=/home/node/.n8n/custom 