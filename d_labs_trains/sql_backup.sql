DROP TABLE IF EXISTS `d_labs_trains_train`;
CREATE TABLE `d_labs_trains_train` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `idname` VARCHAR(60) NOT NULL,
  `label` VARCHAR(50) NOT NULL,
  `model` VARCHAR(60) NOT NULL,
  `hash` BIGINT UNSIGNED NOT NULL,
  `status` VARCHAR(60) NOT NULL,
  `damage` INT(11) NOT NULL,
  `stash` VARCHAR(50) NOT NULL,
  `upgrade` VARCHAR(50) NOT NULL,
  `price` INT(20) NOT NULL DEFAULT 0,
  `coal` INT(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `d_labs_train_timetable`;
CREATE TABLE `d_labs_train_timetable` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `board_name` varchar(255) NOT NULL,
  `date` varchar(10) DEFAULT NULL, 
  `time` varchar(255) DEFAULT NULL,
  `content` varchar(255) DEFAULT NULL,
  `price` varchar(10) DEFAULT NULL, 
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DROP TABLE IF EXISTS `d_labs_train_boss`;
CREATE TABLE `d_labs_train_boss` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `money` DECIMAL(10,2) NOT NULL DEFAULT 0.0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `d_labs_train_boss` (`money`) VALUES (0.0);





-- If you used database tables before version 2.1, apply this table change
ALTER TABLE `d_labs_trains_train`
MODIFY COLUMN `hash` BIGINT UNSIGNED NOT NULL;

-- Migration: per-train coal tank 
ALTER TABLE `d_labs_trains_train`
ADD COLUMN IF NOT EXISTS `coal` INT(11) NOT NULL DEFAULT 0;
