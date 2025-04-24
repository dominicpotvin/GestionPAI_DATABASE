# 📘 SQLite Cheat Sheet – Projet `entreprises.db`

Ce document regroupe les commandes essentielles pour interagir avec la base de données SQLite `entreprises.db` via la console `sqlite3` dans VS Code ou Bash.

---

## ▶️ Lancer SQLite

```bash
sqlite3 E:/DataBase/entreprises.db
```

---

## 📋 Lister les tables

```sql
.tables
```

---

## 🧱 Afficher la structure complète (DDL)

```sql
.schema
```

---

## 🧱 Afficher uniquement la structure d'une table spécifique

```sql
.schema produits
```

---

## 📂 Lister les colonnes d'une table

```sql
PRAGMA table_info(produits);
```

---

## 📊 Afficher toutes les lignes d'une table

```sql
SELECT * FROM produits;
```

---

## 🔎 Filtrer les lignes avec condition

```sql
SELECT * FROM produits WHERE description = '*';
```

---

## 🧼 Supprimer les produits avec une description `'*'`

```sql
DELETE FROM produits WHERE TRIM(description) = '*';
```

---

## 🧽 Supprimer les catégories nommées `'*'`

```sql
DELETE FROM categories WHERE nom_categorie = '*';
```

---

## 🔐 Voir les clés étrangères d'une table

```sql
PRAGMA foreign_key_list(produits);
```

---

## 🧠 Lister les vues existantes

```sql
SELECT name FROM sqlite_master WHERE type='view';
```

---

## ❓ Aide intégrée

```sql
.help
```

---

> Généré automatiquement pour faciliter la gestion de la base de données `entreprises.db`.
