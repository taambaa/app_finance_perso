# .devcontainer/Dockerfile

# Utilise une image Ubuntu plus complète comme base
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Installe les dépendances nécessaires pour Flutter et d'autres outils
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends git curl unzip xz-utils libglu1-mesa libg++-dev locales libsecret-1-0 libgtk-3-0 libsoup-2.4-1 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Installe Node.js et npm (pour Firebase CLI)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

# Installe Flutter SDK
ARG FLUTTER_VERSION="stable"
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter --branch ${FLUTTER_VERSION} --depth 1
ENV PATH="/usr/local/flutter/bin:${PATH}"

# Précache Flutter pour s'assurer que le Dart SDK est prêt
RUN flutter precache --web

# Définir l'utilisateur par défaut comme 'vscode'
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN if [ "$USER_GID" != "$(id -g $USERNAME)" ]; then groupadd --gid $USER_GID $USERNAME; fi \
    && if [ "$USER_UID" != "$(id -u $USERNAME)" ]; then useradd -s /bin/bash --uid $USER_UID -g $USERNAME -m $USERNAME; fi \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(ALL\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
USER $USERNAME
