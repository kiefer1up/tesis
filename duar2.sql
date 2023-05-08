-- phpMyAdmin SQL Dump
-- version 4.6.6deb5
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 10, 2020 at 04:01 PM
-- Server version: 10.1.47-MariaDB-0ubuntu0.18.04.1
-- PHP Version: 7.2.24-0ubuntu0.18.04.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `duarcon`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_detail_temp` (IN `id_prod` VARCHAR(30), IN `xyz_prod` VARCHAR(3), IN `q_prod` SMALLINT(6), IN `token` VARCHAR(50), IN `order_type` TINYINT(1))  BEGIN
INSERT INTO d_ot_temporal(prod_id, prod_xyz, prod_q, user_token, order_type) 
VALUES(id_prod, xyz_prod, q_prod, token, order_type);

SELECT tmp.correlativo, tmp.prod_id, p.prod_name, tmp.prod_xyz, tmp.prod_q, tmp.order_type, tmp.user_token FROM d_ot_temporal tmp INNER JOIN prod p ON tmp.prod_id = p.prod_id WHERE tmp.user_token = token AND tmp.order_type = order_type;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `del_detail_temp` (IN `correla` TINYINT(4), IN `token` VARCHAR(50), IN `type_order` TINYINT(1))  BEGIN
DELETE FROM d_ot_temporal WHERE correlativo = correla;
SELECT tmp.correlativo, tmp.prod_id, p.prod_name, tmp.prod_xyz, tmp.prod_q, tmp.user_token, tmp.order_type FROM d_ot_temporal tmp INNER JOIN prod p ON tmp.prod_id = p.prod_id WHERE tmp.user_token = token AND tmp.order_type = type_order;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `d_cli` (IN `id` VARCHAR(10))  NO SQL
BEGIN
DELETE FROM cli WHERE cli_rut = id;
SELECT * FROM cli;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `d_user` (IN `id` VARCHAR(10))  NO SQL
BEGIN
DELETE FROM user WHERE user_id = id;
CALL s_user;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_order_in` (IN `user_id` INT(10), IN `cli_id` INT(10), IN `order_type` TINYINT(1), IN `token` INT(50))  NO SQL
BEGIN
	DECLARE order_ot mediumint(9);
	DECLARE registro int;
    
    DECLARE nw_exist smallint(6);
	DECLARE ac_exist smallint(6);
	DECLARE tmp_cod_prod 	varchar(30);
	DECLARE tmp_cant_prod	smallint(6);
    DECLARE tmp_xyz_prod	varchar (3);

	DECLARE a	int;
	SET	a = 1;    
    
    CREATE TEMPORARY TABLE tbl_tmp_tokenUser
		(
		id int NOT null	AUTO_INCREMENT PRIMARY KEY,
        	cod_prod varchar(30), 
        	cant_prod smallint(6),
		xyz_prod varchar (3),order_type_prod tinyint(1)
		);

	SET registro =(SELECT COUNT(*) FROM d_ot_temporal WHERE user_token = token AND order_type= order_type);
    IF registro > 0 THEN
INSERT INTO tbl_tmp_tokenUser(cod_prod, cant_prod, xyz_prod, order_type_prod)  SELECT prod_id, prod_q, prod_xyz, order_type FROM d_ot_temporal WHERE user_token = token AND order_type = order_type;
INSERT INTO order_ot(user_id, cli_id, order_type) VALUES(user_id, cli_id, order_type);
SET order_ot = LAST_INSERT_ID();

INSERT d_ot(order_id, prod_id, prod_q, prod_xyz) SELECT (order_ot) as noto, prod_id, prod_q, prod_xyz FROM d_ot_temporal WHERE user_token = token AND order_type= order_type;

WHILE a <= registro DO
SELECT cod_prod,cant_prod,xyz_prod INTO tmp_cod_prod, tmp_cant_prod,tmp_xyz_prod FROM tbl_tmp_tokenUser WHERE id = a;
SELECT stock_q INTO ac_exist FROM stock WHERE stock_prod_id = tmp_cod_prod AND stock_xyz_xyz = tmp_xyz_prod;
        
SET nw_exist = ac_exist + tmp_cant_prod;
UPDATE stock SET stock_q = nw_exist WHERE stock_prod_id = tmp_cod_prod AND stock_xyz_xyz = tmp_xyz_prod;
        
SET a=a+1;
END WHILE;

DELETE FROM d_ot_temporal WHERE user_token = token AND order_type = order_type;
TRUNCATE TABLE tbl_tmp_tokenUser;
SELECT * FROM order_ot WHERE ot_id = order_ot;

ELSE
SELECT * FROM sale;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `proc_order_out` (IN `user_id` VARCHAR(10), IN `cli_id` VARCHAR(10), IN `order_type` TINYINT(1), IN `token` VARCHAR(50))  BEGIN
	DECLARE order_ot mediumint(9);
	DECLARE registro int;
    
    DECLARE nw_exist smallint(6);
	DECLARE ac_exist smallint(6);
	DECLARE tmp_cod_prod 	varchar(30);
	DECLARE tmp_cant_prod	smallint(6);
    DECLARE tmp_xyz_prod	varchar (3);

	DECLARE a	int;
	SET	a = 1;    
    
    CREATE TEMPORARY TABLE tbl_tmp_tokenUser
		(
		id int NOT null	AUTO_INCREMENT PRIMARY KEY,
        	cod_prod varchar(30), 
        	cant_prod smallint(6),
		xyz_prod varchar (3)
		);

	SET registro =(SELECT COUNT(*) FROM d_ot_temporal WHERE user_token = token);
    IF registro > 0 THEN
    
INSERT INTO tbl_tmp_tokenUser(cod_prod, cant_prod, xyz_prod)  SELECT prod_id, prod_q, prod_xyz FROM d_ot_temporal WHERE user_token = token;
INSERT INTO order_ot(user_id, cli_id, order_type) VALUES(user_id, cli_id, order_type);
SET order_ot = LAST_INSERT_ID();
        
INSERT d_ot(order_id, prod_id, prod_q, prod_xyz) SELECT (order_ot) as noto, prod_id, prod_q, prod_xyz FROM d_ot_temporal WHERE user_token = token;

WHILE a <= registro DO
SELECT cod_prod,cant_prod,xyz_prod INTO tmp_cod_prod, tmp_cant_prod,tmp_xyz_prod  FROM tbl_tmp_tokenUser WHERE id = a;
SELECT stock_q INTO ac_exist FROM stock WHERE stock_prod_id = tmp_cod_prod AND stock_xyz_xyz = tmp_xyz_prod;
        
SET nw_exist = ac_exist - tmp_cant_prod;
UPDATE stock SET stock_q = nw_exist WHERE stock_prod_id = tmp_cod_prod AND stock_xyz_xyz = tmp_xyz_prod;
        
SET a=a+1;
END WHILE;

DELETE FROM d_ot_temporal WHERE user_token = token;
TRUNCATE TABLE tbl_tmp_tokenUser;
SELECT * FROM order_ot WHERE ot_id = order_ot;
    
ELSE
SELECT 0;
END IF;
  
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `r_client` (IN `id` VARCHAR(10), IN `name` VARCHAR(20), IN `cont` VARCHAR(40), IN `pat` VARCHAR(6))  NO SQL
BEGIN
INSERT INTO cli(cli_rut,cli_name,contacto,patente) VALUES (id,name,cont,pat);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `show_detail_ot` (IN `token` VARCHAR(50), IN `orderType` TINYINT(1))  BEGIN
SELECT tmp.correlativo, tmp.prod_id, p.prod_name, tmp.prod_xyz, tmp.prod_q, tmp.user_token , tmp.order_type FROM d_ot_temporal tmp INNER JOIN prod p ON tmp.prod_id = p.prod_id WHERE tmp.user_token = token AND tmp.order_type = orderType;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `s_cli` ()  NO SQL
BEGIN
SELECT * FROM cli;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `s_cli_id` (IN `id` VARCHAR(10))  NO SQL
BEGIN
SELECT cli_rut, cli_name, contacto, patente FROM cli WHERE cli_rut = id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `s_ot_dt` (IN `id` VARCHAR(30))  NO SQL
BEGIN
SELECT o.ot_id, o.cli_id, p.prod_name ,o.order_date, o.order_type, o.user_id, d.prod_id, d.prod_q, d.prod_xyz FROM ((order_ot o 
INNER JOIN d_ot d ON o.ot_id = d.order_id)                                                                                      INNER JOIN prod p ON d.prod_id = p.prod_id)                                                                                                       WHERE o.ot_id = id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `s_ot_start` ()  NO SQL
BEGIN
SELECT o.ot_id, o.cli_id, o.order_date, t.oder_name, o.user_id, c.cli_name ,c.contacto, c.patente   
FROM ((order_ot o INNER JOIN cli c ON o.cli_id     = c.cli_rut)  
INNER JOIN order_type t ON o.order_type = t.order_type_id) ORDER BY o.ot_id DESC
LIMIT 10;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `s_prod` (IN `name` VARCHAR(60))  NO SQL
BEGIN
SELECT * FROM prod WHERE prod_name = name ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `s_sale_id` (IN `id` VARCHAR(10))  NO SQL
BEGIN
SELECT * FROM sale WHERE rut_sale = id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `s_stock_prod` (IN `id_prod` VARCHAR(30))  NO SQL
BEGIN
SELECT s.stock_prod_id, p.prod_name, SUM(s.stock_q) as stock_q FROM stock s INNER JOIN prod p ON s.stock_prod_id = p.prod_id  WHERE stock_prod_id = id_prod GROUP BY s.stock_prod_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `s_stock_q_nid` (IN `q` SMALLINT(6))  NO SQL
BEGIN
SELECT s.stock_prod_id, p.prod_name, SUM(s.stock_q) FROM stock s INNER JOIN prod p ON s.stock_prod_id = p.prod_id GROUP BY s.stock_prod_id HAVING SUM(s.stock_q) <= q;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `s_stock_q_xyz` (IN `id` VARCHAR(30))  NO SQL
SELECT stock_q,stock_xyz_xyz FROM stock WHERE stock_prod_id = id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `s_user` ()  NO SQL
BEGIN
SELECT u.user_id, u.NOMBRE, r.rol FROM user u INNER JOIN rol r ON u.ID_ROL = r.id_rol ORDER BY user_id ASC;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cli`
--

CREATE TABLE `cli` (
  `cli_rut` varchar(10) NOT NULL,
  `cli_name` varchar(20) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL,
  `contacto` varchar(40) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL,
  `patente` varchar(6) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `cli`
--

INSERT INTO `cli` (`cli_rut`, `cli_name`, `contacto`, `patente`) VALUES
('174140464', 'FELIPE KIEFER', 'KIEFERXB@GMAIL.COM', 'FPCH19');

-- --------------------------------------------------------

--
-- Table structure for table `d_ot`
--

CREATE TABLE `d_ot` (
  `order_id` mediumint(9) NOT NULL,
  `prod_id` varchar(30) COLLATE utf8_spanish2_ci NOT NULL,
  `prod_q` smallint(6) NOT NULL,
  `prod_xyz` varchar(3) COLLATE utf8_spanish2_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Dumping data for table `d_ot`
--

INSERT INTO `d_ot` (`order_id`, `prod_id`, `prod_q`, `prod_xyz`) VALUES
(5, '0001', 3, 'CA3'),
(6, '0001', 3, 'CA3'),
(7, '0001', 3, 'CA3'),
(8, '0001', 3, 'CA3'),
(9, '0001', 3, 'CA3'),
(10, '0001', 3, 'CA3'),
(12, '0001', 3, 'CA3'),
(13, '0001', 3, 'CA3'),
(14, '0001', 3, 'CA3'),
(15, '0001', 3, 'CA3'),
(16, '0001', 3, 'CA3'),
(17, '0001', 3, 'CA3'),
(18, '0001', 3, 'CA3'),
(19, '0001', 3, 'CA3'),
(20, '0476', 1, 'CD1'),
(20, 'OEM35014', 1, 'EB5'),
(21, '0476', 1, 'CD1'),
(21, 'OEM35014', 1, 'EB5'),
(22, '0476', 1, 'CD1'),
(22, 'OEM35014', 1, 'EB5'),
(23, '0476', 1, 'CD1'),
(23, 'OEM35014', 1, 'EB5'),
(24, '0476', 1, 'CD1'),
(24, 'OEM35014', 1, 'EB5'),
(25, '0476', 1, 'CC1'),
(25, '0077', 1, 'CA6'),
(25, '0476', 1, 'CC1'),
(25, 'OEM35014', 1, 'EB5'),
(26, '0476', 1, 'CD1'),
(26, 'OEM35014', 1, 'EB5'),
(27, '0001', 1, 'CA3'),
(28, '0001', 1, 'CA3'),
(29, '0001', 1, 'CA3'),
(30, '0001', 1, 'CA3'),
(31, '0001', 1, 'CA3'),
(31, '0001', 1, 'CA3'),
(32, '0001', 1, 'CA3'),
(32, '0001', 1, 'CA3'),
(33, '0001', 2, 'CA3'),
(36, '0001', 2, 'CA3'),
(37, '0001', 2, 'CA3'),
(38, '0001', 2, 'CA3'),
(39, '0001', 1, 'CA3'),
(39, '0001', 1, 'CA3'),
(39, '0001', 2, 'CA3'),
(39, '0001', 3, 'CA3'),
(39, '0001', 5, 'CA3'),
(39, '0001', 6, 'CA3'),
(39, '0001', 7, 'CA3'),
(39, '0001', 8, 'CA3'),
(39, '0001', 7, 'CA3'),
(39, '0001', 1, 'CA3'),
(39, '0001', 1, 'CA3'),
(39, '0001', 2, 'CA3'),
(39, '0001', 2, 'CA3'),
(40, '0001', 2, 'CA3'),
(40, '0001', 2, 'CA3'),
(40, '0001', 1, 'CA3'),
(41, '0001', 1, 'CA3'),
(42, '0001', 1, 'CA3'),
(43, '0001', 1, 'CA3'),
(44, '0001', 1, 'CA3'),
(45, '0001', 1, 'CA3'),
(46, '0001', 5, 'CA3'),
(47, '0001', 16, 'CA3'),
(48, '0476', 1, 'CC1'),
(49, '0001', 1, 'CA3'),
(50, '0001', 10, 'CA3');

-- --------------------------------------------------------

--
-- Table structure for table `d_ot_temporal`
--

CREATE TABLE `d_ot_temporal` (
  `prod_id` varchar(30) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL,
  `prod_q` smallint(6) NOT NULL,
  `prod_xyz` varchar(3) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL,
  `correlativo` tinyint(4) NOT NULL,
  `user_token` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL,
  `order_type` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `order_ot`
--

CREATE TABLE `order_ot` (
  `ot_id` mediumint(9) NOT NULL,
  `order_type` tinyint(1) NOT NULL,
  `cli_id` varchar(10) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `user_id` varchar(10) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `order_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Dumping data for table `order_ot`
