# Image de base
FROM alpine:latest

# Mise à jour et installation
RUN apk update && \
    apk add --no-cache bash curl git

# Répertoire de travail
WORKDIR /app

# Copier les fichiers
COPY . .

# Créer un fichier info
RUN echo "Image créée par Ala" > /info.txt && \
    echo "Date: $(date)" >> /info.txt && \
    echo "Build: $BUILD_NUMBER" >> /info.txt

# Commande par défaut
CMD ["sh", "-c", "echo '🚀 Image Docker fonctionnelle!' && cat /info.txt && echo '' && echo '📁 Fichiers dans /app:' && ls -la"]
