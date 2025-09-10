--- Progetto BD 24-25 (6CFU)
--- GRUPPO n.69
--- Yuri Romano 5231931 , Aurora Parodi 5216444 

--- PARTE 2 
/* il file deve essere file SQL ... cio formato solo testo e apribili ed eseguibili in pgAdmin */

/*************************************************************************************************************************************************************************/
--1a. Schema
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per la creazione dello schema logico della base di dati in accordo allo schema relazionale ottenuto alla fine della fase di progettazione logica, per la porzione necessaria per i punti successivi (cio le tabelle coinvolte dalle interrogazioni nel carico di lavoro, nella definizione della vista, nelle interrogazioni, in funzioni, procedure e trigger). Lo schema dovrˆ essere comprensivo dei vincoli esprimibili con check. */

CREATE TABLE festival (
    id INTEGER PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    edizione INTEGER,
    anno INTEGER,
    inizio DATE,
    fine DATE,
    teatro VARCHAR(100),
    direttore VARCHAR(100)
);

CREATE TABLE serate (
    id INTEGER PRIMARY KEY,
    numero INTEGER NOT NULL,
    data_serata DATE,
    tipo VARCHAR(50),
    festival_id INTEGER,
    FOREIGN KEY (festival_id) REFERENCES festival(id)
);

CREATE TABLE case_disco (
    id INTEGER PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    citta VARCHAR(100),
    tel VARCHAR(20),
    mail VARCHAR(100)
);

CREATE TABLE artisti (
    id INTEGER PRIMARY KEY,
    nome_artistico VARCHAR(150) NOT NULL,
    nome VARCHAR(100),
    cognome VARCHAR(100),
    nascita DATE,
    paese VARCHAR(50),
    singolo_o_gruppo VARCHAR(20),
    casa_disco_id INTEGER,
    FOREIGN KEY (casa_disco_id) REFERENCES case_disco(id)
);

CREATE TABLE categorie (
    id INTEGER PRIMARY KEY,
    nome VARCHAR(50) NOT NULL
);

CREATE TABLE canzoni (
    id INTEGER PRIMARY KEY,
    titolo VARCHAR(200) NOT NULL,
    durata INTEGER,
    testo_autore VARCHAR(100),
    musica_autore VARCHAR(100),
    editore VARCHAR(100),
    anno INTEGER
);

CREATE TABLE partecipazioni (
    id INTEGER PRIMARY KEY,
    artista_id INTEGER,
    canzone_id INTEGER,
    festival_id INTEGER,
    categoria_id INTEGER,
    posizione INTEGER,
    punti DECIMAL(8,2),
    FOREIGN KEY (artista_id) REFERENCES artisti(id),
    FOREIGN KEY (canzone_id) REFERENCES canzoni(id),
    FOREIGN KEY (festival_id) REFERENCES festival(id),
    FOREIGN KEY (categoria_id) REFERENCES categorie(id)
);

CREATE TABLE giurie (
    id INTEGER PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    descrizione TEXT
);

CREATE TABLE voti (
    id INTEGER PRIMARY KEY,
    serata_id INTEGER,
    partecipazione_id INTEGER,
    giuria_id INTEGER,
    numero_voti INTEGER,
    percentuale DECIMAL(5,2),
    peso DECIMAL(5,2),
    FOREIGN KEY (serata_id) REFERENCES serate(id),
    FOREIGN KEY (partecipazione_id) REFERENCES partecipazioni(id),
    FOREIGN KEY (giuria_id) REFERENCES giurie(id)
);

CREATE TABLE covers (
    id INTEGER PRIMARY KEY,
    partecipazione_id INTEGER,
    titolo VARCHAR(200),
    artista_orig VARCHAR(100),
    anno_orig INTEGER,
    ospite_id INTEGER,
    FOREIGN KEY (partecipazione_id) REFERENCES partecipazioni(id),
    FOREIGN KEY (ospite_id) REFERENCES artisti(id)
);

