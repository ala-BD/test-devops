# Dockerfile
FROM alpine:latest

# Installer des packages
RUN apk add --no-cache \
    bash \
    curl \
    git

# Créer un répertoire de travail
WORKDIR /app

# Copier le contenu du projet
COPY . .

# Afficher des informations (personnalisable)
RUN echo "Image Docker pour le projet de Ala" > /info.txt
RUN echo "Créé le: $(date)" >> /info.txt

# Commande par défaut
CMD ["/bin/bash", "-c", "cat /info.txt && echo '✅ Application fonctionnelle!' && ls -la /app"]
