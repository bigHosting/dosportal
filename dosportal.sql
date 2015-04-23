-- MySQL dump 10.13  Distrib 5.5.40, for Linux (x86_64)
--
-- Host: localhost    Database: dosportal
-- ------------------------------------------------------
-- Server version	5.5.40-cll-lve

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `DYNAMIC_HTTP_IN`
--

DROP TABLE IF EXISTS `DYNAMIC_HTTP_IN`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DYNAMIC_HTTP_IN` (
  `id` mediumint(10) unsigned NOT NULL AUTO_INCREMENT,
  `sourceip` varchar(15) NOT NULL DEFAULT '-',
  `cidr` smallint(2) NOT NULL DEFAULT '32',
  `proto` enum('tcp','udp','all') NOT NULL DEFAULT 'tcp',
  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expiretime` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  `hits` int(8) unsigned NOT NULL DEFAULT '0',
  `country` varchar(3) NOT NULL DEFAULT 'UNK',
  `comment` varchar(250) NOT NULL DEFAULT '-',
  `block_with` enum('DROP','REJECT','TARPIT') NOT NULL DEFAULT 'REJECT',
  `insertby` varchar(250) NOT NULL DEFAULT '-',
  `allow_edit` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_whitelist` (`sourceip`,`cidr`)
) ENGINE=InnoDB AUTO_INCREMENT=43639 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @:w
saved_cs_client */;

--
-- Dumping data for table `DYNAMIC_HTTP_IN`
--

LOCK TABLES `DYNAMIC_HTTP_IN` WRITE;
/*!40000 ALTER TABLE `DYNAMIC_HTTP_IN` DISABLE KEYS */;

/*!40000 ALTER TABLE `DYNAMIC_HTTP_IN` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER DYNAMIC_HTTP_IN_history BEFORE DELETE ON `DYNAMIC_HTTP_IN`
FOR EACH ROW BEGIN
INSERT INTO DYNAMIC_HTTP_IN_history (sourceip,cidr,proto,inserttime,expiretime,hits,country,comment,block_with,insertby,allow_edit) VALUES (
OLD.sourceip,OLD.cidr,OLD.proto,OLD.inserttime,OLD.expiretime,OLD.hits,OLD.country,OLD.comment,OLD.block_with,OLD.insertby,OLD.allow_edit );
 END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `DYNAMIC_HTTP_IN_history`
--

DROP TABLE IF EXISTS `DYNAMIC_HTTP_IN_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DYNAMIC_HTTP_IN_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sourceip` varchar(15) NOT NULL DEFAULT '-',
  `cidr` smallint(2) NOT NULL DEFAULT '32',
  `proto` enum('tcp','udp','all') NOT NULL DEFAULT 'tcp',
  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expiretime` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  `hits` int(8) unsigned NOT NULL DEFAULT '0',
  `country` varchar(3) NOT NULL DEFAULT 'UNK',
  `comment` varchar(250) NOT NULL DEFAULT '-',
  `block_with` enum('DROP','REJECT','TARPIT') NOT NULL DEFAULT 'REJECT',
  `insertby` varchar(250) NOT NULL DEFAULT '-',
  `allow_edit` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=670896 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;


--
-- Dumping data for table `DYNAMIC_HTTP_IN_history`
--

