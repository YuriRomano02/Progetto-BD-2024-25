--- Progetto BD 24-25 (12 CFU)
--- GRUPPO n.69
--- Yuri Romano 5231931 , Aurora Parodi 5216444 

--- PARTE III 
/* il file deve essere file SQL ... cio formato solo testo e apribili ed eseguibili in pgAdmin */

/*************************************************************************************************************************************************************************/ 
--1b. Schema per popolamento in the large
/*************************************************************************************************************************************************************************/ 

/* per ogni relazione R coinvolta nel carico di lavoro, inserire qui i comandi SQL per creare una nuova relazione R_CL con schema equivalente a R ma senza vincoli di chiave primaria, secondaria o esterna e con eventuali attributi dummy */

CREATE TABLE festival_CL (
    id INTEGER,
    nome VARCHAR(150),
    edizione INTEGER,
    anno INTEGER,
    inizio DATE,
    fine DATE,
    teatro VARCHAR(100),
    direttore VARCHAR(100)
);

CREATE TABLE serate_CL (
    id INTEGER,
    numero INTEGER,
    data_serata DATE,
    tipo VARCHAR(50),
    festival_id INTEGER
);

CREATE TABLE case_disco_CL (
    id INTEGER,
    nome VARCHAR(100),
    citta VARCHAR(100),
    tel VARCHAR(20),
    mail VARCHAR(100)
);

CREATE TABLE artisti_CL (
    id INTEGER,
    nome_artistico VARCHAR(150),
    nome VARCHAR(100),
    cognome VARCHAR(100),
    nascita DATE,
    paese VARCHAR(50),
    singolo_o_gruppo VARCHAR(20),
    casa_disco_id INTEGER
);

CREATE TABLE categorie_CL (
    id INTEGER,
    nome VARCHAR(50)
);

CREATE TABLE canzoni_CL (
    id INTEGER,
    titolo VARCHAR(200),
    durata INTEGER,
    testo_autore VARCHAR(100),
    musica_autore VARCHAR(100),
    editore VARCHAR(100),
    anno INTEGER
);

CREATE TABLE partecipazioni_CL (
    id INTEGER,
    artista_id INTEGER,
    canzone_id INTEGER,
    festival_id INTEGER,
    categoria_id INTEGER,
    posizione INTEGER,
    punti DECIMAL(8,2)
);

CREATE TABLE giurie_CL (
    id INTEGER,
    tipo VARCHAR(50),
    descrizione TEXT
);

CREATE TABLE voti_CL (
    id INTEGER,
    serata_id INTEGER,
    partecipazione_id INTEGER,
    giuria_id INTEGER,
    numero_voti INTEGER,
    percentuale DECIMAL(5,2),
    peso DECIMAL(5,2)
);

CREATE TABLE covers_CL (
    id INTEGER,
    partecipazione_id INTEGER,
    titolo VARCHAR(200),
    artista_orig VARCHAR(100),
    anno_orig INTEGER,
    ospite_id INTEGER
);

CREATE TABLE esibizioni_CL (
    id INTEGER,
    serata_id INTEGER,
    partecipazione_id INTEGER,
    ordine_numero INTEGER,
    tipo VARCHAR(20),
    cover_id INTEGER
);

/*************************************************************************************************************************************************************************/
--1c. Carico di lavoro
/*************************************************************************************************************************************************************************/ 

/*************************************************************************************************************************************************************************/ 
/* Q1: Query con singola selezione e nessun join */
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per la creazione della query, in modo da visualizzarne piane di esecuzione e tempi di esecuzione */ 

EXPLAIN ANALYZE
SELECT nome_artistico, nome, cognome, paese 
FROM artisti_CL 
WHERE casa_disco_id = 2;

/*************************************************************************************************************************************************************************/ 
/* Q2: Query con condizione di selezione complessa e nessun join */
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per la creazione della query, in modo da visualizzarne piane di esecuzione e tempi di esecuzion */ 

