-- Activer les contraintes de clés étrangères
PRAGMA foreign_keys = ON;

-- Table des fournisseurs (à partir du fichier Excel)
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
  email TEXT,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des clients
CREATE TABLE clients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nom TEXT NOT NULL,
  adresse TEXT,
  ville TEXT,
  code_postal TEXT,
  telephone TEXT,
  email TEXT,
  site_web TEXT,
  notes TEXT,
  actif INTEGER DEFAULT 1,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table des projets
CREATE TABLE projets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nom TEXT NOT NULL,
  description TEXT,
  client_id INTEGER,
  date_debut DATE,
  date_fin DATE,
  statut TEXT CHECK(statut IN ('En attente', 'En cours', 'Terminé', 'Annulé')),
  budget REAL,
  responsable TEXT,
  priorité TEXT CHECK(priorité IN ('Basse', 'Normale', 'Haute', 'Urgente')),
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (client_id) REFERENCES clients(id)
);

-- Table des commandes
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

-- Table des articles de commande
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

-- Table des documents (dessins, fichiers, etc.)
CREATE TABLE documents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nom TEXT NOT NULL,
  description TEXT,
  chemin_fichier TEXT NOT NULL,
  type_document TEXT,
  taille INTEGER,
  projet_id INTEGER,
  commande_id INTEGER,
  version TEXT,
  auteur TEXT,
  date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (projet_id) REFERENCES projets(id),
  FOREIGN KEY (commande_id) REFERENCES commandes(id)
);

-- Table pour les dessins techniques
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

-- Création d'index pour optimiser les recherches
CREATE INDEX idx_fournisseurs_entreprise ON fournisseurs(entreprise);
CREATE INDEX idx_fournisseurs_ville ON fournisseurs(ville);
CREATE INDEX idx_clients_nom ON clients(nom);
CREATE INDEX idx_projets_client ON projets(client_id);
CREATE INDEX idx_commandes_fournisseur ON commandes(fournisseur_id);
CREATE INDEX idx_commandes_projet ON commandes(projet_id);
CREATE INDEX idx_documents_projet ON documents(projet_id);
CREATE INDEX idx_dessins_projet ON dessins(projet_id);

-- Exemple de commande pour importer les données des fournisseurs
-- .mode csv
-- .headers off
-- .import E:/DataBase/entreprises_complet.csv fournisseurs