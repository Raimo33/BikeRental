DROP DATABASE IF EXISTS DBBikeRentalShop;
CREATE DATABASE DBBikeRentalShop;
USE DBBikeRentalShop;

DROP TABLE IF EXISTS Noleggio;
DROP TABLE IF EXISTS Pagamento;
DROP TABLE IF EXISTS Tariffa_Base;
DROP TABLE IF EXISTS Cliente;
DROP TABLE IF EXISTS Bici;
DROP TABLE IF EXISTS Tipologia_Bici;
DROP TABLE IF EXISTS Utilizza;

CREATE TABLE Cliente (
  codice_fiscale CHAR(16) PRIMARY KEY,
  nome VARCHAR(30) NOT NULL,
  cognome VARCHAR(30) NOT NULL,
  cellulare VARCHAR(15),

  CONSTRAINT chk_cellulare CHECK (cellulare REGEXP '^[0-9+ -]+$')
);

CREATE TABLE Tariffa_Base (
  numero_giorni INT PRIMARY KEY,
  prezzo DECIMAL(5,2) NOT NULL,

  CONSTRAINT chk_prezzo CHECK (prezzo > 0),
  CONSTRAINT chk_numero_giorni CHECK (numero_giorni > 0)
);

CREATE TABLE Tipologia_Bici (
  nome VARCHAR(20) PRIMARY KEY,
  moltiplicatore_costo DECIMAL(3,2) NOT NULL,

  CONSTRAINT chk_moltiplicatore_costo CHECK (moltiplicatore_costo > 0)
);

CREATE TABLE Bici (
  codice_telaio CHAR(10) PRIMARY KEY,
  numero_serie_gps CHAR(15) UNIQUE NOT NULL,
  taglia ENUM('S', 'M', 'L') NOT NULL,
  genere ENUM('uomo', 'donna') NOT NULL,
  nota_danni VARCHAR(100),
  stato ENUM('disponibile', 'in uso', 'manutenzione') NOT NULL,
  tipologia VARCHAR(20) NOT NULL,

  FOREIGN KEY (tipologia) REFERENCES Tipologia_Bici(nome) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Noleggio (
  id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  data_inizio DATETIME NOT NULL,
  data_fine DATETIME,
  cliente CHAR(16) NOT NULL,
  tariffa INTEGER NOT NULL,

  FOREIGN KEY (cliente) REFERENCES Cliente(codice_fiscale) ON UPDATE CASCADE ON DELETE RESTRICT,
  FOREIGN KEY (tariffa) REFERENCES Tariffa_Base(numero_giorni) ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT chk_data CHECK (data_fine IS NULL OR data_fine > data_inizio)
);

CREATE TABLE Pagamento (
  codice_ricevuta CHAR(10) PRIMARY KEY,
  modalita ENUM('carta', 'contanti', 'bitcoin') NOT NULL,
  importo DECIMAL(6,2) NOT NULL,
  noleggio INT NOT NULL,

  FOREIGN KEY (noleggio) REFERENCES Noleggio(id) ON UPDATE CASCADE ON DELETE CASCADE,

  CONSTRAINT chk_importo CHECK (importo > 0)
);

CREATE TABLE Utilizza (
  noleggio INT,
  bici CHAR(10),
  batteria_inizio TINYINT NOT NULL,
  batteria_fine TINYINT,

  PRIMARY KEY (noleggio, bici),

  FOREIGN KEY (noleggio) REFERENCES Noleggio(id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (bici) REFERENCES Bici(codice_telaio) ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT chk_batteria_inizio CHECK (batteria_inizio BETWEEN 0 AND 100),
  CONSTRAINT chk_batteria_fine CHECK (batteria_fine IS NULL OR (batteria_fine BETWEEN 0 AND 100 AND batteria_fine <= batteria_inizio))
);