EXPLAIN ANALYZE
SELECT titolo, durata, testo_autore, musica_autore 
FROM canzoni_CL 
WHERE durata BETWEEN 180 AND 210 
  AND (testo_autore LIKE '%Marco%' OR musica_autore LIKE '%Emma%')
  AND anno >= 2024;

/*************************************************************************************************************************************************************************/ 
/* Q3: Query con almeno un join e almeno una condizione di selezione */
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per la creazione della query, in modo da visualizzarne piane di esecuzione e tempi di esecuzione */ 

EXPLAIN ANALYZE
SELECT a.nome_artistico, cd.nome as casa_disco, v.percentuale, v.numero_voti
FROM artisti_CL a
JOIN partecipazioni_CL p ON a.id = p.artista_id
JOIN voti_CL v ON p.id = v.partecipazione_id
JOIN case_disco_CL cd ON a.casa_disco_id = cd.id
JOIN serate_CL s ON v.serata_id = s.id
WHERE s.tipo = 'cover' 
  AND v.percentuale > 25.0
  AND cd.citta IN ('Milano', 'Roma');

/*************************************************************************************************************************************************************************/
--1e. Schema fisico
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per cancellare tutti gli indici giˆ esistenti per le tabelle coinvolte nel carico di lavoro */

DROP INDEX IF EXISTS idx_artisti_casa_disco;
DROP INDEX IF EXISTS idx_canzoni_durata;
DROP INDEX IF EXISTS idx_canzoni_autori;
DROP INDEX IF EXISTS idx_voti_percentuale;
DROP INDEX IF EXISTS idx_voti_partecipazione;
DROP INDEX IF EXISTS idx_partecipazioni_artista;
DROP INDEX IF EXISTS idx_serate_tipo;
DROP INDEX IF EXISTS idx_case_disco_citta;

/* inserire qui i comandi SQL perla creazione dello schema fisico della base di dati in accordo al risultato della fase di progettazione fisica per il carico di lavoro. */

CREATE INDEX idx_artisti_casa_disco ON artisti_CL(casa_disco_id);

CREATE INDEX idx_canzoni_durata ON canzoni_CL(durata);
CREATE INDEX idx_canzoni_autori ON canzoni_CL(testo_autore, musica_autore);
CREATE INDEX idx_canzoni_anno ON canzoni_CL(anno);

CREATE INDEX idx_voti_percentuale ON voti_CL(percentuale);
CREATE INDEX idx_voti_partecipazione ON voti_CL(partecipazione_id);
CREATE INDEX idx_voti_serata ON voti_CL(serata_id);
CREATE INDEX idx_partecipazioni_artista ON partecipazioni_CL(artista_id);
CREATE INDEX idx_serate_tipo ON serate_CL(tipo);
CREATE INDEX idx_case_disco_citta ON case_disco_CL(citta);

CREATE INDEX idx_partecipazioni_id ON partecipazioni_CL(id);
CREATE INDEX idx_artisti_id ON artisti_CL(id);

/*************************************************************************************************************************************************************************/ 
--1f. Popolamento in the large
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per il popolamento 'in the large' delle relazioni coinvolte nel carico di lavoro  */

INSERT INTO festival_CL 
SELECT generate_series(1, 5), 
       'Sanremo ' || (2020 + generate_series(1, 5)), 
       70 + generate_series(1, 5),
       2020 + generate_series(1, 5),
       ('2025-02-' || (10 + generate_series(1, 5)))::DATE,
       ('2025-02-' || (15 + generate_series(1, 5)))::DATE,
       'Teatro Ariston',
       CASE generate_series(1, 5) % 3 
         WHEN 0 THEN 'Carlo Conti'
         WHEN 1 THEN 'Amadeus'
         ELSE 'Claudio Baglioni'
       END;

INSERT INTO serate_CL
SELECT f.id * 5 + s.num - 5,
       s.num,
       (f.inizio + (s.num - 1))::DATE,
       CASE s.num 
         WHEN 1 THEN 'prima'
         WHEN 2 THEN 'seconda' 
         WHEN 3 THEN 'terza'
         WHEN 4 THEN 'cover'
         WHEN 5 THEN 'finale'
       END,
       f.id
