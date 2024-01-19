#!/bin/bash

# Déclaration des variables par défaut
VERSION="0.1"
DEBUG=false

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'


BUILD_TYPE="default"
optionAll=1
optImage=1
except=1


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
    echo
    echo "Options de la commande build:"
    echo "  --image               Selection du type image"
    echo "  --all, -a             Construire toutes les images du workspace"
    echo
    echo "Options de la commande test:"
    echo "  --all               Tester tout les programmes"
    echo "  --except            Exclure les dossiers (--all obligatoire) exemple: asde test --all --execpt arg"
    echo
    echo "Options de la commande install:"
    echo "  --all               Tester tout les programmes"
    echo "  --except            Exclure les dossiers (--all obligatoire) exemple: asde test --all --execpt arg"

    exit 1
}

#!/bin/bash

OPTIONS="vdaft"
LONGOPTS="version,debug,image,container,all,folder,type,except"

# Parsing des options
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")

# Vérification des erreurs dans le parsing
if [ $? -ne 0 ]; then
    exit 1
fi

eval set -- "$PARSED"

# Traitement des options
while true; do
    case "$1" in
        -v|--version)
            echo "Version $VERSION"
            exit 0
            ;;
        -d|--debug)
            # Traitement pour l'option -d
            DEBUG=true
            shift
            ;;
        --image|--container)
            if [ "$1" = "--image" ]; then     
                optImage=0
            fi
            if [ "$1" = "--container" ]; then     
                optContainer=0
            fi
            shift
            ;;
        --except)
            except=0
            if [ $4 ] || [ $5 ] || [ $6 ]; then
                except_fichier1="$4"
                except_fichier2="$5"
                except_fichier3="$6"
                
                # Test que les variables sont bien passer
            fi
            shift
            ;;
        -a|--all)           
            optionAll=0
            shift 
            ;;
        -f|--folder)
            folder="$5"    # peut etre faire une vérif d'argument !!
            echo "$folder"
            shift
            ;;
        -t|--type)
            cmdOpt="$3"
            if [ "$cmdOpt" = "install" ]; then
                type="$4"
            fi
            if [ "$cmdOpt" = "build" ]; then
                type="$5"
            fi           
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            usage
            ;;
    esac
done

# # Vérification de la commande spécifiée
# if [[ -z $command ]]; then
#     echo "Veuillez spécifier une commande."
#     usage
# fi

