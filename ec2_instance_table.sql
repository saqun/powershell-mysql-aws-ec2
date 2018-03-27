-- phpMyAdmin SQL Dump
-- version 4.6.4
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 25, 2018 at 08:15 PM
-- Server version: 5.7.14
-- PHP Version: 5.6.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `test`
--

-- --------------------------------------------------------

--
-- Table structure for table `ec2_instance_table`
--

CREATE TABLE `ec2_instance_table` (
  `ID` int(11) NOT NULL,
  `INSTANCE_NAME` varchar(255) NOT NULL,
  `DESCRIPTION` text NOT NULL,
  `CREATED_DATE` datetime NOT NULL,
  `CREATED_TIME` time NOT NULL,
  `CREATED_BY` varchar(255) NOT NULL,
  `AMI_ID` varchar(255) NOT NULL,
  `REGION` varchar(255) NOT NULL,
  `PUBLIC_IP` varchar(255) NOT NULL,
  `PUBLIC_DNS` varchar(255) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ec2_instance_table`
--

INSERT INTO `ec2_instance_table` (`ID`, `INSTANCE_NAME`, `DESCRIPTION`, `CREATED_DATE`, `CREATED_TIME`, `CREATED_BY`, `AMI_ID`, `REGION`, `PUBLIC_IP`, `PUBLIC_DNS`) VALUES
(22, 'i-0db6ef35c3aa4372c', 'AWS Instances', '2018-03-21 00:00:00', '12:09:59', 'Sakun', 'ami-38708c5a', 'ap-southeast-2', '13.211.188.89', 'ec2-13-211-188-89.ap-southeast-2.compute.amazonaws.com'),
(28, 'i-test4', 'AWS Instances', '2018-03-21 10:57:11', '09:57:11', 'Sakun', 'ami-38708c5a', 'ap-southeast-2', '13.210.44.210', 'ec2-13-210-44-210.ap-southeast-2.compute.amazonaws.com'),
(29, 'i-09e02583c0b1c91cc', 'AWS Instances', '2018-03-22 11:58:25', '11:58:25', 'Sakun', 'ami-38708c5a', 'ap-southeast-2', '13.210.68.129', 'ec2-13-210-68-129.ap-southeast-2.compute.amazonaws.com'),
(30, 'i-06fbf41d09b80f022', 'AWS Instances', '2018-03-22 19:20:22', '19:20:22', 'Sakun', 'ami-38708c5a', 'ap-southeast-2', '54.252.234.35', 'ec2-54-252-234-35.ap-southeast-2.compute.amazonaws.com'),
(31, 'i-0e0ba079107243a83', 'AWS Instances', '2018-03-23 09:13:18', '09:13:18', 'Sakun', 'ami-38708c5a', 'ap-southeast-2', '13.210.192.230', 'ec2-13-210-192-230.ap-southeast-2.compute.amazonaws.com');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ec2_instance_table`
--
ALTER TABLE `ec2_instance_table`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `ec2_instance_table`
--
ALTER TABLE `ec2_instance_table`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
