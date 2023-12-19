const Docker = require('dockerode');
const docker = new Docker();

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

// Fonction pour arrêter un service Docker
async function stopDockerService(container) {
  try {
    await container.stop();
    await container.remove();
    console.log(`Service Docker ${container.id} arrêté et supprimé.`);
  } catch (err) {
    console.error('Erreur lors de l\'arrêt du service Docker :', err);
  }
}

// Fonction pour tester un service Docker
function testService(container) {
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
    testService(container);

    setTimeout(async () => {
      await stopDockerService(container); // Arrêt du service après les tests
    }, 5000); 
  } else {
    console.log('Le déploiement du service a échoué.');
  }
}

// Appel de la fonction pour déployer et tester un microservice
deployAndTestMicroservice();
