// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract GestionRisqueContrepartie {
    // Structure pour représenter une contrepartie
    struct Contrepartie {
        address portefeuille;
        uint256 scoreCredit;
        uint256 limiteExposition;
        uint256 expositionCourante;
        bool estActif;
    }

    // Mapping pour stocker les contreparties
    mapping(address => Contrepartie) public contreparties;
    
    // Mapping pour suivre les expositions entre contreparties
    mapping(address => mapping(address => uint256)) public expositions;

    // Événements pour tracer les actions importantes
    event ContrepartieAjoutee(address indexed contrepartie, uint256 limiteExposition);
    event ExpositionMiseAJour(address indexed contrepartie, uint256 nouvelleExposition);
    event LimiteDepassee(address indexed contrepartie, uint256 exposition);

    // Modificateur pour vérifier si une contrepartie est active
    modifier contrepartieActive(address _adresse) {
        require(contreparties[_adresse].estActif, "Contrepartie inactive");
        _;
    }

    // Fonction pour ajouter une nouvelle contrepartie
    function ajouterContrepartie(
        address _portefeuille, 
        uint256 _scoreCredit, 
        uint256 _limiteExposition
    ) public {
        require(_portefeuille != address(0), "Adresse invalide");
        require(!contreparties[_portefeuille].estActif, "Contrepartie deja existante");

        contreparties[_portefeuille] = Contrepartie({
            portefeuille: _portefeuille,
            scoreCredit: _scoreCredit,
            limiteExposition: _limiteExposition,
            expositionCourante: 0,
            estActif: true
        });

        emit ContrepartieAjoutee(_portefeuille, _limiteExposition);
    }

    // Fonction pour mettre à jour l'exposition
    function mettreAJourExposition(
        address _contrepartie, 
        uint256 _nouvelleExposition
    ) public contrepartieActive(_contrepartie) {
        Contrepartie storage contrepartie = contreparties[_contrepartie];
        
        // Vérifier si la nouvelle exposition dépasse la limite
        require(
            _nouvelleExposition <= contrepartie.limiteExposition, 
            "Limite d'exposition depassee"
        );

        contrepartie.expositionCourante = _nouvelleExposition;

        // Émettre un événement si proche de la limite
        if (_nouvelleExposition >= (contrepartie.limiteExposition * 90 / 100)) {
            emit LimiteDepassee(_contrepartie, _nouvelleExposition);
        }

        emit ExpositionMiseAJour(_contrepartie, _nouvelleExposition);
    }

    // Fonction de calcul de risque
    function calculerRisque(address _contrepartie) public view returns (uint256) {
        Contrepartie memory contrepartie = contreparties[_contrepartie];
        
        // Calcul du score de risque
        uint256 scoreRisque = (contrepartie.expositionCourante * 100 / contrepartie.limiteExposition) 
                               / contrepartie.scoreCredit;
        
        return scoreRisque;
    }

    // Fonction pour vérifier le statut de la contrepartie
    function verifierStatutContrepartie(address _contrepartie) public view returns (bool) {
        Contrepartie memory contrepartie = contreparties[_contrepartie];
        
        return (
            contrepartie.estActif && 
            contrepartie.expositionCourante <= contrepartie.limiteExposition
        );
    }
}