CREATE TABLE esibizioni (
    id INTEGER PRIMARY KEY,
    serata_id INTEGER,
    partecipazione_id INTEGER,
    ordine_numero INTEGER,
    tipo VARCHAR(20),
    cover_id INTEGER,
    FOREIGN KEY (serata_id) REFERENCES serate(id),
    FOREIGN KEY (partecipazione_id) REFERENCES partecipazioni(id),
    FOREIGN KEY (cover_id) REFERENCES covers(id)
);

/*************************************************************************************************************************************************************************/ 
--1b. Popolamento 
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per il popolamento 'in piccolo' di tale base di dati (utile per il test dei vincoli e delle operazioni in parte 2.) */

INSERT INTO festival (id, nome, edizione, anno, inizio, fine, teatro, direttore) 
VALUES (1, 'Sanremo 2025', 75, 2025, '2025-02-11', '2025-02-15', 'Ariston', 'Carlo Conti');

INSERT INTO serate VALUES 
(1, 1, '2025-02-11', 'prima', 1),
(2, 2, '2025-02-12', 'seconda', 1),
(3, 3, '2025-02-13', 'terza', 1),
(4, 4, '2025-02-14', 'cover', 1),
(5, 5, '2025-02-15', 'finale', 1);

INSERT INTO categorie VALUES (1, 'Campioni'), (2, 'Nuove Proposte');

INSERT INTO giurie VALUES 
(1, 'Televoto', 'pubblico a casa'),
(2, 'Stampa', 'giornalisti e critici'), 
(3, 'Radio', 'radio nazionali');

INSERT INTO case_disco VALUES
(1, 'Universal', 'Milano', '02123456', 'info@universal.it'),
(2, 'Sony', 'Roma', '06654321', 'sony@music.it'),
(3, 'Warner', 'Milano', '02987654', 'warner@music.it'),
(4, 'Piccola Casa', 'Torino', '011555666', 'indie@music.it');

INSERT INTO artisti VALUES
(1, 'Mengoni', 'Marco', 'Mengoni', '1988-12-25', 'Italia', 'singolo', 1),
(2, 'Maneskin', NULL, NULL, NULL, 'Italia', 'gruppo', 2),
(3, 'Annalisa', 'Annalisa', 'Scarrone', '1985-08-05', 'Italia', 'singolo', 3),
(4, 'Pinguini', NULL, NULL, NULL, 'Italia', 'gruppo', 1),
(5, 'Ghali', 'Ghali', 'Amdouni', '1993-05-21', 'Italia', 'singolo', 2),
(6, 'Il Volo', NULL, NULL, NULL, 'Italia', 'gruppo', 3),
(7, 'Giorgia', 'Giorgia', 'Todrani', '1971-04-26', 'Italia', 'singolo', 1),
(8, 'Negramaro', NULL, NULL, NULL, 'Italia', 'gruppo', 2),
(9, 'Emma', 'Emma', 'Marrone', '1984-05-25', 'Italia', 'singolo', 3),
(10, 'The Kolors', NULL, NULL, NULL, 'Italia', 'gruppo', 1),
(11, 'Giovane1', 'Marco', 'Bianchi', '2001-03-15', 'Italia', 'singolo', 4),
(12, 'Giovane2', 'Sara', 'Verdi', '1999-07-22', 'Italia', 'singolo', 4),
(13, 'Nuova Band', NULL, NULL, NULL, 'Italia', 'gruppo', 4),
(14, 'Stella', 'Stella', 'Neri', '2000-11-10', 'Italia', 'singolo', 4);