# Traitement des commandes
if [ $# -gt 0 ]; then
    command="$1"
    case "$command" in
        build)
            # Traitement spécifique à la commande "build"
            echo "Commande build détectée. Exécution du processus de construction..."
            # Ajoutez ici le code pour la construction (compilation, assemblage, etc.)

            # Condition pour le traitement de l'option --all dans le contexte de la commande "build"
            if [ "$optionAll" -eq 0 ]; then                            
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
                
            
            fi

            # Condition pour l'option --image
            if [ "$optImage" -eq 0 ]; then 
                # Condition pour le traitement de l'option -f
                if [ "$folder" ]; then
                    # peut avoir 2 type docker et natif
                    echo "je suis dans le dossier $folder"
                    # vérifier que le dossier contient bien le fichier de configuration               
                    if [ -e "$folder/asde.yaml" ]; then
                        if [ "$type" ]; then
                            if [ "$type" = "docker" ]; then
                                nameImage=$(yq e ".services[$i].actions[].types[].details.name" $folder/asde.yaml)
                                pathDockerfile=$(yq e ".services[$i].actions[].types[].details.dockerfilePath" $folder/asde.yaml)
                                tag=$(yq e ".services[$i].actions[].types[].details.tag" $folder/asde.yaml)

                                docker build -t "$nameImage":"$tag" $pathDockerfile
                            fi
                            if [ "$type" = "natif" ]; then
                                 echo "natif"
                            fi  
                        fi
                    fi
                fi
            fi

            ;;
        test)
            echo "Test du programme avec version $VERSION et mode debug $DEBUG"
            # Ajoutez ici les commandes pour tester le programme

            if [ "$optionAll" -eq 0 ]; then
                # Ajoutez ici les commandes pour la construction du programme
                directory="."  # chemin à remplacer en fonction de votre besoin
                

                if [ "$except" -eq 0 ]; then

                    if [ $except_fichier1 ] || [ $except_fichier2 ] || [ $except_fichier3 ] ; then
                        
                        #List des sous dossiers contenant le fichier de configuration 
                        listFolder=$(find "$directory" -mindepth 1 -maxdepth 1 -type d -exec test -e '{}/asde.yaml' \; -print)
                        
                        newList=()
                        serviceExcept=("$except_fichier1" "$except_fichier2" "$except_fichier3")

                        # partie de dissociation entre les dossiers exclus et ceux de base
                        if [ "$listFolder" ]; then
                            for element in $listFolder; do
                                services_length=$(yq e ".services | length" $element/asde.yaml)
                                for ((i = 0; i < services_length; i++)); do
                                    for except in $serviceExcept ; do    
                                        if [ "$element" != "./$except" ]; then
                                            newList+=($element)
                                        fi
                                    done
                                done    
                            done
                            
                            for newElement in "${newList[@]}"; do
                                services_length=$(yq eval '.services | length' $newElement/asde.yaml)

                                for ((i = 0; i < services_length; i++)); do
                                    nameService=$(yq eval ".services[$i].name" $newElement/asde.yaml)
                                    action_length=$(yq eval ".services[$i].actions | length" $newElement/asde.yaml)
                                    for ((j = 0; j < action_length; j++)) ; do
                                        action=$(yq eval ".services[$i].actions[$j].action" $newElement/asde.yaml) 
                                            
                                        if [ "$action" = "test" ]; then
                                            cmd=$(yq e ".services[$i].actions[$j].types[].details.cmd" "$newElement/asde.yaml")
                                            path=$(yq e ".services[$i].actions[$j].types[].details.path" "$newElement/asde.yaml")
                                            env=$(yq e ".services[$i].actions[$j].types[].details.options.env" "$newElement/asde.yaml")

                                            echo "Ce service viens du fichier $newElement/asde.yaml"
                                            echo " $nameService va éxecuter la command test "
                                            echo
                                                cd client
                                                $cmd      # vous pouvez rajouter l'argument $env
                                                if [ $? -eq 0 ]; then
                                                    echo "Test bien éxecuter"
                                                else
                                                    echo "Une erreur s'est produite lors des tests"
                                                    usage
                                                fi
                                            echo
                                        else
                                            echo "$action"
                                            echo "Ce service viens du fichier $newElement/asde.yaml"
                                            echo " $newElement ne contient pas de command test "
                                            echo
                                        fi
                                    done

                                done
                            done
                               
                        # je coince au niveau du filtre
                        else
                            echo "Vous avez aucun sous dossier contenant le fichier de config 'asde.yaml' "
                        fi 
                    else
                        echo "Vous n'avez passez aucun argument a l'option --except"
                    fi
                else  
                    listFolder=$(find "$directory" -mindepth 1 -maxdepth 1 -type d -exec test -e '{}/asde.yaml' \; -print)

                    if [ "$listFolder" ]; then
                        for element in $listFolder; do
                            # Récupération et itération des services
                            services_length=$(yq eval '.services | length' $element/asde.yaml)

                            for ((i = 0; i < services_length; i++)); do
                                nameService=$(yq eval ".services[$i].name" $element/asde.yaml)
                                action_length=$(yq eval ".services[$i].actions | length" $element/asde.yaml)
                                for ((j = 0; j < action_length; j++)) ; do
                                    action=$(yq eval ".services[$i].actions[$j].action" $element/asde.yaml) 
                                        
                                    if [ "$action" = "test" ]; then
                                        cmd=$(yq e ".services[$i].actions[$j].types[].details.cmd" "$element/asde.yaml")
                                        path=$(yq e ".services[$i].actions[$j].types[].details.path" "$element/asde.yaml")
                                        env=$(yq e ".services[$i].actions[$j].types[].details.options.env" "$element/asde.yaml")

                                        echo "Ce service viens du fichier $element/asde.yaml"
                                        echo " $nameService va éxecuter la command test "
                                        echo
                                            cd client
                                            $cmd      # vous pouvez rajouter l'argument $env
                                            if [ $? -eq 0 ]; then
                                                echo "Test bien éxecuter"
                                            else
                                                echo "Une erreur s'est produite lors des tests"
                                                usage
                                            fi
                                        echo
                                    else
                                        echo "$action"
                                        echo "Ce service viens du fichier $element/asde.yaml"
                                        echo " $nameService ne contient pas de command test "
                                        echo
                                    fi
                                done

                            done
                        done
                    else
                        echo " Vos dossiers ne contiennent pas le fichier de configuration 'asde.yaml' "
                    fi
                fi
            fi
            ;;
        install)

            echo "Installation du programme avec version $VERSION et mode debug $DEBUG"
            # Ajoutez ici les commandes pour installer le programme
            if [ "$optionAll" -eq 0 ]; then
                 echo "Construction du programme avec version $VERSION et mode debug $DEBUG"
                # Ajoutez ici les commandes pour la construction du programme
                directory="./"         # chemin a remplacer en fonction de son 

                # List des sous dossiers qui contiennent le fichier "asde.yaml"
                listFolder=$(find "$directory" -mindepth 1 -maxdepth 1 -type d -exec test -e '{}/asde.yaml' \; -print)
                #echo "$listFolder"

                if [ "$listFolder" ]; then
                    for element in $listFolder; do
                         # je peux rajouter option par type de programme
                         services_length=$(yq eval '.services | length' $element/asde.yaml)

                            for ((i = 0; i < services_length; i++)); do
                                nameService=$(yq eval ".services[$i].name" $element/asde.yaml)
                                action_length=$(yq eval ".services[$i].actions | length" $element/asde.yaml)
                                for ((j = 0; j < action_length; j++)) ; do
                                    action=$(yq eval ".services[$i].actions[$j].action" $element/asde.yaml) 
                                        
                                    if [ "$action" = "install" ]; then
                                        cmd=$(yq e ".services[$i].actions[$j].types[].details.cmd" "$element/asde.yaml")
                                        cwd=$(yq e ".services[$i].actions[$j].types[].details.cwd" "$element/asde.yaml")

                                        echo "Ce service viens du fichier $element/asde.yaml"
                                        echo " $nameService va éxecuter la command install "
                                        echo
                                            cd $cwd
                                            $cmd      
                                            if [ $? -eq 0 ]; then
                                                echo "Installation bien éxècuter"
                                            else
                                                echo "Une erreur c'est produite lors de l'installation"
                                                usage
                                            fi
                                        echo
                                    else
                                        echo "$action"
                                        echo "Ce service viens du fichier $element/asde.yaml"
                                        echo " $nameService ne contient pas de command install "
                                        echo
                                    fi
                                done

                            done
                    done
                else
                    echo " Vos dossiers ne contiennent pas le fichier de configuration 'asde.yaml' "
                fi
            fi
            ;;
        exec)
            if [[ -z $2 ]]; then
                echo "Veuillez spécifier un programme à exécuter."
                usage
            else
                PROGRAM="$2"
                echo "Exécution du programme $PROGRAM avec version $VERSION et mode debug $DEBUG"
                # Ajoutez ici les commandes pour exécuter le programme spécifié
            fi
            # if [ "$optImage" -eq 0 ]; then
            #     echo "image"
            # fi
            ;;  
        *)
            echo "Commande(s) spécifiée(s): $@"
            # Ajoutez ici le traitement spécifique aux autres commandes
            usage
            ;;
    esac
else
    echo "Aucune commande spécifiée."
    usage
fi


