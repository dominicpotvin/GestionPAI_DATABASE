#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Script pour convertir le fichier Excel d'inventaire en fichiers CSV
pour l'importation dans une base de données SQLite.
"""

import pandas as pd
import os
import csv
import re
from datetime import datetime

def clean_value(value):
    """Nettoie les valeurs pour le format CSV"""
    if pd.isna(value) or value is None:
        return ""
    return str(value).strip()

def safe_date_format(date_value):
    """Convertit les dates en format ISO"""
    if pd.isna(date_value) or not date_value:
        return ""
    try:
        if isinstance(date_value, str):
            # Essayer plusieurs formats de date possibles
            for fmt in ('%Y-%m-%d', '%d/%m/%Y', '%m/%d/%Y'):
                try:
                    return datetime.strptime(date_value, fmt).strftime('%Y-%m-%d')
                except ValueError:
                    continue
            return date_value
        # Si c'est déjà un objet datetime
        return date_value.strftime('%Y-%m-%d')
    except:
        return str(date_value)

def main():
    print("Conversion du fichier Excel en fichiers CSV pour SQLite...")
    
    # Définir le chemin du fichier Excel (à modifier selon votre emplacement)
    excel_file = 'Classeur3.xlsx'
    output_dir = 'csv_output'
    
    # Créer le dossier de sortie s'il n'existe pas
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Charger le fichier Excel
    print(f"Chargement du fichier {excel_file}...")
    df = pd.read_excel(excel_file)
    
    # Nettoyer les noms de colonnes
    df.columns = [col.strip() for col in df.columns]
    
    print(f"Nombre total d'enregistrements: {len(df)}")
    
    # 1. Extraire les catégories uniques
    categories = []
    category_map = {}
    
    if 'CATEGORIE' in df.columns:
        unique_categories = sorted(df['CATEGORIE'].dropna().unique())
        for i, category in enumerate(unique_categories, start=1):
            cat_name = clean_value(category)
            if cat_name:
                categories.append({'id': i, 'nom_categorie': cat_name})
                category_map[cat_name] = i
    
    print(f"Catégories extraites: {len(categories)}")
    
    # 2. Préparer les données des produits
    produits = []
    dimensions = []
    stock = []
    historique_prix = []
    
    product_id = 1
    dimension_id = 1
    stock_id = 1
    history_id = 1
    
    for _, row in df.iterrows():
        # Ignorer les lignes vides
        if row.isna().all():
            continue
        
        # Extraire les données du produit
        description = clean_value(row.get('DESCRIPTION', ''))
        if not description:
            continue  # Ignorer les lignes sans description
            
        categorie = clean_value(row.get('CATEGORIE', ''))
        categorie_id = category_map.get(categorie, '')
        
        # Créer l'entrée produit
        produit = {
            'id': product_id,
            'description': description,
            'categorie_id': categorie_id,
            'description_sommaire': clean_value(row.get('DESCRIPTION SOMMAIRE', '')),
            'prix_liste': clean_value(row.get('PRIX DE LISTE', '')),
            'prix_unitaire': clean_value(row.get('PRIX UNITAIRE', '')),
            'quantite_min': clean_value(row.get('QUANTITE MIN', '')),
            'date_mise_a_jour': safe_date_format(row.get('DATE DE MISE A JOUR', '')),
            'fournisseur_id': '',  # À lier ultérieurement
            'code_fournisseur': clean_value(row.get('CODE DE FOURNISSEUR', ''))
        }
        produits.append(produit)
        
        # Extraire les dimensions (si présentes)
        dimension1 = row.get('DIMENTION 1', '')
        dimension2 = row.get('DIMENTION 2', '')
        dimension3 = row.get('DIMENTION 3', '')
        longueur = row.get('LONGUEUR', '')
        
        # Déterminer l'unité (po ou mm) basée sur le contenu
        unite = ''
        if not pd.isna(description):
            if 'MM' in str(description).upper() or 'mm' in str(description):
                unite = 'mm'
            else:
                unite = 'po'
        
        dimensions.append({
            'id': dimension_id,
            'produit_id': product_id,
            'dimension1': clean_value(dimension1),
            'dimension2': clean_value(dimension2),
            'dimension3': clean_value(dimension3),
            'longueur': clean_value(longueur),
            'unite': unite
        })
        dimension_id += 1
        
        # Créer une entrée de stock
        stock.append({
            'id': stock_id,
            'produit_id': product_id,
            'quantite': 0,  # Valeur par défaut
            'localisation': '',
            'projet_id': clean_value(row.get('PROJET', '')),
            'valeur_inventaire': clean_value(row.get('Valeur inventaire 5 avril 2018', 0)),
            'date_derniere_verification': ''
        })
        stock_id += 1
        
        # Ajouter l'historique des prix si disponible
        hist_prix = row.get('historique de prix', '')
        hist_date = row.get('historique de date', '')
        
        if not pd.isna(hist_prix) and not pd.isna(hist_date):
            historique_prix.append({
                'id': history_id,
                'produit_id': product_id,
                'prix': clean_value(hist_prix),
                'date_changement': safe_date_format(hist_date)
            })
            history_id += 1
        
        # Aussi ajouter le prix actuel à l'historique si disponible
        prix_actuel = row.get('PRIX DE LISTE', '')
        date_maj = row.get('DATE DE MISE A JOUR', '')
        
        if not pd.isna(prix_actuel) and not pd.isna(date_maj):
            historique_prix.append({
                'id': history_id,
                'produit_id': product_id,
                'prix': clean_value(prix_actuel),
                'date_changement': safe_date_format(date_maj)
            })
            history_id += 1
        
        product_id += 1
    
    print(f"Produits: {len(produits)}")
    print(f"Dimensions: {len(dimensions)}")
    print(f"Stock: {len(stock)}")
    print(f"Historique prix: {len(historique_prix)}")
    
    # 3. Écrire les fichiers CSV
    def write_csv(filename, data, fieldnames):
        file_path = os.path.join(output_dir, filename)
        with open(file_path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(data)
        print(f"Fichier créé: {file_path}")
    
    # Écrire les catégories
    write_csv('categories.csv', categories, ['id', 'nom_categorie'])
    
    # Écrire les produits
    write_csv('produits.csv', produits, ['id', 'description', 'categorie_id', 'description_sommaire', 
                                      'prix_liste', 'prix_unitaire', 'quantite_min', 'date_mise_a_jour', 
                                      'fournisseur_id', 'code_fournisseur'])
    
    # Écrire les dimensions
    write_csv('dimensions_produits.csv', dimensions, ['id', 'produit_id', 'dimension1', 'dimension2', 
                                                   'dimension3', 'longueur', 'unite'])
    
    # Écrire le stock
    write_csv('stock_produits.csv', stock, ['id', 'produit_id', 'quantite', 'localisation', 
                                         'projet_id', 'valeur_inventaire', 'date_derniere_verification'])
    
    # Écrire l'historique des prix
    write_csv('historique_prix.csv', historique_prix, ['id', 'produit_id', 'prix', 'date_changement'])
    
    # 4. Créer un script SQL pour l'importation
    sql_script = """-- Activer le mode d'affichage en colonnes et les en-têtes pour une meilleure lisibilité