--

INSERT INTO `order_ot` (`ot_id`, `order_type`, `cli_id`, `user_id`, `order_date`) VALUES
(5, 1, '1', '1', '2020-09-24 17:32:05'),
(6, 1, '1', '1', '2020-09-24 17:37:36'),
(7, 1, '1', '1', '2020-09-24 17:38:25'),
(8, 1, '1', '1', '2020-09-24 17:44:14'),
(9, 1, '1', '1', '2020-09-24 17:57:09'),
(10, 1, '1', '1', '2020-09-24 19:31:36'),
(11, 1, '1', '1', '2020-09-24 19:31:36'),
(12, 1, '1', '1', '2020-09-24 19:54:50'),
(13, 1, '1', '1', '2020-09-24 19:58:43'),
(14, 1, '1', '1', '2020-09-24 20:11:01'),
(15, 1, '1', '1', '2020-09-24 20:17:01'),
(16, 1, '1', '1', '2020-09-24 20:19:40'),
(17, 1, '1', '1', '2020-09-24 20:21:42'),
(18, 1, '1', '1', '2020-09-24 20:23:04'),
(19, 1, '1', '1', '2020-09-24 20:23:56'),
(20, 1, '174140464', '174140464', '2020-10-01 06:38:53'),
(21, 1, '174140464', '174140464', '2020-10-01 06:39:51'),
(22, 1, '174140464', '174140464', '2020-10-01 06:41:38'),
(23, 1, '174140464', '174140464', '2020-10-01 06:45:28'),
(24, 1, '174140464', '174140464', '2020-10-01 06:51:09'),
(25, 1, '1', '1', '2020-10-01 06:52:42'),
(26, 1, '174140464', '174140464', '2020-10-01 06:53:25'),
(27, 1, '174140464', '174140464', '2020-10-01 07:00:38'),
(28, 1, '174140464', '174140464', '2020-10-01 07:12:33'),
(29, 1, '174140464', '174140464', '2020-10-01 07:13:21'),
(30, 1, '174140464', '174140464', '2020-10-01 07:18:04'),
(31, 1, '174140464', '174140464', '2020-10-01 16:13:33'),
(32, 1, '174140464', '174140464', '2020-10-01 16:17:11'),
(33, 1, '174140464', '174140464', '2020-10-06 17:39:57'),
(34, 0, '1', '174140464', '2020-10-13 12:34:44'),
(35, 0, '1', '174140464', '2020-10-13 12:42:33'),
(36, 0, '1', '174140464', '2020-10-13 12:44:48'),
(37, 0, '1', '174140464', '2020-10-13 12:49:32'),
(38, 0, '1', '174140464', '2020-10-13 12:51:16'),
(39, 1, '174140464', '174140464', '2020-10-13 18:31:51'),
(40, 0, '1', '1', '2020-11-01 22:11:03'),
(41, 0, '1', '174140464', '2020-11-01 22:48:24'),
(42, 0, '1', '174140464', '2020-11-01 22:53:30'),
(43, 1, '1', '174140464', '2020-11-01 22:54:22'),
(44, 0, '1', '174140464', '2020-11-03 19:38:39'),
(45, 1, '174140464', '174140464', '2020-11-03 20:25:01'),
(46, 0, '1', '174140464', '2020-11-06 17:12:45'),
(47, 1, '174140464', '174140464', '2020-11-06 17:14:20'),
(48, 1, '174140464', '174140464', '2020-11-06 17:15:47'),
(49, 0, '1', '174140464', '2020-11-08 18:16:13'),
(50, 0, '1', '174140464', '2020-11-08 18:20:27');

-- --------------------------------------------------------

--
-- Table structure for table `order_type`
--

