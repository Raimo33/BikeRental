DROP TRIGGER IF EXISTS trg_chk_bici_disponibile;
DROP TRIGGER IF EXISTS trg_set_bici_in_uso;
DROP TRIGGER IF EXISTS trg_set_bici_disponibile;

DELIMITER $$

CREATE TRIGGER trg_chk_bici_disponibile
BEFORE INSERT ON Utilizza
FOR EACH ROW
BEGIN
  IF (SELECT stato FROM Bici WHERE codice_telaio = NEW.bici) <> 'disponibile' THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'La bici non è disponibile per il noleggio.';
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

DELIMITER ;