# TODO V2.2 - Démarrage des fonctionnalités V2

## Objectif

Ouvrir le chantier V2 avec des fonctionnalités incrémentales, testables et compatibles avec l'application portable Windows.

## Priorité 1 - Fondations utiles

- [ ] Internationalisation i18n EN/FR
  - [x] Ajouter la structure `AppLocalizations`
  - [x] Prévoir les premières clés pour les écrans principaux
  - [x] Ajouter le choix de langue système/FR/EN dans les paramètres
  - [ ] Basculer progressivement les libellés codés en dur
- [x] Export configuration complète en ZIP
  - [x] Inclure `config.json`, `templates.json`, `snapshots.json`, `groups.json`
  - [x] Inclure les dossiers `templates/` et `snapshots/`
  - [x] Ajouter une action dans les paramètres
  - [x] Afficher succès/erreur utilisateur

## Priorité 2 - Monitoring et observabilité

- [x] Graphiques historiques CPU/RAM sur 5 minutes
  - [x] Stocker un historique glissant par instance
  - [x] Ajouter une visualisation dans l'onglet Monitoring
- [ ] Alertes CPU/RAM avec notification Windows toast
  - [ ] Définir les seuils dans les paramètres
  - [ ] Déclencher une notification sur dépassement prolongé
- [ ] Détection et affichage des ports forwardés par instance
  - [ ] Explorer les sources fiables côté WSL/Windows
  - [ ] Afficher les ports dans le détail d'instance

## Priorité 3 - Administration avancée

- [ ] Éditeur `.wslconfig` global
  - [ ] Localiser le fichier utilisateur Windows
  - [ ] Éditer les limites CPU/RAM/swap
  - [ ] Proposer une validation minimale avant sauvegarde
- [ ] Scripts de démarrage automatique par instance
  - [ ] Stocker les scripts par instance
  - [ ] Exécuter au démarrage de l'instance
  - [ ] Afficher les erreurs d'exécution
- [ ] Intégration Git dans `InstanceCard`
  - [ ] Détecter la branche courante pour un chemin configuré
  - [ ] Afficher la branche sans ralentir le dashboard
- [ ] Mode multi-postes
  - [ ] Partager les templates via un dossier réseau
  - [ ] Gérer les conflits et indisponibilités réseau

## Priorité 4 - Distribution

- [ ] Mise à jour automatique de l'application
  - [ ] Définir la source des releases
  - [ ] Vérifier la signature ou l'intégrité du téléchargement
  - [ ] Prévoir un rollback simple

## Démarrage prévu

- [x] Commencer par l'export configuration complète en ZIP, car la dépendance `archive` existe déjà.
- [x] Ensuite, préparer la structure i18n pour faciliter les changements d'interface à venir.
