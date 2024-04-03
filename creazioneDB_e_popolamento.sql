-- phpMyAdmin SQL Dump
-- version 4.2.7.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Feb 19, 2022 alle 15:24
-- Versione del server: 5.6.20
-- PHP Version: 5.5.15

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `chat`
--
CREATE DATABASE IF NOT EXISTS `chat` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `chat`;

DELIMITER $$
--
-- Procedure
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Aggiungi_Utente_al_Gruppo`(IN `Utente_in` VARCHAR(30) CHARSET utf8, IN `Gruppo_in` INT(255) UNSIGNED)
BEGIN

	DECLARE p INT DEFAULT 0;
   
   SELECT g.private_chat into p
   FROM gruppo g
   WHERE g.ID_Gruppo = ABS(Gruppo_in);
   
   IF( p = 0) THEN
   
   SELECT 1 INTO p
 	FROM gruppo 
    WHERE NOT EXISTS(
     SELECT 1 AS Presenza
     FROM user_gruppo
     WHERE utente = TRIM(Utente_in)
       AND gruppo = ABS(Gruppo_in)
     )LIMIT 1;
    
    IF(p = 1) THEN

    INSERT INTO user_gruppo VALUES(TRIM(Utente_in) , ABS(Gruppo_in) , CURRENT_TIMESTAMP , 0 , 0);
    
    INSERT INTO log_gruppo
    VALUES (NULL , TRIM(Utente_in) , ABS(Gruppo_in) , 1 , CURRENT_TIMESTAMP);
    
    END IF;
    
    END IF;
   
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Cambia_Tema`(IN `Utente` VARCHAR(255) CHARSET ascii, IN `tema_in` INT(1) UNSIGNED)
BEGIN

	update utente u
    SET u.tema = tema_in
    WHERE u.username = Utente;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Cancella_Chat`(IN `Mitt` VARCHAR(255) CHARSET ascii, IN `Group_in` INT(255) UNSIGNED)
BEGIN

	DECLARE max_msg INT DEFAULT 0;
    
    SELECT MAX(m.ID_Messaggio) INTO max_msg
    FROM messaggio m
    WHERE m.Mittente = TRIM(Mitt) 
    AND m.ID_Gruppo =TRIM(Group_in);
    
    IF(max_msg IS NULL) THEN SET max_msg = 0;END IF;
    
    UPDATE user_gruppo ug
    SET ug.ignora_da = max_msg
    WHERE ug.utente = TRIM(Mitt) 
    AND ug.gruppo = TRIM(Group_in);

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Crea_Chat_Privata`(IN `Utente1` VARCHAR(25) CHARSET utf8, IN `Utente2` VARCHAR(25) CHARSET utf8)
    MODIFIES SQL DATA
    COMMENT 'Crea una chat privata tra due utenti '
