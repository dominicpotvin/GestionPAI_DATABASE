-- Activer le mode d'affichage en colonnes et les en-têtes pour une meilleure lisibilité
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

-- Lier avec la table fournisseurs existante (si applicable)
.print "\n--- Établir les liens avec les fournisseurs ---"
.print "Pour lier les produits aux fournisseurs, vous pouvez exécuter une requête comme:"
.print "UPDATE produits SET fournisseur_id = (SELECT id FROM fournisseurs WHERE entreprise = 'NOM_FOURNISSEUR') WHERE code_fournisseur = 'CODE_SPECIFIQUE';"

-- Exemples de requêtes utiles
.print "\n--- Exemples de requêtes utiles ---"
.print "1. Liste des produits par catégorie:"
SELECT c.nom_categorie, COUNT(p.id) AS nombre_produits 
FROM categories c
LEFT JOIN produits p ON c.id = p.categorie_id
GROUP BY c.nom_categorie
ORDER BY nombre_produits DESC;

.print "\n2. Produits avec leurs dimensions:"
SELECT p.id, p.description, d.dimension1, d.dimension2, d.dimension3, d.longueur, d.unite
FROM produits p
JOIN dimensions_produits d ON p.id = d.produit_id
WHERE d.dimension1 IS NOT NULL
LIMIT 10;

.print "\n3. Historique des prix par produit:"
SELECT p.description, h.prix, h.date_changement
FROM produits p
JOIN historique_prix h ON p.id = h.produit_id
ORDER BY h.date_changement DESC
LIMIT 10;