FROM festival_CL f, 
     (SELECT generate_series(1, 5) as num) s;

INSERT INTO case_disco_CL
SELECT generate_series(1, 50),
       CASE generate_series(1, 50) % 10
         WHEN 0 THEN 'Universal Music'
         WHEN 1 THEN 'Sony Music'
         WHEN 2 THEN 'Warner Music'
         WHEN 3 THEN 'EMI Records'
         WHEN 4 THEN 'Atlantic Records'
         WHEN 5 THEN 'Columbia Records'
         WHEN 6 THEN 'RCA Records'
         WHEN 7 THEN 'Def Jam'
         WHEN 8 THEN 'Capitol Records'
         ELSE 'Indie Label ' || generate_series(1, 50)
       END,
       CASE generate_series(1, 50) % 4
         WHEN 0 THEN 'Milano'
         WHEN 1 THEN 'Roma'
         WHEN 2 THEN 'Torino'
         ELSE 'Napoli'
       END,
       '02' || LPAD((generate_series(1, 50) * 123456)::TEXT, 7, '0'),
       'info' || generate_series(1, 50) || '@music.it';

INSERT INTO categorie_CL VALUES (1, 'Campioni'), (2, 'Nuove Proposte');

INSERT INTO giurie_CL VALUES 
(1, 'Televoto', 'Voto del pubblico'),
(2, 'Stampa', 'Giuria della stampa'),
(3, 'Radio', 'Giuria delle radio');

INSERT INTO artisti_CL
SELECT generate_series(1, 1000),
       'Artista' || generate_series(1, 1000),
       CASE generate_series(1, 1000) % 2 
         WHEN 0 THEN 'Nome' || generate_series(1, 1000)
         ELSE NULL
       END,
       CASE generate_series(1, 1000) % 2 
         WHEN 0 THEN 'Cognome' || generate_series(1, 1000)
         ELSE NULL
       END,
       ('1980-01-01'::DATE + (generate_series(1, 1000) * 10 || ' days')::INTERVAL)::DATE,
       'Italia',
       CASE generate_series(1, 1000) % 3
         WHEN 0 THEN 'singolo'
         ELSE 'gruppo'
       END,
       (generate_series(1, 1000) % 50) + 1;

INSERT INTO canzoni_CL
SELECT generate_series(1, 2000),
       'Canzone ' || generate_series(1, 2000),
       150 + (generate_series(1, 2000) % 120),
       'Autore Testo ' || ((generate_series(1, 2000) % 100) + 1),
       'Autore Musica ' || ((generate_series(1, 2000) % 100) + 1),
       'Editore ' || ((generate_series(1, 2000) % 20) + 1),
       2020 + (generate_series(1, 2000) % 5);

INSERT INTO partecipazioni_CL
SELECT generate_series(1, 5000),
       (generate_series(1, 5000) % 1000) + 1,
       (generate_series(1, 5000) % 2000) + 1,
       (generate_series(1, 5000) % 5) + 1,
       CASE generate_series(1, 5000) % 10
         WHEN 0 THEN 2
         ELSE 1
       END,
       NULL,
       NULL;

INSERT INTO voti_CL
SELECT generate_series(1, 25000),
       (generate_series(1, 25000) % 25) + 1,
       (generate_series(1, 25000) % 5000) + 1,
       (generate_series(1, 25000) % 3) + 1,
       1000 + (generate_series(1, 25000) % 50000),
       10.0 + (generate_series(1, 25000) % 800) / 10.0,
       CASE (generate_series(1, 25000) % 3) + 1
         WHEN 1 THEN 34.0
         WHEN 2 THEN 33.0
         ELSE 33.0
       END;