INSERT INTO `DYNAMIC_HTTP_IN_history` VALUES (39248,'118.168.6.195',32,'tcp','2015-02-15 18:01:29','2015-02-15 13:00:02',652,'TW','graylo
g-mail','REJECT','graylog-mail','Y');
INSERT INTO `DYNAMIC_HTTP_IN_history` VALUES (39249,'178.62.168.14',32,'tcp','2015-02-15 18:01:29','2015-02-15 13:00:03',570,'GB','graylo
g-mail','REJECT','graylog-mail','Y');

LOCK TABLES `DYNAMIC_HTTP_IN_history` WRITE;
/*!40000 ALTER TABLE `DYNAMIC_HTTP_IN_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `DYNAMIC_HTTP_IN_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DYNAMIC_HTTP_IN_history_thresholdhits`
--

DROP TABLE IF EXISTS `DYNAMIC_HTTP_IN_history_thresholdhits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DYNAMIC_HTTP_IN_history_thresholdhits` (
  `id` mediumint(10) unsigned NOT NULL AUTO_INCREMENT,
  `hits` smallint(6) unsigned NOT NULL DEFAULT '200',
  `block_for` int(10) unsigned NOT NULL DEFAULT '200',
  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `comment` varchar(250) NOT NULL DEFAULT '-',
  `insertby` varchar(250) NOT NULL DEFAULT '-',
  PRIMARY KEY (`id`),
  UNIQUE KEY `myindex` (`hits`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DYNAMIC_HTTP_IN_history_thresholdhits`
--

LOCK TABLES `DYNAMIC_HTTP_IN_history_thresholdhits` WRITE;
/*!40000 ALTER TABLE `DYNAMIC_HTTP_IN_history_thresholdhits` DISABLE KEYS */;
INSERT INTO `DYNAMIC_HTTP_IN_history_thresholdhits` VALUES (1,3,604800,'2014-12-02 20:59:02','1w block','adminuser');
INSERT INTO `DYNAMIC_HTTP_IN_history_thresholdhits` VALUES (2,6,2419200,'2014-12-02 20:59:51','1m block','adminuser');
INSERT INTO `DYNAMIC_HTTP_IN_history_thresholdhits` VALUES (3,10,7776000,'2014-12-02 21:00:57','3m block','adminuser');
/*!40000 ALTER TABLE `DYNAMIC_HTTP_IN_history_thresholdhits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DYNAMIC_HTTP_IN_temp_whitelist`
--

DROP TABLE IF EXISTS `DYNAMIC_HTTP_IN_temp_whitelist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DYNAMIC_HTTP_IN_temp_whitelist` (
  `id` mediumint(10) unsigned NOT NULL AUTO_INCREMENT,
  `sourceip` varchar(15) NOT NULL DEFAULT '-',
  `cidr` smallint(2) NOT NULL DEFAULT '32',
  `proto` enum('tcp','udp','all') NOT NULL DEFAULT 'tcp',
  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expiretime` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  `hits` int(8) unsigned NOT NULL DEFAULT '0',
  `country` varchar(3) NOT NULL DEFAULT 'UNK',
  `comment` varchar(250) NOT NULL DEFAULT '-',
  `block_with` enum('DROP','REJECT','TARPIT') NOT NULL DEFAULT 'REJECT',
  `insertby` varchar(250) NOT NULL DEFAULT '-',
  `allow_edit` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_whitelist` (`sourceip`,`cidr`)
) ENGINE=InnoDB AUTO_INCREMENT=139 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DYNAMIC_HTTP_IN_temp_whitelist`
--

LOCK TABLES `DYNAMIC_HTTP_IN_temp_whitelist` WRITE;
/*!40000 ALTER TABLE `DYNAMIC_HTTP_IN_temp_whitelist` DISABLE KEYS */;
/*!40000 ALTER TABLE `DYNAMIC_HTTP_IN_temp_whitelist` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER DYNAMIC_HTTP_IN_temp_whitelist_history BEFORE DELETE ON `DYNAMIC_HTTP_IN_temp_whitelist`
    FOR EACH ROW BEGIN
        INSERT INTO DYNAMIC_HTTP_IN_temp_whitelist_history (sourceip,cidr,proto,inserttime,expiretime,hits,country,comment,block_with,insertby,allow_edit) VALUES (
        OLD.sourceip,OLD.cidr,OLD.proto,OLD.inserttime,OLD.expiretime,OLD.hits,OLD.country,OLD.comment,OLD.block_with,OLD.insertby,OLD.allow_edit );
    END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `DYNAMIC_HTTP_IN_temp_whitelist_history`
--

DROP TABLE IF EXISTS `DYNAMIC_HTTP_IN_temp_whitelist_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `DYNAMIC_HTTP_IN_temp_whitelist_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sourceip` varchar(15) NOT NULL DEFAULT '-',
  `cidr` smallint(2) NOT NULL DEFAULT '32',
  `proto` enum('tcp','udp','all') NOT NULL DEFAULT 'tcp',
  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expiretime` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  `hits` int(8) unsigned NOT NULL DEFAULT '0',
  `country` varchar(3) NOT NULL DEFAULT 'UNK',
  `comment` varchar(250) NOT NULL DEFAULT '-',
  `block_with` enum('DROP','REJECT','TARPIT') NOT NULL DEFAULT 'REJECT',
  `insertby` varchar(250) NOT NULL DEFAULT '-',
  `allow_edit` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DYNAMIC_HTTP_IN_temp_whitelist_history`
--

LOCK TABLES `DYNAMIC_HTTP_IN_temp_whitelist_history` WRITE;
/*!40000 ALTER TABLE `DYNAMIC_HTTP_IN_temp_whitelist_history` DISABLE KEYS */;
INSERT INTO `DYNAMIC_HTTP_IN_temp_whitelist_history` VALUES (1,'31.146.121.195',32,'tcp','2015-02-07 15:05:54','2015-02-07 12:05:54',0,'UNK','whitelisted','REJECT','adminuser','Y');
INSERT INTO `DYNAMIC_HTTP_IN_temp_whitelist_history` VALUES (2,'76.72.11.215',32,'tcp','2015-02-07 06:11:25','2015-02-08 01:11:25',8000,'US','graylog-ftp','REJECT','graylog-ftp','Y');
INSERT INTO `DYNAMIC_HTTP_IN_temp_whitelist_history` VALUES (3,'80.74.253.53',32,'tcp','2015-04-13 16:51:36','2015-04-15 23:43:39',0,'UNK','whitelisted','REJECT','adminuser','Y');
INSERT INTO `DYNAMIC_HTTP_IN_temp_whitelist_history` VALUES (4,'80.74.253.54',32,'tcp','2015-04-13 16:51:36','2015-04-15 23:43:39',0,'UNK','whitelisted','REJECT','adminuser','Y');
/*!40000 ALTER TABLE `DYNAMIC_HTTP_IN_temp_whitelist_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RTBH_stats`
--

DROP TABLE IF EXISTS `RTBH_stats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RTBH_stats` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `ips_manual` mediumint(10) unsigned NOT NULL DEFAULT '0',
  `hits_manual` int(15) unsigned NOT NULL DEFAULT '0',
  `ips_web` mediumint(10) unsigned NOT NULL DEFAULT '0',
  `hits_web` int(15) unsigned NOT NULL DEFAULT '0',
  `ips_asm` mediumint(10) unsigned NOT NULL DEFAULT '0',
  `hits_asm` int(15) unsigned NOT NULL DEFAULT '0',
  `ips_mail` mediumint(10) unsigned NOT NULL DEFAULT '0',
  `hits_mail` int(15) unsigned NOT NULL DEFAULT '0',
  `ips_ftp` mediumint(10) unsigned NOT NULL DEFAULT '0',
  `hits_ftp` int(15) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RTBH_stats`
--

LOCK TABLES `RTBH_stats` WRITE;
/*!40000 ALTER TABLE `RTBH_stats` DISABLE KEYS */;
INSERT INTO `RTBH_stats` VALUES (1,'2015-03-20 16:26:12',179,110000,171,91099,423,727742,2111,958489,5649,1667868);
INSERT INTO `RTBH_stats` VALUES (2,'2015-03-20 16:26:14',179,110000,170,90972,427,734022,2112,959128,5634,1667868);
INSERT INTO `RTBH_stats` VALUES (3,'2015-03-20 16:26:22',179,110000,170,90972,427,734022,2112,959128,5634,1667868);
INSERT INTO `RTBH_stats` VALUES (4,'2015-03-20 16:26:24',179,110000,170,90972,433,749166,2109,956460,5667,1667868);
INSERT INTO `RTBH_stats` VALUES (5,'2015-03-20 16:26:26',179,110000,171,91474,459,761681,2115,959812,5696,1667868);
INSERT INTO `RTBH_stats` VALUES (6,'2015-03-20 16:26:28',179,110000,171,91082,483,785277,2161,981156,5681,1667868);
INSERT INTO `RTBH_stats` VALUES (7,'2015-02-27 04:59:30',180,5500,176,92598,587,851282,2236,997086,6230,1667868);
INSERT INTO `RTBH_stats` VALUES (8,'2015-02-28 04:59:30',180,5500,223,98693,694,936896,2338,1029876,6952,1730744);
INSERT INTO `RTBH_stats` VALUES (9,'2015-03-01 04:59:30',180,5500,243,101949,743,950162,2458,1068514,8383,1951169);
INSERT INTO `RTBH_stats` VALUES (10,'2015-03-02 04:59:30',180,5500,258,106312,833,1045721,2549,1095971,9671,2166942);
INSERT INTO `RTBH_stats` VALUES (11,'2015-03-03 04:59:30',180,5500,281,121134,937,1128598,2657,1125065,10344,2288987);
INSERT INTO `RTBH_stats` VALUES (12,'2015-03-04 04:59:30',180,5500,292,123396,1017,1187477,2804,1185129,11613,2487368);
INSERT INTO `RTBH_stats` VALUES (13,'2015-03-05 04:59:30',180,5500,301,124555,1117,1255813,2929,1220924,12955,2683255);
INSERT INTO `RTBH_stats` VALUES (14,'2015-03-06 04:59:30',179,5500,330,134366,1199,1350312,3031,1266045,14235,2891941);
INSERT INTO `RTBH_stats` VALUES (15,'2015-03-07 04:59:30',179,5500,341,132591,1248,1422456,3108,1285932,15929,3115059);
INSERT INTO `RTBH_stats` VALUES (16,'2015-03-08 04:59:30',179,5500,354,135418,1257,1431852,3246,1333609,17496,3341070);
INSERT INTO `RTBH_stats` VALUES (17,'2015-03-09 03:59:30',198,5500,386,149191,1276,1480145,3337,1363679,19091,3613698);
INSERT INTO `RTBH_stats` VALUES (18,'2015-03-10 03:59:30',200,5500,398,153679,1350,1610808,3448,1400419,20533,3866749);
INSERT INTO `RTBH_stats` VALUES (19,'2015-03-11 03:59:30',200,5500,404,152851,1388,1667626,3545,1437934,21876,4043838);
INSERT INTO `RTBH_stats` VALUES (20,'2015-03-12 03:59:30',200,5500,411,155497,1412,1689942,3628,1463717,23061,4200006);
INSERT INTO `RTBH_stats` VALUES (21,'2015-03-13 03:59:30',200,5500,413,154636,1440,1758437,3739,1498964,24114,4353713);
INSERT INTO `RTBH_stats` VALUES (22,'2015-03-14 03:59:30',200,5500,426,157896,1492,1809289,3873,1543648,24969,4448988);
INSERT INTO `RTBH_stats` VALUES (23,'2015-03-15 03:59:30',200,5500,429,157778,1496,1804443,3978,1581563,25738,4542426);
INSERT INTO `RTBH_stats` VALUES (24,'2015-03-16 03:59:30',200,5500,440,154159,1513,1808815,4072,1610198,26410,4689654);
INSERT INTO `RTBH_stats` VALUES (25,'2015-03-17 03:59:30',195,3000,458,159511,1563,1905830,4163,1642966,27022,4762910);
INSERT INTO `RTBH_stats` VALUES (26,'2015-03-18 03:59:30',196,3000,472,162545,1590,1934078,4276,1688781,27646,4886514);
INSERT INTO `RTBH_stats` VALUES (27,'2015-03-19 03:59:30',203,3000,481,164513,1655,2006095,4403,1732925,28040,5023770);
INSERT INTO `RTBH_stats` VALUES (28,'2015-03-20 03:59:30',221,3000,491,166354,1668,2012775,4531,1776324,29157,5258689);
INSERT INTO `RTBH_stats` VALUES (29,'2015-03-21 03:59:30',440,3000,505,168782,1641,1972278,3875,1529684,28294,5091216);
INSERT INTO `RTBH_stats` VALUES (30,'2015-03-22 03:59:30',442,3000,533,177829,1683,2051497,3971,1571959,29162,5236901);
INSERT INTO `RTBH_stats` VALUES (31,'2015-03-23 03:59:30',442,3000,547,188040,1720,2118940,4071,1598555,29985,5358569);
INSERT INTO `RTBH_stats` VALUES (32,'2015-03-24 03:59:30',437,3000,588,198333,1777,2206830,4232,1651156,41307,7076308);
INSERT INTO `RTBH_stats` VALUES (33,'2015-03-25 03:59:30',437,3000,644,213539,1802,2231602,4400,1701046,54950,8917985);
INSERT INTO `RTBH_stats` VALUES (34,'2015-03-26 03:59:30',437,3000,691,226792,1808,2213089,4530,1741592,64017,10219449);
INSERT INTO `RTBH_stats` VALUES (35,'2015-03-27 03:59:30',437,3000,728,234204,1846,2294876,4652,1780765,33270,9423068);
INSERT INTO `RTBH_stats` VALUES (36,'2015-03-28 03:59:30',437,3000,763,245937,1880,2418293,4878,1855915,28092,10312960);
INSERT INTO `RTBH_stats` VALUES (37,'2015-03-29 03:59:30',437,3000,773,249585,1866,2425538,5059,1910869,33501,12121819);
INSERT INTO `RTBH_stats` VALUES (38,'2015-03-30 03:59:30',437,3000,809,257628,1914,2495464,5192,1973037,37058,13243925);
INSERT INTO `RTBH_stats` VALUES (39,'2015-03-31 03:59:30',438,3000,848,267917,1930,2634447,5379,2036391,42866,15389553);
INSERT INTO `RTBH_stats` VALUES (40,'2015-04-01 03:59:30',438,3000,910,293314,1956,2609252,5497,2083832,38126,14855724);
INSERT INTO `RTBH_stats` VALUES (41,'2015-04-02 03:59:30',438,3000,890,282323,1976,2695556,5734,2167825,44211,16942998);
/*!40000 ALTER TABLE `RTBH_stats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `graylog_settings_connections`
--

DROP TABLE IF EXISTS `graylog_settings_connections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `graylog_settings_connections` (
  `id` mediumint(10) unsigned NOT NULL AUTO_INCREMENT,
  `connections` smallint(6) unsigned NOT NULL DEFAULT '200',
  `block_for` int(10) unsigned NOT NULL DEFAULT '200',
  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `comment` varchar(250) NOT NULL DEFAULT '-',
  `insertby` varchar(250) NOT NULL DEFAULT '-',
  PRIMARY KEY (`id`),
  UNIQUE KEY `myindex` (`connections`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `graylog_settings_connections`
--

LOCK TABLES `graylog_settings_connections` WRITE;
/*!40000 ALTER TABLE `graylog_settings_connections` DISABLE KEYS */;
INSERT INTO `graylog_settings_connections` VALUES (1,100,1800,'2014-12-03 18:07:49','30m block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (2,500,7200,'2014-12-03 18:12:43','2h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (3,599,7200,'2014-12-03 18:13:02','2h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (4,600,14400,'2014-11-30 15:09:53','4h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (5,700,14400,'2014-11-30 15:10:03','4h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (6,799,14400,'2014-11-30 15:10:21','4h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (7,800,28800,'2014-11-30 15:11:09','8h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (8,900,28800,'2014-11-30 15:11:18','8h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (9,999,28800,'2014-11-30 15:12:00','8h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (10,1000,64800,'2014-11-30 15:14:04','18h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (11,1500,86400,'2014-11-30 15:19:31','18h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (12,1600,86400,'2014-11-30 15:15:18','24h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (13,1999,86400,'2014-11-30 15:15:55','24h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (14,4000,86400,'2014-11-30 15:16:36','24h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (15,8000,604800,'2014-11-30 15:17:10','7d block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (16,9000,604800,'2014-11-30 15:17:27','7d block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (17,10000,31557600,'2014-12-03 21:23:15','1y block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (18,200,1800,'2014-12-03 18:13:16','30m block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (19,299,7200,'2014-12-03 18:12:10','2h block','adminuser');
INSERT INTO `graylog_settings_connections` VALUES (20,399,7200,'2014-12-03 18:10:52','2h block','adminuser');
/*!40000 ALTER TABLE `graylog_settings_connections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `graylog_strings`
--

DROP TABLE IF EXISTS `graylog_strings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `graylog_strings` (
  `id` mediumint(10) unsigned NOT NULL AUTO_INCREMENT,
  `string` varchar(250) NOT NULL DEFAULT 'wpad.dat',
  `type` enum('GET','POST','HEAD') DEFAULT NULL,
  `hits` smallint(5) unsigned NOT NULL DEFAULT '200',
  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expiretime` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  `comment` varchar(250) NOT NULL DEFAULT '-',
  `insertby` varchar(250) NOT NULL DEFAULT '-',
  PRIMARY KEY (`id`),
  UNIQUE KEY `myindex` (`string`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `graylog_strings`
--

LOCK TABLES `graylog_strings` WRITE;
/*!40000 ALTER TABLE `graylog_strings` DISABLE KEYS */;
INSERT INTO `graylog_strings` VALUES (1,'wp-login.php','POST',200,'2014-12-18 03:49:12','9999-12-31 23:59:59','WP Administrator Login','adminuser');
INSERT INTO `graylog_strings` VALUES (4,'wpad.dat','GET',200,'2015-02-25 17:25:53','9999-12-31 23:59:59','admin page','adminuser');
INSERT INTO `graylog_strings` VALUES (5,'ftpchk3.php','GET',50,'2015-02-01 21:21:15','9999-12-31 23:59:59','FTP CMS detector','adminuser');
/*!40000 ALTER TABLE `graylog_strings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `our_networks`
--

DROP TABLE IF EXISTS `our_networks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `our_networks` (
  `id` mediumint(10) unsigned NOT NULL AUTO_INCREMENT,
  `sourceip` varchar(15) NOT NULL DEFAULT '-',
  `cidr` smallint(2) NOT NULL DEFAULT '32',
  `country` varchar(3) NOT NULL DEFAULT 'UNK',
  `inserttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `expiretime` datetime NOT NULL DEFAULT '9999-12-31 23:59:59',
  `hits` int(8) unsigned NOT NULL DEFAULT '0',
  `comment` varchar(250) NOT NULL DEFAULT '-',
  `insertby` varchar(250) NOT NULL DEFAULT '-',
  `allow_edit` enum('Y','N') NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_whitelist` (`sourceip`,`cidr`)
) ENGINE=InnoDB AUTO_INCREMENT=481 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `our_networks`
--

LOCK TABLES `our_networks` WRITE;
/*!40000 ALTER TABLE `our_networks` DISABLE KEYS */;
INSERT INTO `our_networks` VALUES (24,'127.0.0.1',32,'UNK','2014-07-11 14:43:34','9999-12-31 23:59:59',0,'self','adminuser','N');
INSERT INTO `our_networks` VALUES (25,'127.0.0.0',8,'UNK','2014-07-11 14:43:34','9999-12-31 23:59:59',0,'self','adminuser','N');
INSERT INTO `our_networks` VALUES (26,'10.0.0.0',8,'UNK','2014-07-11 14:43:34','9999-12-31 23:59:59',0,'Private','adminuser','N');
INSERT INTO `our_networks` VALUES (27,'192.168.0.0',16,'UNK','2014-07-11 14:43:34','9999-12-31 23:59:59',0,'Private','adminuser','N');
INSERT INTO `our_networks` VALUES (28,'172.16.0.0',12,'UNK','2014-07-11 14:43:34','9999-12-31 23:59:59',0,'Private','adminuser','N');
INSERT INTO `our_networks` VALUES (49,'192.203.230.10',32,'UNK','2014-12-16 21:17:25','9999-12-31 23:59:59',0,'DNS root','adminuser','N');
INSERT INTO `our_networks` VALUES (50,'192.5.5.241',32,'UNK','2014-12-16 21:17:38','9999-12-31 23:59:59',0,'DNS root','adminuser','N');
INSERT INTO `our_networks` VALUES (51,'192.112.36.4',32,'UNK','2014-12-16 21:17:55','9999-12-31 23:59:59',0,'DNS root','adminuser','N');
INSERT INTO `our_networks` VALUES (52,'128.63.2.53',32,'UNK','2014-12-16 21:18:07','9999-12-31 23:59:59',0,'DNS root','adminuser','N');
INSERT INTO `our_networks` VALUES (53,'192.36.148.17',32,'UNK','2014-12-16 21:18:21','9999-12-31 23:59:59',0,'DNS root','adminuser','N');
INSERT INTO `our_networks` VALUES (54,'192.58.128.30',32,'UNK','2014-12-16 21:18:38','9999-12-31 23:59:59',0,'DNS root','adminuser','N');
INSERT INTO `our_networks` VALUES (55,'193.0.14.129',32,'UNK','2014-12-16 21:18:54','9999-12-31 23:59:59',0,'DNS root','adminuser','N');
INSERT INTO `our_networks` VALUES (56,'199.7.83.42',32,'UNK','2014-12-16 21:19:09','9999-12-31 23:59:59',0,'DNS root','adminuser','N');
INSERT INTO `our_networks` VALUES (57,'202.12.27.33',32,'UNK','2014-12-16 21:19:22','9999-12-31 23:59:59',0,'DNS root','adminuser','N');
INSERT INTO `our_networks` VALUES (58,'149.115.0.0',16,'UNK','2014-12-16 21:25:18','9999-12-31 23:59:59',0,'Miami','adminuser','N');
INSERT INTO `our_networks` VALUES (59,'173.0.84.0',24,'UNK','2014-12-26 16:06:35','9999-12-31 23:59:59',0,'PayPal','adminuser','N');
INSERT INTO `our_networks` VALUES (60,'173.0.88.0',24,'UNK','2014-12-26 16:06:47','9999-12-31 23:59:59',0,'PayPal','adminuser','N');
INSERT INTO `our_networks` VALUES (61,'173.0.92.0',24,'UNK','2014-12-26 16:07:40','9999-12-31 23:59:59',0,'PayPal-D-3483952','adminuser','N');
INSERT INTO `our_networks` VALUES (62,'173.0.93.0',24,'UNK','2014-12-26 16:07:57','9999-12-31 23:59:59',0,'PayPal-D-3483952','adminuser','N');
INSERT INTO `our_networks` VALUES (63,'64.4.248.0',24,'UNK','2014-12-26 16:08:37','9999-12-31 23:59:59',0,'PayPal-D-3483952','adminuser','N');
INSERT INTO `our_networks` VALUES (64,'64.4.249.0',24,'UNK','2014-12-26 16:08:50','9999-12-31 23:59:59',0,'PayPal-D-3483952','adminuser','N');
INSERT INTO `our_networks` VALUES (65,'66.211.168.0',24,'UNK','2014-12-26 16:09:33','9999-12-31 23:59:59',0,'PayPal-D-3483952','adminuser','N');
INSERT INTO `our_networks` VALUES (66,'173.0.81.1',32,'UNK','2014-12-26 16:10:53','9999-12-31 23:59:59',0,'PayPal-D-3483952','adminuser','N');
INSERT INTO `our_networks` VALUES (67,'173.0.81.33',32,'UNK','2014-12-26 16:11:18','9999-12-31 23:59:59',0,'PayPal-D-3483952','adminuser','N');
INSERT INTO `our_networks` VALUES (68,'66.211.170.66',32,'UNK','2014-12-26 16:11:34','9999-12-31 23:59:59',0,'PayPal-D-3483952','adminuser','N');
/*!40000 ALTER TABLE `our_networks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'dosportal'
--
/*!50106 SET @save_time_zone= @@TIME_ZONE */ ;
/*!50106 DROP EVENT IF EXISTS `clean_DYNAMIC_HTTP_IN` */;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = '' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `clean_DYNAMIC_HTTP_IN` ON SCHEDULE EVERY 5 MINUTE STARTS '2014-11-30 17:09:13' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN DELETE FROM `DYNAMIC_HTTP_IN` WHERE expiretime < DATE_SUB(NOW(), INTERVAL 5 MINUTE);
END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `clean_DYNAMIC_HTTP_IN_temp_whitelist` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = '' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `clean_DYNAMIC_HTTP_IN_temp_whitelist` ON SCHEDULE EVERY 5 MINUTE STARTS '2015-02-06 21:58:51' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN DELETE FROM `DYNAMIC_HTTP_IN_temp_whitelist` WHERE expiretime < DATE_SUB(NOW(), INTERVAL 5 MINUTE);
END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `DYNAMIC_HTTP_IN_history_cleanup` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = '' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `DYNAMIC_HTTP_IN_history_cleanup` ON SCHEDULE EVERY 1 DAY STARTS '2015-01-19 12:10:37' ON COMPLETION NOT PRESERVE ENABLE DO delete from DYNAMIC_HTTP_IN_history WHERE inserttime < (NOW() - INTERVAL 60 DAY) */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `out_daily` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = '' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `out_daily` ON SCHEDULE EVERY 1 HOUR STARTS '2013-09-16 18:36:18' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'renumbering out_daily table' DO BEGIN set @a=0; update out_daily set id=(@a:=@a+1); ALTER TABLE out_daily auto_increment = 1; END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `out_hourly` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = '' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `out_hourly` ON SCHEDULE EVERY 1 HOUR STARTS '2013-09-16 18:35:02' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'renumbering out_hourly table' DO BEGIN set @a=0; update out_hourly set id=(@a:=@a+1); ALTER TABLE out_hourly auto_increment = 1; END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `renumber_DYNAMIC_HTTP_IN` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = '' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `renumber_DYNAMIC_HTTP_IN` ON SCHEDULE EVERY 1 HOUR STARTS '2014-11-30 17:01:29' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'renumbering DYNAMIC_HTTP_IN table' DO BEGIN
SET @rownum = 0;update DYNAMIC_HTTP_IN SET Id = (@rownum:=@rownum+1) ORDER BY id; ALTER TABLE DYNAMIC_HTTP_IN auto_increment = 1;
END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
/*!50106 DROP EVENT IF EXISTS `RTBH_hourly_stats` */;;
DELIMITER ;;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;;
/*!50003 SET character_set_client  = utf8 */ ;;
/*!50003 SET character_set_results = utf8 */ ;;
/*!50003 SET collation_connection  = utf8_general_ci */ ;;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;;
/*!50003 SET sql_mode              = '' */ ;;
/*!50003 SET @saved_time_zone      = @@time_zone */ ;;
/*!50003 SET time_zone             = 'SYSTEM' */ ;;
/*!50106 CREATE*/ /*!50117 DEFINER=`root`@`localhost`*/ /*!50106 EVENT `RTBH_hourly_stats` ON SCHEDULE EVERY 1 DAY STARTS '2015-02-25 23:59:30' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
          INSERT INTO RTBH_stats (`ips_manual`,`hits_manual`, `ips_web`,`hits_web`, `ips_asm`,`hits_asm`, `ips_mail`,`hits_mail`, `ips_ftp`,`hits_ftp`) VALUES (
              (select count(1) from DYNAMIC_HTTP_IN where insertby NOT LIKE 'graylog%'),
              (select SUM(hits) from DYNAMIC_HTTP_IN where insertby NOT LIKE 'graylog%'),
              (select count(1) from DYNAMIC_HTTP_IN where insertby='graylog-web'),
              (select SUM(hits) from DYNAMIC_HTTP_IN where insertby='graylog-web'),

              (select count(1) from DYNAMIC_HTTP_IN where insertby='graylog-asm'),
              (select SUM(hits) from DYNAMIC_HTTP_IN where insertby='graylog-asm'),

              (select count(1) from DYNAMIC_HTTP_IN where insertby='graylog-mail'),
              (select SUM(hits) from DYNAMIC_HTTP_IN where insertby='graylog-mail'),

              (select count(1) from DYNAMIC_HTTP_IN where insertby='graylog-ftp'),
              (select SUM(hits) from DYNAMIC_HTTP_IN where insertby='graylog-ftp'));
END */ ;;
/*!50003 SET time_zone             = @saved_time_zone */ ;;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;;
/*!50003 SET character_set_client  = @saved_cs_client */ ;;
/*!50003 SET character_set_results = @saved_cs_results */ ;;
/*!50003 SET collation_connection  = @saved_col_connection */ ;;
DELIMITER ;
/*!50106 SET TIME_ZONE= @save_time_zone */ ;

--
-- Dumping routines for database 'dosportal'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-04-16 18:09:26
