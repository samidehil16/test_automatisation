const Docker = require('dockerode');
const { error } = require('node:console');
const { exit } = require('node:process');
const docker = new Docker();
const readline = require('node:readline').createInterface({
  input: process.stdin,
  output: process.stdout,
});

// readline.question("What's your name?", name => {
//   console.log('name who is', name);
//   readline.close();
// });


async function createBuilImage(__dirname,imageName){
  try{
    let stream = await docker.buildImage({
      context: __dirname,
      src: ['Dockerfile','file1','file2']
    }, {t: imageName}, function (err, response) {
      //console.log(response)
    });

    await new Promise((resolve, reject) => {
      dockerode.modem.followProgress(stream, (err, res) => err ? reject(err) : resolve(res));
    });

  }catch(err) {
    console.log(err);
  }
}

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



// Fonction pour tester un service Docker
function testServiceDocker(container) {
  console.log(`Test du service Docker ${container.id}.`);
  console.log(`État du service ${container.id} : ${container.state}`);
}

// Exemple : Déploiement et test d'un microservice
async function deployAndTestMicroservice() {
  const serviceName = 'client'; // Nom de votre service
  const imageName = 'sami/client:latest'; // Nom de l'image Docker
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

// Fonction pour arrêter un service Docker
async function RemoveDockerService(container) {
  try {
    await container.stop();
    await container.remove();
    console.log(`Service Docker ${container.id} arrêté et supprimé.`);
  } catch (err) {
    console.error('Erreur lors de l\'arrêt du service Docker :', err);
  }
}


 function automatisation(){

  readline.question(' What do you want? \n', expr =>{
    switch(expr) {

      case'create-build-image':
            let imageName ='';
            let directory ='';
            readline.question('Take me name of Docker image \n', name =>{
              imageName = name 
              readline.question('What is your path to the DockerFile ? \n', dirname =>{
                directory = dirname
                createBuilImage(directory,imageName);
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
                RemoveDockerService(container);
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
            exit();
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