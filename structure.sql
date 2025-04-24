CREATE TABLE sqlite_sequence(name,seq);
CREATE TABLE commandes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  numero_commande TEXT NOT NULL,
  date_commande DATE NOT NULL,
  fournisseur_id INTEGER,
  projet_id INTEGER,
  montant_total REAL,
  statut TEXT CHECK(statut IN ('En attente', 'Confirmée', 'Expédiée', 'Reçue', 'Annulée')),
  date_livraison_prevue DATE,
  date_livraison_reelle DATE,
  notes TEXT,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (fournisseur_id) REFERENCES fournisseurs(id),
  FOREIGN KEY (projet_id) REFERENCES projets(id)
);
CREATE TABLE articles_commande (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  commande_id INTEGER NOT NULL,
  description TEXT NOT NULL,
  quantite INTEGER NOT NULL,
  prix_unitaire REAL,
  unite TEXT,
  sous_total REAL,
  statut TEXT CHECK(statut IN ('En attente', 'Reçu', 'Partiel', 'Retour')),
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (commande_id) REFERENCES commandes(id)
);
CREATE TABLE dessins (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  numero TEXT NOT NULL,
  titre TEXT NOT NULL,
  description TEXT,
  projet_id INTEGER,
  document_id INTEGER,
  revision TEXT,
  statut TEXT CHECK(statut IN ('Brouillon', 'En revue', 'Approuvé', 'Production', 'Archivé')),
  dessinateur TEXT,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (projet_id) REFERENCES projets(id),
  FOREIGN KEY (document_id) REFERENCES documents(id)
);
CREATE INDEX idx_commandes_fournisseur ON commandes(fournisseur_id);
CREATE INDEX idx_commandes_projet ON commandes(projet_id);
CREATE INDEX idx_dessins_projet ON dessins(projet_id);
CREATE TABLE clients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nom TEXT NOT NULL,
  adresse TEXT,
  ville TEXT,
  code_postal TEXT,
  telephone TEXT,
  email TEXT,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE projets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nom TEXT NOT NULL,
  description TEXT,
  client_id INTEGER,
  date_debut DATE,
  date_fin DATE,
  statut TEXT,
  FOREIGN KEY (client_id) REFERENCES clients(id)
);
CREATE TABLE documents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nom TEXT NOT NULL,
  chemin_fichier TEXT NOT NULL,
  type TEXT,
  projet_id INTEGER,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (projet_id) REFERENCES projets(id)
);
CREATE TABLE fournisseurs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entreprise TEXT NOT NULL,
  adresse TEXT,
  ville TEXT,
  code_postal TEXT,
  contact TEXT,
  telephone TEXT,
  poste TEXT,
  fax TEXT,
  email TEXT
);
CREATE VIEW vue_projets_actifs AS
SELECT p.id, p.nom as projet, c.nom as client, p.date_debut, p.date_fin, p.statut
FROM projets p
JOIN clients c ON p.client_id = c.id
WHERE p.statut != 'Terminé' AND p.statut != 'Annulé'
/* vue_projets_actifs(id,projet,client,date_debut,date_fin,statut) */;
CREATE TABLE categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nom_categorie TEXT UNIQUE NOT NULL
);
CREATE TABLE produits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  description TEXT NOT NULL,
  categorie_id INTEGER,
  description_sommaire TEXT,
  prix_liste REAL,
  prix_unitaire REAL,
  quantite_min INTEGER,
  date_mise_a_jour TIMESTAMP,
  fournisseur_id INTEGER,
  code_fournisseur TEXT,
  FOREIGN KEY (categorie_id) REFERENCES categories(id),
  FOREIGN KEY (fournisseur_id) REFERENCES fournisseurs(id)
);
CREATE TABLE dimensions_produits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  produit_id INTEGER NOT NULL,
  dimension1 REAL,
  dimension2 REAL,
  dimension3 REAL,
  longueur REAL,
  unite TEXT,
  FOREIGN KEY (produit_id) REFERENCES produits(id)
);
CREATE TABLE historique_prix (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  produit_id INTEGER NOT NULL,
  prix REAL NOT NULL,
  date_changement TIMESTAMP NOT NULL,
  FOREIGN KEY (produit_id) REFERENCES produits(id)
);
CREATE TABLE stock_produits (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  produit_id INTEGER NOT NULL,
  quantite INTEGER DEFAULT 0,
  localisation TEXT,
  projet_id INTEGER,
  valeur_inventaire REAL,
  date_derniere_verification TIMESTAMP,
  FOREIGN KEY (produit_id) REFERENCES produits(id),
  FOREIGN KEY (projet_id) REFERENCES projets(id)
);