BEGIN
	
    DECLARE utente_input  int(1) default 0;
    
    DECLARE utente_input1 varchar(30) default '';
    DECLARE utente_input2 varchar(30) default '';
    
    DECLARE id_max INT(255) DEFAULT 0;
    
    
    SELECT u.username INTO utente_input1
    FROM utente u WHERE u.username = TRIM(Utente1);
    
    SELECT u.username INTO utente_input2
    FROM utente u WHERE u.username = TRIM(Utente2);
    
    
    IF(
        utente_input1 = TRIM(Utente1) AND 
        utente_input2 = TRIM(Utente2)
    ) THEN -- verifica esistenza utenti
    
    
    IF(
        utente_input1 <> utente_input2
    ) THEN -- verifica che siano due utenti diversi
    
    SELECT 1 INTO utente_input
 	FROM gruppo g
 	INNER JOIN user_gruppo ug1 ON (ug1.gruppo = g.ID_Gruppo)
	INNER JOIN user_gruppo ug2 ON (ug2.gruppo = g.ID_Gruppo AND ug2.Utente <> ug1.Utente)
 	WHERE g.private_chat = 1   AND 
    ug1.Utente = utente_input1 AND 
    ug2.Utente = utente_input2;
       
	IF(utente_input = 0) THEN
            
            INSERT INTO gruppo VALUES 
            (NULL , NULL , NULL , CURRENT_TIMESTAMP , 1 , CURRENT_TIMESTAMP);
            
            SELECT MAX(g.ID_Gruppo) INTO id_max
 			FROM gruppo g
 			WHERE g.private_chat = 1;
              
            INSERT INTO user_gruppo VALUES(utente_input1 , id_max , NULL , 0 , 0);
            INSERT INTO user_gruppo VALUES(utente_input2 , id_max , NULL , 0 , 0);

			SELECT id_max as ID_G;  -- ritorno l'ID della chat privata appena creata
   END IF;   END IF;    END IF;

   

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Crea_Gruppo`(IN `Fondatore` VARCHAR(30) CHARSET utf8, IN `Nome_Gruppo` VARCHAR(255) CHARSET utf8)
BEGIN
	
    
    IF(TRIM(Nome_Gruppo) != '') THEN
    	insert into Gruppo values(NULL , TRIM(Nome_Gruppo) , TRIM(Fondatore) , CURRENT_TIMESTAMP , 0 , CURRENT_TIMESTAMP);
        
    	
    end if;
    


END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Elimina_Gruppo`(IN `Gruppo` INT(255) UNSIGNED, IN `Responsabile` VARCHAR(255) CHARSET ascii)
    MODIFIES SQL DATA
BEGIN
	DECLARE permitte INT DEFAULT 0;
    
    SELECT g.ID_Gruppo INTO permitte
    FROM user_gruppo ug
    INNER JOIN gruppo g ON g.ID_Gruppo = ug.gruppo
    WHERE ug.utente = TRIM(Responsabile) AND
    ug.gruppo = ABS(Gruppo) AND
    g.Fondatore = TRIM(Responsabile);
    
    DELETE FROM gruppo
    WHERE ID_Gruppo = permitte;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Elimina_Utente_dal_Gruppo`(IN `Mitt` VARCHAR(255) CHARSET ascii, IN `Group_in` INT(255) UNSIGNED)
    MODIFIES SQL DATA
BEGIN
	
	DECLARE p INT DEFAULT 0;
    
    SELECT g.private_chat into p
    FROM gruppo g
    WHERE g.ID_Gruppo = ABS(Group_in);
    
    IF(p = 0) THEN
    
     SELECT 1 INTO p
 	FROM gruppo WHERE EXISTS(
     SELECT 1 FROM user_gruppo
     WHERE utente = TRIM(Mitt)
       AND gruppo = ABS(Group_in)
     )LIMIT 1;
    
    
    IF(p = 1) THEN
     SET FOREIGN_KEY_CHECKS = 0;
     
    INSERT INTO log_gruppo VALUES 
    (NULL,TRIM(Mitt),ABS(Group_in),2,CURRENT_TIMESTAMP);
      
	DELETE FROM user_gruppo 
    WHERE utente = TRIM(Mitt) 
    AND gruppo = ABS(Group_in);
    
    SET FOREIGN_KEY_CHECKS = 1;
     
   END IF;
   
   END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Get_Info_gruppo`(IN `ID_gruppo` INT(255) UNSIGNED, IN `mitt` VARCHAR(255) CHARSET ascii)
