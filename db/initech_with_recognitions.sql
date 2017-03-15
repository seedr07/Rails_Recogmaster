-- MySQL dump 10.13  Distrib 5.1.39, for apple-darwin9.5.0 (i386)
--
-- Host: localhost    Database: recognize_dev
-- ------------------------------------------------------
-- Server version	5.1.39

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
-- Table structure for table `attachments`
--

DROP TABLE IF EXISTS `attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `owner_id` int(11) DEFAULT NULL,
  `owner_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attachments`
--

LOCK TABLES `attachments` WRITE;
/*!40000 ALTER TABLE `attachments` DISABLE KEYS */;
INSERT INTO `attachments` VALUES (1,NULL,'AvatarAttachment',8,'User','2013-01-18 02:44:09','2013-01-18 02:44:09'),(2,NULL,'AvatarAttachment',9,'User','2013-01-18 02:50:46','2013-01-18 02:50:46'),(3,NULL,'AvatarAttachment',10,'User','2013-01-18 02:50:46','2013-01-18 02:50:46'),(4,NULL,'AvatarAttachment',11,'User','2013-01-18 02:50:46','2013-01-18 02:50:46'),(5,NULL,'AvatarAttachment',12,'User','2013-01-18 02:50:46','2013-01-18 02:50:46'),(6,NULL,'AvatarAttachment',13,'User','2013-01-18 02:50:46','2013-01-18 02:50:46'),(7,NULL,'AvatarAttachment',14,'User','2013-01-18 02:50:46','2013-01-18 02:50:46'),(8,NULL,'AvatarAttachment',15,'User','2013-01-18 02:50:46','2013-01-18 02:50:46'),(9,NULL,'AvatarAttachment',16,'User','2013-01-18 02:50:46','2013-01-18 02:50:46'),(10,NULL,'AvatarAttachment',17,'User','2013-01-18 02:50:46','2013-01-18 02:50:46'),(11,NULL,'AvatarAttachment',18,'User','2013-01-18 02:50:46','2013-01-18 02:50:46'),(12,NULL,'AvatarAttachment',19,'User','2013-01-18 02:50:46','2013-01-18 02:50:46');
/*!40000 ALTER TABLE `attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `badges`
--

DROP TABLE IF EXISTS `badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `badges` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `short_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `long_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `badges`
--

LOCK TABLES `badges` WRITE;
/*!40000 ALTER TABLE `badges` DISABLE KEYS */;
INSERT INTO `badges` VALUES (1,'boss','Boss','Boss','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(2,'brilliant','Brilliant','Brilliant','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(3,'caring','Caring','Caring','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(4,'coffee_maker','Coffee maker','Coffee maker','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(5,'comedian','Comedian','Comedian','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(6,'cooperative','Cooperative','Cooperative','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(7,'creative','Creative','Creative','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(8,'detailed','Detailed','Detailed','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(9,'determined','Determined','Determined','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(10,'efficient','Efficient','Efficient','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(11,'friend','Friend','Friend','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(12,'fun','Fun','Fun','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(13,'honorable','Honorable','Honorable','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(14,'innovative','Innovative','Innovative','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(15,'leader','Leader','Leader','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(16,'listener','Listener','Listener','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(17,'on_track','On track','On track','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(18,'organized','Organized','Organized','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(19,'passionate','Passionate','Passionate','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(20,'peace_maker','Peace maker','Peace maker','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(21,'popular','Popular','Popular','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(22,'powerful','Powerful','Powerful','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(23,'problem_solver','Problem solver','Problem solver','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(24,'provider','Provider','Provider','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(25,'punctual','Punctual','Punctual','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(26,'responsive','Responsive','Responsive','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(27,'speaker','Speaker','Speaker','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(28,'speedy','Speedy','Speedy','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(29,'new_user','New user','New user','','2013-01-18 02:41:11','2013-01-18 02:41:11'),(30,'on_fire','On fire','On fire','','2013-01-18 02:41:11','2013-01-18 02:41:11');
/*!40000 ALTER TABLE `badges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `badges_tags`
--

DROP TABLE IF EXISTS `badges_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `badges_tags` (
  `badge_id` int(11) DEFAULT NULL,
  `tag_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `badges_tags`
--

