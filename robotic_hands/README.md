# Guide d'utilisation des mains robotiques avec Arduino Uno

Arduino Uno est un microcontrolleur qui permet de controller des éléments mécaniques pour créer des systèmes automatiques par exemple. (voir documentation https://www.arduino.cc/en/Guide/ArduinoUno)

Après installation des prérequis (IDE Arduino, Pilotes de la carte...), branchez les deux mains robotiques.

## Utilisation avec MATLAB (Librairie Servo)

MATLAB propose des librairies pour utiliser Arduino. En particulier pour se connecter aux ports et pour utiliser les servomoteurs. Il faut installer ces extensions.

### Connexion

Pour se connecter aux mains et créer un objet arduino associé, il faut utiliser la classe arduino() et lui donner en entrée le port USB auquel la carte Uno est branchée ('COM12' par exemple). Ceci peut être vérifié dans votre gestionnaire des périphériques.
Cette connexion peut être automatisée dans un script.

### Utilisation

Chaque servo moteur est assocé à un PinPWM. Pour déplacer le moteur dans une positon précise, il suffit de créer un objet servo() pour chaque doigt et le déplacer à une position avec writePosition() entre 0 et 1. Malheureusement, les positions [0,1] dépendent des branchements et sont donc différentes (extension, tension) pour chaque doigt. La configuration des mains est sauvegardée dans le fichier hand_config.json pour être utilisée automatiquement et changée.

### Test

Pour tester le fonctionnement des mains, vous pouvez lancer la fonction test_hands() qui prends en entrée le nom du port usb ('COM12' par exemple). Les doigts sont sensés s'activer du pouce à l'auriculaire, de la main droite à la mains gauche. Chaque doigt est sensé se tendre puis s'etendre.

Pour tester l'activation des doigts pour appuyer sur une touche d'un clavier, lancez test_activation() qui prends en entrée le nom du port usb.