INSERT INTO canzoni VALUES
(1, 'Due Vite', 205, 'Marco Mengoni', 'Marco Mengoni', 'Universal', 2025),
(2, 'Supermodel', 198, 'Damiano', 'Maneskin', 'Sony', 2025),
(3, 'Sinceramente', 187, 'Annalisa', 'Annalisa', 'Warner', 2025),
(4, 'Giovani', 210, 'Riccardo', 'Pinguini', 'Universal', 2025),
(5, 'Casa Mia', 195, 'Ghali', 'Ghali', 'Sony', 2025),
(6, 'Capolavoro', 220, 'Gianluca', 'Il Volo', 'Warner', 2025),
(7, 'Parole', 203, 'Giorgia', 'Giorgia', 'Universal', 2025),
(8, 'Contatto', 188, 'Giuliano', 'Negramaro', 'Sony', 2025),
(9, 'Apnea', 192, 'Emma', 'Emma', 'Warner', 2025),
(10, 'Disco', 201, 'Stash', 'The Kolors', 'Universal', 2025),
(11, 'Primo Sogno', 179, 'Marco B', 'Marco B', 'Indie', 2025),
(12, 'Liberta', 185, 'Sara V', 'Sara V', 'Indie', 2025),
(13, 'Insieme', 190, 'Band', 'Band', 'Indie', 2025),
(14, 'Futuro', 175, 'Stella', 'Stella', 'Indie', 2025);

INSERT INTO partecipazioni VALUES
(1, 1, 1, 1, 1, NULL, NULL), (2, 2, 2, 1, 1, NULL, NULL), (3, 3, 3, 1, 1, NULL, NULL),
(4, 4, 4, 1, 1, NULL, NULL), (5, 5, 5, 1, 1, NULL, NULL), (6, 6, 6, 1, 1, NULL, NULL),
(7, 7, 7, 1, 1, NULL, NULL), (8, 8, 8, 1, 1, NULL, NULL), (9, 9, 9, 1, 1, NULL, NULL),
(10, 10, 10, 1, 1, NULL, NULL), (11, 11, 11, 1, 2, NULL, NULL), (12, 12, 12, 1, 2, NULL, NULL),
(13, 13, 13, 1, 2, NULL, NULL), (14, 14, 14, 1, 2, NULL, NULL);

INSERT INTO covers VALUES
(1, 1, 'Caruso', 'Lucio Dalla', 1986, NULL),
(2, 2, 'Azzurro', 'Celentano', 1968, NULL),
(3, 3, 'Solitudine', 'Laura Pausini', 1993, NULL);

INSERT INTO esibizioni VALUES
(1, 1, 1, 1, 'gara', NULL), (2, 1, 2, 2, 'gara', NULL), (3, 1, 3, 3, 'gara', NULL),
(4, 2, 4, 1, 'gara', NULL), (5, 2, 11, 2, 'gara', NULL), (6, 4, 1, 1, 'cover', 1);

INSERT INTO voti VALUES
(1, 1, 1, 2, 85, 25.5, 100), (2, 1, 2, 2, 78, 23.4, 100), (3, 1, 3, 2, 92, 27.6, 100),
(4, 2, 4, 1, 12500, 35.2, 50), (5, 2, 4, 3, 88, 31.1, 50), (6, 2, 11, 1, 8900, 22.1, 34);

/*************************************************************************************************************************************************************************/ 
--2. Vista
/* Inserire qui la specifica il linguaggio naturale di una vista che si ritiene utile per visualizzare alcune informazioni aggregate di interesse per il dominio, che
include accesso ad informazioni contenute in almeno tre tabelle diverse, unÕoperazione di raggruppamento e il calcolo di almeno tre diverse informazioni aggregate       */
/*************************************************************************************************************************************************************************/ 

/* Vista per vedere come vanno gli artisti - mostra nome, casa disco, categoria e i voti che prendono in media */

CREATE VIEW risultati_artisti AS
SELECT 
    a.nome_artistico,
    cd.nome as casa_discografica,
    cat.nome as categoria,
    COUNT(e.id) as num_esibizioni,
    AVG(v.numero_voti) as media_voti,
    AVG(v.percentuale) as media_perc,
    SUM(v.percentuale * v.peso / 100) / COUNT(*) as punteggio_finale
FROM artisti a
JOIN case_disco cd ON a.casa_disco_id = cd.id
JOIN partecipazioni p ON a.id = p.artista_id
JOIN categorie cat ON p.categoria_id = cat.id
LEFT JOIN esibizioni e ON p.id = e.partecipazione_id
LEFT JOIN voti v ON p.id = v.partecipazione_id
GROUP BY a.id, a.nome_artistico, cd.nome, cat.nome
HAVING COUNT(v.id) > 0;