BEGIN
	DECLARE tipo_g INT DEFAULT 0;
    
    SELECT g.private_chat into tipo_g
    FROM gruppo g
    WHERE g.ID_Gruppo = ID_gruppo;
    
    IF tipo_g = 0 THEN
        	SELECT g.Nome as info_g
        	FROM gruppo g
            WHERE g.ID_Gruppo = ID_gruppo;
       
    ELSE
    	    SELECT ug.utente as info_g
        	FROM gruppo g
            INNER JOIN user_gruppo ug ON ug.gruppo = g.ID_Gruppo
            WHERE g.ID_Gruppo = ID_gruppo AND ug.utente <> mitt;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ID_Visualizzato_MAX`(IN `Gruppo_In` INT(255) UNSIGNED, IN `Mitt` VARCHAR(25) CHARSET ascii)
    READS SQL DATA
BEGIN

	DECLARE priv INT DEFAULT 0;
    
    
    SELECT g.private_chat INTO priv
    FROM gruppo g
    WHERE g.ID_Gruppo = ABS(Gruppo_In);
    
    IF( priv = 1) THEN
    	SELECT ug.ultimo_messaggio_letto as mess_max
        FROM user_gruppo ug
        WHERE ug.utente <> TRIM(Mitt) AND
        ug.gruppo = ABS(Gruppo_In);
    
    ELSE
    	SELECT MIN(ug.ultimo_messaggio_letto) as mess_max
        FROM user_gruppo ug
        WHERE ug.gruppo = ABS(Gruppo_In);
    
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Inserisci_File`(IN `nome_new` VARCHAR(255) CHARSET ascii, IN `nome_old` VARCHAR(255) CHARSET ascii, IN `estensione` VARCHAR(20) CHARSET ascii, IN `dimensione` INT(255) UNSIGNED, IN `id_mess` INT(255) UNSIGNED)
BEGIN
	INSERT INTO file 
    VALUES (NULL , nome_new , nome_old , estensione , id_mess ,dimensione);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Inserisci_Utente`(IN `Utente_In` VARCHAR(30) CHARSET utf8, IN `psw_in` TEXT CHARSET utf8)
BEGIN
	IF(TRIM(Utente_In) != '' AND TRIM(psw_in) != '') THEN
	insert into Utente VALUES(TRIM(Utente_in) , TRIM(psw_in) , CURRENT_TIMESTAMP , 0); 
	END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Invia_Messaggio`(IN `Mittente` VARCHAR(30) CHARSET utf8, IN `Gruppo_in` INT(255) UNSIGNED, IN `Testo` TEXT CHARSET utf8)
BEGIN
	

	insert into messaggio values(NULL , TRIM(Mittente) , CURRENT_TIMESTAMP , ABS(Gruppo_in) ,TRIM(testo) );
    
    UPDATE gruppo SET ultima_attivita = CURRENT_TIMESTAMP
    where ID_gruppo = ABS(Gruppo_in);
    
    UPDATE user_gruppo ug 
    SET ug.ultimo_messaggio_letto 
    = (Select MAX(m.ID_Messaggio) FROM messaggio m)
    WHERE ug.utente = TRIM(Mittente) AND
    	 ug.gruppo = ABS(Gruppo_in);
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Open_Chat`(IN `Mitt` VARCHAR(255) CHARSET ascii, IN `ID_Group` INT(255) UNSIGNED)
    MODIFIES SQL DATA
BEGIN
	DECLARE MAX_MESS INT DEFAULT 0;
    
    SELECT MAX(m.ID_Messaggio) INTO MAX_MESS
    FROM messaggio m
    WHERE m.ID_Gruppo = ABS(ID_Group);
    
    IF( MAX_MESS > 0) THEN
    
	UPDATE user_gruppo UG 
    SET UG.ultimo_messaggio_letto = MAX_MESS
    WHERE UG.gruppo = ABS(ID_Group) AND
    UG.utente = TRIM(Mitt);
    
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Rinomina_Gruppo`(IN `ID_Group` INT(255) UNSIGNED, IN `new_name` VARCHAR(255) CHARSET ascii, IN `responsabile` VARCHAR(255) CHARSET ascii)
BEGIN

	DECLARE permit INT DEFAULT 0;
    
    SELECT ug.gruppo INTO permit
    FROM user_gruppo ug
    WHERE ug.utente = TRIM(responsabile) AND
    ug.gruppo = ABS(ID_Group) ;
    
    if(permit IS NOT NULL) then
    
	UPDATE gruppo 
    SET Nome = TRIM(new_name)
    WHERE ID_Gruppo = ABS(ID_Group);
    
    INSERT INTO log_gruppo VALUES
    (NULL , TRIM(responsabile) , ABS(ID_Group) , 3 , CURRENT_TIMESTAMP);
	
    end if;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `file`
--

