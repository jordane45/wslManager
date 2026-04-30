# WSL Manager - TODO V2

## Objectif

Ajouter une organisation visuelle des instances WSL par groupes et remplacer l'affichage principal en liste par une grille responsive.

## Suivi

- [x] V2-001 - Creer ce fichier de suivi `TODO_v2.md`
- [x] V2-002 - Ajouter un modele local pour les groupes d'instances
- [x] V2-003 - Ajouter un service de persistance `groups.json`
- [x] V2-004 - Ajouter un provider Riverpod pour charger/sauvegarder les groupes
- [x] V2-005 - Remplacer la liste du dashboard par une grille responsive
- [x] V2-006 - Regrouper les instances par groupe avec section repliable
- [x] V2-007 - Ajouter l'action "Creer un groupe"
- [x] V2-008 - Ajouter l'action "Changer de groupe" sur chaque instance
- [x] V2-009 - Gerer les instances sans groupe dans "Non classees"
- [x] V2-010 - Verifier la compilation/analyse quand l'environnement Flutter le permet

## Verification

- `git diff --check -- wsl_manager/lib wsl_manager_output/TODO_v2.md` : OK
- `dart analyze` via le SDK Flutter direct : OK, aucun probleme detecte
- `flutter analyze` via le wrapper Flutter reste bloque dans ce shell par `Unable to find git in your PATH`

## Design fonctionnel

### Groupes

- Un groupe est une preference locale de l'application, pas une propriete WSL.
- Une instance appartient a zero ou un groupe.
- Les instances sans affectation sont affichees dans le groupe virtuel "Non classees".
- Les groupes peuvent etre replies/deplies.

### Stockage

Fichier cible dans le dossier AppData de l'application :

```json
{
  "version": 1,
  "groups": [
    {
      "id": "dev",
      "name": "Dev",
      "order": 0,
      "collapsed": false
    }
  ],
  "assignments": {
    "Ubuntu-22.04": "dev"
  }
}
```

### Dashboard

- Conserver la recherche.
- Conserver le tri.
- Ajouter un bouton de creation de groupe.
- Afficher chaque groupe sous forme de section.
- Afficher les instances en grille responsive.
- Adapter les cartes d'instances a une largeur de grille.

## Hors perimetre de cette passe

- Drag and drop entre groupes.
- Ordonnancement manuel des instances.
- Multi-affectation d'une instance a plusieurs groupes.
- Synchronisation des groupes entre machines.