CREATE TABLE `order_type` (
  `oder_name` varchar(5) COLLATE utf8_spanish2_ci NOT NULL,
  `order_type_id` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Dumping data for table `order_type`
--

INSERT INTO `order_type` (`oder_name`, `order_type_id`) VALUES
('in', 0),
('out', 1);

-- --------------------------------------------------------

--
-- Table structure for table `prod`
--

CREATE TABLE `prod` (
  `prod_id` varchar(30) COLLATE utf8_spanish2_ci NOT NULL,
  `prod_name` varchar(64) COLLATE utf8_spanish2_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Dumping data for table `prod`
--

INSERT INTO `prod` (`prod_id`, `prod_name`) VALUES
('0001', 'PF-GT-GTXHD-DP-882-S'),
('0035', 'D_BRAKE'),
('0058', 'PF-63404-PM'),
('0063', 'PF-14406-GTX'),
('0077', 'D BRAKE'),
('0080', 'PF-DP-714-PM'),
('0114', 'D BRAKE'),
('0116', 'D BRAKE'),
('0124', 'D BRAKE'),
('0166', 'D BRAKE'),
('0172', 'D BRAKE'),
('0183', 'D BRAKE'),
('0186', 'D BRAKE'),
('0195', 'D BRAKE'),
('0247', 'D BRAKE'),
('0250', 'P BRAKE'),
('0256', 'D BRAKE'),
('0270', 'P BRAKE'),
('0271', 'P BRAKE'),
('0275', 'P BRAKE'),
('0284', 'P BRAKE'),
('0292', 'P BRAKE'),
('0313', 'P BRAKE'),
('0341', 'P BRAKE'),
('0357', 'P BRAKE'),
('0359', 'P BRAKE'),
('0408', 'P BRAKE'),
('0418', 'P BRAKE'),
('0426', 'P BRAKE'),
('0430', 'P BRAKE'),
('0435', 'P BRAKE'),
('0439', 'P BRAKE'),
('0453', 'P BRAKE'),
('0456', 'P BRAKE'),
('0471', 'P BRAKE'),
('0476', 'P BRAKE'),
('0481', 'P BRAKE'),
('0489', 'P BRAKE'),
('0490', 'P BRAKE'),
('0491', 'P BRAKE'),
('0504', 'P BRAKE'),
('0531', 'P BRAKE'),
('0537', 'P BRAKE'),
('0539', 'P BRAKE'),
('0540', 'P BRAKE'),
('0541', 'P BRAKE'),
('0542', 'P BRAKE'),
('0543', 'P BRAKE'),
('0583', 'P BRAKE'),
('0592', 'P BRAKE'),
('0598', 'P BRAKE'),
('0609', 'P BRAKE'),
('0624', 'P BRAKE'),
('0625', 'P BRAKE'),
('0626', 'P BRAKE'),
('0631', 'P BRAKE'),
('0633', 'P BRAKE'),
('0647', 'P BRAKE'),
('0648', 'P BRAKE'),
('0650', 'P BRAKE'),
('0652', 'P BRAKE'),
('0655', 'P BRAKE'),
('0658', 'P BRAKE'),
('0669', 'P BRAKE'),
('0670', 'P BRAKE'),
('0673', 'P BRAKE'),
('0674', 'P BRAKE'),
('0677', 'P BRAKE'),
('0684', 'P BRAKE'),
('0686', 'P BRAKE'),
('0687', 'P BRAKE'),
('0690', 'P BRAKE'),
('0697', 'P BRAKE'),
('0698', 'P BRAKE'),
('0703', 'P BRAKE'),
('0717', 'P BRAKE'),
('0718', 'P BRAKE'),
('0724', 'P BRAKE'),
('0729', 'P BRAKE'),
('0734', 'P BRAKE'),
('0735', 'P BRAKE'),
('0736', 'P BRAKE'),
('0745', 'P BRAKE'),
('0746', 'P BRAKE'),
('0747', 'P BRAKE'),
('0753', 'P BRAKE'),
('0757', 'P BRAKE'),
('0758', 'P BRAKE'),
('0759', 'P BRAKE'),
('0760', 'P BRAKE'),
('0765', 'P BRAKE'),
('0767', 'P BRAKE'),
('0768', 'P BRAKE'),
('0769', 'P BRAKE'),
('0775', 'P BRAKE'),
('0776', 'P BRAKE'),
('0779', 'P BRAKE'),
('0780', 'P BRAKE'),
('0781', 'P BRAKE'),
('0782', 'P BRAKE'),
('0786', 'P BRAKE'),
('0798', 'P BRAKE'),
('0799', 'P BRAKE'),
('0800', 'P BRAKE'),
('0801', 'P BRAKE'),
('0802', 'P BRAKE'),
('0803', 'P BRAKE'),
('0804', 'P BRAKE'),
('0805', 'P BRAKE'),
('0813', 'P BRAKE'),
('0816', 'P BRAKE'),
('0817', 'P BRAKE'),
('0818', 'P BRAKE'),
('0819', 'P BRAKE'),
('0821', 'P BRAKE'),
('0823', 'P BRAKE'),
('0826', 'P BRAKE'),
('0827', 'P BRAKE'),
('0828', 'P BRAKE'),
('0842', 'P BRAKE'),
('0858', 'P BRAKE'),
('0866', 'P BRAKE'),
('0876', 'P BRAKE'),
('0878', 'P BRAKE'),
('0886', 'P BRAKE'),
('0899', 'P BRAKE'),
('0903', 'P BRAKE'),
('0904', 'P BRAKE'),
('0912', 'P BRAKE'),
('0914', 'P BRAKE'),
('0915', 'P BRAKE'),
('0916', 'P BRAKE'),
('0917', 'P BRAKE'),
('0918', 'P BRAKE'),
('0920', 'P BRAKE'),
('0928', 'P BRAKE'),
('0929', 'P BRAKE'),
('0932', 'P BRAKE'),
('0934', 'P BRAKE'),
('0937', 'P BRAKE'),
('0938', 'P BRAKE'),
('0939', 'P BRAKE'),
('0941', 'P BRAKE'),
('0950', 'P BRAKE'),
('0952', 'P BRAKE'),
('0955', 'P BRAKE'),
('0958', 'P BRAKE'),
('0959', 'P BRAKE'),
('0969', 'P BRAKE'),
('0998', 'P BRAKE'),
('1029', 'P BRAKE'),
('1032', 'P BRAKE'),
('1034', 'P BRAKE'),
('1035', 'P BRAKE'),
('1037', 'P BRAKE'),
('1039', 'P BRAKE'),
('1042', 'P BRAKE'),
('1043', 'P BRAKE'),
('1044', 'P BRAKE'),
('1049', 'P BRAKE'),
('1052', 'P BRAKE'),
('1053', 'P BRAKE'),
('1060', 'P BRAKE'),
('1063', 'P BRAKE'),
('1070', 'P BRAKE'),
('1071', 'P BRAKE'),
('1072', 'P BRAKE'),
('1073', 'P BRAKE'),
('1078', 'P BRAKE'),
('1090', 'P BRAKE'),
('1097', 'P BRAKE'),
('1104', 'P BRAKE'),
('1108', 'P BRAKE'),
('1109', 'P BRAKE'),
('1114', 'P BRAKE'),
('1115', 'P BRAKE'),
('1116', 'P BRAKE'),
('1118', 'P BRAKE'),
('1119', 'P BRAKE'),
('1120', 'P BRAKE'),
('1149', 'P BRAKE'),
('1150', 'P BRAKE'),
('1152', 'P BRAKE'),
('1155', 'P BRAKE'),
('1156', 'P BRAKE'),
('1158', 'P BRAKE'),
('1159', 'P BRAKE'),
('1162', 'P BRAKE'),
('1163', 'P BRAKE'),
('1166', 'P BRAKE'),
('1167', 'P BRAKE'),
('1169', 'P BRAKE'),
('1171', 'P BRAKE'),
('1173', 'P BRAKE'),
('1175', 'P BRAKE'),
('1176', 'P BRAKE'),
('1177', 'P BRAKE'),
('1180', 'P BRAKE'),
('1182', 'P BRAKE'),
('1183', 'P BRAKE'),
('1186', 'P BRAKE'),
('12', 'freno'),
('1201', 'P BRAKE'),
('1207', 'P BRAKE'),
('1208', 'P BRAKE'),
('1212', 'P BRAKE'),
('1214', 'P BRAKE'),
('1218', 'P BRAKE'),
('1220', 'P BRAKE'),
('1221', 'P BRAKE'),
('1223', 'P BRAKE'),
('1225', 'P BRAKE'),
('1228', 'P BRAKE'),
('1235', 'P BRAKE'),
('1240', 'P BRAKE'),
('1241', 'P BRAKE'),
('1242', 'P BRAKE'),
('1245', 'P BRAKE'),
('1246', 'P BRAKE'),
('1248', 'P BRAKE'),
('1249', 'P BRAKE'),
('1250', 'P BRAKE'),
('1252', 'P BRAKE'),
('1253', 'P BRAKE'),
('1258', 'P BRAKE'),
('1261', 'P BRAKE'),
('1262', 'P BRAKE'),
('1275', 'P BRAKE'),
('1284', 'P BRAKE'),
('1286', 'P BRAKE'),
('1295', 'P BRAKE'),
('1305', 'P BRAKE'),
('1310', 'P BRAKE'),
('1311', 'P BRAKE'),
('1314', 'P BRAKE'),
('1327', 'P BRAKE'),
('1329', 'P BRAKE'),
('1333', 'P BRAKE'),
('1334', 'P BRAKE'),
('1335', 'P BRAKE'),
('1340', 'P BRAKE'),
('1345', 'P BRAKE'),
('1353', 'P BRAKE'),
('1354', 'P BRAKE'),
('1356', 'P BRAKE'),
('1361', 'P BRAKE'),
('1363', 'P BRAKE'),
('1364', 'P BRAKE'),
('1370', 'P BRAKE'),
('1377', 'P BRAKE'),
('1379', 'P BRAKE'),
('1384', 'P BRAKE'),
('1390', 'P BRAKE'),
('1391', 'P BRAKE'),
('1405', 'P BRAKE'),
('1406', 'P BRAKE'),
('1418', 'P BRAKE'),
('1419', 'P BRAKE'),
('1420', 'P BRAKE'),
('1430', 'P BRAKE'),
('1432', 'P BRAKE'),
('17126-3', 'BOMBA ENCENDIDO CHEV N300 MAX 1.2'),
('2', 'freno'),
('20521-4', 'KIA RIO 2'),
('20523-0', 'F AIRE KA MORNING 1.1'),
('20534-6', 'F OIL W 713/34 D-MA'),
('20538-9', 'F FUEL OIL COMBUSTIBLE HYUNDAI / H1'),
('20541-9', 'F FUEL COMBUSTIBLE MAZDA B2500'),
('20568-0', 'F AIRE SUBARU'),
('20569-9', 'F AIRE CHEVROLET SPARK 1.0 ANTIGUO'),
('20593-1', 'F AIRE NISSAN TIIDA'),
('20598-2', 'F OIL HK W920/25 MAHINDRA'),
('20599-0', 'F OIL HK 920/48 NAVARA'),
('20602-4', 'KIA GRAND CARNIVAL'),
('20603-2', 'F AIRE HYUNDAI ELANTRA'),
('20605-9', 'F AIRE HYUNDAI H1'),
('20607-5', 'F AIRE TOYATA HILUX'),
('20609-1', 'F FUEL WK 940/6 NISSAN N'),
('20618-0', 'F OIL REXTON/ACTYON'),
('20621-0', 'F FUEL WK 940/6 NISSAN D-'),
('20623-7', 'F FUEL TOYOTA PETROLEO'),
('20654-7', 'F AIRE HYUNDAI NEW ACCENT'),
('20672-5', 'F AIRE SUZUKI APV C-3220'),
('20699-7', 'F AIRE MITSUBISHI'),
('20718-4', 'F IRE HYUNDAI FORTER'),
('20724-4', 'F AIRE HYUNDA FRONTIER'),
('20728-4', 'F AIRE HYUNDAI'),
('20730-6', 'F OIL W712/12'),
('20775-6', 'F OIL GM OPEL'),
('20778-0', 'F OIL GM OPEL'),
('20796-9', 'F FUEL COMBUSTIBLE CHEV CAPTIVA 2.0'),
('20824-8', 'F OIL W924/10 MAHINDRA DI'),
('20826-4', 'F OIL ACEITE W68/85 CHEV SPARK'),
('20827-2', 'F OIL WP920/80 CHEV ISUZU'),
('20830-2', 'F OIL W940/18 NISSAN T'),
('20833-7', 'F AIRE CHANGAN'),
('20837-K', 'F AIRE SSANGYONG 2.0 ACTYON'),
('20849-3', 'F AIRE HYUNDAI'),
('20851-5', 'F AIRE KIA'),
('20852-3', 'F POLEN KIA/HYUNDAI'),
('20856-6', 'F AIRE HYUNDAI NEW ACCENT RB'),
('20858-2', 'F OIL KIA BESTA'),
('20860-4', 'F AIRE POLEN KIA/HYUNDAI'),
('20865-5', 'F POLEN SUZUKI'),
('20889-2', 'F POLEN MAZDA'),
('20891-4', 'F AIRE CHEVROLET'),
('20895-7', 'F POLEN OPEL SUZUKI SWIFT 1.2 K12'),
('20900-7', 'F AIRE CHEVROLET ORLANDO CRUZE'),
('20901-5', 'F AIRE CHEVROLET SPARK GT 1.2'),
('20903-1', 'F AIRE FIAT FIORINO 1.3'),
('20910-4', 'F POLEN CHEVROLET AVEO 1.4'),
('20911-2', 'F AIRE HYUNDAI I-10 1.1 8V 08 TUCSON 2.0'),
('20912-0', 'F AIRE HYUNDAI NEW TUCSON 2.0'),
('20913-9', 'F AIRE KIA SOUL 1.6 16V 08'),
('20915-5', 'F POLEN KIA CERATO 1.6 07'),
('20918-K', 'F POLEN HYUNDAI ACCENT RB 1.'),
('20920-1', 'F AIRE SUZUKI CELERIO'),
('20924-4', 'F AIRE SUZUKI SX4 1.6 (MANN'),
('20932-5', 'F FUEL GASOLINA HYUNDAI I10 1.1'),
('20934-1', 'F POLEN TOYOTA AURIS 1.6/YAR'),
('20957-0', 'F AIRE CHEVRLOT SAIL 1.4 16V'),
('20958-9', 'F AIRE CHEVROLET D-MAX'),
('20960-0', 'F OIL CHEVROLET SAIL 1.4'),
('20972-4', 'F AIRE RENAULT MEGANE 1.6 16V'),
('20973-2', 'F AIRE CHEVROLET SONIC'),
('20974-0', 'F OIL'),
('20978-3', 'F FUEL COMBUSTIBLE PEUGEOT BOXER 2.0 HDI PU723X-BF70'),
('20985-6', 'F POLEN CHEVOLET OPTRA DAEWOO'),
('21010-2', 'F AIRE DODGE'),
('21015-3', 'F AIRE SUZUKI CELERIO'),
('21021-8', 'F POLEN NISSAN'),
('21027-7', 'F AIRE ISUZU'),
('21041-2', 'F POLEN HYUNDAI'),
('21043-9', 'F AIRE NISSA'),
('21044-7', 'F AIRE SUZUKI'),
('21052-0', 'F OIL TOYOTA COROLLA'),
('21053-6', 'F OIL W 8018 CHEV .D-MAAX 2'),
('21055-2', 'F FUEL KIA SORENTO 2.5 CRDI'),
('21056-0', 'F FUEL CITROEN/PEUGEOT 1.6 H'),
('21057-9', 'F FUEL CITROEN C1 1.4'),
('21073-0', 'F AIRE PEUGEOT'),
('21075-3', 'F AIRE TOYOTA'),
('21091-9', 'F FUEL COMBUSTIBLE FIAT CHEVROLET'),
('21092-7', 'F AIRE MAHINDRA UK-8900'),
('21095-1', 'F OIL HU712/7X CHEV'),
('21099-4', 'F OIL W920/82'),
('21120-6', 'F OIL CHEVROLET CAMARO 6.2 10-'),
('21126-5', 'F OIL FORD ESCAPE 3.0 W92'),
('21132-K', 'F AIRE PEUGEOT CITROEN C.3 1.4'),
('21133-8', 'F AIRE PEUGEOT'),
('21135-4', 'F AIRE HYUNDAI I-10'),
('21137-0', 'F AIREPEUGEOT 607 2.0'),
('21139-7', 'F AIRE PEUGEOT 2008 1.6 16V 2009'),
('21146-K', 'F AIRE VW AMAROK'),
('21159-1', 'KIA MORNING 1.2'),
('21207-5', 'F AIRE CITROEN C5 2.0'),
('21212-1', 'KIA MORNING 1.2 2001'),
('21213-K', 'F AIRE NISSAN PATHFINDER 2.5 2006'),
('21219-9', 'F POLEN HYUNDAI 1.1 2008'),
('21222-9', 'F POLEN VW'),
('21224-5', 'F POLEN 200XD I SSANGYONG ACTYON'),
('21239-3', 'F OIL MG3 1.5 12 W713/'),
('21246-6', 'F FUEL NISSAN NAVARA 2.5 WK9'),
('21267-9', 'F FUEL SSANGYONG ACTYON'),
('21274-1', 'F POLEN PEUGEOT 3008'),
('21283-0', 'F POLEN NISSAN X-TRAIL'),
('21305-5', 'F OIL 93745801 HU714/5 HYUNDAI'),
('21308-K', 'F AIRE GM CHEVROLET CRUZE'),
('21336-5', 'F AIRE CHERY ARRIZO 5 1.5 20'),
('21338-1', 'F FUEL PETROLEO VW TIGUAN 2.0 20'),
('21340-3', 'F AIRE NSSAN KICKS 1.6 2016'),
('21341-1', 'F POLEN SUZUKI DZIRE 1.2 201 2016'),
('21342-K', 'F POLEN SUZIKI SWIFT 1.2 201'),
('21384-5', 'F AIRE SUZUKI ALTO K10'),
('21386-1', 'F AIRE HYUNDAI SANTA FE 2. 2 CRDI/KIA SORENTO 2.2 CRDI 2011-2014'),
('21391-8', 'F AIRE HYUNDAI KIA'),
('21395-0', 'F FUEL ELEMENTO ACEITE TOYOTA RAV 4 2,400 CC 2013-2014'),
('21404-3', 'F OIL SSANG YOUNG ACTION SPORT 2.0 DIESEL 2007-2014'),
('21406-K', 'F FUEL MITSUBISHI . FUSO CANTER 6.5 E/7.5T HLUX'),
('21408-6', 'F AIRE FORD HILUT'),
('21410-8', 'F AIRE NISSAN MARCH 1.6 2013'),
('21412-4', 'F AIRE SUZUKI SWIFT 1.4 K14'),
('21414-0', 'F FUEL NISSAN NAVARA PFF50216'),
('21415-9', 'F OIL HK HU7008Z AMAROK'),
('21416-7', 'F OIL HK HU822/5X'),
('21419-1', 'F AIRE CHERRY TIGGO'),
('21420-5', 'F FUEL PU-9001X CHEVROLET'),
('21429-9', 'F AIRE TOYOTA.OLD NEW YARIS 1.5'),
('21430-2', 'F AIRE CHEVROLET TRACKER 1.8 13/15'),
('21434-5', 'F AIRE CHERY FUL WIN 1.5'),
('21439-6', 'F AIRE KIA RIO 3/KIA RIO 4'),
('21441-8', 'F AIRE HYUNDAI/KIA SORENTO 2.2 DREJES'),
('21442-6', 'F AIRE HYUNDAI STA FE'),
('21443-4', 'F POLEN HYUNDAI KIA SONATA 2.0'),
('21444-2', 'F AIRE MERCEDEZ DITO'),
('21445-0', 'F FUEL COMBUSTIBLE NISSAN NAVARA 2.5'),
('21447-7', 'F FUEL PETROLEO 1906E6 PEUGEOT 301 HD'),
('21448-5', 'F FUEL COMBUSTIBLE CITROEN NEMO 1.3 HDI'),
('21452-3', 'F AIRE FIAT CITY NEMO CITRON'),
('21454-K', 'F AIRE TOYOTA'),
('21466-3', 'F AIRE RENAULT MEGANE III 2.0 GASOLINA'),
('21468-K', 'F AIRE SSANGYONG ACTYON 2.0 DIESEL 2013'),
('21469-8', 'SSANGYOUNG ACTION 2.0'),
('21472-8', 'F OIL HU718/1X MER'),
('21483-3', 'F OIL HU724/5 HYUNDAI V'),
('21485-K', 'F AIRE GREAT WALL H0'),
('21487-6', 'F AIRE MAHINDRA XU'),
('21514-7', 'F POLEN CHEVROLET'),
('21515-5', 'F OIL CITROEN'),
('21519-8', 'F OIL ISUZU'),
('21527-9', 'F AIRE PEUGEOT'),
('21530-9', 'F OIL HYUNDAI'),
('21532-5', 'F AIRE RENAULT'),
('21548-1', 'F AIRE VW'),
('21552-K', 'F POLEN CHEVROLET SAIL 1.4 2011-2016'),
('21553-8', 'F POLEN CHEVOLET ORLANDO'),
('21560-0', 'F AIRE NEW TOYOTA HILUX 2.4 2.8 DIESEL'),
('21564-3', 'F AIRE TOYOTA H 3.0'),
('21576-7', 'F AIRE NISSAN'),
('21577-5', 'F OIL NISSAN NP-300 YS HU618X RENAULT'),
('21612-7', 'F POLEN TOYOTA HILOX 2.4/2.8'),
('21617-8', 'F AIRE MITSUBISHI L-200 2.4 NUEVA'),
('21620-8', 'F FUEL P.BOXER 2.2 HDI WK85'),
('21621-6', 'F FUEL WK-920/1 KIA FORD'),
('21622-4', 'F FUEL PETR HK NISSAN WK932/80'),
('21623-2', 'F FUEL DECANT. HK NISSA WK 850/1'),
('21631-3', 'F POLEN FIAT'),
('21632-1', 'FILTRO AIRE POLEN PEUGEOT'),
('21637-2', 'F POLEN'),
('21638-0', 'F POLEN PSA CITROEN BERLINGO 1.6'),
('21640-2', 'F FUEL FILTRO ACEITE MAZDA'),
('21643-7', 'F AIRE GM CHEVROLET SAIL NUEVO'),
('21645-3', 'F AIRE HYUNDAI GRAND I10 C-3'),
('21646-1', 'F AIRE HYUNDAI'),
('21648-8', 'F AIRE MAZDA'),
('21662-3', 'F AIRE SUZUKI'),
('21663-1', 'F AIRE M BENZ'),
('21666-6', 'F AIRE HINO'),
('21667-4', 'F AIRE HINO'),
('21668-2', 'F AIRE RENO'),
('21669-0', 'F AIRE SUZUKI'),
('21670-4', 'F AIRE CITROEN PEUGEOT 2008 1.4(2014-2016)'),
('21671-2', 'F AIRE HYUNDAI'),
('21673-9', 'F FUEL OPEL'),
('21675-5', 'F FUEL COMBUSTIBLE'),
('21686-0', 'F OIL FUEL MAZDA PETROLEO'),
('21690-9', 'F FUEL HYUNDAI H-1 WK824/1'),
('21691-K', 'F FUEL PEUGEOT'),
('21704-2', 'F AIRE MAZDA CX-5 2.0/2.5 20'),
('21709-3', 'F OIL HINO XZU413/423 W1135/11'),
('21710-7', 'F OIL HINO FB4J W1250/1'),
('21716-6', 'F OIL ME088532'),
('21725-5', 'F OIL NISSAN NP-300 YS HU618X RENAULT'),
('21732-8', 'F POLEN CU 3540 M BENZ'),
('21733-6', 'F POLEN MAZDA BT50 3.2/ FORD'),
('21735-2', 'F AIRE MAHINDRA 2018'),
('21739-5', 'F AIRE FIAT CITY'),
('21762-K', 'F AIRE'),
('21768-9', 'F POLEN'),
('21769-7', 'F AIRE MG ROBER CONFORTPLUS 1..5'),
('21770-0', 'F POLEN MEG CONFORT PLUS 1'),
('21771-9', 'F OIL CHERY TIGGO 1.6'),
('21790-5', 'F FUEL WK820/18 M BENZ'),
('21791-3', 'F FUEL PETROLEO VW AMAROK 2.0 TDI'),
('21831-6', 'F FUEL NISSAN NP-300'),
('21832-4', 'F OIL W811/80 HYUNDAI/KIA/FORD'),
('23260-2', 'F OIL INFINITI Q30-Q50'),
('23261-0', 'F AIRE RENAULT DOKKER'),
('23262-9', 'F FUEL COMBUSTIBLE FORD TRANSIT 2.2'),
('23264-5', 'F POLEN FORD EDGE 2.0/3.5'),
('23265-3', 'F AIRE FORD F150'),
('23266-1', 'F AIRE FORD ECOSPORT 1.5'),
('23268-8', 'F AIRE SSANGYONG 2.0 NUEVO/2.2'),
('23271-8', 'F AIRE CHERRY TIGGO'),
('23279-3', 'F AIRE TOYOTA'),
('23280-7', 'F AIRE PEUGEOT EXPENT 2.0'),
('23282-3', 'F AIRE MAXUS V80'),
('23283-1', 'F AIRE KIA'),
('23285-8', 'F POLEN TOYOTA'),
('23286-6', 'F POLEN VW TIGUAN 1.4 16V'),
('23292-0', 'F AIRE KIA CARNIVAL 2015'),
('23293-9', 'F AIRE HYUNDAI ELANTRA 2016'),
('23335-8', 'F AIRE HYUNDAI GRNAD I10 1.2'),
('23363-7', 'F OIL FORD TRANSIT 2.2'),
('23371-4', 'F FUEL PETROLEO AMAROK 2.0 TD 180CV'),
('23395-1', 'F AIRE HYUNDAI'),
('23593-8', 'F OIL BMW'),
('23595-4', 'F OIL PEUGEOT'),
('23601-2', 'F FUEL PETROLEO CAPTIVA'),
('23642-K', 'F AIRE KIA SORENTO 2.2 2016'),
('23645-4', 'F AIRE ELEM PETROLEO C-ELYSEE 1-6 H'),
('23665-9', 'F AIRE G.WALL WINGLE 2.2 201'),
('23699-3', 'F AIRE HYUNDAI D3300 TUCSON 2.0 20'),
('24024-9', 'F AIRE HYUNDAI'),
('24025-7', 'KIA RIO ANTIGUO'),
('24043-5', 'F AIRE CHERVROLET S10/BLAZER'),
('24045-1', 'F AIRE CHEVROLET'),
('24046-K', 'F AIRE GM CHEVROLET LUV'),
('24052-4', 'F AIRE NISSAN'),
('24056-7', 'F AIRE MITSUBISHI'),
('24086-9', 'F AIRE TOYOTA L-2546 C2513 (UK-7257)'),
('24106-7', 'F FUEL LUV D LK-714/1'),
('24123-7', 'F OIL KIA BESTA'),
('24126-1', 'F FUEL COMBUSTIBLE KIA BESTA'),
('24128-8', 'F OIL NISSAN D-21'),
('24131-8', 'F FUEL NISSAN LK932/80'),
('24138-5', 'F OIL FORD PARTNER 1.9'),
('24143-1', 'F FUEL CHEVROLT LUV 2.3'),
('24154-7', 'F OIL ACEITE L14459 W818/8 HK'),
('24155-5', 'F OIL ACEITE L10111 712/22'),
('24156-3', 'F OIL L24457 713/1'),
('24157-1', 'F OIL L10241 712/55'),
('24158-K', 'F OIL L14612 67/80'),
('24159-8', 'F OIL ACEITE L14476 W68/80'),
('24160-1', 'F OIL L1 14477 610/80'),
('24161-K', 'F OIL L1 4610 610/82'),
('24163-6', 'F OIL W-719/15 L1019'),
('24164-4', 'F OIL L20195 719/27'),
('24170-9', 'F OIL HK HU - 612 HYUNDAI'),
('24177-6', 'F AIRE HYUNDAI'),
('24186-5', 'F OIL HU819/1X D2'),
('24226-8', 'F AIRE MAZDA 3 1.6 04'),
('24227-6', 'F AIRE PEUGEOT L-3087'),
('24228-4', 'F AIRE OPEL COMBO'),
('24234-9', 'F AIRE CITROEN L-3485/1'),
('24235-7', 'F AIRE ECOSPORT 1.6 04'),
('24238-1', 'F AIRE PEUGEOT L-17278'),
('24242-K', 'F OIL HU-711/51X'),
('24244-6', 'F OIL L17696 W75/2'),
('24245-4', 'F OIL L18071 67/81'),
('24255-1', 'F AIRE PEUGEOT PARTNER'),
('24256-K', 'F AIRE HYUNDAI L -2631'),
('24325-6', 'F AIRE POLEN HYUNDAI'),
('24328-0', 'F AIRE MITSUBISHI'),
('24350-7', 'FILTRO GASOLINA NISSAN BENCINA'),
('24357-4', 'F AIRE HYUNDAI NEW ACCENT'),
('24377-9', 'F OIL H-100 D. WP 928/81 MITSUBISHI'),
('24397-3', 'F OIL LUV DIESEL'),
('24402-3', 'F OIL FUEL CHEVROLET SPARK GT 1.2'),
('24406-6', 'F AIRE HRYSLER CHEROKEE 2.5'),
('24588-7', 'F AIRE NISSA'),
('24589-5', 'F AIRE SUZUKI ALTO C-1517'),
('24599-2', 'F AIRE SUZUKI GRAND NOMADE'),
('24614-K', 'F AIRE CHEVROLET VIVANT VW'),
('24619-0', 'F AIRE CITROEN L-3282'),
('24622-0', 'F AIRE SSANGYONG REXXTON 2.7/ MAGINGRA'),
('24624-7', 'F OIL HK HU- 716/2X PEUGEOT 1.6 ANTIGUO'),
('24630-1', 'F OIL HK L 713/16 FIAT'),
('24640-9', 'F AIRE TOYOTA NEW YARIS'),
('24645-K', 'F OIL HK L 912/8 HYUNDAI'),
('24666-2', 'BOBINA DE ENCENDIDO TOYOTA YARIS TODOS'),
('24715-8', 'F AIRE DAEWOO MUSSO GSL'),
('25993-4', 'F AIRE TOYOTA HIACE 3.0 2011'),
('25994-2', 'F POLEN HYUNDAI N.TUCSON2.0'),
('26190-4', 'F AIRE UK-8562 CHERY TIGGO 3'),
('26192-0', 'F AIRE UK-8140 MG GS5 1.6'),
('28113-D3100', 'F AIRE HYUNDAI TUCSON 2.0'),
('3', 'freno'),
('91418-5', 'F OIL ACEITE L14476 W68/80'),
('aa', 'aaa'),
('aaa', 'aaa'),
('ABRK-W-21B-L1', 'A BRAKE WAGNER 21B L1'),
('AFM-10W-40-L3,8', 'A FORD MOTORCRAFT SAE 10W-40 L1'),
('AFP-10W-40-L3,8-SS', 'A FEDERAL PLATINUM 10W-40 BEND SYNTHETIC 3,8L'),
('AFP-10W-40-L3,8-SS-API SN PLUS', 'A FEDERAL PLATINUM 10W-40 BEND SYNTHETIC API SN PLUS 3,8L'),
('AFS-20W50-L3,8', 'A FEDERAL SUPER 20W-50 3,8L'),
('AL-10W40-L3,8-SS', 'A LUBRITEK 10W-40 SYNTHETIC BLEND'),
('AL-10W40-L4', 'A LUBRAX 10W40 4L'),
('AL-20W50-L4', 'A LUBRAX 20W-50 4L'),
('AMO-10W40-L4-SS', 'A MOBIL SUPER 2000 10W-40 SEMI-SYNTHETIC 4L'),
('AP-10W40-L4-SS', 'A PETRONA 10W40 4L SEMI SYNTHETIC'),
('AP-15W40-L4', 'A PETRONA 15W40 4L'),
('AP-20W50-L4-M', 'A PETRONA 20W-50 MINERAL 4L'),
('AP-5W30-L4-FS', 'A PETRONA 5W30 4L FULL SYNTHETIC'),
('APT-TRANS-75W80-L1', 'A MANUAL TRANSMISSION 75W-80 1L'),
('ARS-5W30-L3,8-FS', 'A ROYAL SYNTHETIC 5W-30 FULLY SYNTHETIC 3,8L'),
('ARSOL-10W40-L1-SS', 'A REPSOL 10W-40 FULLY SYNTHETIQUE 1L'),
('ARSOL-10W40-L4-FS', 'A REPSOL 10W-40 ELITE MULTIVALVULA FULLY SYNTHETIQUE 4L'),
('ARSOL-15W40-L4-TURBO-DIESEL', 'A REPSOL 10W-40 FULLY SYNTHETIQUE 1L'),
('ARSOL-15W40-L4-TURBOMIDSAPS-DI', 'A REPSOL 10W-40 FULLY SYNTHETIQUE 1L'),
('ARSOL-20W50-L4-FS', 'A REPSOL 5W-40 ELITE EVOLUTION FULLY SYNTHETIQUE 5L'),
('ARSOL-5W30-L4-FS', 'A REPSOL 3W-30 FULLY SYNTHETIQUE 4L'),
('ARSOL-5W40-L5-FS', 'A REPSOL 5W-40 ELITE EVOLUTION FULLY SYNTHETIQUE 5L'),
('ASC-10W40-L1-SS', 'A SHIELD CHOICE 10W-40 BLEND SYNTHETIQUE'),
('ASC-10W40-L3,8-SS', 'A SHIELD CHOICE 10W-40 BLEND SYNTHETIQUE'),
('ASH-10W40-L4-FS', 'A SHELL HELIX ULTRA 10W-40 FULLY SYNTHETIC 4L'),
('ASH-5W30-L5-FS', 'A SHELL HELIX ULTRA 5W-30 FULLY SYNTHETIC 5L'),
('ATQ-10W40-L4', 'A TOTAL QUARZ 7000 10W-40 SYNTHETIC TECHNOLOGY'),
('ATQ-10W40-L4-SS', 'A TOTAL QUARZ 7000 10W-40 SYNTHETIC TECHNOLOGY'),
('ATQ-5W30-L5', 'A TOTAL QUARZ INEO MC3 5W-30 SYNTHETIC TECHNOLOGY'),
('AXCEL-10W40-L3,8', 'A MOTOR XCEL SUPER TURBO 10W-40 3,8L'),
('C2256', 'F AIRE CORSA'),
('DF-012-GTX', 'D BRAKE NISSAN D 2.1 2.4'),
('DF-016-GTX', 'D BRAKE'),
('DF-057-GTX', 'D BRAKE'),
('DF-059-GTX', 'D BRAKE PARTNER 206 BERLINGO 307'),
('DF-073-GTX', 'D BRAKE FRONTIER 2.7'),
('DF-158-GTX', 'D BRAKE'),
('DF-183-GTX', 'D BRAKE CHEVROLET CRUZE'),
('DF-208-GTX', 'D BRAKE PEUGEOT 206 TAMBOR'),
('DF-283-GTX', 'D BRAKE FIAT CITY'),
('DF-297-GTX', 'D BRAKE RENO'),
('DF-318-GTX', 'D BRAKE CHEVROLET ASTRA'),
('DF-322-GTX', 'D BRAKE H-100'),
('DF-330-GTX', 'D BRAKE SSANGYONG ACTION KYRON REXTON'),
('DF-331-GTX', 'D BRAKE SAMSUNG'),
('DF-359-GTX', 'D BRAKE NEW ASEN DIESEL KIA RIO 2'),
('DF-413-GTX', 'D BRAKE PEUGEOT'),
('DF-415-GTX', 'D BRAKE'),
('DF-425-GTXX', 'D BRAKE BETO'),
('DF-426-GTX', 'D BRAKE DITO TA'),
('DF-445-GTX', 'D BRAKE L-200'),
('DF-499-GTX', 'D BRAKE ESPORT'),
('DF-564-GTX', 'D BRAKE TOYOTA HILOX VYGO 3.0'),
('DF-575-GTX', 'D BRAKE'),
('DF-581-GTX', 'D BRAKE NISSAN TIDA'),
('DF-587-GTX', 'D BRAKE DOBLO 1.6'),
('DF-600-GTX', 'D BRAKE'),
('DF-609-GTX', 'D BRAKE VW'),
('DF-640-GTX', 'D BRAKE NEW HYUNDAI'),
('DF-687-GTX', 'D BRAKE APV'),
('DF-731-GTX', 'D BRAKE SPARK'),
('DF-749-GTX', 'D BRAKE NISSAN NAVARA'),
('DF-767-GTX', 'D BRAKE'),
('DF-770-GTX', 'D BRAKE FIAT DOBLO'),
('DF-779-GTX', 'D BRAKE KIA FRONTIER'),
('DF-785-GTX', 'D BRAKE NEW YARIS'),
('DF-792-GTX', 'D BRAKE KIA FRONTIER'),
('DF-813-GTX', 'D BRAKE RV HYUNDAI'),
('DF-859-GTX', 'D BRAKE RENAULT BOREK'),
('DF-DF-16-GTX', 'D BRAKE GT SAIL AVEO'),
('DF-DF-17-GTX', 'D BRAKE MONZA OPEL CORSA DAEWOO'),
('DF-DF-509-GTX', 'D BRAKE'),
('DF-TF-052-GTX', 'D BRAKE'),
('FH-018B-A', 'BRAKE SHOES BALATA APACHE 510'),
('FH-1007-A', 'BRAKE SHOES BALATA'),
('FH-1016-A', 'BRAKE SHOES BALATA KIA SPOTAJE 2006'),
('FH-1039-A', 'BRAKE SHOES BALATA'),
('FH-1050-GTX', 'BRAKE SHOES BALATA'),
('FH-1087-A', 'BRAKE SHOES BALATA FIAT ADVENTURA'),
('FH-1167-A', 'BRAKE SHOES BALATA SAMSUNG'),
('FH-1174-A', 'BRAKE SHOES BALATA NV350'),
('FH-1189-Z', 'BRAKE SHOES BALATA'),
('FH-3124-GTX', 'BRAKE SHOES BALATA SANG YONG'),
('FH-3350-GTX', 'BRAKE SHOES BALATA KIA'),
('FH-4400-A', 'BRAKE SHOES BALATA AVEO'),
('FH-4400-GTX', 'BRAKE SHOES BALATA CHEVROLET SAIL'),
('FH-44020-GTX', 'BRAKE SHOES BALATA'),
('FH-4458X-GTX', 'BRAKE SHOES BALATA'),
('FH-488-A', 'BRAKE SHOES BALATA SPOTAGE 2006-2007'),
('FH-705-A', 'BRAKE SHOES BALATA'),
('FH-806-A', 'BRAKE SHOES BALATA'),
('FH-8122-GTX', 'BRAKE SHOES BALATA HYUNDAI PORTER KIA FRONTIER'),
('FH-8163-GTX', 'BRAKE SHOES BALATA'),
('FH-8166B-GTX', 'BRAKE SHOES BALATA TOYOTA HILUX'),
('FH-8199-A', 'BRAKE SHOES BALATA H1 DIMAX 4X4'),
('FH-8206-GTX', 'BRAKE SHOES BALATA'),
('FH-8222-A', 'BRAKE SHOES BALATA'),
('FH-8237-GTX', 'BRAKE SHOES BALATA DIMAX H GREAT WALL'),
('FH-8244-GTX', 'BRAKE SHOES BALATA L 200'),
('FH-8258-A', 'BRAKE SHOES BALATA ACCENT HYUNDAI'),
('FH-8258-GTX', 'BRAKE SHOES BALATA'),
('FH-8265-GTX', 'BRAKE SHOES BALATA NEW ACCENT'),
('FH-8276-GTX', 'BRAKE SHOES BALATA TUCSON 2009'),
('FH-8288-A', 'BRAKE SHOES BALATA NAVARA'),
('FH-8289-A', 'BRAKE SHOES BALATA FIAT DOBLO'),
('FH-8320-A', 'BRAKE SHOES BALATA'),
('FH-8396-A', 'BRAKE SHOES BALATA N300'),
('FH-8396-GTX', 'BRAKE SHOES BALATA'),
('FH-872B-A', 'BRAKE SHOES BALATA'),
('FH-872B-GTX', 'BRAKE SHOES BALATA H1'),
('FH-888-A', 'BRAKE SHOES BALATA'),
('FH-924-A', 'BRAKE SHOES BALATA'),
('FH-924-GTX', 'BRAKE SHOES BALATA NISSAN TIIDA'),
('FH-984-A', 'BRAKE SHOES BALATA'),
('FH-B582-A', 'BRAKE SHOES BALATA TOYOTA YARIS SSANG YONG'),
('LP5145', 'P BRAKE'),
('OEM35014', 'F FUEL NISSAN NP 300 2.3 2016 (C CARTON)'),
('PP1018', 'P BRAKE'),
('PP1210', 'P BRAKE'),
('PP1733', 'P BRAKE'),
('REFFC-L3,8', 'FEDERAL ANTIFREEZE COOLANT'),
('RODRIGO', 'F AIRE HYUNDAI SANTA FE'),
('RX1104', 'P BRAKE'),
('RX1432', 'P BRAKE'),
('S0196', 'D BRAKE'),
('TF-055-GTX', 'D BRAKE PEUGEOT BIPPER'),
('TF-097-GTX', 'D BRAKE'),
('TF-133-GTX', 'D BRAKE NEW YARIS'),
('TF-135-GTX', 'D BRAKE TAMBOR SAIL'),
('TF-TF-28-GTX', 'D BRAKE CORSA'),
('TFA-2256', 'F AIRE CORSA'),
('UC-5710', 'F AUXILIAR KIA'),
('Z6E6133A0', 'F AIRE MASDA 3 1.6 2006');

-- --------------------------------------------------------

--
-- Table structure for table `prov`
--

CREATE TABLE `prov` (
  `id_prov` int(20) NOT NULL,
  `name_prov` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish2_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `prov`
--

INSERT INTO `prov` (`id_prov`, `name_prov`) VALUES
(1, 'ITAL_FRENOS');

-- --------------------------------------------------------

--
-- Table structure for table `rol`
--

CREATE TABLE `rol` (
  `id_rol` tinyint(1) NOT NULL,
  `rol` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `rol`
--

INSERT INTO `rol` (`id_rol`, `rol`) VALUES
(1, 'root'),
(2, 'user'),
(3, 'mecan');

-- --------------------------------------------------------

--
-- Table structure for table `sale`
--

CREATE TABLE `sale` (
  `rut_sale` varchar(10) NOT NULL,
  `name_sale` varchar(20) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL,
  `contacto` varchar(40) CHARACTER SET utf8 COLLATE utf8_spanish2_ci NOT NULL,
  `id_prov` int(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `sale`
--

INSERT INTO `sale` (`rut_sale`, `name_sale`, `contacto`, `id_prov`) VALUES
('1', 'JUANITO PEREZ', 'JUANITOPEREZ@GMAIL.COM', 1);

-- --------------------------------------------------------

--
-- Table structure for table `stock`
--

CREATE TABLE `stock` (
  `stock_prod_id` varchar(30) COLLATE utf8_spanish2_ci NOT NULL,
  `stock_q` smallint(6) NOT NULL,
  `stock_xyz_xyz` varchar(3) COLLATE utf8_spanish2_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Dumping data for table `stock`
--

INSERT INTO `stock` (`stock_prod_id`, `stock_q`, `stock_xyz_xyz`) VALUES
('21468-K', 5, 'BB5'),
('0001', 11, 'CA3'),
('0035', 3, 'CA5'),
('0058', 1, 'CA1'),
('0063', 2, 'CA4'),
('0077', 1, 'CA6'),
('0080', 3, 'CA2'),
('0114', 3, 'CA1'),
('0116', 1, 'CA8'),
('0124', 1, 'CA9'),
('0166', 3, 'CA7'),
('0172', 3, 'CA1'),
('0183', 3, 'CA1'),
('0186', 1, 'CA1'),
('0195', 4, 'CA1'),
('0247', 4, 'CA1'),
('0250', 1, 'CA3'),
('0256', 1, 'CA1'),
('0270', 1, 'CB1'),
('0271', 1, 'CB1'),
('0275', 3, 'CB1'),
('0284', 2, 'CB1'),
('0292', 2, 'CB1'),
('0313', 1, 'CB1'),
('0341', 1, 'CB1'),
('0357', 1, 'CB1'),
('0359', 2, 'CB1'),
('0408', 1, 'CB1'),
('0418', 2, 'CB1'),
('0426', 20, 'CB1'),
('0426', 5, 'CC1'),
('0430', 1, 'CB1'),
('0435', 8, 'CC1'),
('0439', 4, 'CC1'),
('0453', 2, 'CC1'),
('0456', 1, 'CC1'),
('0471', 8, 'CC1'),
('0476', 9, 'CC1'),
('0476', 1, 'CC4'),
('0476', -5, 'CD1'),
('0481', 2, 'CD1'),
('0489', 2, 'CD1'),
('0490', 7, 'CD1'),
('0491', 6, 'CD1'),
('0504', 4, 'CD1'),
('0531', 3, 'CD1'),
('0537', 2, 'CA2'),
('0539', 4, 'CA2'),
('0540', 2, 'CA2'),
('0541', 1, 'CA2'),
('0542', 5, 'CA2'),
('0543', 3, 'CA2'),
('0583', 3, 'CA2'),
('0592', 5, 'CA2'),
('0598', 1, 'CA2'),
('0609', 5, 'CA2'),
('0624', 3, 'CA2'),
('0625', 1, 'CA2'),
('0626', 1, 'CA2'),
('0631', 1, 'CA2'),
('0633', 7, 'CA2'),
('0647', 1, 'CB2'),
('0648', 6, 'CB2'),
('0650', 4, 'CB2'),
('0652', 2, 'CB2'),
('0655', 1, 'CB2'),
('0658', 1, 'CB2'),
('0669', 1, 'CB2'),
('0670', 2, 'CB2'),
('0673', 4, 'CB2'),
('0674', 2, 'CB2'),
('0677', 1, 'CB2'),
('0684', 1, 'CB2'),
('0686', 1, 'CB2'),
('0687', 1, 'CB2'),
('0690', 1, 'CC2'),
('0697', 2, 'CC2'),
('0698', 6, 'CC2'),
('0703', 1, 'CC2'),
('0717', 6, 'CC2'),
('0718', 3, 'CC2'),
('0724', 2, 'CC2'),
('0729', 9, 'CC2'),
('0734', 1, 'CC2'),
('0735', 1, 'CC2'),
('0736', 1, 'CC2'),
('0745', 1, 'CD2'),
('0746', 4, 'CD2'),
('0747', 1, 'CD2'),
('0753', 2, 'CD2'),
('0757', 1, 'CD2'),
('0758', 5, 'CD2'),
('0759', 1, 'CD2'),
('0760', 1, 'CD2'),
('0765', 6, 'CD2'),
('0767', 6, 'CD2'),
('0768', 2, 'CD2'),
('0769', 2, 'CD2'),
('0775', 1, 'CA3'),
('0775', 1, 'CC3'),
('0775', 1, 'CD2'),
('0776', 2, 'CA3'),
('0779', 4, 'CA3'),
('0780', 1, 'CA3'),
('0781', 1, 'CA3'),
('0782', 5, 'CA3'),
('0786', 2, 'CA3'),
('0798', 1, 'CA3'),
('0799', 3, 'CB3'),
('0799', 1, 'CD2'),
('0800', 2, 'CB3'),
('0801', 2, 'CB3'),
('0802', 3, 'CB3'),
('0803', 3, 'CB3'),
('0804', 1, 'CB3'),
('0805', 3, 'CB3'),
('0813', 6, 'CB3'),
('0816', 3, 'CB3'),
('0817', 1, 'CB3'),
('0818', 2, 'CB3'),
('0819', 3, 'CB3'),
('0821', 3, 'CC3'),
('0823', 1, 'CC3'),
('0826', 4, 'CC3'),
('0827', 3, 'CC3'),
('0828', 5, 'CC3'),
('0842', 1, 'CC3'),
('0858', 2, 'CC3'),
('0866', 2, 'CC3'),
('0876', 2, 'CC3'),
('0878', 4, 'CC3'),
('0886', 1, 'CC3'),
('0899', 2, 'CC3'),
('0903', 9, 'CD3'),
('0903', 2, 'CD4'),
('0904', 4, 'CD3'),
('0912', 1, 'CD3'),
('0914', 3, 'CD3'),
('0915', 4, 'CD3'),
('0916', 3, 'CD3'),
('0917', 2, 'CD3'),
('0918', 2, 'CA4'),
('0920', 1, 'CA4'),
('0928', 1, 'CA4'),
('0929', 1, 'CA4'),
('0932', 3, 'CA4'),
('0934', 2, 'CA4'),
('0937', 3, 'CA4'),
('0938', 3, 'CA4'),
('0939', 9, 'CA4'),
('0941', 3, 'CA4'),
('0950', 5, 'CB4'),
('0952', 3, 'CB4'),
('0955', 2, 'CB4'),
('0958', 5, 'CB4'),
('0959', 2, 'CB4'),
('0969', 3, 'CB4'),
('0998', 4, 'CB4'),
('1029', 2, 'CB4'),
('1029', 1, 'CC4'),
('1032', 2, 'CB4'),
('1034', 3, 'CC4'),
('1035', 3, 'CC4'),
('1037', 5, 'CC4'),
('1039', 3, 'CC4'),
('1042', 1, 'CD4'),
('1043', 4, 'CD4'),
('1044', 3, 'CD4'),
('1049', 4, 'CD4'),
('1052', 2, 'CD4'),
('1053', 6, 'CA5'),
('1060', 2, 'CA5'),
('1063', 3, 'CA5'),
('1070', 5, 'CA5'),
('1071', 4, 'CA5'),
('1072', 1, 'CA5'),
('1073', 1, 'CA5'),
('1078', 3, 'CA5'),
('1090', 4, 'CB5'),
('1097', 1, 'CB5'),
('1104', 1, 'CB5'),
('1108', 2, 'CB5'),
('1109', 1, 'CB5'),
('1114', 2, 'CB5'),
('1115', 3, 'CB5'),
('1116', 2, 'CB5'),
('1118', 8, 'CB5'),
('1119', 4, 'CC5'),
('1120', 1, 'CC5'),
('1149', 1, 'CC5'),
('1150', 1, 'CC5'),
('1152', 2, 'CC5'),
('1155', 9, 'CC5'),
('1156', 7, 'CC5'),
('1158', 4, 'CC5'),
('1159', 2, 'CC5'),
('1162', 3, 'CC5'),
('1163', 2, 'CD5'),
('1166', 1, 'CD5'),
('1167', 1, 'CD5'),
('1169', 3, 'CD5'),
('1171', 5, 'CD5'),
('1173', 5, 'CA6'),
('1175', 2, 'CA6'),
('1176', 5, 'CA6'),
('1177', 1, 'CA6'),
('1180', 2, 'CA6'),
('1182', 3, 'CA6'),
('1182', 1, 'CD5'),
('1183', 2, 'CD5'),
('1186', 8, 'CA6'),
('1186', 6, 'CD5'),
('1201', 5, 'CB6'),
('1207', 1, 'CB6'),
('1208', 1, 'CB6'),
('1212', 1, 'CB6'),
('1214', 2, 'CB6'),
('1218', 3, 'CB6'),
('1220', 2, 'CB6'),
('1221', 2, 'CB6'),
('1223', 5, 'CC6'),
('1225', 2, 'CC6'),
('1228', 6, 'CC6'),
('1235', 1, 'CC6'),
('1240', 1, 'CC6'),
('1241', 2, 'CC6'),
('1242', 5, 'CC6'),
('1245', 2, 'CC6'),
('1246', 2, 'CC6'),
('1248', 2, 'CC6'),
('1249', 3, 'CC6'),
('1250', 2, 'CD6'),
('1252', 1, 'CD5'),
('1252', 2, 'CD6'),
('1253', 2, 'CD6'),
('1258', 2, 'CD6'),
('1261', 3, 'CD6'),
('1262', 1, 'CD6'),
('1275', 3, 'CD6'),
('1284', 7, 'EA3'),
('1286', 2, 'EA3'),
('1295', 6, 'EA3'),
('1305', 7, 'EB3'),
('1305', 1, 'EC3'),
('1310', 1, 'EB3'),
('1311', 3, 'EB3'),
('1314', 2, 'EB3'),
('1327', 1, 'EB3'),
('1329', 3, 'EB3'),
('1333', 10, 'EB3'),
('1334', 3, 'EB3'),
('1335', 4, 'EB3'),
('1340', 1, 'EB3'),
('1340', 8, 'EC3'),
('1345', 1, 'EC3'),
('1353', 2, 'EC3'),
('1354', 9, 'EC3'),
('1356', 2, 'EC3'),
('1361', 3, 'EC3'),
('1363', 2, 'EC3'),
('1364', 1, 'EC3'),
('1370', 2, 'EC3'),
('1377', 1, 'EC3'),
('1379', 1, 'EC3'),
('1384', 1, 'EC3'),
('1390', 1, 'EC3'),
('1391', 1, 'EC3'),
('1405', 1, 'EC4'),
('1406', 3, 'EC4'),
('1418', 5, 'EC4'),
('1419', 5, 'EC4'),
('1420', 2, 'CC6'),
('1430', 2, 'EC4'),
('1432', 5, 'EC4'),
('17126-3', 2, 'AD4'),
('20521-4', 6, 'BF2'),
('20523-0', 4, 'BE2'),
('20534-6', 5, 'AA4'),
('20538-9', 1, 'AB2'),
('20538-9', 8, 'EA5'),
('20541-9', 1, 'AD3'),
('20568-0', 2, 'BA4'),
('20569-9', 4, 'BA3'),
('20593-1', 7, 'BA4'),
('20593-1', 6, 'BE4'),
('20598-2', 12, 'EC5'),
('20599-0', 14, 'AA3'),
('20602-4', 1, 'BF2'),
('20603-2', 3, 'BB3'),
('20605-9', 1, 'BA2'),
('20605-9', 8, 'BD2'),
('20607-5', 1, 'AB1'),
('20607-5', 7, 'AF6'),
('20607-5', 7, 'BD4'),
('20609-1', 8, 'AA2'),
('20618-0', 2, 'AB3'),
('20618-0', 15, 'AD5'),
('20618-0', 7, 'AE4'),
('20621-0', 4, 'AA2'),
('20623-7', 9, 'AB4'),
('20623-7', 4, 'AD5'),
('20654-7', 7, 'BC3'),
('20672-5', 12, 'BC4'),
('20672-5', 4, 'BD4'),
('20699-7', 11, 'BA1'),
('20718-4', 1, 'BD2'),
('20724-4', 2, 'AF4'),
('20728-4', 2, 'AF2'),
('20728-4', 5, 'AF5'),
('20728-4', 4, 'GA5'),
('20730-6', 5, 'AA4'),
('20775-6', 11, 'AD4'),
('20778-0', 5, 'AB2'),
('20796-9', 19, 'AD3'),
('20824-8', 6, 'AA3'),
('20826-4', 50, 'AA4'),
('20826-4', 21, 'FD4'),
('20827-2', 3, 'AA3'),
('20827-2', 3, 'AA4'),
('20830-2', 3, 'AA3'),
('20833-7', 3, 'BA1'),
('20837-K', 5, 'BA4'),
('20837-K', 6, 'BA5'),
('20837-K', 1, 'BB4'),
('20849-3', 6, 'BA2'),
('20851-5', 3, 'AF2'),
('20852-3', 2, 'FF4'),
('20856-6', 4, 'BA2'),
('20856-6', 6, 'BB2'),
('20856-6', 4, 'BB3'),
('20858-2', 19, 'AB2'),
('20860-4', 2, 'AD2'),
('20860-4', 4, 'AF4'),
('20860-4', 6, 'FE2'),
('20865-5', 2, 'FF5'),
('20889-2', 2, 'FE3'),
('20891-4', 8, 'BA3'),
('20895-7', 1, 'FE3'),
('20895-7', 3, 'FF5'),
('20895-7', 1, 'FF6'),
('20900-7', 8, 'BA3'),
('20901-5', 6, 'BA3'),
('20903-1', 3, 'AE2'),
('20903-1', 14, 'BE5'),
('20903-1', 1, 'BF5'),
('20910-4', 2, 'FF4'),
('20911-2', 4, 'BA2'),
('20911-2', 6, 'BB3'),
('20912-0', 5, 'BA2'),
('20912-0', 7, 'BB2'),
('20912-0', 2, 'BB3'),
('20913-9', 2, 'BF1'),
('20915-5', 7, 'FF6'),
('20918-K', 1, 'FF4'),
('20918-K', 3, 'FF6'),
('20920-1', 2, 'BE2'),
('20924-4', 2, 'BC4'),
('20932-5', 1, 'EC6'),
('20934-1', 6, 'BC1'),
('20934-1', 5, 'FE2'),
('20934-1', 6, 'FF5'),
('20957-0', 7, 'BA3'),
('20958-9', 1, 'BD4'),
('20958-9', 3, 'BF1'),
('20960-0', 10, 'AB2'),
('20972-4', 5, 'BB5'),
('20972-4', 1, 'BC3'),
('20973-2', 3, 'BA4'),
('20974-0', 22, 'AB2'),
('20978-3', 14, 'AA2'),
('20978-3', 1, 'AD3'),
('20985-6', 4, 'FE4'),
('20985-6', 5, 'FF7'),
('21010-2', 1, 'BB3'),
('21015-3', 1, 'AF2'),
('21015-3', 8, 'BC4'),
('21021-8', 2, 'FE3'),
('21027-7', 1, 'AB1'),
('21027-7', 4, 'AF6'),
('21041-2', 4, 'FF4'),
('21043-9', 3, 'AD2'),
('21044-7', 6, 'BB4'),
('21044-7', 6, 'BE4'),
('21052-0', 2, 'AB2'),
('21053-6', 10, 'AA2'),
('21055-2', 8, 'AA2'),
('21056-0', 6, 'AB2'),
('21057-9', 2, 'AD4'),
('21073-0', 3, 'AF3'),
('21075-3', 3, 'BC2'),
('21091-9', 4, 'AE4'),
('21092-7', 4, 'BE1'),
('21095-1', 12, 'AB3'),
('21099-4', 5, 'AA3'),
('21120-6', 22, 'AA2'),
('21126-5', 9, 'AB3'),
('21132-K', 5, 'BF5'),
('21133-8', 6, 'BB1'),
('21133-8', 1, 'BF4'),
('21133-8', 6, 'BF5'),
('21135-4', 4, 'BA2'),
('21135-4', 4, 'BB3'),
('21137-0', 2, 'BB1'),
('21139-7', 1, 'BB1'),
('21146-K', 4, 'AF4'),
('21159-1', 3, 'AD4'),
('21207-5', 2, 'BE3'),
('21212-1', 8, 'BF2'),
('21213-K', 3, 'AD2'),
('21219-9', 13, 'FF4'),
('21222-9', 6, 'FF5'),
('21224-5', 3, 'BB4'),
('21224-5', 2, 'FE3'),
('21239-3', 6, 'AA4'),
('21246-6', 10, 'AA3'),
('21267-9', 3, 'AA1'),
('21267-9', 4, 'AA2'),
('21274-1', 2, 'EC5'),
('21283-0', 3, 'FF4'),
('21305-5', 5, 'AB3'),
('21308-K', 7, 'BA5'),
('21336-5', 2, 'BD4'),
('21338-1', 2, 'EC6'),
('21340-3', 5, 'BA4'),
('21341-1', 2, 'FF5'),
('21341-1', 3, 'FF6'),
('21342-K', 1, 'FF5'),
('21342-K', 3, 'FF6'),
('21384-5', 5, 'BC4'),
('21386-1', 2, 'BB2'),
('21386-1', 3, 'BF2'),
('21386-1', 1, 'BB3'),
('21391-8', 2, 'AF1'),
('21391-8', 2, 'AF5'),
('21391-8', 4, 'AF6'),
('21395-0', 18, 'AD4'),
('21404-3', 12, 'AE4'),
('21406-K', 7, 'AB2'),
('21408-6', 3, 'AF6'),
('21410-8', 6, 'BA2'),
('21410-8', 8, 'BA4'),
('21412-4', 4, 'BC4'),
('21412-4', 6, 'BE2'),
('21414-0', 7, 'AA2'),
('21415-9', 11, 'AA4'),
('21416-7', 6, 'AB3'),
('21419-1', 1, 'BA5'),
('21420-5', 17, 'AB2'),
('21429-9', 3, 'BC2'),
('21430-2', 3, 'BA3'),
('21434-5', 1, 'FF4'),
('21439-6', 4, 'BE2'),
('21439-6', 5, 'BF2'),
('21441-8', 1, 'BB2'),
('21442-6', 4, 'BB2'),
('21443-4', 7, 'FF6'),
('21444-2', 3, 'BE5'),
('21445-0', 4, 'EA5'),
('21447-7', 13, 'EB5'),
('21448-5', 11, 'EC6'),
('21452-3', 27, 'AE2'),
('21454-K', 2, 'BC2'),
('21466-3', 1, 'BC3'),
('21468-K', 2, 'BB4'),
('21469-8', 7, 'AE4'),
('21472-8', 9, 'AB3'),
('21483-3', 10, 'AB3'),
('21485-K', 1, 'AF4'),
('21487-6', 7, 'BE1'),
('21514-7', 3, 'FE4'),
('21515-5', 62, 'AD3'),
('21519-8', 11, 'AD3'),
('21519-8', 10, 'AD4'),
('21527-9', 3, 'BB1'),
('21530-9', 5, 'AB2'),
('21532-5', 4, 'BC3'),
('21548-1', 3, 'BD1'),
('21552-K', 5, 'FE4'),
('21552-K', 1, 'FF4'),
('21553-8', 2, 'FE4'),
('21560-0', 5, 'BC1'),
('21560-0', 5, 'BD1'),
('21564-3', 21, 'AD4'),
('21564-3', 2, 'AE4'),
('21576-7', 1, 'AC6'),
('21577-5', 2, 'AC6'),
('21612-7', 6, 'BC1'),
('21612-7', 6, 'FE2'),
('21617-8', 6, 'AD2'),
('21617-8', 1, 'BA1'),
('21617-8', 9, 'BC1'),
('21620-8', 5, 'AA2'),
('21621-6', 13, 'AA2'),
('21622-4', 6, 'AA3'),
('21623-2', 5, 'AA3'),
('21631-3', 1, 'FF4'),
('21631-3', 5, 'FF5'),
('21632-1', 2, 'BB1'),
('21632-1', 2, 'FF7'),
('21637-2', 3, 'FE3'),
('21638-0', 2, 'EC5'),
('21640-2', 10, 'AB4'),
('21643-7', 2, 'BA3'),
('21643-7', 8, 'BA5'),
('21645-3', 6, 'BB2'),
('21646-1', 8, 'BA2'),
('21648-8', 3, 'AD2'),
('21662-3', 1, 'BC4'),
('21663-1', 3, 'AF5'),
('21666-6', 1, 'AB1'),
('21667-4', 3, 'AB1'),
('21667-4', 4, 'BD2'),
('21668-2', 13, 'BE2'),
('21669-0', 6, 'BC4'),
('21670-4', 1, 'BB1'),
('21671-2', 11, 'BB3'),
('21673-9', 6, 'AB2'),
('21675-5', 2, 'AE4'),
('21686-0', 5, 'AB2'),
('21686-0', 5, 'AB4'),
('21690-9', 2, 'AC6'),
('21691-K', 3, 'AD5'),
('21704-2', 6, 'AD2'),
('21709-3', 13, 'AD6'),
('21710-7', 6, 'AD6'),
('21716-6', 2, 'AD6'),
('21725-5', 5, 'AC6'),
('21732-8', 3, 'BE5'),
('21733-6', 7, 'FE3'),
('21735-2', 8, 'BE1'),
('21739-5', 8, 'AE2'),
('21762-K', 3, 'BF3'),
('21768-9', 1, 'FE3'),
('21769-7', 11, 'BF3'),
('21770-0', 3, 'FE3'),
('21771-9', 5, 'AA4'),
('21790-5', 1, 'AA2'),
('21791-3', 1, 'EA5'),
('21791-3', 2, 'EA6'),
('21831-6', 9, 'AA2'),
('21831-6', 4, 'AC6'),
('21831-6', 2, 'AD6'),
('21832-4', 4, 'AA4'),
('23260-2', 3, 'AD3'),
('23261-0', 7, 'BC3'),
('23262-9', 3, 'AD4'),
('23262-9', 1, 'AE4'),
('23264-5', 4, 'FE3'),
('23265-3', 5, 'BF1'),
('23266-1', 5, 'BF1'),
('23268-8', 4, 'BB4'),
('23268-8', 7, 'BB5'),
('23271-8', 2, 'BA5'),
('23279-3', 6, 'BC2'),
('23279-3', 5, 'BD2'),
('23280-7', 5, 'AE2'),
('23280-7', 2, 'BB1'),
('23280-7', 2, 'BF5'),
('23282-3', 5, 'GA5'),
('23283-1', 5, 'BF1'),
('23285-8', 6, 'FF5'),
('23286-6', 6, 'FF4'),
('23292-0', 3, 'BF2'),
('23293-9', 2, 'BB3'),
('23335-8', 5, 'BC2'),
('23363-7', 5, 'AB4'),
('23371-4', 12, 'EA6'),
('23395-1', 3, 'BB2'),
('23593-8', 6, 'AD3'),
('23595-4', 6, 'AD3'),
('23601-2', 8, 'EA5'),
('23642-K', 3, 'BF2'),
('23645-4', 3, 'BE2'),
('23645-4', 1, 'BF3'),
('23665-9', 3, 'AC6'),
('23699-3', 1, 'AC6'),
('23699-3', 5, 'BB2'),
('23699-3', 1, 'BE2'),
('24024-9', 1, 'AF4'),
('24024-9', 2, 'BD2'),
('24025-7', 2, 'BF2'),
('24043-5', 1, 'BF3'),
('24045-1', 2, 'BA3'),
('24046-K', 4, 'BA5'),
('24052-4', 4, 'BD3'),
('24056-7', 6, 'BA1'),
('24086-9', 10, 'BC2'),
('24106-7', 5, 'AA2'),
('24123-7', 5, 'AB2'),
('24126-1', 12, 'EA5'),
('24128-8', 9, 'AD3'),
('24131-8', 5, 'AB2'),
('24138-5', 2, 'AE4'),
('24143-1', 3, 'AD3'),
('24154-7', 22, 'AB2'),
('24154-7', 38, 'FD4'),
('24155-5', 14, 'AA4'),
('24155-5', 19, 'FD4'),
('24156-3', 17, 'AB3'),
('24157-1', 14, 'AA3'),
('24158-K', 2, 'AA4'),
('24159-8', 15, 'AB3'),
('24159-8', 16, 'FD4'),
('24160-1', 17, 'AA3'),
('24161-K', 36, 'AA3'),
('24163-6', 15, 'AA3'),
('24164-4', 13, 'AA3'),
('24170-9', 7, 'AB3'),
('24177-6', 9, 'AF6'),
('24177-6', 6, 'BD2'),
('24186-5', 8, 'AB3'),
('24226-8', 6, 'AD2'),
('24227-6', 2, 'BB1'),
('24228-4', 5, 'BF4'),
('24234-9', 4, 'BE3'),
('24235-7', 7, 'BF3'),
('24238-1', 6, 'AB1'),
('24238-1', 1, 'AF2'),
('24238-1', 5, 'BF5'),
('24242-K', 9, 'AB3'),
('24244-6', 7, 'AA4'),
('24245-4', 37, 'AA3'),
('24255-1', 2, 'AD2'),
('24255-1', 4, 'BB1'),
('24256-K', 6, 'BB2'),
('24325-6', 2, 'BB3'),
('24325-6', 1, 'FF4'),
('24328-0', 5, 'AF5'),
('24350-7', 1, 'AD3'),
('24357-4', 5, 'BC3'),
('24377-9', 26, 'AA2'),
('24397-3', 2, 'AA1'),
('24402-3', 3, 'AB2'),
('24402-3', 1, 'AE4'),
('24406-6', 4, 'BD1'),
('24588-7', 1, 'AF6'),
('24588-7', 2, 'BD2'),
('24589-5', 3, 'BC2'),
('24599-2', 4, 'BC4'),
('24614-K', 4, 'BD3'),
('24614-K', 7, 'BF3'),
('24619-0', 2, 'AD2'),
('24619-0', 2, 'BE3'),
('24622-0', 10, 'BB4'),
('24622-0', 3, 'BF1'),
('24624-7', 54, 'AB3'),
('24630-1', 13, 'AB3'),
('24640-9', 3, 'BC1'),
('24645-K', 10, 'AB3'),
('24666-2', 1, 'EA5'),
('24715-8', 3, 'BE5'),
('25993-4', 3, 'AE5'),
('25994-2', 4, 'FE3'),
('26190-4', 2, 'AC6'),
('26190-4', 4, 'BA5'),
('26192-0', 1, 'AC6'),
('28113-D3100', 3, 'BB3'),
('91418-5', 1, 'FD4'),
('ABRK-W-21B-L1', 13, 'FC4'),
('AFM-10W-40-L3,8', 5, 'FC5'),
('AFP-10W-40-L3,8-SS', 6, 'FB2'),
('AFP-10W-40-L3,8-SS-API SN PLUS', 10, 'FC5'),
('AFS-20W50-L3,8', 4, 'FB3'),
('AL-10W40-L3,8-SS', 0, 'FC6'),
('AL-10W40-L4', 7, 'FA2'),
('AL-20W50-L4', 6, 'FB3'),
('AL-20W50-L4', 6, 'FC3'),
('AMO-10W40-L4-SS', 13, 'FA2'),
('AMO-10W40-L4-SS', 12, 'FB4'),
('AMO-10W40-L4-SS', 4, 'FD4'),
('AP-10W40-L4-SS', 2, 'FA5'),
('AP-15W40-L4', 21, 'FA1'),
('AP-15W40-L4', 26, 'FA4'),
('AP-15W40-L4', 10, 'FB3'),
('AP-15W40-L4', 8, 'FB6'),
('AP-20W50-L4-M', 1, 'FB6'),
('AP-5W30-L4-FS', 19, 'FA5'),
('AP-5W30-L4-FS', 24, 'FA6'),
('APT-TRANS-75W80-L1', 8, 'FC4'),
('ARS-5W30-L3,8-FS', 12, 'FB2'),
('ARSOL-10W40-L1-SS', 20, 'FC5'),
('ARSOL-10W40-L4-FS', 1, 'FC2'),
('ARSOL-10W40-L4-FS', 14, 'FD2'),
('ARSOL-10W40-L4-FS', 1, 'FD3'),
('ARSOL-15W40-L4-TURBO-DIESEL', 6, 'FC3'),
('ARSOL-15W40-L4-TURBOMIDSAPS-DI', 4, 'FC3'),
('ARSOL-20W50-L4-FS', 4, 'FD3'),
('ARSOL-5W30-L4-FS', 21, 'FC2'),
('ARSOL-5W30-L4-FS', 7, 'FD2'),
('ARSOL-5W40-L5-FS', 4, 'FD3'),
('ASC-10W40-L1-SS', 20, 'FB5'),
('ASC-10W40-L1-SS', 3, 'FB6'),
('ASC-10W40-L3,8-SS', 10, 'FB6'),
('ASH-10W40-L4-FS', 7, 'FC3'),
('ASH-10W40-L4-FS', 3, 'FC6'),
('ASH-5W30-L5-FS', 6, 'FB2'),
('ASH-5W30-L5-FS', 1, 'FB3'),
('ASH-5W30-L5-FS', 2, 'FB4'),
('ATQ-10W40-L4', 18, 'FA3'),
('ATQ-10W40-L4-SS', 17, 'FB5'),
('ATQ-5W30-L5', 4, 'FA2'),
('ATQ-5W30-L5', 6, 'FA3'),
('ATQ-5W30-L5', 4, 'FC4'),
('ATQ-5W30-L5', 1, 'FD4'),
('AXCEL-10W40-L3,8', 11, 'FC4'),
('C2256', 9, 'BB5'),
('DF-012-GTX', 2, 'DD4'),
('DF-016-GTX', 3, 'DC1'),
('DF-057-GTX', 2, 'DD3'),
('DF-059-GTX', 8, 'DD3'),
('DF-073-GTX', 2, 'DC1'),
('DF-158-GTX', 1, 'DC5'),
('DF-183-GTX', 2, 'DD5'),
('DF-208-GTX', 3, 'DD3'),
('DF-283-GTX', 4, 'DD2'),
('DF-297-GTX', 2, 'DC5'),
('DF-318-GTX', 1, 'DD3'),
('DF-318-GTX', 3, 'DD4'),
('DF-322-GTX', 2, 'DC3'),
('DF-330-GTX', 5, 'DC2'),
('DF-330-GTX', 1, 'DC3'),
('DF-331-GTX', 4, 'DC3'),
('DF-359-GTX', 2, 'DC3'),
('DF-413-GTX', 1, 'DC5'),
('DF-413-GTX', 2, 'DD3'),
('DF-415-GTX', 4, 'DD6'),
('DF-425-GTXX', 2, 'DC4'),
('DF-426-GTX', 2, 'DC4'),
('DF-445-GTX', 4, 'DD4'),
('DF-499-GTX', 1, 'DC3'),
('DF-499-GTX', 1, 'DC4'),
('DF-564-GTX', 2, 'DC3'),
('DF-575-GTX', 2, 'DD5'),
('DF-581-GTX', 4, 'DD5'),
('DF-587-GTX', 1, 'DD4'),
('DF-587-GTX', 7, 'DD6'),
('DF-600-GTX', 2, 'DC6'),
('DF-609-GTX', 4, 'DC5'),
('DF-640-GTX', 6, 'DC1'),
('DF-640-GTX', 6, 'DD6'),
('DF-687-GTX', 2, 'DC6'),
('DF-731-GTX', 2, 'DC5'),
('DF-749-GTX', 1, 'DC4'),
('DF-749-GTX', 1, 'DD4'),
('DF-767-GTX', 2, 'DC2'),
('DF-770-GTX', 2, 'DC5'),
('DF-770-GTX', 1, 'DD6'),
('DF-779-GTX', 4, 'DC2'),
('DF-779-GTX', 2, 'DC6'),
('DF-785-GTX', 2, 'DC2'),
('DF-785-GTX', 2, 'DC6'),
('DF-792-GTX', 2, 'DC6'),
('DF-813-GTX', 2, 'DD5'),
('DF-859-GTX', 2, 'DC4'),
('DF-DF-16-GTX', 4, 'DC5'),
('DF-DF-16-GTX', 3, 'DD5'),
('DF-DF-16-GTX', 3, 'DD6'),
('DF-DF-17-GTX', 4, 'DD3'),
('DF-DF-509-GTX', 2, 'DD4'),
('DF-TF-052-GTX', 2, 'DD5'),
('FH-018B-A', 1, 'DB7'),
('FH-1007-A', 4, 'AA6'),
('FH-1007-A', 1, 'DB4'),
('FH-1016-A', 1, 'DB5'),
('FH-1039-A', 3, 'AA6'),
('FH-1050-GTX', 1, 'DB6'),
('FH-1087-A', 1, 'AA6'),
('FH-1087-A', 1, 'DB5'),
('FH-1167-A', 1, 'AA6'),
('FH-1174-A', 2, 'DA4'),
('FH-1189-Z', 1, 'AB6'),
('FH-3124-GTX', 1, 'DB5'),
('FH-3350-GTX', 1, 'DB4'),
('FH-3350-GTX', 1, 'DB6'),
('FH-4400-A', 3, 'AA6'),
('FH-4400-A', 1, 'DB7'),
('FH-4400-GTX', 2, 'DB6'),
('FH-44020-GTX', 2, 'AA6'),
('FH-4458X-GTX', 1, 'DB4'),
('FH-4458X-GTX', 1, 'FD6'),
('FH-488-A', 1, 'DC6'),
('FH-705-A', 1, 'DB7'),
('FH-806-A', 1, 'AB6'),
('FH-8122-GTX', 5, 'DB6'),
('FH-8163-GTX', 1, 'DB6'),
('FH-8166B-GTX', 4, 'FD6'),
('FH-8199-A', 1, 'AB6'),
('FH-8199-A', 1, 'DB7'),
('FH-8206-GTX', 1, 'AA6'),
('FH-8222-A', 1, 'AA6'),
('FH-8237-GTX', 1, 'DB6'),
('FH-8237-GTX', 1, 'DC6'),
('FH-8244-GTX', 1, 'DB6'),
('FH-8258-A', 1, 'AB6'),
('FH-8258-GTX', 6, 'DB4'),
('FH-8265-GTX', 4, 'AB6'),
('FH-8276-GTX', 1, 'DB6'),
('FH-8288-A', 1, 'DB5'),
('FH-8289-A', 2, 'AA1'),
('FH-8289-A', 2, 'AB6'),
('FH-8289-A', 3, 'DA4'),
('FH-8289-A', 1, 'DB5'),
('FH-8320-A', 2, 'DB4'),
('FH-8396-A', 1, 'AA1'),
('FH-8396-A', 1, 'DB5'),
('FH-8396-GTX', 3, 'DB5'),
('FH-872B-A', 1, 'AA1'),
('FH-872B-GTX', 4, 'DB7'),
('FH-888-A', 1, 'AA6'),
('FH-924-A', 2, 'AA6'),
('FH-924-GTX', 2, 'DB4'),
('FH-984-A', 1, 'AA6'),
('FH-B582-A', 7, 'AA6'),
('FH-B582-A', 1, 'DB7'),
('LP5145', 1, 'CA4'),
('OEM35014', -4, 'EB5'),
('PP1018', 1, 'CC5'),
('PP1210', 3, 'CB6'),
('PP1210', 1, 'CC4'),
('PP1733', 1, 'EC4'),
('REFFC-L3,8', 0, 'FC6'),
('RODRIGO', 1, 'BB2'),
('RX1104', 1, 'EC4'),
('RX1432', 1, 'EC4'),
('S0196', 1, 'CA1'),
('TF-055-GTX', 4, 'DD2'),
('TF-097-GTX', 2, 'DC1'),
('TF-133-GTX', 1, 'DC1'),
('TF-133-GTX', 7, 'DD2'),
('TF-135-GTX', 2, 'DC3'),
('TFA-2256', 11, 'BB5'),
('TF-TF-28-GTX', 2, 'DD6'),
('UC-5710', 20, 'EB5'),
('Z6E6133A0', 3, 'AD2');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` varchar(50) COLLATE utf8_spanish2_ci NOT NULL,
  `NOMBRE` varchar(20) COLLATE utf8_spanish2_ci NOT NULL,
  `PASSWORD` varchar(100) COLLATE utf8_spanish2_ci NOT NULL,
  `ID_ROL` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `NOMBRE`, `PASSWORD`, `ID_ROL`) VALUES
('174140464', 'Felipe Kiefer', 'c4ca4238a0b923820dcc509a6f75849b', 1);

-- --------------------------------------------------------

--
-- Table structure for table `xyz`
--

CREATE TABLE `xyz` (
  `UBICACION` varchar(3) COLLATE utf8_spanish2_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Dumping data for table `xyz`
--

INSERT INTO `xyz` (`UBICACION`) VALUES
('AA1'),
('AA2'),
('AA3'),
('AA4'),
('AA6'),
('AB1'),
('AB2'),
('AB3'),
('AB4'),
('AB6'),
('AC6'),
('AD2'),
('AD3'),
('AD4'),
('AD5'),
('AD6'),
('AE2'),
('AE4'),
('AE5'),
('AF1'),
('AF2'),
('AF3'),
('AF4'),
('AF5'),
('AF6'),
('BA1'),
('BA2'),
('BA3'),
('BA4'),
('BA5'),
('BB1'),
('BB2'),
('BB3'),
('BB4'),
('BB5'),
('BC1'),
('BC2'),
('BC3'),
('BC4'),
('BD1'),
('BD2'),
('BD3'),
('BD4'),
('BE1'),
('BE2'),
('BE3'),
('BE4'),
('BE5'),
('BF1'),
('BF2'),
('BF3'),
('BF4'),
('BF5'),
('CA1'),
('CA2'),
('CA3'),
('CA4'),
('CA5'),
('CA6'),
('CA7'),
('CA8'),
('CA9'),
('CB1'),
('CB2'),
('CB3'),
('CB4'),
('CB5'),
('CB6'),
('CC1'),
('CC2'),
('CC3'),
('CC4'),
('CC5'),
('CC6'),
('CD1'),
('CD2'),
('CD3'),
('CD4'),
('CD5'),
('CD6'),
('DA4'),
('DB4'),
('DB5'),
('DB6'),
('DB7'),
('DC1'),
('DC2'),
('DC3'),
('DC4'),
('DC5'),
('DC6'),
('DD2'),
('DD3'),
('DD4'),
('DD5'),
('DD6'),
('EA3'),
('EA5'),
('EA6'),
('EB3'),
('EB5'),
('EC3'),
('EC4'),
('EC5'),
('EC6'),
('FA1'),
('FA2'),
('FA3'),
('FA4'),
('FA5'),
('FA6'),
('FB2'),
('FB3'),
('FB4'),
('FB5'),
('FB6'),
('FC2'),
('FC3'),
('FC4'),
('FC5'),
('FC6'),
('FD2'),
('FD3'),
('FD4'),
('FD6'),
('FE2'),
('FE3'),
('FE4'),
('FF4'),
('FF5'),
('FF6'),
('FF7'),
('GA5'),
('OUT');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cli`
--
ALTER TABLE `cli`
  ADD PRIMARY KEY (`cli_rut`),
  ADD UNIQUE KEY `cli_rut_2` (`cli_rut`),
  ADD KEY `cli_rut` (`cli_rut`);

--
-- Indexes for table `d_ot`
--
ALTER TABLE `d_ot`
  ADD KEY `ID_IN` (`order_id`),
  ADD KEY `ID_PROD` (`prod_id`),
  ADD KEY `A` (`prod_xyz`);

--
-- Indexes for table `d_ot_temporal`
--
ALTER TABLE `d_ot_temporal`
  ADD UNIQUE KEY `correlativo` (`correlativo`),
  ADD KEY `id_prod` (`prod_id`),
  ADD KEY `a` (`prod_xyz`),
  ADD KEY `user_token` (`user_token`);

--
-- Indexes for table `order_ot`
--
ALTER TABLE `order_ot`
  ADD PRIMARY KEY (`ot_id`),
  ADD KEY `TIPO_ORDEN` (`order_type`),
  ADD KEY `cli` (`cli_id`),
  ADD KEY `user` (`user_id`);

--
-- Indexes for table `order_type`
--
ALTER TABLE `order_type`
  ADD PRIMARY KEY (`order_type_id`);

--
-- Indexes for table `prod`
--
ALTER TABLE `prod`
  ADD PRIMARY KEY (`prod_id`);

--
-- Indexes for table `prov`
--
ALTER TABLE `prov`
  ADD PRIMARY KEY (`id_prov`);

--
-- Indexes for table `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`);

--
-- Indexes for table `sale`
--
ALTER TABLE `sale`
  ADD PRIMARY KEY (`rut_sale`),
  ADD KEY `id_prov` (`id_prov`);

--
-- Indexes for table `stock`
--
ALTER TABLE `stock`
  ADD KEY `ID_PROD` (`stock_prod_id`),
  ADD KEY `UBICACION` (`stock_xyz_xyz`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`),
  ADD KEY `id_rol` (`ID_ROL`);

--
-- Indexes for table `xyz`
--
ALTER TABLE `xyz`
  ADD PRIMARY KEY (`UBICACION`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `d_ot_temporal`
--
ALTER TABLE `d_ot_temporal`
  MODIFY `correlativo` tinyint(4) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `order_ot`
--
ALTER TABLE `order_ot`
  MODIFY `ot_id` mediumint(9) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `d_ot`
--
ALTER TABLE `d_ot`
  ADD CONSTRAINT `d_ot_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `order_ot` (`ot_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `d_ot_ibfk_2` FOREIGN KEY (`prod_xyz`) REFERENCES `xyz` (`UBICACION`) ON UPDATE CASCADE;

--
-- Constraints for table `d_ot_temporal`
--
ALTER TABLE `d_ot_temporal`
  ADD CONSTRAINT `d_ot_temporal_ibfk_2` FOREIGN KEY (`prod_id`) REFERENCES `prod` (`prod_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `d_ot_temporal_ibfk_3` FOREIGN KEY (`prod_xyz`) REFERENCES `xyz` (`UBICACION`) ON UPDATE CASCADE,
  ADD CONSTRAINT `d_ot_temporal_ibfk_4` FOREIGN KEY (`user_token`) REFERENCES `user` (`user_id`) ON UPDATE CASCADE;

--
-- Constraints for table `sale`
--
ALTER TABLE `sale`
  ADD CONSTRAINT `sale_ibfk_1` FOREIGN KEY (`id_prov`) REFERENCES `prov` (`id_prov`) ON UPDATE CASCADE;

--
-- Constraints for table `stock`
--
ALTER TABLE `stock`
  ADD CONSTRAINT `stock_ibfk_1` FOREIGN KEY (`stock_xyz_xyz`) REFERENCES `xyz` (`UBICACION`) ON UPDATE CASCADE;

--
-- Constraints for table `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `user_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON DELETE CASCADE ON UPDATE NO ACTION,
  ADD CONSTRAINT `user_ibfk_2` FOREIGN KEY (`ID_ROL`) REFERENCES `rol` (`id_rol`) ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
