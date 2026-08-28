-- ============================================================
--  NovaLife RP — database/install.sql
--  Schéma complet. Compatible MySQL 5.7 / MariaDB 10.x
--  Procédure: CREATE DATABASE novalife; USE novalife; SOURCE install.sql;
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- Joueurs (personnage principal)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `players` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `citizenid`   VARCHAR(12)  NOT NULL,
    `license`     VARCHAR(60)  NOT NULL,
    `name`        VARCHAR(50)  NOT NULL DEFAULT 'Unknown',
    `money`       JSON         NOT NULL,                       -- {"cash":N,"bank":N}
    `job`         JSON         NOT NULL,                       -- {"name":..,"grade":..}
    `identity`    JSON         NULL,                           -- rempli par novalife_identity
    `position`    JSON         NULL,                           -- dernière position valide
    `admin_group` VARCHAR(20)  NULL DEFAULT NULL,              -- helper/mod/admin/superadmin/owner
    `char_id`     TINYINT      NOT NULL DEFAULT 1,             -- multi-personnages
    `last_seen`   DATETIME     NULL,
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_citizenid` (`citizenid`),
    KEY `idx_license` (`license`),
    KEY `idx_char` (`license`, `char_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Multi-personnages (un joueur peut en avoir plusieurs)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `characters` (
    `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `license`    VARCHAR(60)  NOT NULL,
    `char_id`    TINYINT      NOT NULL DEFAULT 1,
    `citizenid`  VARCHAR(12)  NOT NULL,
    `identity`   JSON         NOT NULL,
    `money`      JSON         NULL,
    `job`        JSON         NULL,
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_license_char` (`license`, `char_id`),
    KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Identité / permis (novalife_identity)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `identities` (
    `citizenid`      VARCHAR(12) NOT NULL,
    `firstname`      VARCHAR(40) NOT NULL,
    `lastname`       VARCHAR(40) NOT NULL,
    `dob`            DATE        NOT NULL,                     -- date de naissance
    `sex`            ENUM('homme','femme') NOT NULL DEFAULT 'homme',
    `height`         SMALLINT    NOT NULL DEFAULT 180,         -- cm
    `nationality`    VARCHAR(40) NOT NULL DEFAULT 'Française',
    `appearance`     JSON        NULL,                         -- perso (visage, etc.)
    `licenses`       JSON        NULL,                         -- {"car":1,"bike":0,"truck":0,"weapon":0}
    PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Véhicules personnels
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `player_vehicles` (
    `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `citizenid`  VARCHAR(12)  NOT NULL,
    `vehicle`    VARCHAR(40)  NOT NULL,                        -- modèle
    `plate`      VARCHAR(12)  NOT NULL,
    `garage`     VARCHAR(40)  NOT NULL DEFAULT 'public',
    `state`      TINYINT      NOT NULL DEFAULT 1,              -- 1=garé, 0=sorti, 2=fourrière
    `fuel`       FLOAT        NOT NULL DEFAULT 100.0,
    `engine`     INT          NOT NULL DEFAULT 1000,           -- 0..1000 (GTA)
    `body`       INT          NOT NULL DEFAULT 1000,           -- 0..1000
    `insurance`  TINYINT      NOT NULL DEFAULT 1,
    `mods`       JSON         NULL,
    `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_plate` (`plate`),
    KEY `idx_citizenid` (`citizenid`),
    KEY `idx_garage` (`garage`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Clés de véhicules (partage)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `vehicle_keys` (
    `plate`     VARCHAR(12) NOT NULL,
    `citizenid` VARCHAR(12) NOT NULL,
    `have_key`  TINYINT     NOT NULL DEFAULT 1,
    PRIMARY KEY (`plate`, `citizenid`),
    KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Factures
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `bills` (
    `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `citizenid`    VARCHAR(12)  NOT NULL,                      -- débiteur
    `sender`       VARCHAR(40)  NOT NULL,                      -- job/entreprise émetteur
    `sender_citizenid` VARCHAR(12) NULL,
    `amount`       INT          NOT NULL,
    `reason`       VARCHAR(120) NOT NULL,
    `paid`         TINYINT      NOT NULL DEFAULT 0,
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_citizenid` (`citizenid`),
    KEY `idx_paid` (`paid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Banque — comptes & transactions
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `bank_accounts` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `citizenid`   VARCHAR(12)  NULL,                            -- NULL = compte entreprise
    `biz`         VARCHAR(40)  NULL,
    `balance`     BIGINT       NOT NULL DEFAULT 0,
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_biz` (`biz`),
    KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `bank_transactions` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `citizenid`   VARCHAR(12)  NOT NULL,
    `type`        VARCHAR(20)  NOT NULL,                       -- deposit/withdraw/transfer_in/out/bill
    `amount`      INT          NOT NULL,
    `counterparty` VARCHAR(40) NULL,
    `ts`          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Entreprises
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `businesses` (
    `name`        VARCHAR(40)  NOT NULL,
    `label`       VARCHAR(60)  NOT NULL,
    `balance`     BIGINT       NOT NULL DEFAULT 0,
    `owner`       VARCHAR(12)  NULL,                            -- citizenid du patron
    `employees`   JSON         NULL,                            -- [{citizenid,grade}]
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Police — casier judiciaire, amendes, mandats, rapports
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `criminal_records` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `citizenid`   VARCHAR(12)  NOT NULL,
    `charges`     TEXT         NOT NULL,
    `officer`     VARCHAR(40)  NOT NULL,
    `date`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `warrants` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `citizenid`   VARCHAR(12)  NOT NULL,
    `reason`      VARCHAR(160) NOT NULL,
    `issued_by`   VARCHAR(40)  NOT NULL,
    `active`      TINYINT      NOT NULL DEFAULT 1,
    `date`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `police_reports` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `title`       VARCHAR(80)  NOT NULL,
    `body`        TEXT         NOT NULL,
    `author`      VARCHAR(40)  NOT NULL,
    `date`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `impound` (
    `plate`       VARCHAR(12)  NOT NULL,
    `citizenid`   VARCHAR(12)  NOT NULL,
    `reason`      VARCHAR(120) NULL,
    `fee`         INT          NOT NULL DEFAULT 500,
    `date`        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Logs (audit serveur, en plus des webhooks Discord)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `server_logs` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `kind`        VARCHAR(30)  NOT NULL,
    `message`     TEXT         NOT NULL,
    `src`         INT          NULL,
    `ts`          DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_kind` (`kind`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Whitelist (optionnel)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `whitelist` (
    `license`     VARCHAR(60)  NOT NULL,
    `added_by`    VARCHAR(40)  NULL,
    `added_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Bans
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `bans` (
    `license`     VARCHAR(60)  NOT NULL,
    `reason`      VARCHAR(160) NOT NULL,
    `banned_by`   VARCHAR(40)  NOT NULL,
    `expires`     DATETIME     NULL,                            -- NULL = permanent
    `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