CREATE TABLE IF NOT EXISTS `file` (
`ID_File` int(11) NOT NULL,
  `nome_memoria` varchar(255) NOT NULL COMMENT 'Nome usato per la memorizzazione nel server applicativo',
  `nome_effettivo` varchar(255) NOT NULL COMMENT 'Nome dato dal Mittente',
  `estensione` varchar(20) NOT NULL,
  `ID_Messaggio` int(11) NOT NULL,
  `Dimensione` int(255) unsigned NOT NULL DEFAULT '0' COMMENT 'Espressa in KB'
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

--
-- Dump dei dati per la tabella `file`
--

INSERT INTO `file` (`ID_File`, `nome_memoria`, `nome_effettivo`, `estensione`, `ID_Messaggio`, `Dimensione`) VALUES
(1, 'sample JPG0219202215114102410.jpg', 'sample JPG.jpg', 'image/jpeg', 3, 7),
(2, 'sample MP30219202215114102411.mp3', 'sample MP3.mp3', 'audio/mpeg', 3, 746),
(3, 'sample MP40219202215114102412.mp4', 'sample MP4.mp4', 'video/mp4', 3, 1533),
(4, 'sample PDF0219202215114102413.pdf', 'sample PDF.pdf', 'application/pdf', 3, 3),
(5, 'sample PNG0219202215114102414.png', 'sample PNG.png', 'image/png', 3, 5),
(6, 'sample TXT0219202215114102415.txt', 'sample TXT.txt', 'text/plain', 3, 0),
(7, 'sample PNG0219202215152302230.png', 'sample PNG.png', 'image/png', 10, 5),
(8, 'sample TXT0219202215152302231.txt', 'sample TXT.txt', 'text/plain', 10, 0);

-- --------------------------------------------------------

--
-- Struttura della tabella `gruppo`
--

CREATE TABLE IF NOT EXISTS `gruppo` (
`ID_Gruppo` int(255) NOT NULL,
  `Nome` varchar(25) DEFAULT NULL,
  `Fondatore` varchar(30) DEFAULT NULL,
  `Data_Creazione` date DEFAULT NULL,
  `private_chat` tinyint(1) NOT NULL,
  `ultima_attivita` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

--
-- Dump dei dati per la tabella `gruppo`
--

INSERT INTO `gruppo` (`ID_Gruppo`, `Nome`, `Fondatore`, `Data_Creazione`, `private_chat`, `ultima_attivita`) VALUES
(1, NULL, NULL, '2022-02-19', 1, '2022-02-19 14:12:09'),
(2, 'Luigi INC', 'Luigi', '2022-02-19', 0, '2022-02-19 14:13:07'),
(3, NULL, NULL, '2022-02-19', 1, '2022-02-19 14:14:40'),
(4, 'Waluigi INC', 'Waluigi', '2022-02-19', 0, '2022-02-19 14:15:23');

--
-- Trigger `gruppo`
--
DELIMITER //
CREATE TRIGGER `aggiungi_user_gruppo` AFTER INSERT ON `gruppo`
 FOR EACH ROW BEGIN
      IF( new.private_chat = 0 ) THEN
        	INSERT INTO user_gruppo 
       		VALUES(new.Fondatore , new.ID_Gruppo ,CURRENT_TIMESTAMP , 0 , 0);
        END IF;
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `log_gruppo`
--

CREATE TABLE IF NOT EXISTS `log_gruppo` (
`ID_evento` int(255) NOT NULL,
  `user` varchar(255) NOT NULL,
  `ID_Gruppo` int(255) NOT NULL,
  `descrizione` smallint(5) unsigned NOT NULL COMMENT 'Specifica il tipo di evento avvenuto\r\n1: Persona Aggiunta al gruppo.\r\n2: persona eliminata dal gruppo.\r\n3: Rinominazione del gruppo.',
  `data_evento` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

--
-- Dump dei dati per la tabella `log_gruppo`
--

INSERT INTO `log_gruppo` (`ID_evento`, `user`, `ID_Gruppo`, `descrizione`, `data_evento`) VALUES
(1, 'Mario', 2, 1, '2022-02-19 14:11:07'),
(2, 'Waluigi', 2, 1, '2022-02-19 14:11:10'),
(3, 'Wario', 2, 1, '2022-02-19 14:11:13'),
(4, 'Waluigi', 2, 2, '2022-02-19 14:13:27'),
(5, 'Luigi', 2, 3, '2022-02-19 14:13:42'),
(6, 'Luigi', 2, 3, '2022-02-19 14:13:51'),
(7, 'Wario', 4, 1, '2022-02-19 14:14:56'),
(8, 'Mario', 4, 1, '2022-02-19 14:14:59');

-- --------------------------------------------------------

--
-- Struttura della tabella `messaggio`
--

CREATE TABLE IF NOT EXISTS `messaggio` (
`ID_Messaggio` int(11) NOT NULL,
  `Mittente` varchar(30) NOT NULL,
  `Timestamp_Invio` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ID_Gruppo` int(255) NOT NULL,
  `testo_messaggio` text NOT NULL
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 AUTO_INCREMENT=11 ;

--
-- Dump dei dati per la tabella `messaggio`
--

INSERT INTO `messaggio` (`ID_Messaggio`, `Mittente`, `Timestamp_Invio`, `ID_Gruppo`, `testo_messaggio`) VALUES
(1, 'Luigi', '2022-02-19 14:11:19', 2, 'Ciao a tutti!'),
(2, 'Luigi', '2022-02-19 14:11:25', 1, 'Ciao Mario'),
(3, 'Luigi', '2022-02-19 14:11:41', 1, 'Ecco un po'' di file'),
(4, 'Luigi', '2022-02-19 14:12:09', 1, 'Questo messaggio Ã¨ lungo messaggio lungo messaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungomessaggio lungo'),
(5, 'Mario', '2022-02-19 14:12:31', 2, 'Ciao a tutti'),
(6, 'Wario', '2022-02-19 14:12:49', 2, 'Ciao a tutti'),
(7, 'Waluigi', '2022-02-19 14:13:07', 2, 'Ciao a nessuno'),
(8, 'Waluigi', '2022-02-19 14:14:40', 3, 'il tuo gruppo non aveva un bel nome..'),
(9, 'Waluigi', '2022-02-19 14:15:06', 4, 'Un gruppo senza luigi'),
(10, 'Waluigi', '2022-02-19 14:15:23', 4, 'ecco');

-- --------------------------------------------------------

--
-- Struttura della tabella `user_gruppo`
--

CREATE TABLE IF NOT EXISTS `user_gruppo` (
  `utente` varchar(30) NOT NULL,
  `gruppo` int(255) NOT NULL,
  `data_iscrizione` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ultimo_messaggio_letto` int(255) unsigned NOT NULL DEFAULT '0',
  `ignora_da` int(255) unsigned NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `user_gruppo`
--

INSERT INTO `user_gruppo` (`utente`, `gruppo`, `data_iscrizione`, `ultimo_messaggio_letto`, `ignora_da`) VALUES
('Luigi', 1, NULL, 4, 0),
('Luigi', 2, '2022-02-19 14:11:03', 7, 0),
('Luigi', 3, NULL, 8, 0),
('Mario', 1, NULL, 4, 0),
('Mario', 2, '2022-02-19 14:11:07', 5, 0),
('Mario', 4, '2022-02-19 14:14:59', 0, 0),
('Waluigi', 3, NULL, 8, 0),
('Waluigi', 4, '2022-02-19 14:14:50', 10, 0),
('Wario', 2, '2022-02-19 14:11:13', 6, 0),
('Wario', 4, '2022-02-19 14:14:56', 0, 0);

-- --------------------------------------------------------

--
-- Struttura della tabella `utente`
--

CREATE TABLE IF NOT EXISTS `utente` (
  `username` varchar(25) NOT NULL,
  `psw` varchar(120) NOT NULL,
  `utlimo_accesso` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `tema` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dump dei dati per la tabella `utente`
--

INSERT INTO `utente` (`username`, `psw`, `utlimo_accesso`, `tema`) VALUES
('Luigi', '$2y$10$AzWPH4Uv/mzeqTl3svJrPOG6ChLODsjPDa5ra5n.vvM56fpSz.9JO', '2022-02-19 14:10:35', 1),
('Mario', '$2y$10$aXElBC2sAHjCQh6WiMM/8efIWkEj9c1OcTEN0/p63zdIqLU1qhcEO', '2022-02-19 14:10:40', 0),
('Waluigi', '$2y$10$/jD4hQiI.UdmPMX9YtB1seh1CnCZr6gXiznzS8FBd/c6CCf7JCCnW', '2022-02-19 14:10:49', 0),
('Wario', '$2y$10$COu4B3WnaHx30HCePMYmiu1HivJaVRnTzuqOxfDATtB2QiB4fS91a', '2022-02-19 14:10:45', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `file`
--
ALTER TABLE `file`
 ADD PRIMARY KEY (`ID_File`), ADD KEY `File_Messaggio` (`ID_Messaggio`);

--
-- Indexes for table `gruppo`
--
ALTER TABLE `gruppo`
 ADD PRIMARY KEY (`ID_Gruppo`), ADD KEY `Fondatore_Username` (`Fondatore`);

--
-- Indexes for table `log_gruppo`
--
ALTER TABLE `log_gruppo`
 ADD PRIMARY KEY (`ID_evento`), ADD KEY `evento_utente` (`user`), ADD KEY `evento_user_gruppo` (`ID_Gruppo`,`user`);

--
-- Indexes for table `messaggio`
--
ALTER TABLE `messaggio`
 ADD PRIMARY KEY (`ID_Messaggio`), ADD KEY `Mittente_Messaggio` (`Mittente`), ADD KEY `Messaggio_gruppo` (`ID_Gruppo`);

--
-- Indexes for table `user_gruppo`
--
ALTER TABLE `user_gruppo`
 ADD PRIMARY KEY (`utente`,`gruppo`) USING BTREE, ADD KEY `gruppo_utente_gruppo` (`gruppo`);

--
-- Indexes for table `utente`
--
ALTER TABLE `utente`
 ADD PRIMARY KEY (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `file`
--
ALTER TABLE `file`
MODIFY `ID_File` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `gruppo`
--
ALTER TABLE `gruppo`
MODIFY `ID_Gruppo` int(255) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `log_gruppo`
--
ALTER TABLE `log_gruppo`
MODIFY `ID_evento` int(255) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `messaggio`
--
ALTER TABLE `messaggio`
MODIFY `ID_Messaggio` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `file`
--
ALTER TABLE `file`
ADD CONSTRAINT `File_Messaggio` FOREIGN KEY (`ID_Messaggio`) REFERENCES `messaggio` (`ID_Messaggio`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `gruppo`
--
ALTER TABLE `gruppo`
ADD CONSTRAINT `Fondatore_Username` FOREIGN KEY (`Fondatore`) REFERENCES `utente` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `log_gruppo`
--
ALTER TABLE `log_gruppo`
ADD CONSTRAINT `gruppo_evento` FOREIGN KEY (`ID_Gruppo`) REFERENCES `gruppo` (`ID_Gruppo`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT `responsabile_evento` FOREIGN KEY (`user`) REFERENCES `utente` (`username`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limiti per la tabella `messaggio`
--
ALTER TABLE `messaggio`
ADD CONSTRAINT `Messaggio_gruppo` FOREIGN KEY (`ID_Gruppo`) REFERENCES `gruppo` (`ID_Gruppo`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT `Mittente_Messaggio` FOREIGN KEY (`Mittente`) REFERENCES `utente` (`username`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Limiti per la tabella `user_gruppo`
--
ALTER TABLE `user_gruppo`
ADD CONSTRAINT `gruppo_utente_gruppo` FOREIGN KEY (`gruppo`) REFERENCES `gruppo` (`ID_Gruppo`) ON DELETE CASCADE ON UPDATE CASCADE,
ADD CONSTRAINT `utente_utente_gruppo` FOREIGN KEY (`utente`) REFERENCES `utente` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
