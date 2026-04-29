# CHANGES.md — WSL Manager

## Version 1.0.0 — Livrable initial

**Date** : 2025-04-29
**Auteur** : Jordane REYNET (assisté par Claude)

---

## Contexte

Ce ZIP remplace et enrichit l'étude initiale réalisée avec ChatGPT,
qui ne contenait qu'un `TODO.md` de 9 lignes et un `UI_Mockups.md` textuel non actionnable.

---

## Fichiers créés

| Fichier                    | Description                                              |
|----------------------------|----------------------------------------------------------|
| `TODO.md`                  | Guide de développement complet (144 tâches, 13 épiques)  |
| `README.md`                | Présentation du projet et commandes de base              |
| `docs/installation.md`     | Instructions d'installation environnement de dev         |
| `docs/commandes.md`        | Référence des commandes Flutter, WSL, Dart               |
| `CHANGES.md`               | Ce fichier                                               |

## Fichiers supprimés (remplacés)

| Fichier          | Raison                                                             |
|------------------|--------------------------------------------------------------------|
| `TODO.md` (v0)   | Remplacé par la version complète et actionnable                    |
| `UI_Mockups.md`  | Intégré sous forme de descriptions d'écrans dans le `TODO.md`     |

---

## Ajouts fonctionnels par rapport à l'étude ChatGPT

Les fonctionnalités suivantes ont été ajoutées au périmètre V1 :

- **Éditeur wsl.conf intégré** par instance
- **Onglet Snapshots** dans le détail d'une instance
- **Détection WSL1 vs WSL2** + conversion depuis l'interface
- **Définir la distro par défaut** WSL
- **Reset mot de passe utilisateur** depuis l'interface
- **Ouverture Windows Terminal** en plus de VSCode et Explorateur
- **Icône systray** avec menu contextuel et accès rapide start/stop
- **UacBanner** — élévation à la demande, non obligatoire au démarrage
- **Mode mock WslService** pour le développement sans WSL
- **Lecture IP de l'instance** depuis /proc/net/fib_trie
- **Lecture taille de l'image disque** (ext4.vhdx)

## Fonctionnalités déplacées en V2

- Graphiques historiques CPU/RAM
- Alertes seuils CPU/RAM (notifications toast)
- Affichage des ports forwardés
- Éditeur `.wslconfig` global
- i18n (préparation structure en V1)
- Mise à jour automatique de l'application
