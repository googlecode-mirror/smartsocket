-- phpMyAdmin SQL Dump
-- version 3.1.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jun 30, 2009 at 08:47 AM
-- Server version: 5.1.30
-- PHP Version: 5.2.8

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `smartlobby`
--

-- --------------------------------------------------------

--
-- Table structure for table `rooms`
--

CREATE TABLE IF NOT EXISTS `rooms` (
  `name` varchar(255) DEFAULT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'lobby',
  `password` varchar(255) DEFAULT NULL,
  `id` int(255) NOT NULL AUTO_INCREMENT,
  `owner` varchar(12) NOT NULL DEFAULT '__SERVER__',
  `max_count` int(2) NOT NULL DEFAULT '16',
  `count` int(2) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

--
-- Dumping data for table `rooms`
--

INSERT INTO `rooms` (`name`, `type`, `password`, `id`, `owner`, `max_count`, `count`) VALUES
('Main Lobby', 'lobby', '', 1, '__SERVER__', 16, 0),
('Private Chat', 'chat', 'smartlobby', 2, '__SERVER__', 16, 0),
('Test Game', 'game', '', 3, '__SERVER__', 16, 0);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `username` varchar(12) NOT NULL,
  `password` varchar(255) NOT NULL,
  `id` int(255) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `users`
--


-- --------------------------------------------------------

--
-- Table structure for table `users_online`
--

CREATE TABLE IF NOT EXISTS `users_online` (
  `username` varchar(12) NOT NULL,
  `socket_id` varchar(255) NOT NULL,
  `ip_address` varchar(255) NOT NULL,
  `room` int(255) NOT NULL,
  `id` int(255) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

--
-- Dumping data for table `users_online`
--

INSERT INTO `users_online` (`username`, `socket_id`, `ip_address`, `room`, `id`) VALUES
('hh', 'Resource id #15', '', 0, 1),
('asd', 'Resource id #47', '', 0, 2),
('sdf', 'Resource id #15', '', 0, 3),
('dfg', 'Resource id #20', '', 0, 4),
('dfg', 'Resource id #25', '', 0, 5);
