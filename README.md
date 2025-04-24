# Conversion d'inventaire Excel vers SQLite

Ce script Python convertit votre fichier Excel d'inventaire en fichiers CSV correctement formatés pour importation dans votre base de données SQLite. Il génère une structure de données normalisée avec les tables suivantes :
- `categories` - Toutes les catégories de produits
- `produits` - Informations de base sur les produits
- `dimensions_produits` - Dimensions associées à chaque produit
- `stock_produits` - État du stock et valorisation
- `historique_prix` - Historique des prix des produits

## Prérequis

- Python 3.6 ou supérieur
- Les bibliothèques Python suivantes:
  - pandas
  - openpyxl

## Installation des dépendances

```bash
pip install pandas openpyxl
```

## Utilisation

1. Placez votre fichier Excel `Classeur3.xlsx` dans le même dossier que le script
2. Exécutez le script :

```bash
python inventaire_to_csv.py
```

3. Les fichiers CSV seront générés dans un sous-dossier nommé `csv_output`
4. Un script SQL `import_donnees.sql` sera également créé pour faciliter l'importation

## Importation dans SQLite

1. Copiez tous les fichiers CSV et le script SQL dans le dossier où se trouve votre base de données SQLite
2. Ouvrez votre base de données SQLite:

```bash
cd C:\sqlite
./sqlite3.exe E:/DataBase/entreprises.db
```

3. Importez les données en exécutant le script SQL:

```
.read import_donnees.sql
```

## Structure des données

Le script crée la structure suivante:

- `categories.csv`: Toutes les catégories uniques avec leurs identifiants
- `produits.csv`: Tous les produits avec leurs catégories et informations de base
- `dimensions_produits.csv`: Dimensions associées à chaque produit
- `stock_produits.csv`: État du stock pour chaque produit
- `historique_prix.csv`: Historique des prix des produits

## Fonctionnalités

- Extraction automatique de toutes les catégories uniques
- Détection intelligente des unités de mesure (mm ou pouces)
- Normalisation et nettoyage des données pour une importation sans erreur
- Génération d'un script SQL prêt à l'emploi pour l'importation

## Personnalisation

Vous pouvez modifier les paramètres suivants dans le script:

- `excel_file` - Le nom de votre fichier Excel
- `output_dir` - Le dossier où les fichiers CSV seront générés

## Problèmes courants

- **Erreur de format de date**: Si vous rencontrez des erreurs liées aux dates, vérifiez le format de date dans votre fichier Excel
- **Caractères spéciaux**: Le script gère les caractères spéciaux, mais il peut être nécessaire d'ajuster l'encodage