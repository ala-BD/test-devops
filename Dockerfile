# ============================================
# DOCKERFILE: test-devops-ala
# Description: Image Docker pour projet CI/CD
# Maintainer: Ala
# Date: $(date)
# ============================================

# Étape 1: Image de base
FROM alpine:3.18

# Étape 2: Métadonnées
LABEL maintainer="Ala <ala@example.com>"
LABEL version="1.0"
LABEL description="Image Docker pour le projet test-devops-ala"
LABEL project="test-devops"
LABEL ci-cd="jenkins"

# Étape 3: Variables d'environnement
ENV APP_HOME=/app
ENV APP_USER=appuser
ENV APP_GROUP=appgroup

# Étape 4: Installation des packages
RUN echo "=== INSTALLATION DES PACKAGES ===" && \
    # Mise à jour des paquets
    apk update && \
    # Installation des outils système
    apk add --no-cache \
        bash \
        curl \
        git \
        wget \
        vim \
        tree \
        jq \
        htop \
        && \
    # Nettoyage du cache
    rm -rf /var/cache/apk/* && \
    # Création de l'utilisateur
    addgroup -S ${APP_GROUP} && \
    adduser -S ${APP_USER} -G ${APP_GROUP} && \
    echo "✅ Packages installés avec succès"

# Étape 5: Configuration du workspace
WORKDIR ${APP_HOME}

# Étape 6: Copie des fichiers du projet
COPY . .

# Étape 7: Correction des permissions
RUN chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME} && \
    chmod -R 755 ${APP_HOME}

# Étape 8: Création des fichiers d'information
RUN echo "==========================================" > /info.txt && \
    echo "           INFORMATION DE L'IMAGE          " >> /info.txt && \
    echo "==========================================" >> /info.txt && \
    echo "" >> /info.txt && \
    echo "📋 DÉTAILS:" >> /info.txt && \
    echo "  • Projet:    test-devops-ala" >> /info.txt && \
    echo "  • Version:   1.0" >> /info.txt && \
    echo "  • Build:     ${DOCKER_TAG:-local}" >> /info.txt && \
    echo "  • Date:      $(date '+%Y-%m-%d %H:%M:%S')" >> /info.txt && \
    echo "  • Base:      Alpine $(cat /etc/alpine-release)" >> /info.txt && \
    echo "  • Maintainer: Ala" >> /info.txt && \
    echo "" >> /info.txt && \
    echo "🔧 OUTILS DISPONIBLES:" >> /info.txt && \
    echo "  • Bash:      $(bash --version | head -1)" >> /info.txt && \
    echo "  • Curl:      $(curl --version | head -1)" >> /info.txt && \
    echo "  • Git:       $(git --version)" >> /info.txt && \
    echo "" >> /info.txt && \
    echo "📁 RÉPERTOIRES:" >> /info.txt && \
    echo "  • Home:      ${APP_HOME}" >> /info.txt && \
    echo "  • User:      ${APP_USER}" >> /info.txt && \
    echo "" >> /info.txt && \
    echo "🚀 POUR COMMENCER:" >> /info.txt && \
    echo "  1. docker run --rm [image]           # Affiche ce message" >> /info.txt && \
    echo "  2. docker run -it --rm [image] bash # Ouvre un shell" >> /info.txt && \
    echo "==========================================" >> /info.txt

# Étape 9: Script de démarrage
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Étape 10: Utilisateur non-root pour la sécurité
USER ${APP_USER}

# Étape 11: Point d'entrée
ENTRYPOINT ["docker-entrypoint.sh"]

# Étape 12: Commande par défaut
CMD ["info"]