.mode column
.headers on

-- Activer les contraintes de clés étrangères
PRAGMA foreign_keys = ON;

-- Effacer les données existantes des tables pour éviter les doublons
DELETE FROM historique_prix;
DELETE FROM stock_produits;
DELETE FROM dimensions_produits;
DELETE FROM produits;
DELETE FROM categories;

-- Importer les catégories
.mode csv
.headers on
.import categories.csv categories

-- Importer les produits
.mode csv
.headers on
.import produits.csv produits

-- Importer les dimensions des produits
.mode csv
.headers on
.import dimensions_produits.csv dimensions_produits

-- Importer les données de stock
.mode csv
.headers on
.import stock_produits.csv stock_produits

-- Importer l'historique des prix
.mode csv
.headers on
.import historique_prix.csv historique_prix

-- Vérifier que l'importation a fonctionné
.print "\\n--- Nombre d'enregistrements par table ---"
SELECT 'Categories' AS table_name, COUNT(*) AS record_count FROM categories
UNION ALL
SELECT 'Produits', COUNT(*) FROM produits
UNION ALL
SELECT 'Dimensions', COUNT(*) FROM dimensions_produits
UNION ALL
SELECT 'Stock', COUNT(*) FROM stock_produits
UNION ALL
SELECT 'Historique Prix', COUNT(*) FROM historique_prix;

-- Lier avec la table fournisseurs existante (si applicable)
.print "\\n--- Établir les liens avec les fournisseurs ---"
.print "Pour lier les produits aux fournisseurs, vous pouvez exécuter une requête comme:"
.print "UPDATE produits SET fournisseur_id = (SELECT id FROM fournisseurs WHERE entreprise = 'NOM_FOURNISSEUR') WHERE code_fournisseur = 'CODE_SPECIFIQUE';"

-- Exemples de requêtes utiles
.print "\\n--- Exemples de requêtes utiles ---"
.print "1. Liste des produits par catégorie:"
SELECT c.nom_categorie, COUNT(p.id) AS nombre_produits 
FROM categories c
LEFT JOIN produits p ON c.id = p.categorie_id
GROUP BY c.nom_categorie
ORDER BY nombre_produits DESC;

.print "\\n2. Produits avec leurs dimensions:"
SELECT p.id, p.description, d.dimension1, d.dimension2, d.dimension3, d.longueur, d.unite
FROM produits p
JOIN dimensions_produits d ON p.id = d.produit_id
WHERE d.dimension1 IS NOT NULL
LIMIT 10;

.print "\\n3. Historique des prix par produit:"
SELECT p.description, h.prix, h.date_changement
FROM produits p
JOIN historique_prix h ON p.id = h.produit_id
ORDER BY h.date_changement DESC
LIMIT 10;
"""
    
    with open(os.path.join(output_dir, 'import_donnees.sql'), 'w', encoding='utf-8') as f:
        f.write(sql_script)
    print("Script SQL d'importation créé")
    
    print("\nConversion terminée! Les fichiers CSV ont été générés dans le dossier:", output_dir)
    print("Pour les importer dans SQLite, placez-les dans le même dossier que votre base de données")
    print("et exécutez le script 'import_donnees.sql'")

if __name__ == "__main__":
    main()