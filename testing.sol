// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./GestionRisqueContrepartie.sol";

contract TestGestionRisqueContrepartie {
    GestionRisqueContrepartie public contratRisque;
    address public proprietaire;
    address public contrepartieTest;

    constructor() {
        contratRisque = new GestionRisqueContrepartie();
        proprietaire = msg.sender;
        contrepartieTest = address(0x123);
    }

    // Test d'ajout de contrepartie
    function testerAjoutContrepartie() public {
        contratRisque.ajouterContrepartie(contrepartieTest, 80, 10000);
        
        // Récupérer et vérifier les informations de la contrepartie
        (
            address portefeuille, 
            uint256 scoreCredit, 
            uint256 limiteExposition, 
            uint256 expositionCourante, 
            bool estActif
        ) = contratRisque.contreparties(contrepartieTest);
        
        // Utiliser explicitement chaque variable pour éviter les avertissements
        require(portefeuille == contrepartieTest, "Adresse de portefeuille incorrecte");
        require(scoreCredit == 80, "Score de credit incorrect");
        require(limiteExposition == 10000, "Limite d'exposition incorrecte");
        require(expositionCourante == 0, "Exposition initiale devrait etre zero");
        require(estActif == true, "La contrepartie devrait etre active");
    }

    // Test de mise à jour d'exposition
    function testerMiseAJourExposition() public {
        // D'abord ajouter la contrepartie
        contratRisque.ajouterContrepartie(contrepartieTest, 80, 10000);
        
        // Mettre à jour l'exposition
        contratRisque.mettreAJourExposition(contrepartieTest, 5000);
        
        // Vérifier l'exposition
        (, , , uint256 expositionCourante, ) = contratRisque.contreparties(contrepartieTest);
        require(expositionCourante == 5000, "Exposition incorrecte");
    }

    // Test de calcul de risque
    function testerCalculRisque() public {
        contratRisque.ajouterContrepartie(contrepartieTest, 80, 10000);
        contratRisque.mettreAJourExposition(contrepartieTest, 5000);
        
        uint256 scoreRisque = contratRisque.calculerRisque(contrepartieTest);
        
        // Vérification du calcul de risque
        require(scoreRisque > 0, "Score de risque devrait etre positif");
    }

    // Test de vérification de statut
    function testerVerificationStatut() public {
        contratRisque.ajouterContrepartie(contrepartieTest, 80, 10000);
        contratRisque.mettreAJourExposition(contrepartieTest, 5000);
        
        bool statut = contratRisque.verifierStatutContrepartie(contrepartieTest);
        require(statut == true, "Le statut devrait etre actif");
    }

    // Test de gestion des erreurs
    function testerErreurDepassementLimite() public {
        contratRisque.ajouterContrepartie(contrepartieTest, 80, 10000);
        
        // Ce test devrait échouer si l'exposition dépasse la limite
        try contratRisque.mettreAJourExposition(contrepartieTest, 15000) {
            require(false, "Devrait echouer pour depassement de limite");
        } catch Error(string memory) {
            // Test réussi si une erreur est levée
        }
    }
}