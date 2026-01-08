USE DBBikeRentalShop;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Utilizza;
TRUNCATE TABLE Pagamento;
TRUNCATE TABLE Noleggio;
TRUNCATE TABLE Bici;
TRUNCATE TABLE Tipologia_Bici;
TRUNCATE TABLE Tariffa_Base;
TRUNCATE TABLE Cliente;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO Tariffa_Base (numero_giorni, prezzo) VALUES
  (1,   10.00),
  (7,   50.00),
  (30, 150.00);

INSERT INTO Tipologia_Bici (nome, moltiplicatore_costo) VALUES
  ('city',      1.00),
  ('mountain',  1.20),
  ('e-bike',    1.50);

INSERT INTO Cliente (codice_fiscale, nome, cognome, cellulare) VALUES
  ('NKMSHT70A01Z404U', 'Satoshi', 'Nakamoto', '+10000000001'),
  ('DRSJCK77C15Z404X', 'Jack',    'Dorsey',   '+10000000002'),
  ('MSKELN71D28Z404Q', 'Elon',    'Musk',     '+10000000003'),
  ('MLIJVR72E05Z404L', 'Javier',  'Milei',    '+540000000005'),
  ('RMNCLD90C22Z404S', 'Claudio', 'Raimondi', '+390000000003'),
  ('RSSMRC88F10Z404T', 'Marco',   'Rossi',    '+390000000006');

INSERT INTO Bici (codice_telaio, numero_serie_gps, taglia, genere, nota_danni, stato, tipologia) VALUES
  ('TEL0000001', 'GPS-1000000000001', 'M', 'uomo',  NULL,                  'disponibile',  'city'),
  ('TEL0000002', 'GPS-1000000000002', 'S', 'donna', 'graffio tubo',        'disponibile',  'city'),
  ('TEL0000003', 'GPS-1000000000003', 'M', 'uomo',  NULL,                  'in uso',       'mountain'),
  ('TEL0000004', 'GPS-1000000000004', 'L', 'uomo',  NULL,                  'disponibile',  'mountain'),
  ('TEL0000005', 'GPS-1000000000005', 'M', 'donna', 'batteria difettosa',  'manutenzione', 'e-bike'),
  ('TEL0000006', 'GPS-1000000000006', 'L', 'uomo',  NULL,                  'disponibile',  'e-bike'),
  ('TEL0000007', 'GPS-1000000000007', 'S', 'donna', NULL,                  'disponibile',  'city'),
  ('TEL0000008', 'GPS-1000000000008', 'M', 'uomo',  'freno ant. rotto',    'manutenzione', 'mountain'),
  ('TEL0000009', 'GPS-1000000000009', 'L', 'donna', NULL,                  'in uso',       'e-bike');

INSERT INTO Noleggio (data_inizio, data_fine, cliente, tariffa) VALUES
  ('2025-12-28 10:00:00', '2025-12-28 18:30:00', 'RMNCLD90C22Z404S', 1),
  ('2026-01-02 09:00:00', '2026-01-04 17:45:00', 'DRSJCK77C15Z404X', 7),
  ('2026-01-07 08:10:00', NULL,                  'RSSMRC88F10Z404T', 1),
  ('2025-12-20 11:20:00', '2025-12-22 19:00:00', 'MSKELN71D28Z404Q', 1),
  ('2025-12-15 09:30:00', '2026-01-13 10:00:00', 'NKMSHT70A01Z404U', 30);

INSERT INTO Pagamento (codice_ricevuta, modalita, importo, noleggio) VALUES
  ('RCPT000001', 'carta',    10.00, 1),
  ('RCPT000002', 'contanti', 60.00, 2),
  ('RCPT000003', 'carta',    15.00, 3),
  ('RCPT000004', 'contanti', 10.00, 4),
  ('RCPT000005', 'bitcoin', 225.00, 5);

INSERT INTO Utilizza (noleggio, bici, batteria_inizio, batteria_fine) VALUES
  (1, 'TEL0000001', 0,   0),
  (2, 'TEL0000003', 0,   0),
  (3, 'TEL0000009', 92,  NULL),
  (4, 'TEL0000002', 0,   0),
  (5, 'TEL0000006', 98,  55);