/*************************************************************************************************************************************************************************/ 
--3. Interrogazioni
/*************************************************************************************************************************************************************************/ 

/*************************************************************************************************************************************************************************/ 
/* 3a (interrogazione con operazione insiemistica)															 */
/* Artisti che fanno sia i campioni che gli ospiti per le cover */
/*************************************************************************************************************************************************************************/ 

SELECT a.nome_artistico 
FROM artisti a
JOIN partecipazioni p ON a.id = p.artista_id
JOIN categorie cat ON p.categoria_id = cat.id
WHERE cat.nome = 'Campioni'

INTERSECT

SELECT a.nome_artistico  
FROM artisti a
JOIN covers c ON a.id = c.ospite_id;

/*************************************************************************************************************************************************************************/ 
/* 3b (interrogazione di divisione)                                                                                                                                      */
/* Artisti che si esibiscono in tutte le serate */
/*************************************************************************************************************************************************************************/ 

SELECT a.nome_artistico
FROM artisti a
WHERE NOT EXISTS (
    SELECT s.id
    FROM serate s
    WHERE NOT EXISTS (
        SELECT 1
        FROM esibizioni e
        JOIN partecipazioni p ON e.partecipazione_id = p.id
        WHERE p.artista_id = a.id 
        AND e.serata_id = s.id
    )
);

/*************************************************************************************************************************************************************************/ 
/* 3c (interrogazione con sottointerrogazione correlata)                                                                                                                 */
/* Artisti che hanno preso piu voti della media della loro categoria */
/*************************************************************************************************************************************************************************/ 

SELECT a.nome_artistico, cat.nome, AVG(v.percentuale) as punteggio
FROM artisti a
JOIN partecipazioni p ON a.id = p.artista_id
JOIN categorie cat ON p.categoria_id = cat.id
JOIN voti v ON p.id = v.partecipazione_id
GROUP BY a.id, a.nome_artistico, cat.id, cat.nome
HAVING AVG(v.percentuale) > (
    SELECT AVG(v2.percentuale)
    FROM voti v2
    JOIN partecipazioni p2 ON v2.partecipazione_id = p2.id
    WHERE p2.categoria_id = cat.id
);

/*************************************************************************************************************************************************************************/ 
--4. Funzioni
/*************************************************************************************************************************************************************************/ 

/*************************************************************************************************************************************************************************/ 
/* 4a: operazione di inserimento non banale, effettuando tutti gli opportuni controlli e calcoli di dati derivati.                                                       */
/* Funzione per aggiungere una partecipazione controllando che non ci siano doppioni e che la durata vada bene */
/*************************************************************************************************************************************************************************/ 

CREATE OR REPLACE FUNCTION aggiungi_partecipazione(
    artista_id_param INTEGER,
    canzone_id_param INTEGER, 
    festival_id_param INTEGER,
    categoria_id_param INTEGER
) RETURNS INTEGER AS $$
DECLARE
    durata_minuti INTEGER;
    limite INTEGER;
    gia_partecipa INTEGER;
    nuovo_id INTEGER;
BEGIN
    SELECT COUNT(*) INTO gia_partecipa
    FROM partecipazioni 
    WHERE artista_id = artista_id_param AND festival_id = festival_id_param;
    
    IF gia_partecipa > 0 THEN
        RAISE EXCEPTION 'questo artista gia partecipa!';
    END IF;
    
    SELECT durata INTO durata_minuti
    FROM canzoni WHERE id = canzone_id_param;
    
    IF categoria_id_param = 1 THEN 
        limite := 210;
    ELSE  
        limite := 180;
    END IF;
    
    IF durata_minuti > limite THEN
        RAISE EXCEPTION 'canzone troppo lunga per questa categoria';
    END IF;
    
    INSERT INTO partecipazioni (artista_id, canzone_id, festival_id, categoria_id)
    VALUES (artista_id_param, canzone_id_param, festival_id_param, categoria_id_param)
    RETURNING id INTO nuovo_id;
    
    RETURN nuovo_id;
