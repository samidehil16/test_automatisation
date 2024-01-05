#!/bin/bash

# Déclaration des variables par défaut
VERSION="0.1"
DEBUG=false

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'


# Fonction pour afficher l'utilisation du script

usage() {
    echo "Usage: $0 [options] <commande> [options de commande]"
    echo "Options générales:"
    echo "  -v, --version         Afficher la version du script"
    echo "  -d, --debug           Activer le mode débogage"
    echo
    echo "Commandes disponibles:"
    echo -e "${BLUE}  build                 Construire le programme ${NC}"
    echo -e "${GREEN}  test                  Tester le programme  ${NC}"
    echo -e "${YELLOW}  install               Installer le programme ${NC}"
    echo "  exec <programme>      Exécuter le programme spécifié"
    exit 1
}


# Analyse des options (par exemple c’est une manière de faire manuelle, il existe des api bash pour gérer les options de ligne de commande)
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -v|--version)
            echo "Version $VERSION"
            exit 0
            ;;
        -d|--debug)
            DEBUG=true
            shift
            ;;
        build|test|install|exec)
            COMMAND="$key"
            shift
            break
            ;;
        *)
            usage
            ;;
    esac
done


# # Vérification de la commande spécifiée
if [[ -z $COMMAND ]]; then
    echo "Veuillez spécifier une commande."
    usage
fi

# # Exécution des sous-commandes avec leurs options respectives
case $COMMAND in
    build)
        echo "Construction du programme avec version $VERSION et mode debug $DEBUG"
        # Ajoutez ici les commandes pour la construction du programme
         directory="./"         # chemin a remplacer en fonction de son 

        # List des sous dossiers qui contiennent le fichier "asde.yaml"
         listFolder=$(find "$directory" -mindepth 1 -maxdepth 1 -type d -exec test -e '{}/asde.yaml' \; -print)
        #echo "$listFolder"

        for element in "${listFolder[@]}"
        do
             yq e '.buildimage.type' asde.yaml 
        done



        ;;
    test)
        echo "Test du programme avec version $VERSION et mode debug $DEBUG"
        # Ajoutez ici les commandes pour tester le programme
        ;;
    install)
        echo "Installation du programme avec version $VERSION et mode debug $DEBUG"
        # Ajoutez ici les commandes pour installer le programme
        ;;
    exec)
        if [[ -z $1 ]]; then
            echo "Veuillez spécifier un programme à exécuter."
            usage
        else
            PROGRAM="$1"
            echo "Exécution du programme $PROGRAM avec version $VERSION et mode debug $DEBUG"
            # Ajoutez ici les commandes pour exécuter le programme spécifié
        fi
        ;;
    *)
        echo "Commande invalide."
        usage
        ;;
esac