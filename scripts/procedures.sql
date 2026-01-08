DROP PROCEDURE IF EXISTS sp_inizia_noleggio;
DROP PROCEDURE IF EXISTS sp_concludi_noleggio;
DROP PROCEDURE IF EXISTS sp_report_incassi;

DELIMITER $$

CREATE PROCEDURE sp_inizia_noleggio(
  IN p_codice_fiscale CHAR(16),
  IN p_codice_telaio CHAR(10),
  IN p_numero_giorni INT,
  IN p_batteria_inizio TINYINT
)
BEGIN
  INSERT INTO Noleggio (data_inizio, cliente, tariffa) VALUES (NOW(), p_codice_fiscale, p_numero_giorni);
  INSERT INTO Utilizza (noleggio, bici, batteria_inizio) VALUES (LAST_INSERT_ID(), p_codice_telaio, p_batteria_inizio);
END $$

CREATE PROCEDURE sp_concludi_noleggio(
  IN p_noleggio_id INT,
  IN p_codice_ricevuta CHAR(10),
  IN p_modalita ENUM('carta', 'contanti', 'bitcoin'),
  IN p_batteria_fine TINYINT,
  IN p_nuova_nota_danni VARCHAR(100)
)
BEGIN
  DECLARE v_importo_finale DECIMAL(6,2);
  DECLARE v_codice_telaio CHAR(10);

  SELECT (tb.prezzo * tbi.moltiplicatore_costo), u.bici
  INTO v_importo_finale, v_codice_telaio
  FROM Noleggio n
  INNER JOIN Utilizza u          ON n.id = u.noleggio
  INNER JOIN Bici b              ON u.bici = b.codice_telaio
  INNER JOIN Tipologia_Bici tbi  ON b.tipologia = tbi.nome
  INNER JOIN Tariffa_Base tb     ON n.tariffa = tb.numero_giorni
  WHERE n.id = p_noleggio_id;

  START TRANSACTION;
    UPDATE Noleggio SET data_fine = NOW() WHERE id = p_noleggio_id;
    UPDATE Utilizza SET batteria_fine = p_batteria_fine WHERE noleggio = p_noleggio_id;
    UPDATE Bici SET nota_danni = IFNULL(p_nuova_nota_danni, nota_danni) WHERE codice_telaio = v_codice_telaio;
    INSERT INTO Pagamento (codice_ricevuta, modalita, importo, noleggio) VALUES (p_codice_ricevuta, p_modalita, v_importo_finale, p_noleggio_id);
  COMMIT;
END $$

CREATE PROCEDURE sp_report_incassi(
  IN p_data_inizio DATE,
  IN p_data_fine DATE
)
BEGIN
  SELECT
    p.modalita,
    COUNT(*) AS numero_transazioni,
    SUM(p.importo) AS totale_incassato
  FROM Pagamento p
  JOIN Noleggio n ON p.noleggio = n.id
  WHERE n.data_inizio BETWEEN p_data_inizio AND p_data_fine
  GROUP BY p.modalita;
END $$

DELIMITER ;