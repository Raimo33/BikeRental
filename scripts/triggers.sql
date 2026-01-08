DROP TRIGGER IF EXISTS trg_chk_bici_disponibile;
DROP TRIGGER IF EXISTS trg_set_bici_in_uso;
DROP TRIGGER IF EXISTS trg_set_bici_disponibile;
DROP TRIGGER IF EXISTS trg_chk_importo_pagamento;

DELIMITER $$

CREATE TRIGGER trg_chk_bici_disponibile
BEFORE INSERT ON Utilizza
FOR EACH ROW
BEGIN
  IF (SELECT stato FROM Bici WHERE codice_telaio = NEW.bici) <> 'disponibile' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Bici non disponibile per il noleggio.';
  END IF;
END $$

CREATE TRIGGER trg_set_bici_in_uso
AFTER INSERT ON Utilizza
FOR EACH ROW
BEGIN
  UPDATE Bici
  SET stato = 'in uso'
  WHERE codice_telaio = NEW.bici;
END $$

CREATE TRIGGER trg_set_bici_disponibile
AFTER UPDATE ON Noleggio
FOR EACH ROW
BEGIN
  IF OLD.data_fine IS NULL AND NEW.data_fine IS NOT NULL THEN
    UPDATE Bici 
    SET stato = 'disponibile' 
    WHERE codice_telaio = (SELECT bici FROM Utilizza WHERE noleggio = NEW.id LIMIT 1);
  END IF;
END $$

CREATE TRIGGER trg_chk_importo_pagamento
BEFORE INSERT ON Pagamento
FOR EACH ROW
BEGIN
  DECLARE v_importo_necessario DECIMAL(6,2);
  SELECT (tb.prezzo * tbi.moltiplicatore_costo) INTO v_importo_necessario

  FROM Noleggio n
  INNER JOIN Utilizza u          ON n.id = u.noleggio
  INNER JOIN Bici b              ON u.bici = b.codice_telaio
  INNER JOIN Tipologia_Bici tbi  ON b.tipologia = tbi.nome
  INNER JOIN Tariffa_Base tb     ON n.tariffa = tb.numero_giorni
  WHERE n.id = NEW.noleggio;

  IF NEW.importo < v_importo_necessario THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Importo del pagamento insufficiente.';
  END IF;
END $$

DELIMITER ;