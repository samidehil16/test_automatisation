
# Script_automatisation

An automated script that allows you to deploy Docker services and manage and test micro-services

blog -> "asde.sh"


## Requirements

* "yq" is a command line tool to process YAML files.

````````````
    sudo apt-get update
    sudo apt-get install yq

````````````






  

## Getting Started

This script "asde" will allow you to automate the management of your micro-services and your Docker services thanks to a command execution that will process information contained in the [YAML configuration file](##ConfigYAML) or directly provided by the user as an argument.


  ```````
   ./nom_du_script.sh [options] <commande> [options de commande]
  
  ```````

At the first interaction you will have the choice between multiple integration :  

- `build` : its allows to build micro-serive, a docker image or binary programm .You can have several possibilities with the build option :
`-a |--all` which will allow to build all the programs or then chosir the micro-service folder with the command `-f |--folder` as well as the type of the service has build with `-t |--types`

    
  ```````
    #exemple with --all

        asde buil --all

    #exemple build one micro-service, -f and -t must be utilized

        asde build -f posts -t docker
  ```````

- `test` : To test micro-services.You can have several possibilities with the build option :
`-a |--all` which will allow to test all programm and `--except` to test all programs except the desired services


  ````````
    #exemple with --all

        asde test --all

    #exemple with --all and --except , at the moment three arguments maximum

        asde test --all --except service_1 service_3
  ````````

- `install` : To install a programm.   

  ``````````
    #exemple with --all

        asde install --all

    #exemple with -f

        asde install -f

  ``````````

- `exec` : To exec a programm, service.You can have several possibilities with the build option :
`-a |--all` which will allow to test all programm and `--except` to test all programs except the desired services ,`--image` for run a image  

  ``````````
    #exemple with --all

        asde exec --all

    #exemple

        asde exec --all --image

  ``````````




## Config YAML

The YAML configuration file "asde.yaml" is required for the script to work.
It has a structure to respect, here is an example for each case:

each service will be ordered by its name and it will have actions such as: "build-image" ,"test" and each action will have a type "build-image" can be typed "docker","lxc"...

- `build` : is for example binay programm

`````````````
services:
  - name: serviceBinary 
    actions:        
      - action: build  # for programm "build" "install" "exec" "test"
        types:
          - type: binary
            details:
              name: Program42
              cwd: ./binaries # path of programm
              env:
                SOME_ENV: SOMEVAL           # is env variable
                SECOND_ENV: SOMESECOND_VAL

`````````````

For Node.js service a can take more actions :

- `build-image` : is for docker ,lxc...

- `test` : is for docker ,lxc...

`````````````
services:
  - name: serviceWeb1
    actions:
      - action: build-image  
        types:
          - type: docker
            details:
              name: test/client
              tag: latest
              dockerfilePath: ./client          
      - action: test
        types:
          - type: nodejs
            details:
              path: ./client
              cmd: npm test
              options:
                env: NODE_ENV=test

`````````````

- `run` : for run container docker

````````````````
   - name: serviceWeb9
     actions:
       - action: run
         types:
           - type: docker
             details:
               nameImage: test/posts
               options:
                 ENV_VAR_1: valeur_1
                 port: 8080:80
                 volumes: /chemin/local:/chemin/conteneur

````````````````
## Optimizations

I think the script could be optimized and improved if we go further in error management, better accuracy in the logs.

Managing the arguments of commands , can be with a library/package if it exists would be more convenient.

Being able to check if docker engine is already running or start it as a command would be convenient, because otherwise the script does not work.

