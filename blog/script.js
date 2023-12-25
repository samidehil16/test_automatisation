const Docker = require('dockerode');
const { exit } = require('node:process');
const docker = new Docker();
const path = require('path');
const readline = require('node:readline').createInterface({
  input: process.stdin,
  output: process.stdout,
});





// Fonction pour démarrer un service Docker
async function startDockerService(imageName, containerName, startCommand) {
  try {
    const container = await docker.createContainer({
      Image: imageName,
      name: containerName,
      Cmd: startCommand.split(' '),
    });
    await container.start();
    console.log(`Service Docker ${containerName} démarré avec succès.`);
    return container;
  } catch (err) {
    console.error('Erreur lors du démarrage du service Docker :', err);
    return null;
  }
}







// Construction de l'image à partir du répertoire contextuel

 function buildImage(contextPath ,imageName){

   docker.buildImage({ context: contextPath, src: ['Dockerfile'], t: imageName }, (error, stream) => {
      if (error) {
          console.error('Erreur lors de la construction de l\'image :', error);
          return;
      }

      // Affichage des logs de construction de l'image
      docker.modem.followProgress(stream, onFinished);

      function onFinished(err, output) {
          if (err) {
              console.error('Erreur lors de la construction de l\'image :', err);
          } else {
              console.log('Image construite avec succès :', output);
          }
      }
  });

}



// Fonction pour tester un service Docker
function testServiceDocker(idContainer) {
  const res = docker.getContainer(idContainer)
  let state = '';
  const info = res.inspect((err,data)=>{
    if(err){
      console.log(err)
    } else state = data.State.Status
  })
  console.log(`Test du service Docker ${res.id}.`);
  console.log(`État du service ${res.id} : ${state}`);
}

// Exemple : Déploiement et test d'un microservice
async function deployAndTestMicroservice() {
  const serviceName = ""; // Nom de votre service
  const imageName = ""; // Nom de l'image Docker
  const startCommand = 'npm start'; // Commande pour démarrer votre service

  console.log(`Déploiement de ${serviceName}...`);
  const container = await startDockerService(imageName, serviceName, startCommand);

  if (container) {
    testServiceDocker(container);

    setTimeout(async () => {
      await stopDockerService(container); // Arrêt du service après les tests
    }, 5000); 
  } else {
    console.log('Le déploiement du service a échoué.');
  }
}

// Appel de la fonction pour déployer et tester un microservice
 //deployAndTestMicroservice();

// Fonction pour supprimer un service Docker
async function RemoveDockerService(container) {
  try {
    await container.stop(); // fonction de dockerode qui stop un container
    await container.remove(); // fonction de dockerode qui supprime un container
    console.log(`Service Docker ${container.id} arrêté et supprimé.`);
  } catch (err) {
    console.error('Erreur lors de l\'arrêt du service Docker :', err);
  }
}

async function stopDockerService(container) {
  try {
    await container.stop(); // fonction de dockerode qui stop un container
    console.log(`Service Docker ${container.id} arrêté et supprimé.`);
  } catch (err) {
    console.error('Erreur lors de l\'arrêt du service Docker :', err);
  }
}


 function automatisation(){

  readline.question(' What do you want? \n', expr =>{ // permet de crée une intéraction dans un terminal et de récupérer la réponse
    switch(expr) {

      case'create-build-image':
            
            readline.question('Take me name of Docker image \n', name =>{
              const options = {
                t: name // Nom et tag de l'image à construire
            };
              readline.question('What is your path to the DockerFile ? \n', dirname =>{
                const contextPath = path.resolve(__dirname, dirname);
                  console.log(options.t);
                  buildImage(contextPath,name);
              })
            });
        break;
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

      case'remove-container':
            readline.question('Number of container please ? \n',answer =>{
              var container = docker.getContainer(answer); // récuparation du container par ID
              if (container) {
                RemoveDockerService(container); // permet de supprimer un container
              } else console.log("Ce container existe pas") 
                      
            });
            
      break;
      
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
      
      case'exit':
            exit(); // Permet de quitter le srcipt
      break;

      default: 
        readline.question('Are you finish ? \n',answer =>{
          if (answer === "yes") {
            exit();
          } else automatisation();
        });
    }
  })

 }

 automatisation();