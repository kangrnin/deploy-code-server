# Start from the code-server Debian base image
FROM codercom/code-server:3.10.2

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/usr/bin/zsh

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# material icon
RUN code-server --install-extension pkief.material-icon-theme
# formatter
RUN code-server --install-extension esbenp.prettier-vscode
# - python
RUN code-server --install-extension ms-python.python
# vue
RUN code-server --install-extension liuji-jim.vue
RUN code-server --install-extension octref.vetur
# javascript
RUN code-server --install-extension dbaeumer.vscode-eslint
# git
RUN code-server --install-extension eamodio.gitlens
RUN code-server --install-extension donjayamanne.githistory


# Install apt packages:
WORKDIR /home/coder
ARG PASSWORD
RUN echo $PASSWORD
RUN (echo $PASSWORD && echo $PASSWORD) | sudo passwd coder
RUN (echo y && echo $PASSWORD) | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN sed -i '11 s/robbyrussell/avit/' .zshrc

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
