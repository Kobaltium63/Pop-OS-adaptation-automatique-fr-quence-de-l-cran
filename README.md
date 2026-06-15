script vibe codé d'automatisation permettant de faire varier la fréquence de l'écran lorsque la machine est en charge

# Pop-OS-adaptation-automatique-fr-quence-de-l-cran-pour-Wayland

Petit utilitaire pour **Pop!_OS / Wayland** permettant de changer automatiquement la fréquence de rafraîchissement de l'écran interne selon l'état du chargeur.

Dans la version décrite ici, le comportement est le suivant :
- **144 Hz** quand le chargeur est branché ;
- **60 Hz** quand le chargeur est débranché.

L'outil repose sur un script shell et une règle **udev** pour déclencher automatiquement `cosmic-randr` lorsque l'état de l'alimentation change.

## Fonctionnement

Le script installé lit l'état du chargeur dans un fichier système comme :

```bash
/sys/class/power_supply/ACAD/online
```

Puis applique l'une de ces commandes :

```bash
cosmic-randr mode --refresh 144 eDP-1 1920 1080
cosmic-randr mode --refresh 60 eDP-1 1920 1080
```

Une règle **udev** déclenche ensuite automatiquement le script quand le chargeur est branché ou débranché[1][2].

## Fichiers installés

Le script d'installation crée les fichiers suivants :

- `/usr/local/bin/power-refresh-cosmic.sh`
- `/etc/udev/rules.d/99-power-refresh-cosmic.rules`

Ces fichiers permettent respectivement :
- d'appliquer la bonne fréquence selon l'état du chargeur ;
- de déclencher automatiquement cette action au changement d'alimentation[3][1].

## Installation

Utiliser le script d'installation :

```bash
chmod +x install-power-refresh.sh
sudo ./install-power-refresh.sh
```

Le script :
- installe le script principal dans `/usr/local/bin` ;
- ajoute une règle `udev` dans `/etc/udev/rules.d` ;
- recharge les règles `udev` pour rendre la configuration active[3][1].

## Désinstallation

Utiliser le script de désinstallation :

```bash
chmod +x uninstall-power-refresh.sh
./uninstall-power-refresh.sh
```

Le script de désinstallation :
- supprime la règle `udev` ;
- supprime le script principal ;
- recharge les règles `udev` pour appliquer immédiatement la suppression[4][3].

## Utilisation

Une fois installé, le comportement est automatique. Pour tester manuellement :

### Vérifier l'état du chargeur

```bash
cat /sys/class/power_supply/ACAD/online
```

- `1` = chargeur branché
- `0` = chargeur débranché

### Lancer le script à la main

```bash
/usr/local/bin/power-refresh-cosmic.sh
```

### Vérifier le résultat

Tu peux ensuite confirmer que la fréquence a bien changé via `cosmic-randr` ou dans les paramètres d'affichage de Pop!_OS.

## Cas d'usage

Cet outil est surtout utile pour :
- gagner un peu d'autonomie sur batterie en revenant automatiquement à 60 Hz ;
- retrouver immédiatement la fluidité maximale sur secteur ;
- éviter de modifier manuellement le taux de rafraîchissement à chaque branchement / débranchement.

## Dépannage

### Le script fonctionne à la main mais pas automatiquement

Dans ce cas, la règle `udev` peut être correcte mais le contexte de session Wayland peut limiter certaines exécutions automatiques. Il peut alors être nécessaire de redémarrer la session ou d'utiliser une autre méthode plus orientée session utilisateur[2].

### Le mauvais périphérique d'alimentation est utilisé

Selon la machine, le nom peut être `AC`, `ACAD`, `Mains` ou autre. Vérifier le contenu de :

```bash
ls /sys/class/power_supply/
```

Puis adapter le script d'installation si besoin.

### Le mauvais écran est ciblé

Le nom de la sortie (`eDP-1`) et la résolution (`1920x1080`) doivent correspondre à la machine réelle. Si nécessaire, adapter la commande `cosmic-randr` dans le script installé.

## Public visé

Cet outil s'adresse surtout aux utilisateurs de **Pop!_OS** sous **Wayland / COSMIC** qui veulent automatiser un changement de fréquence d'écran en fonction du chargeur, sans devoir lancer la commande manuellement à chaque fois.

## Note sur la création et responsabilité

Cet outil a été conçu avec l'aide de **Perplexity**, dans une logique de prototypage rapide et d'automatisation assistée. Il s'agit d'un projet pratique, pensé pour simplifier l'usage de `cosmic-randr` et l'automatisation via `udev`, mais pas d'un logiciel officiellement validé, certifié ou garanti pour tous les matériels, toutes les versions de Pop!_OS ou toutes les configurations d'affichage.

Le créateur met cet outil à disposition de bonne foi, comme une surcouche utilitaire autour d'outils déjà présents sur le système, mais son fonctionnement n'est **pas garanti**. Comme pour beaucoup d'outils distribués en mode libre ou personnel, il doit être considéré comme fourni **"tel quel"**, sans promesse de compatibilité parfaite, d'absence de bug, ni d'adaptation à un usage particulier[5][6]. En conséquence, son utilisation se fait sous la responsabilité de l'utilisateur, qui reste libre de vérifier les commandes exécutées, de relire le code, et de tester le comportement de la configuration sur sa propre machine avant un usage régulier ou sensible[7][8].
