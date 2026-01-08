DROP VIEW IF EXISTS v_noleggi_attivi;
DROP VIEW IF EXISTS v_clienti_frequenti;
DROP VIEW IF EXISTS v_bici_da_caricare;

CREATE VIEW v_noleggi_attivi AS
SELECT
  n.id,
  n.data_inizio,
  DATE_ADD(n.data_inizio, INTERVAL tb.numero_giorni DAY) AS data_fine_prevista,
  n.cliente
FROM Noleggio n
JOIN Tariffa_Base tb ON n.tariffa = tb.numero_giorni
WHERE n.data_fine IS NULL
ORDER BY data_fine_prevista ASC;

CREATE VIEW v_clienti_frequenti AS
SELECT
  c.codice_fiscale,
  c.nome,
  c.cognome,
  COUNT(n.id) AS numero_noleggi
FROM Cliente c
JOIN Noleggio n ON c.codice_fiscale = n.cliente
GROUP BY c.codice_fiscale, c.nome, c.cognome
HAVING COUNT(n.id) >= 2
ORDER BY numero_noleggi DESC;

CREATE VIEW v_bici_da_caricare AS
SELECT 
    b.codice_telaio,
    u.batteria_fine AS livello_attuale
FROM Bici b
JOIN Utilizza u ON b.codice_telaio = u.bici
JOIN Noleggio n ON u.noleggio = n.id
WHERE b.stato = 'disponibile'
  AND n.data_fine = (
      SELECT MAX(n2.data_fine) 
      FROM Noleggio n2 
      JOIN Utilizza u2 ON n2.id = u2.noleggio 
      WHERE u2.bici = b.codice_telaio
  )
  AND u.batteria_fine < 20
ORDER BY u.batteria_fine ASC;