LOCK TABLES `badges_tags` WRITE;
/*!40000 ALTER TABLE `badges_tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `badges_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `companies`
--

DROP TABLE IF EXISTS `companies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `companies` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `domain` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `slug` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_companies_on_slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `companies`
--

LOCK TABLES `companies` WRITE;
/*!40000 ALTER TABLE `companies` DISABLE KEYS */;
INSERT INTO `companies` VALUES (1,'Recognize App',NULL,'2013-01-18 02:41:22','2013-01-18 02:41:23','recognizeapp.com','recognizeapp'),(2,'Initech',NULL,'2013-01-18 02:42:37','2013-01-18 02:42:45','initech.com','initech');
/*!40000 ALTER TABLE `companies` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recognition_approvals`
--

DROP TABLE IF EXISTS `recognition_approvals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recognition_approvals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `giver_id` int(11) DEFAULT NULL,
  `recognition_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_recognition_approvals_on_giver_id` (`giver_id`),
  KEY `index_recognition_approvals_on_recognition_id` (`recognition_id`),
  KEY `index_recognition_approvals_on_giver_id_and_recognition_id` (`giver_id`,`recognition_id`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recognition_approvals`
--

LOCK TABLES `recognition_approvals` WRITE;
/*!40000 ALTER TABLE `recognition_approvals` DISABLE KEYS */;
INSERT INTO `recognition_approvals` VALUES (1,12,33,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(2,17,46,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(3,18,23,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(4,8,18,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(5,19,18,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(6,17,43,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(7,17,47,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(8,10,51,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(9,16,31,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(10,17,33,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(11,19,51,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(12,15,43,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(13,10,41,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(14,13,28,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(15,16,39,'2013-01-18 03:35:09','2013-01-18 03:35:09'),(16,11,37,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(17,12,49,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(18,12,27,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(19,17,30,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(20,18,7,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(21,19,9,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(22,15,34,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(23,17,9,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(24,9,20,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(25,19,22,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(26,11,8,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(27,9,18,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(28,9,42,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(29,11,27,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(30,19,3,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(31,18,6,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(32,11,6,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(33,8,4,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(34,11,16,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(35,14,20,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(36,13,22,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(37,9,13,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(38,16,49,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(39,8,37,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(40,13,34,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(41,11,39,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(42,15,6,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(43,12,35,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(44,19,19,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(45,11,52,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(46,18,41,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(47,13,12,'2013-01-18 03:35:10','2013-01-18 03:35:10'),(48,9,28,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(49,10,49,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(50,12,47,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(51,10,34,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(52,13,36,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(53,13,7,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(54,17,22,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(55,18,30,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(56,10,26,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(57,18,51,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(58,16,33,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(59,19,38,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(60,16,15,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(61,16,37,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(62,13,49,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(63,11,15,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(64,11,49,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(65,9,30,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(66,10,31,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(67,12,4,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(68,15,28,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(69,13,18,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(70,11,43,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(71,14,21,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(72,15,48,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(73,10,28,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(74,18,9,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(75,14,17,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(76,10,9,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(77,13,17,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(78,19,50,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(79,19,34,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(80,19,24,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(81,10,22,'2013-01-18 03:35:11','2013-01-18 03:35:11'),(82,16,5,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(83,14,7,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(84,9,52,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(85,15,26,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(86,8,44,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(87,15,18,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(88,15,7,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(89,13,43,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(90,15,44,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(91,16,21,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(92,17,18,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(93,15,50,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(94,14,28,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(95,19,26,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(96,10,40,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(97,18,19,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(98,10,12,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(99,11,10,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(100,14,25,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(101,17,37,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(102,11,41,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(103,13,15,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(104,14,41,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(105,8,38,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(106,18,28,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(107,19,16,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(108,8,8,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(109,19,4,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(110,16,12,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(111,15,52,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(112,16,45,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(113,12,23,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(114,14,33,'2013-01-18 03:35:12','2013-01-18 03:35:12'),(115,11,36,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(116,13,50,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(117,10,13,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(118,14,46,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(119,18,42,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(120,16,14,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(121,18,49,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(122,19,37,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(123,8,42,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(124,14,45,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(125,9,26,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(126,12,5,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(127,10,50,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(128,16,24,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(129,13,16,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(130,12,10,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(131,15,9,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(132,19,42,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(133,19,43,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(134,14,32,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(135,12,46,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(136,16,6,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(137,8,10,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(138,9,23,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(139,9,32,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(140,13,35,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(141,15,51,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(142,16,36,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(143,9,48,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(144,18,34,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(145,10,5,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(146,17,13,'2013-01-18 03:35:13','2013-01-18 03:35:13'),(147,18,37,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(148,15,14,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(149,11,13,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(150,9,36,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(151,8,29,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(152,13,30,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(153,11,40,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(154,18,39,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(155,8,46,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(156,8,13,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(157,8,5,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(158,17,26,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(159,16,40,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(160,14,30,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(161,17,40,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(162,19,10,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(163,13,39,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(164,16,11,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(165,17,48,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(166,12,44,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(167,10,35,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(168,8,33,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(169,14,39,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(170,11,14,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(171,16,4,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(172,14,34,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(173,8,50,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(174,12,7,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(175,16,10,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(176,8,6,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(177,14,36,'2013-01-18 03:35:14','2013-01-18 03:35:14'),(178,15,24,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(179,19,20,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(180,8,43,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(181,18,40,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(182,15,30,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(183,11,12,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(184,19,39,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(185,9,31,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(186,13,31,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(187,12,24,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(188,11,19,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(189,17,24,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(190,8,31,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(191,15,27,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(192,8,14,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(193,9,12,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(194,14,47,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(195,14,6,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(196,17,35,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(197,18,33,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(198,14,9,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(199,18,32,'2013-01-18 03:35:15','2013-01-18 03:35:15'),(200,12,19,'2013-01-18 03:35:15','2013-01-18 03:35:15');
/*!40000 ALTER TABLE `recognition_approvals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `recognitions`
--

DROP TABLE IF EXISTS `recognitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recognitions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `badge_id` int(11) DEFAULT NULL,
  `sender_id` int(11) DEFAULT NULL,
  `recipient_id` int(11) DEFAULT NULL,
  `recipient_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `company_id` int(11) DEFAULT NULL,
  `approvals_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_recognitions_on_badge_id` (`badge_id`),
  KEY `index_recognitions_on_sender_id` (`sender_id`),
  KEY `index_recognitions_on_recipient_id_and_recipient_type` (`recipient_id`,`recipient_type`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recognitions`
--

LOCK TABLES `recognitions` WRITE;
/*!40000 ALTER TABLE `recognitions` DISABLE KEYS */;
INSERT INTO `recognitions` VALUES (1,29,1,2,'User','Welcome to Recognize!','2013-01-18 02:41:23','2013-01-18 02:41:23',1,0),(2,29,1,8,'User','Welcome to Recognize!','2013-01-18 02:42:37','2013-01-18 02:42:37',2,0),(3,14,16,18,'User','The new contact page web design is out of this world. It is truly innotivate. Most assume a contact page is straightforward and requires no thought. You asked \"why\" about every detail. This evolved the contact page to be unlike any other. Wow! ','2013-01-18 03:35:05','2013-01-18 03:35:05',2,1),(4,15,14,17,'User','Happy fifth year anniversary! I just want to say, you\'ve made some great decisions and have led the company to many wins.','2013-01-18 03:35:05','2013-01-18 03:35:05',2,4),(5,5,15,11,'User','The laughs you through in the prospect dinner last night were spot on. I think we won the client!','2013-01-18 03:35:05','2013-01-18 03:35:05',2,4),(6,12,13,9,'User','In previous companies I haven\'t met an office manager with so much positivity and happiness. It really lifts everyone\'s spirits.','2013-01-18 03:35:05','2013-01-18 03:35:05',2,6),(7,21,17,19,'User','You got second place in number of likes on Yammer in 2012!','2013-01-18 03:35:05','2013-01-18 03:35:05',2,5),(8,28,18,14,'User','You came on board the project at 4pm, stayed in all night, and crushed so many bugs.','2013-01-18 03:35:05','2013-01-18 03:35:05',2,2),(9,19,12,13,'User','So much passion for the best practices. We need that.','2013-01-18 03:35:05','2013-01-18 03:35:05',2,6),(10,20,14,18,'User','You really helped calm the situation in the client meeting today. Your account management skills are unmatched.','2013-01-18 03:35:05','2013-01-18 03:35:05',2,5),(11,6,14,8,'User','I know how important this business is to you. You are the owner and I understand your passion. But when we sit down and duke out next steps, I am always amazing at your level of cooperation and your belief in my vision. Thanks again.','2013-01-18 03:35:06','2013-01-18 03:35:06',2,1),(12,11,18,14,'User','Working here I\'ve met a lot of great people. Thanks for being there for me at work and not at work.','2013-01-18 03:35:06','2013-01-18 03:35:06',2,5),(13,3,13,18,'User','Thanks for the recognition. It made my day :)\n\n','2013-01-18 03:35:06','2013-01-18 03:35:06',2,5),(14,1,17,18,'User','This past project has been such a treat. You really showed a lot of respect when I expressed my opinions. Thanks boss!','2013-01-18 03:35:06','2013-01-18 03:35:06',2,4),(15,3,19,15,'User','Thanks for the recognition. It made my day :)\n\n','2013-01-18 03:35:06','2013-01-18 03:35:06',2,3),(16,24,12,10,'User','The snacks you brought were delicious.','2013-01-18 03:35:06','2013-01-18 03:35:06',2,3),(17,26,17,18,'User','Always getting back to me on critical issues even on the weekend. For instance. last weekend I needed a special financial report. I knw you were away, but you responded via email anywhere and provided some data I could use right away unblocking me. Perfect! ','2013-01-18 03:35:06','2013-01-18 03:35:06',2,2),(18,3,14,11,'User','Before I had Blake, you helped me around the office. Thanks for being there for me.','2013-01-18 03:35:06','2013-01-18 03:35:06',2,6),(19,18,15,8,'User','The meeting you organized really went off well. Everything was laid out as planned. Thanks for being on target.','2013-01-18 03:35:06','2013-01-18 03:35:06',2,4),(20,3,11,16,'User','Before I had Blake, you helped me around the office. Thanks for being there for me.','2013-01-18 03:35:06','2013-01-18 03:35:06',2,3),(21,14,10,15,'User','The new contact page web design is out of this world. It is truly innotivate. Most assume a contact page is straightforward and requires no thought. You asked \"why\" about every detail. This evolved the contact page to be unlike any other. Wow! ','2013-01-18 03:35:06','2013-01-18 03:35:06',2,2),(22,7,15,18,'User','Today we launched our first quarterly report since going public. The design of the document is unreal. It matches the best of FFFFound and Dribbble. We couldn\'t have made it with your amazing creative touch. All the sections had a special feel to them. The typeface is just right for our new company spirit. Thanks again.','2013-01-18 03:35:06','2013-01-18 03:35:06',2,4),(23,7,16,14,'User','The new homepage design is amazing. The whole team really wants to thank you for providing all the quality work into the project.','2013-01-18 03:35:06','2013-01-18 03:35:06',2,3),(24,24,9,8,'User','The snacks you brought were delicious.','2013-01-18 03:35:06','2013-01-18 03:35:06',2,5),(25,19,9,16,'User','So much passion for the best practices. We need that.','2013-01-18 03:35:06','2013-01-18 03:35:06',2,1),(26,14,13,11,'User','The new contact page web design is out of this world. It is truly innotivate. Most assume a contact page is straightforward and requires no thought. You asked \"why\" about every detail. This evolved the contact page to be unlike any other. Wow! ','2013-01-18 03:35:06','2013-01-18 03:35:06',2,5),(27,26,13,9,'User','Always getting back to me on critical issues even on the weekend. For instance. last weekend I needed a special financial report. I knw you were away, but you responded via email anywhere and provided some data I could use right away unblocking me. Perfect! ','2013-01-18 03:35:06','2013-01-18 03:35:06',2,3),(28,19,8,12,'User','So much passion for the best practices. We need that.','2013-01-18 03:35:06','2013-01-18 03:35:06',2,6),(29,19,18,9,'User','So much passion for the best practices. We need that.','2013-01-18 03:35:06','2013-01-18 03:35:06',2,1),(30,9,16,8,'User','How many press releases did you come up with last night? You were an animal!','2013-01-18 03:35:07','2013-01-18 03:35:07',2,6),(31,4,12,19,'User','Thanks for the coffee at Blue Bottle today!\n\n','2013-01-18 03:35:07','2013-01-18 03:35:07',2,5),(32,27,15,8,'User','At the West Conf in Chicago, your presentation was impressive. How many twitter followers did you get from that? :) ','2013-01-18 03:35:07','2013-01-18 03:35:07',2,3),(33,3,9,11,'User','Thanks for the recognition. It made my day :)\n\n','2013-01-18 03:35:07','2013-01-18 03:35:07',2,6),(34,9,11,9,'User','How many press releases did you come up with last night? You were an animal!','2013-01-18 03:35:07','2013-01-18 03:35:07',2,6),(35,13,8,18,'User','When we were faced with a difficult decision with the recent client work, it took guts when you chose to go with ABC Company.','2013-01-18 03:35:07','2013-01-18 03:35:07',2,4),(36,20,17,18,'User','You really helped calm the situation in the client meeting today. Your account management skills are unmatched.','2013-01-18 03:35:07','2013-01-18 03:35:07',2,5),(37,21,9,13,'User','You got second place in number of likes on Yammer in 2012!','2013-01-18 03:35:07','2013-01-18 03:35:07',2,6),(38,24,17,14,'User','Thanks for the beer this afternoon :)','2013-01-18 03:35:07','2013-01-18 03:35:07',2,2),(39,6,8,17,'User','I know how important this business is to you. You are the owner and I understand your passion. But when we sit down and duke out next steps, I am always amazing at your level of cooperation and your belief in my vision. Thanks again.','2013-01-18 03:35:07','2013-01-18 03:35:07',2,6),(40,12,9,13,'User','In previous companies I haven\'t met an office manager with so much positivity and happiness. It really lifts everyone\'s spirits.','2013-01-18 03:35:07','2013-01-18 03:35:07',2,5),(41,18,17,12,'User','The meeting you organized really went off well. Everything was laid out as planned. Thanks for being on target.','2013-01-18 03:35:07','2013-01-18 03:35:07',2,4),(42,7,11,13,'User','The new homepage design is amazing. The whole team really wants to thank you for providing all the quality work into the project.','2013-01-18 03:35:07','2013-01-18 03:35:07',2,4),(43,4,16,18,'User','Thanks for the coffee at Blue Bottle today!\n\n','2013-01-18 03:35:07','2013-01-18 03:35:07',2,6),(44,15,14,16,'User','Happy fifth year anniversary! I just want to say, you\'ve made some great decisions and have led the company to many wins.','2013-01-18 03:35:07','2013-01-18 03:35:07',2,3),(45,7,18,10,'User','Today we launched our first quarterly report since going public. The design of the document is unreal. It matches the best of FFFFound and Dribbble. We couldn\'t have made it with your amazing creative touch. All the sections had a special feel to them. The typeface is just right for our new company spirit. Thanks again.','2013-01-18 03:35:07','2013-01-18 03:35:07',2,2),(46,20,11,9,'User','You really helped calm the situation in the client meeting today. Your account management skills are unmatched.','2013-01-18 03:35:07','2013-01-18 03:35:07',2,4),(47,19,15,19,'User','So much passion for the best practices. We need that.','2013-01-18 03:35:07','2013-01-18 03:35:07',2,3),(48,27,8,18,'User','At the West Conf in Chicago, your presentation was impressive. How many twitter followers did you get from that? :) ','2013-01-18 03:35:07','2013-01-18 03:35:07',2,3),(49,9,8,14,'User','How many press releases did you come up with last night? You were an animal!','2013-01-18 03:35:07','2013-01-18 03:35:07',2,6),(50,1,17,18,'User','This past project has been such a treat. You really showed a lot of respect when I expressed my opinions. Thanks boss!','2013-01-18 03:35:08','2013-01-18 03:35:08',2,5),(51,15,12,13,'User','Happy fifth year anniversary! I just want to say, you\'ve made some great decisions and have led the company to many wins.','2013-01-18 03:35:08','2013-01-18 03:35:08',2,4),(52,14,16,13,'User','The new contact page web design is out of this world. It is truly innotivate. Most assume a contact page is straightforward and requires no thought. You asked \"why\" about every detail. This evolved the contact page to be unlike any other. Wow! ','2013-01-18 03:35:08','2013-01-18 03:35:08',2,3);
/*!40000 ALTER TABLE `recognitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'admin','2013-01-18 02:41:10','2013-01-18 02:41:10'),(2,'company_admin','2013-01-18 02:41:10','2013-01-18 02:41:10'),(3,'team_leader','2013-01-18 02:41:10','2013-01-18 02:41:10'),(4,'employee','2013-01-18 02:41:10','2013-01-18 02:41:10'),(5,'system_user','2013-01-18 02:41:10','2013-01-18 02:41:10');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20120619021221'),('20120619022926'),('20120626060824'),('20120626061139'),('20120626061458'),('20120626064433'),('20120626064902'),('20120626065209'),('20120626070306'),('20120701011144'),('20120708065427'),('20120708092845'),('20120708111807'),('20120714190837'),('20120714190956'),('20120714193338'),('20120723004648'),('20120909011322'),('20120909040537'),('20120909203556'),('20120913073242'),('20120919054149'),('20120924213316'),('20120927205653'),('20121004083739'),('20121005061748'),('20121005221338'),('20121007052802'),('20121007111235'),('20121009063031'),('20121009201337'),('20121011013334'),('20121109042239'),('20121111110707'),('20121112170553'),('20121112171527'),('20121112175818'),('20121129205713'),('20121203044846'),('20121206050955');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `data` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES (1,'489979b9499371ee7703fe4adaee95cf','BAh7CUkiEF9jc3JmX3Rva2VuBjoGRUZJIjFhblBnczZNbk51dEJBS0ExdmdG\nZ0liRlQ5RFJSRExNcWhlWWdwRlZtWXlFPQY7AEZJIhV1c2VyX2NyZWRlbnRp\nYWxzBjsARkkiAYAzMzA4MzA4MzFjYzI2ZTJlNmY0ZmRkOTZlNTlkN2YxYjg4\nNDhmMDc4MzVmMDg0Nzc4MWJkMTdiYmJjOWM3ZDczZDU2YzAwOTg4MmM1NGNl\nMTlkNzMyNTgzMGRlYjYzNzUyNTYwYTVkZDg5ODM3MzkzYTExNjg5MjEwODRj\nYzUyMAY7AFRJIhh1c2VyX2NyZWRlbnRpYWxzX2lkBjsARmkNSSIKZW1haWwG\nOwBGSSIfbWlsdG9uLndhZGRhbXNAaW5pdGVjaC5jb20GOwBU\n','2013-01-18 02:41:50','2013-01-18 02:48:46'),(2,'d8579dc8d237451ccbcc7ce27ab57d8c','BAh7B0kiEF9jc3JmX3Rva2VuBjoGRUZJIjF4Ukl4UVhLeGJqbEtMTlZ2TXNE\nOHhuODVxa0hvOHFBUkRQZHdwcU8yQ0RjPQY7AEZJIgpmbGFzaAY7AEZvOiVB\nY3Rpb25EaXNwYXRjaDo6Rmxhc2g6OkZsYXNoSGFzaAk6CkB1c2VkbzoIU2V0\nBjoKQGhhc2h7BjoLbm90aWNlVDoMQGNsb3NlZEY6DUBmbGFzaGVzewY7Ckki\nHVN1Y2Nlc3NmdWxseSBsb2dnZWQgb3V0LgY7AEY6CUBub3cw\n','2013-01-18 02:48:59','2013-01-18 02:51:01'),(3,'32805f33018f50cf24081b3c492827af','BAh7CEkiFXVzZXJfY3JlZGVudGlhbHMGOgZFRkkiAYAzMzA4MzA4MzFjYzI2\nZTJlNmY0ZmRkOTZlNTlkN2YxYjg4NDhmMDc4MzVmMDg0Nzc4MWJkMTdiYmJj\nOWM3ZDczZDU2YzAwOTg4MmM1NGNlMTlkNzMyNTgzMGRlYjYzNzUyNTYwYTVk\nZDg5ODM3MzkzYTExNjg5MjEwODRjYzUyMAY7AFRJIhh1c2VyX2NyZWRlbnRp\nYWxzX2lkBjsARmkNSSIQX2NzcmZfdG9rZW4GOwBGSSIxYU5lMmJZT01IVk90\nSFpTU0FRUDNYUDZjam0yeDdKMVp0c2xnd3JjR3BkRT0GOwBG\n','2013-01-18 03:02:22','2013-01-18 03:02:40');
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `signup_requests`
--

DROP TABLE IF EXISTS `signup_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `signup_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pricing` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `signup_requests`
--

LOCK TABLES `signup_requests` WRITE;
/*!40000 ALTER TABLE `signup_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `signup_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `support_emails`
--

DROP TABLE IF EXISTS `support_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `support_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_emails`
--

LOCK TABLES `support_emails` WRITE;
/*!40000 ALTER TABLE `support_emails` DISABLE KEYS */;
/*!40000 ALTER TABLE `support_emails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `company_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teams`
--

LOCK TABLES `teams` WRITE;
/*!40000 ALTER TABLE `teams` DISABLE KEYS */;
INSERT INTO `teams` VALUES (1,1,'Marketing','2013-01-18 02:41:22','2013-01-18 02:41:22'),(2,1,'Human Resources','2013-01-18 02:41:22','2013-01-18 02:41:22'),(3,1,'Engineering','2013-01-18 02:41:22','2013-01-18 02:41:22'),(4,1,'Sales','2013-01-18 02:41:22','2013-01-18 02:41:22'),(5,1,'IT','2013-01-18 02:41:22','2013-01-18 02:41:22'),(6,2,'Marketing','2013-01-18 02:42:37','2013-01-18 02:42:37'),(7,2,'Human Resources','2013-01-18 02:42:37','2013-01-18 02:42:37'),(8,2,'Engineering','2013-01-18 02:42:37','2013-01-18 02:42:37'),(9,2,'Sales','2013-01-18 02:42:37','2013-01-18 02:42:37'),(10,2,'IT','2013-01-18 02:42:37','2013-01-18 02:42:37');
/*!40000 ALTER TABLE `teams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES (3,1,5,'2013-01-18 02:41:23','2013-01-18 02:41:23'),(4,2,4,'2013-01-18 02:41:23','2013-01-18 02:41:23'),(5,2,2,'2013-01-18 02:41:23','2013-01-18 02:41:23'),(6,3,4,'2013-01-18 02:41:23','2013-01-18 02:41:23'),(7,4,4,'2013-01-18 02:41:23','2013-01-18 02:41:23'),(8,5,4,'2013-01-18 02:41:23','2013-01-18 02:41:23'),(9,6,4,'2013-01-18 02:41:23','2013-01-18 02:41:23'),(10,7,4,'2013-01-18 02:41:23','2013-01-18 02:41:23'),(11,2,1,'2013-01-18 02:41:23','2013-01-18 02:41:23'),(12,3,1,'2013-01-18 02:41:23','2013-01-18 02:41:23'),(13,3,2,'2013-01-18 02:41:23','2013-01-18 02:41:23'),(14,8,4,'2013-01-18 02:42:37','2013-01-18 02:42:37'),(15,8,2,'2013-01-18 02:42:37','2013-01-18 02:42:37'),(16,9,4,'2013-01-18 02:47:48','2013-01-18 02:47:48'),(17,10,4,'2013-01-18 02:47:48','2013-01-18 02:47:48'),(18,11,4,'2013-01-18 02:47:48','2013-01-18 02:47:48'),(19,12,4,'2013-01-18 02:47:48','2013-01-18 02:47:48'),(20,13,4,'2013-01-18 02:47:48','2013-01-18 02:47:48'),(21,14,4,'2013-01-18 02:47:48','2013-01-18 02:47:48'),(22,15,4,'2013-01-18 02:47:48','2013-01-18 02:47:48'),(23,16,4,'2013-01-18 02:47:49','2013-01-18 02:47:49'),(24,17,4,'2013-01-18 02:47:49','2013-01-18 02:47:49'),(25,18,4,'2013-01-18 02:47:49','2013-01-18 02:47:49'),(26,19,4,'2013-01-18 02:47:49','2013-01-18 02:47:49');
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_sessions`
--

LOCK TABLES `user_sessions` WRITE;
/*!40000 ALTER TABLE `user_sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_teams`
--

DROP TABLE IF EXISTS `user_teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_teams` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `team_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_teams`
--

LOCK TABLES `user_teams` WRITE;
/*!40000 ALTER TABLE `user_teams` DISABLE KEYS */;
INSERT INTO `user_teams` VALUES (2,8,10,'2013-01-18 02:43:46','2013-01-18 02:43:46'),(3,8,9,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(4,8,6,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(5,8,7,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(6,9,6,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(7,9,7,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(8,9,8,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(9,9,10,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(10,9,9,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(11,10,10,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(12,10,7,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(13,10,9,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(14,11,7,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(15,11,9,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(16,11,6,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(17,11,10,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(18,12,9,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(19,12,7,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(20,12,8,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(21,12,6,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(22,13,9,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(23,14,6,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(24,14,10,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(25,14,9,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(26,14,8,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(27,14,7,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(28,15,7,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(29,15,9,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(30,15,6,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(31,15,10,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(32,16,9,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(33,16,8,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(34,16,6,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(35,16,7,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(36,16,10,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(37,17,9,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(38,17,8,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(39,17,10,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(40,17,6,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(41,18,8,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(42,18,9,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(43,18,6,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(44,18,10,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(45,19,6,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(46,19,8,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(47,19,9,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(48,19,10,'2013-01-18 03:05:56','2013-01-18 03:05:56'),(49,19,7,'2013-01-18 03:05:56','2013-01-18 03:05:56');
/*!40000 ALTER TABLE `user_teams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `first_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `company_id` int(11) DEFAULT NULL,
  `bio` text COLLATE utf8_unicode_ci,
  `crypted_password` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password_salt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `persistence_token` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `perishable_token` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `invited_by_id` int(11) DEFAULT NULL,
  `invited_at` datetime DEFAULT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `slug` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `job_title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `received_recognitions_count` int(11) DEFAULT '0',
  `sent_recognitions_count` int(11) DEFAULT '0',
  `given_recognition_approvals_count` int(11) DEFAULT '0',
  `total_points` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_users_on_slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Recognize','App','app@recognizeapp.com',1,NULL,NULL,NULL,NULL,'2013-01-18 02:41:22','2013-01-18 02:42:37','N9RK6vH4N2uRyfQYM1fn',NULL,NULL,NULL,NULL,'app',NULL,0,2,0,4),(2,'Alex','Grande','alex@recognizeapp.com',1,NULL,'972543ea6c1e510c3c90555c7dfa03730cea701abf88821bd393a9e54d12c2b6098905a8a7bbcebe77dbd68448e2daf3766b9a1af581b466950061856707650a','Ckbzp41dqqfaXAzR1qe2','4692e3723b4eb590dc3cf76415ed2100e60b7870a10424af33dea5b31c2a281c416e79c7d526a8108e413b3c51d2c95236617fad0ac8fd186acb2c5667679251','2013-01-18 02:41:23','2013-01-18 02:41:23','MO43L8lDcPftriWTFqu',NULL,NULL,'active','2013-01-18 02:41:23','alex',NULL,1,0,0,0),(3,'Peter','Philips','peter@recognizeapp.com',1,NULL,'132dd257915ea1cd38799cc1524c707b4a53f29ca85aef35d15f6c25c3fb0253408a1e584228462e10bb9516c0eb06f7d52336eba9efdd00e99f0169bbad6860','dT24OTg3rw6NghlhPgE','ff56464dbe78a37f28721d1c4d1a12d480db0a81e66fad39c1dacd799e3df43aeac899c737b264ce7ca00296593ded6221054a9df40a2ce42d91f005733012a8','2013-01-18 02:41:23','2013-01-18 02:41:23','onTpSXAx9jEe1dldEm87',NULL,NULL,'active','2013-01-18 02:41:23','peter',NULL,0,0,0,0),(4,'Kate','Cohen','kate@recognizeapp.com',1,NULL,'204fb18330f4cf6e1ae675a3b3de84b2caf4c8f6c7fd01c455f420eaccd7be5d2be3c91138ef72edd99d1bfebe9e3d0da6d95be1cef2901822f3d6cb3057de74','PxjBfVcBggVnNeWkfK1','00c555180d27b9a79c3a6b823e45cf20746b95ec8eb6630b7f64eb81501b34347306bc88f824dd0ac98a46f07736b5b025d37d43fd7757326d26e5805bb3d0bf','2013-01-18 02:41:23','2013-01-18 02:41:23','rXezf0iGEc8FJPg61W',NULL,NULL,'active','2013-01-18 02:41:23','kate',NULL,0,0,0,0),(5,'Martin','Karasek','martin@recognizeapp.com',1,NULL,'a499bf4aa8ea8c8e4c51e8080ce9e19c9f71c728d9d710f409989e9676a09a8433c6bebb38d3f2d9dacb660c441ac219141f361ca1c3e228e20210cccd19477a','QkV1Jnq5UDRKj1qMZQtj','70518dc9632069b6893d3cacef86815c7f92e5b25e97bd8b826c817ad190122411c33325633c8ee7f1509c606a74b26242206410fe591e9f63ca8eb1cdd0110f','2013-01-18 02:41:23','2013-01-18 02:41:23','eYO7ogSw7USql1xRP7t',NULL,NULL,'active','2013-01-18 02:41:23','martin',NULL,0,0,0,0),(6,'Howard','Wong','howie@recognizeapp.com',1,NULL,'8b3df613ed4f57ff3b6996a80e5feab0d4ea45cc8d49371199d2bea5f84b19ed999291beddb9b9a6c2018244273654ce069ad1417ec18f316ab9d6ea7cb42d39','SkFotEif2jrIFGotQ4N','24b94bb70cd205d4c65a8021fd186f711b9140967a3fe25a346a69001cd1b620e3b00a5854a8c133da1667148bffbd717301e1fb605a5f4a99d4d54ba7b4e8c0','2013-01-18 02:41:23','2013-01-18 02:41:23','bkbcnLAfrj9x1WlPCc7N',NULL,NULL,'active','2013-01-18 02:41:23','howie',NULL,0,0,0,0),(7,'Pavel','Ma&#269;ek','pavel@recognizeapp.com',1,NULL,'1191f9c10f79a45371e8f4fcac2aafed7cd0a797beabfea69b065da4c4123239c46759bab4c110a007994c065a364b7566a9489f97e876b1c4b006e7d09541aa','ggVy6q8Zkq1qdm8neoK3','23632086b60a9606d1007f9882300e1a574006d63d32663c218b0c1dd780f6e49d74ee8249d4d4300c1f7c0b9a50a505c11addd4ac2f34f16de3f041d6405003','2013-01-18 02:41:23','2013-01-18 02:41:23','OoTXLUsY4GgruAVkKQbQ',NULL,NULL,'active','2013-01-18 02:41:23','pavel',NULL,0,0,0,0),(8,'Ron ','Livingston','rlivingston@initech.com',2,NULL,'c0decf1e3a6ef4a79b2d9f67f817b2fe2d7adf3187163d7b60a2b77b60a25c06bb2e68f649878f7f4f12e95edda8fa7d4d5d60fe5a863491119d4e2ed5838278','mdbxDTWTABpVowHmUsMN','330830831cc26e2e6f4fdd96e59d7f1b8848f07835f0847781bd17bbbc9c7d73d56c009882c54ce19d7325830deb63752560a5dd89837393a1168921084cc520','2013-01-18 02:42:37','2013-01-18 03:35:15','zlHdVHlkpssWX3SGlrB',NULL,NULL,'active','2013-01-18 02:44:22','rlivingston','',6,5,18,183),(9,'Jenn','Anistown','jenn.anistown@initech.com',2,NULL,'4eb43ceed8c964cd49192eed7af4d5c575ec75e530e12454cd03fe467e4b924510d63e261d7044cd76e513796884839c15eabccb44273cf76814fd154d76898f','819MJokXv41b0r1nk4t8','37f94fe0151af5523d382e50467d8bd2ab52b0a952426f53b3e5b5c216f64fa8702cd6c8149c7884cec6572619af8519b7ed1e3e733fc24f5488471b76e0ac98','2013-01-18 02:47:48','2013-01-18 03:35:15','tPrHs7WZ3PymhsXFmL',8,'2013-01-18 02:47:48','active','2013-01-18 02:48:03','jenn-anistown',NULL,5,5,14,174),(10,'David','Herman','david.herman@initech.com',2,NULL,'da93897ca1de7efa71c3f835fca6c70158b3319cbb239ad05a545da6210274982197305e667c05cb82ec4e764b417cbaf854d5571dc0540d1d13c26108e7a63a','N5bL9phvVL3W9dJf8C2','46201ef1099dea9f81078adaa5ad94ec92168673eb892c8018b53dbdf19d4e0072860a9d75f502c44af95518de35bb47600ebe85de3991f50ac7aabae88cb6a8','2013-01-18 02:47:48','2013-01-18 03:35:14','oJFmE7Nd1DCMONnDA3VY',8,'2013-01-18 02:47:48','active','2013-01-18 02:48:14','david-herman',NULL,2,1,15,62),(11,'Ajay','Naidu','ajay.naidu@initech.com',2,NULL,'1a8e87c3cfcd03bc68abe8ee321df6e552db07314b54f307032322ed45975023391a064bd0dd87c5e366272ff03573696bdf6c372b597aa934d31513c623dce8','StFV0lTWxoIcMCVashD','41da209c1be3d8b534cd7dcc519f22113058cad6b8158cf42d0a3bb72a0097d1c82d64f6f230f37a1d9d3aa934638d9c7d2c04324f5ca92b51c7b575e5f59ff1','2013-01-18 02:47:48','2013-01-18 03:35:15','MkuOCG24fdx4KHxLN3RW',8,'2013-01-18 02:47:48','active','2013-01-18 02:48:23','ajay-naidu',NULL,4,4,18,171),(12,'Diedrich','Bader','diedrich.bader@initech.com',2,NULL,'75fbcba1a45a274949581b5ca79dac5b691d34bc2c1e3f3899566f2b808e7d621bda034e10234919232842194880d4ec849206a981f29a2f6f72262495a1d883','3VOfXu6RQi1KFSBft20v','60d3defb3b7ac2990b6cc889acfdac3e4bc93a3216ba1a4a80e8ae6d6e2e9806c2f74888a51461b4f687220ed97c9b244a2aa62847222a5aafdb2cd50aae34e9','2013-01-18 02:47:48','2013-01-18 03:35:15','5DMNUT2Hx39c5xQronR',8,'2013-01-18 02:47:48','active','2013-01-18 02:48:28','diedrich-bader',NULL,2,4,14,92),(13,'Alexandra','Wentworth','alexandra.wentworth@initech.com',2,NULL,'50559110720305ac46dc4be58baf7ec18a9fc9067d6304cab42194f225d5b84dcfe9e805f8169270186ffecf666f9a4db674a93c0900359214dc9eb734b6a28f','JnMtJPiLSffKzfwReIaG','ed81e824b5ae88914d22680e51239c03566640c2dcba7fca51cdbdf8a93717fcdcc1c6d17d6e081eead4b15cc9e1e178f8563d68f13e2368f8b15b30283a2e64','2013-01-18 02:47:48','2013-01-18 03:35:15','aOl0wgNynRd4Xpq3mYn1',8,'2013-01-18 02:47:48','active','2013-01-18 02:48:30','alexandra-wentworth',NULL,6,4,17,225),(14,'Kinna','Mcinroe','kinna.mcinroe@initech.com',2,NULL,'a02dae43e61ad171913c6ff0307090a285c823ae85000a23610cb4c71f963c00eecb0e3eec430102b8e53f7cadc0945e4e1b8d971caf1b711941591f2527876f','tZ0PGwfp1PgetYtcOO1','a11840336bf09cefac59b56bb2f1cc05776476aad35914e8a42e82f3a6e70d09e87b3c67c71041e02b44cbcb2ff1d9000cc45e4df6438e8bfd0143d79c541ba9','2013-01-18 02:47:48','2013-01-18 03:35:15','9eeM2zGAz7NZVcOSkop',8,'2013-01-18 02:47:48','active','2013-01-18 02:48:33','kinna-mcinroe',NULL,5,5,18,168),(15,'Greg','Pitts','greg.pitts@initech.com',2,NULL,'26a236df15472ace9ab4001682f4b5337545cd46701ce06ed7096e95ab5cd180391a155ec04fc29cd0e651f01f2ef996b1e7ee3b8657451da6ba525a30bcbaef','LQFTuNlUNPRnOMieBA','7f7a999ebe77b1f3171a0186412e66828be2d1aff8eab9eec0aebec60740371407545cda75892ba43f82e002e525de1fa779328ee7c9d70379adc2c5cb12502c','2013-01-18 02:47:48','2013-01-18 03:35:15','niB88tvV0TKO1w9uFqMX',8,'2013-01-18 02:47:48','active','2013-01-18 02:48:36','greg-pitts',NULL,2,5,17,72),(16,'Peter','Gibbons','peter.gibbons@initech.com',2,NULL,'b134bc4cc1aae5cb2645439c60e9c622c5c21c16a581ae6b9dcd2d9c53cb2ed6d8db82d3138bdfd9d2580737cd657ae7db0813f217ae367edc99b7de9814c3a0','G6NNT06egjJu9DrxdXKa','7b54c0665ea90df9e94bc5a8fd61c09e10c54aaa8d014a1dcdf856f06bf4477bd67740e4704539d9c39df6595fa608efd45301bc49d19f7fffd4addaf08ab459','2013-01-18 02:47:49','2013-01-18 03:35:15','6Phf5tpnk5tIAHp0GFXD',8,'2013-01-18 02:47:49','active','2013-01-18 02:48:38','peter-gibbons',NULL,3,5,18,93),(17,'Samir','Nagheenanajar','samir.nagheenanajar@initech.com',2,NULL,'6d7a6726a021284c58d28e311f0d347793ceaea726a06c991da1a827c863cef226c9b030c8db20c76fbde86356519f2d19a689f63b5a3cdb8975d3382091adf7','cCpFmNV9AHXC9P7qWeF2','56ded0413e9ef865cd7926f6ce6a721cd59b4f5ddd686ba95f6786a9bec7ea4dc6340942d4804863d852e4fe3b52fbadc21ee9396bb491a9fb04d7a215737e05','2013-01-18 02:47:49','2013-01-18 03:35:15','rAmlHDJWfaTWroyUWP8B',8,'2013-01-18 02:47:49','active','2013-01-18 02:48:41','samir-nagheenanajar',NULL,2,7,15,99),(18,'Bill','Lumbergh','bill.lumbergh@initech.com',2,NULL,'dc038aa6e81ea8dc808868dd25297a6b495bd8ef35a335c849209f8e995e8a8260f701ee0fed7b8ac7dc824b031e1abb4e17d335ab230cf4b3b593068df647e4','EYZGwBVNfcVnt1BdYH6','2f1484e7b1e709fbfc3c3725e0fb328bd99303371f2acdf1c12a12117ee1db9926524e8665fb9e8f1fc9a035f39484048cf057c2c3f4991b76c0c8574797de08','2013-01-18 02:47:49','2013-01-18 03:35:15','ZVf6IXIGTgUWuhjyNTHD',8,'2013-01-18 02:47:49','active','2013-01-18 02:48:44','bill-lumbergh',NULL,11,4,17,355),(19,'Milton','Waddams','milton.waddams@initech.com',2,NULL,'9a33fbf26160065a649fe4cdd8c68e180beafc7989f3d6782cc6fbfde6ec1cc02e64a647c11b5dc3075df3aef699e95ca509267a23954983d037588dbbd85ed8','DzjxfVSvBkShauCzK8u','79a0e2bc79778f0cd199f6bd56e638a524e3ad5806ba5b2665de22ed60f96e1375e8f0cb5288f2c29d1c4ebba6e79acaa4b1b1420409571d13a7b7a979da31f0','2013-01-18 02:47:49','2013-01-18 03:35:15','ckXfAdrwK55NuZfI2iy',8,'2013-01-18 02:47:49','active','2013-01-18 02:48:46','milton-waddams',NULL,3,1,19,116);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-01-17 19:36:18
