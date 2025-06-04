
-- Création de la table application
CREATE TABLE application (
  id SERIAL PRIMARY KEY,
  "nomApplication" VARCHAR(255) UNIQUE
);

-- Création de la table composant
CREATE TABLE composant (
  id SERIAL PRIMARY KEY,
  "nomComposant" VARCHAR(255) UNIQUE
);

-- Création de la table entite
CREATE TABLE entite (
  id SERIAL PRIMARY KEY,
  "nomentite" VARCHAR(255) UNIQUE
);

-- Création de la table incident (simplifiée)
CREATE TABLE incident (
  id SERIAL PRIMARY KEY,
  "Refjira" VARCHAR(255),
  application VARCHAR(255),
  etat VARCHAR(25) NOT NULL,
  "Etat_JIRA" VARCHAR(25) NOT NULL,
  pr VARCHAR(20),
  criticite VARCHAR(255),
  entite VARCHAR(255),
  respo VARCHAR(100),
  date_incident DATE,
  cause TEXT,
  date VARCHAR(25),
  description TEXT,
  filiale VARCHAR(255),
  impact TEXT,
  module VARCHAR(255),
  resume TEXT,
  date_resolution VARCHAR(25),
  solution TEXT,
  "PM" VARCHAR(3) DEFAULT 'non',
  statut_pm VARCHAR(25),
  lien TEXT,
  compostant_impacte VARCHAR(100),
  heureincident VARCHAR(25) NOT NULL,
  date_sasie VARCHAR(25),
  tdc VARCHAR(25) NOT NULL,
  hps VARCHAR(25) NOT NULL,
  updated INT DEFAULT 0,
  dateupdate DATE DEFAULT CURRENT_DATE,
  date_clo VARCHAR(25) NOT NULL,
  indispo VARCHAR(10) NOT NULL,
  insta VARCHAR(10) NOT NULL,
  dinsta INT,
  dindispo INT,
  delaireso VARCHAR(255),
  perimetre VARCHAR(25),
  event1 VARCHAR(25),
  type_application VARCHAR(10) DEFAULT '24/7'
);

-- Fonction de mise à jour d'état
CREATE OR REPLACE FUNCTION update_incident_states1()
RETURNS void AS $$
DECLARE
    refjira_val VARCHAR(25);
    etat_jira_val VARCHAR(25);
    criticite_val VARCHAR(25);
    done BOOLEAN := FALSE;
    cur CURSOR FOR SELECT "Refjira", "Etat_JIRA", criticite FROM incidentjira;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO refjira_val, etat_jira_val, criticite_val;
        EXIT WHEN NOT FOUND;
        UPDATE incident
        SET "Etat_JIRA" = etat_jira_val, criticite = criticite_val
        WHERE "Refjira" = refjira_val;
    END LOOP;
    CLOSE cur;
END;
$$ LANGUAGE plpgsql;

-- Déclencheur pour maj_significatif
CREATE OR REPLACE FUNCTION maj_significatif_func()
RETURNS trigger AS $$
BEGIN
    IF NEW.criticite IN ('P0', 'P1') THEN
        NEW.pr := 'MAJEURE';
    ELSIF NEW.criticite = 'P2' THEN
        NEW.pr := 'SIGNIFICATIF';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER maj_significatif_trigger
BEFORE INSERT ON incident
FOR EACH ROW
EXECUTE FUNCTION maj_significatif_func();