END;
$$ LANGUAGE plpgsql;

/*************************************************************************************************************************************************************************/ 
/* 4b: calcolo di unÕinformazione derivata rilevante e non banale, che richieda lÕaccesso a diverse tabelle e unÕaggregazione                                            */
/* Funzione per calcolare la classifica di un artista */
/*************************************************************************************************************************************************************************/ 

CREATE OR REPLACE FUNCTION classifica_artista(artista_id_param INTEGER, festival_id_param INTEGER) 
RETURNS TABLE(
    nome VARCHAR,
    categoria VARCHAR,
    punti_totali DECIMAL,
    posizione INTEGER
) AS $$
BEGIN
    RETURN QUERY
    WITH punti_artisti AS (
        SELECT 
            a.nome_artistico,
            cat.nome,
            SUM(v.percentuale * v.peso / 100) as punti_finali,
            p.artista_id
        FROM artisti a
        JOIN partecipazioni p ON a.id = p.artista_id
        JOIN categorie cat ON p.categoria_id = cat.id  
        JOIN voti v ON p.id = v.partecipazione_id
        WHERE p.festival_id = festival_id_param
        GROUP BY a.id, a.nome_artistico, cat.nome, p.artista_id
    ),
    classifica AS (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY nome ORDER BY punti_finali DESC) as pos
        FROM punti_artisti
    )
    SELECT nome_artistico, nome, punti_finali, pos::INTEGER
    FROM classifica 
    WHERE artista_id = artista_id_param;
END;
$$ LANGUAGE plpgsql;

/*************************************************************************************************************************************************************************/ 
--5. Trigger
/*************************************************************************************************************************************************************************/ 

/*************************************************************************************************************************************************************************/ 
/* 5a: trigger per la verifica di un vincolo che non sia implementabile come vincolo CHECK                                                                               */                                                                          
/* Trigger che controlla che le nuove proposte abbiano solo una canzone */
/*************************************************************************************************************************************************************************/ 

CREATE OR REPLACE FUNCTION controlla_nuove_proposte()
RETURNS TRIGGER AS $$
DECLARE
    quante INTEGER;
    nome_cat VARCHAR;
BEGIN
    SELECT nome INTO nome_cat 
    FROM categorie WHERE id = NEW.categoria_id;
    
    IF nome_cat = 'Nuove Proposte' THEN
        SELECT COUNT(*) INTO quante
        FROM partecipazioni p
        WHERE p.artista_id = NEW.artista_id 
        AND p.categoria_id = NEW.categoria_id
        AND p.festival_id = NEW.festival_id;
        
        IF quante >= 1 THEN
            RAISE EXCEPTION 'le nuove proposte possono avere solo una canzone!';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_nuove_proposte
    BEFORE INSERT ON partecipazioni
    FOR EACH ROW
    EXECUTE FUNCTION controlla_nuove_proposte();

/*************************************************************************************************************************************************************************/ 
/* 5b: trigger per il mantenimento di informazione derivata o per l'implementazione di una regola di dominio                                                             */                                                                          
/* Trigger per aggiornare i punti totali quando cambiano i voti */
/*************************************************************************************************************************************************************************/ 

CREATE OR REPLACE FUNCTION aggiorna_punti()
RETURNS TRIGGER AS $$
DECLARE
    punti_nuovi DECIMAL(8,2);
BEGIN
    SELECT COALESCE(SUM(percentuale * peso / 100), 0)
    INTO punti_nuovi
    FROM voti v
    WHERE v.partecipazione_id = COALESCE(NEW.partecipazione_id, OLD.partecipazione_id);
    
    UPDATE partecipazioni 
    SET punti = punti_nuovi
    WHERE id = COALESCE(NEW.partecipazione_id, OLD.partecipazione_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER aggiorna_punti_trigger
    AFTER INSERT OR UPDATE OR DELETE ON voti
    FOR EACH ROW
    EXECUTE FUNCTION aggiorna_punti();