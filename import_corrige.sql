-- Désactiver temporairement les contraintes de clés étrangères
PRAGMA foreign_keys = OFF;

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

-- Supprimer les lignes d'en-têtes qui ont été importées
DELETE FROM categories WHERE nom_categorie = 'nom_categorie';
DELETE FROM produits WHERE description = 'description';
DELETE FROM dimensions_produits WHERE produit_id = 'produit_id';
DELETE FROM stock_produits WHERE produit_id = 'produit_id';
DELETE FROM historique_prix WHERE produit_id = 'produit_id';

-- Réactiver les contraintes de clés étrangères
PRAGMA foreign_keys = ON;

-- Vérifier que l'importation a fonctionné
.print "\n--- Nombre d'enregistrements par table ---"
SELECT 'Categories' AS table_name, COUNT(*) AS record_count FROM categories
UNION ALL
SELECT 'Produits', COUNT(*) FROM produits
UNION ALL
SELECT 'Dimensions', COUNT(*) FROM dimensions_produits
UNION ALL
SELECT 'Stock', COUNT(*) FROM stock_produits
UNION ALL
SELECT 'Historique Prix', COUNT(*) FROM historique_prix;