INSERT INTO covers_CL
SELECT generate_series(1, 500),
       (generate_series(1, 500) % 5000) + 1,
       'Cover Song ' || generate_series(1, 500),
       'Artista Originale ' || generate_series(1, 500),
       1970 + (generate_series(1, 500) % 50),
       CASE generate_series(1, 500) % 5 
         WHEN 0 THEN (generate_series(1, 500) % 1000) + 1
         ELSE NULL
       END;

INSERT INTO esibizioni_CL
SELECT generate_series(1, 8000),
       (generate_series(1, 8000) % 25) + 1,
       (generate_series(1, 8000) % 5000) + 1,
       (generate_series(1, 8000) % 30) + 1,
       CASE generate_series(1, 8000) % 8
         WHEN 0 THEN 'cover'
         ELSE 'gara'
       END,
       CASE generate_series(1, 8000) % 8
         WHEN 0 THEN (generate_series(1, 8000) % 500) + 1
         ELSE NULL
       END;

/*************************************************************************************************************************************************************************/ 
--2. Controllo dell'accesso 
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per la definizione della politica di controllo dell'accesso della base di dati  (definizione ruoli, gerarchia, definizione utenti, assegnazione privilegi) in modo che, dopo l'esecuzione di questi comandi, 
le operazioni corrispondenti ai privilegi delegati ai ruoli e agli utenti sia correttamente eseguibili. */

CREATE ROLE amministratore_festival;
CREATE ROLE organizzatore_serata;
CREATE ROLE giurato;
CREATE ROLE utente_lettura;

GRANT utente_lettura TO giurato;
GRANT giurato TO organizzatore_serata;
GRANT organizzatore_serata TO amministratore_festival;

GRANT SELECT ON festival, serate, artisti, canzoni, categorie TO utente_lettura;

GRANT SELECT, INSERT, UPDATE ON voti TO giurato;
GRANT SELECT ON partecipazioni, giurie TO giurato;

GRANT SELECT, INSERT, UPDATE, DELETE ON esibizioni TO organizzatore_serata;
GRANT SELECT, INSERT, UPDATE, DELETE ON covers TO organizzatore_serata;
GRANT SELECT, UPDATE ON partecipazioni TO organizzatore_serata;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO amministratore_festival;

CREATE USER admin_sanremo WITH PASSWORD 'admin2025!';
CREATE USER organizzatore1 WITH PASSWORD 'org2025!';
CREATE USER organizzatore2 WITH PASSWORD 'org2025!'; 
CREATE USER giurato_stampa WITH PASSWORD 'stampa2025!';
CREATE USER giurato_radio WITH PASSWORD 'radio2025!';
CREATE USER giurato_televoto WITH PASSWORD 'tv2025!';
CREATE USER ospite_pubblico WITH PASSWORD 'guest2025!';

GRANT amministratore_festival TO admin_sanremo;
GRANT organizzatore_serata TO organizzatore1, organizzatore2;
GRANT giurato TO giurato_stampa, giurato_radio, giurato_televoto;
GRANT utente_lettura TO ospite_pubblico;

GRANT SELECT ON giurie TO giurato_stampa, giurato_radio, giurato_televoto;

ALTER TABLE voti ENABLE ROW LEVEL SECURITY;

CREATE POLICY voti_giurato_policy ON voti
FOR ALL TO giurato
USING (
  giuria_id = (
    SELECT id FROM giurie 
    WHERE (tipo = 'Stampa' AND current_user LIKE '%stampa%') 
       OR (tipo = 'Radio' AND current_user LIKE '%radio%')
       OR (tipo = 'Televoto' AND current_user LIKE '%televoto%')
  )
);

CREATE POLICY esibizioni_organizzatore_policy ON esibizioni
FOR ALL TO organizzatore_serata
USING (
  serata_id IN (
    SELECT id FROM serate 
    WHERE data_serata = CURRENT_DATE
  )
);

GRANT EXECUTE ON FUNCTION aggiungi_partecipazione TO organizzatore_serata, amministratore_festival;
GRANT EXECUTE ON FUNCTION classifica_artista TO ALL;