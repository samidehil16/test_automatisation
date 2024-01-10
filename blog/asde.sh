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

        # vérificaiton qu'on ai bien des sous dossiers avec le fichier "asde.yaml"
        if [ "$listFolder" ]; then
                for element in $listFolder
                do   

                    #Récupération et itération des services 
                    services_length=$(yq e '.services | length' $element/asde.yaml)
                    for ((i = 0; i < services_length; i++)); do
                        # echo "Service $i:"
                        # yq eval ".services[$i]" $element/asde.yaml  #affichage du service
                        # echo "ce service viens du fichier $element/asde.yaml"
                        
                        action=$(yq e ".services[$i].actions[].action" $element/asde.yaml)
                        type=$(yq e ".services[$i].actions[].types[].type" $element/asde.yaml)

                        # Traitement pour build une image
                        if [ "$action" = "build-image" ]; then
                            nameImage=$(yq e ".services[$i].actions[].types[].details.name" $element/asde.yaml)
                            pathDockerfile=$(yq e ".services[$i].actions[].types[].details.dockerfilePath" $element/asde.yaml)
                            tag=$(yq e ".services[$i].actions[].types[].details.tag" $element/asde.yaml)
                            # Avec Docker
                            if [ "$type" = "docker" ]; then
                                 docker build -t "$nameImage":"$tag" $pathDockerfile
                            fi
                        fi
                        # Traitement pour run un container
                        if [ "$action" = "run" ]; then
                            type=$(yq e ".services[$i].actions[].types[].type" $element/asde.yaml)
                            nameImage=$(yq e ".services[$i].actions[].types[].details.nameImage" $element/asde.yaml)
                            port=$(yq e ".services[$i].actions[].types[].details.options.port" $element/asde.yaml)
                            if [ "$type" = "docker" ]; then
                                docker run -p $port $nameImage
                            fi
                        fi
                        # Traitement d'un build pour un binaire
                        if [ "$action" = "build" ]; then
                            type=$(yq e ".services[$i].actions[].types[].type" $element/asde.yaml)
                            cwd=$(yq e ".services[$i].actions[].types[].details.cwd" $element/asde.yaml)
                            if [ "$type" = "binary" ]; then
                                cmake $cwd && make all . 
                            fi
                        fi   
                    done
                done

            else 
                echo " Vos dossiers ne contiennt pas le fichier de configuration 'asde.yaml' "
        fi


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