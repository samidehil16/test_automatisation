
# Script_automatisation

An automated script that allows you to deploy Docker services and manage and test micro-services




## Requirements

* Dockerode 

  `npm install dockerode`

  

## Getting Started

This script will allow us to automate tasks with short and simple commands via the command terminal.To start the script you will need to execute `node script.js` in the command terminal while being in the correct folder.

At the first interaction you will have the choice between multiple integration :  

- `create-build-image` : its allows to build a docker image.    
  
  ```````
   case'create-build-image':
            
            readline.question('Take me name of Docker image \n', name =>{
              const options = {
                t: name // Nom et tag de l'image à construire
            };
              readline.question('What is your path to the DockerFile ? \n', dirname =>{
                const contextPath = path.resolve(__dirname, dirname);
                  console.log(options.t);
                  buildImage(contextPath);
              })
            });
            
            break;
  ````````

- `start-container` : To start a container.   

  ````````
    case'start-container':
              readline.question('Number of container please ? \n',answer =>{
                var container = docker.getContainer(answer); // récuparation du container par ID
                container.start((err,data)=>{   //démarrage container
                  console.log(data)   
                });
              });
              setTimeout(()=>{
                automatisation();
              },4000)
          break;
  ````````

- `stop-container` : To stop a container.   

  ``````````
    case'stop-container':
                readline.question('Number of container please ? \n',answer =>{
                  var container = docker.getContainer(answer); // récuparation du container par ID
                  if (container) {
                    container.stop((err,data)=>{ // stop le container
                      console.log(data);
                    });
                  } else console.log("Ce container existe pas") 
                          
                });
            break;

  ``````````

- `remove-container` : To remove a container.  

  ``````````
    case'remove-container':
            readline.question('Number of container please ? \n',answer =>{
              var container = docker.getContainer(answer); // récuparation du container par ID
              if (container) {
                RemoveDockerService(container); // permet de supprimer un container
              } else console.log("Ce container existe pas") 
                      
            });
            
      break;  

  ``````````
- `info-container-service` : to retrieve container and system information.
  
  ```````````
  case'info-container-service':
          readline.question('Number of container please ? \n',answer =>{
          var container = docker.getContainer(answer); // récuparation du container par ID
          if (container) {
            container.inspect((err,data)=>{  // afficher info container du service
              console.log(data);
            });
          } else console.log("This container does not exist")               
        });
        break;
  ```````````
- `exit` : to exit script.

## Functions

* startDockerService( imageName, containerName, startCommand)  
* buildImage( contextPath, imageName)
* testServiceDocker(idContainer)
* deployAndTestMicroservice()
* RemoveDockerService(container)
* stopDockerService(container)
* automatisation()

#### Dockerode  

 * docker.getContainer(idContainer)
