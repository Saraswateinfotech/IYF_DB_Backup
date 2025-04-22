-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Apr 22, 2025 at 05:03 AM
-- Server version: 10.11.10-MariaDB-log
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u640280979_iyfdashboard`
--
-- --------------------------------------------------------

--
-- Table structure for table `group_migration`
--

CREATE TABLE `group_migration` (
  `migrationId` int(11) NOT NULL,
  `migrationDateTime` datetime NOT NULL DEFAULT current_timestamp(),
  `devoteeId` int(11) NOT NULL,
  `priviousGroup` varchar(50) DEFAULT NULL,
  `currentGroup` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `iyfdashboardAccounts`
--

CREATE TABLE `iyfdashboardAccounts` (
  `id` int(11) NOT NULL,
  `user_id` varchar(50) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone_number` varchar(15) NOT NULL,
  `password` varchar(255) NOT NULL,
  `textpassword` text NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `role` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `iyfdashboardAccounts`
--

INSERT INTO `iyfdashboardAccounts` (`id`, `user_id`, `name`, `email`, `phone_number`, `password`, `textpassword`, `created_at`, `role`) VALUES
(12, 'HHX372882', 'HG Hari Bhakti Prji', 'HH.hh@example.com', '9000054321', '$2b$10$CwD6nra7nDRi1eLpz/HBVOikatV/AgG99SG/XuX0NewXvUf5fSfeG', 'Admin@HHG123', '2025-03-26 19:34:20', 'admin'),
(37, 'HG604238', 'HG Mohan Murari Prji', 'mohit193@gmail.com', '8956231470', '$2b$10$vtW3MPuypKQ.bZS5acNh4uw5.kP02phLsJCMfVOW.sl8kUmyhRxrK', 'mohit193', '2025-04-14 07:48:55', 'facilitator'),
(38, 'HG938474', 'HG Naveen Narad Prij', 'naveen23@gmail.com', '8956231460', '$2b$10$Dq/B0qwQZWfVnEU5BNTnVuXiUjxFKScjZTNq0oUArh/DSFKrS9oxC', 'naveen123@g', '2025-04-14 07:57:24', 'facilitator'),
(39, 'HG433572', 'Hg Avinashi Govind Prji', 'govind23@gamil.com', '7894561231', '$2b$10$ft6MC3j2vxwTGMYidyzjwuUD7wX//EL4RiT6NG2hsmBhQ9/kU2wqq', 'govind@90', '2025-04-14 08:00:32', 'Coordinator'),
(40, 'HGV442127', 'HGVishudh Parth Prji', 'parth99@gamil.com', '9214381627', '$2b$10$8yBaJarq5Fo.jGhs3yyx.O23d2LznHZvc0BWWd.pcfzRbCrLRPJzu', 'parth999', '2025-04-14 08:02:08', 'facilitator'),
(41, 'HGD586232', 'HGDev krishna prji ', 'krishna@gmail.com', '9214381620', '$2b$10$OBptpMZFpKRswlmJ8Q7tteNOeZrSkOv9TLtFDddJTUXh0rACuXFxq', 'krishna5623', '2025-04-14 08:04:26', 'facilitator'),
(42, 'NIL185406', 'NeelMadhav', 'Nilesh@gmail.com', '7474747474', '$2b$10$NuHqRJXdm.TXo7KzZRthauEfV/E5yxaiwjxLfudLiFzqtFs9xIPmS', 'Nilesh@123', '2025-04-14 08:59:30', 'frontliner'),
(43, 'ROH634115', 'Rohan ', 'Rohan@123', '7474747471', '$2b$10$9sWVsDG8Nr/sLHzz4VUrbeMBQqZl/HiX/pbgZZ8IfE9RDy5O2Ozo.', 'Rohan23', '2025-04-14 09:09:10', 'frontliner'),
(44, 'MAD972745', 'Madhav ', 'Madav@gmail.com', '568321479', '$2b$10$bORIP4EuwkIx5LndFvWH9uYPBy.74McLEE.4mGYzOyPWneDpAz0Wi', 'Madav@1123', '2025-04-14 09:10:39', 'frontliner'),
(45, 'GOV986886', 'Govind ', 'Govind12@gmail.com', '7896541230', '$2b$10$yQcDQgKaChFedjtO7SDuO.xZFAP4OhiTJoKve1Z4DHmCpHOn9MGta', 'Govind', '2025-04-14 09:11:09', 'frontliner'),
(46, 'MAD370488', 'Madhusudan ', 'madhu@gamil.com', '7412879735', '$2b$10$bLbGgR6t6pcSeCUishkjJOvFyjsp8OT1aGb7RqFrTBQzlkMhDbZ.S', 'madhu@123', '2025-04-14 09:11:52', 'frontliner'),
(47, 'VAS593936', 'Vashudeva', 'Vashudeva@gamil.com', '7412879736', '$2b$10$8ugIHR8TBlL2oqtWuwqWTePowEpzYXrZ7ZmP.UNatYesnE8qyM7Ky', 'vasudeva234', '2025-04-14 09:12:36', 'frontliner'),
(49, 'HAR409147', 'Hari ', 'Hari@gamil.com', '789653450', '$2b$10$m0h/bRvRXXGgecjImmr2WuKw74vygxgyfwarMVRipPXDcc4ONclQa', 'Hari455', '2025-04-14 09:14:52', 'frontliner'),
(50, 'GOV630188', 'Govinda ', 'govind@123', '896574123', '$2b$10$UivAhqeyNTSDan.TS0TWve7C37i2TKX7K5D65J804JJowJLZenTiC', 'govind', '2025-04-14 09:15:22', 'frontliner'),
(51, 'PAR696446', 'ParhSarthi', 'ParthSarthi@gmail.com', '45697123', '$2b$10$KDmEZz91XNVm9D2qhutY5up6cX12KjSNdcHVmtGS8HT0GghTKHXIe', 'Parth123', '2025-04-14 09:16:11', 'frontliner'),
(52, 'BAL123410', 'Baldeva ', 'Baldeva123@gamil.com', '8956231474', '$2b$10$KOHBXBigV.BuVZ5lHcgMK.cCfljxFYQEf6OG2cN33vbRqFLEqadBG', 'Baldeva123', '2025-04-14 09:17:24', 'frontliner'),
(53, 'GOU136850', 'Gouranga', 'Gouranga999@gamil.com', '784512369', '$2b$10$9sAt8I9zGL7ZXwm4dxm3RuzMQ6o.hc7wjf88pgTz9TZO9mrvi8rWe', 'Gourangs123', '2025-04-14 09:18:00', 'frontliner'),
(54, 'CHA258408', 'Chaitnya ', 'Chaitnya123@gmail.com', '785236941', '$2b$10$lA5qUPQ3ITRUszhMDHENj.H3tUxvOIhKr1bN20g/kOdi8XD2chTZS', 'Chaitnya', '2025-04-14 09:18:43', 'frontliner'),
(55, 'NIT914777', 'Nitai', 'nitai@gamil.com', '78965641230', '$2b$10$q2QdmS8jWYJQFjV78Gayz.844kv9tEuhxxSAyJiJuur.QhLsYJ7LC', 'nitai1234', '2025-04-14 09:19:10', 'frontliner'),
(56, 'NIT106966', 'Nityanand ', 'nityanand@gmail.com', '89562314748', '$2b$10$PIKPoUmpXUt7ISG54Qf5QOWqP/ioBYd054JvocWM0/exk4dU4Sr.a', 'nitai123', '2025-04-14 09:20:25', 'frontliner'),
(57, 'VIM920063', 'Vimal Arjun Prji', 'vimal@gmail.com', '7894561230', '$2b$10$0mc6s6AQ./5lhfA9z8twheKnnVheUTSMFfk/AqK4IVnCee4VDakO6', 'Vimal@123', '2025-04-14 09:34:03', 'facilitator'),
(58, 'HG573659', 'HG Tusta Madan Mohan prji', 'madanmohan132@gamil.com', '7894563210', '$2b$10$vHGFBYCju9ILYlY7Bsu5s.UfBIZtrGcerSxfDy461PGqanWu2xE9K', 'mohan@123', '2025-04-14 09:36:11', 'facilitator'),
(59, 'HG368829', 'HG DigVijay Gouranga prji', 'gouranga1234@gamil.com', '7896325410', '$2b$10$8UFOBDD27ltCAGmez/cyse16S45vODxEX6tS.EVWwPf6YqpsUeqBi', 'gourangs', '2025-04-14 09:37:29', 'facilitator'),
(60, 'HG597876', 'HG Devesh Baldeva Prji', 'Devesh99@gamil.com', '7894563217', '$2b$10$GK4oxyS8/sXyAt8lUXXVg.lj7Svyxv3PfO9.r.Ii30kkNOEE2p7Ae', 'devesh99', '2025-04-14 11:05:26', 'facilitator'),
(61, 'HG 930923', 'HG Hitakara Vamana Prji', 'hitarthvyas02@gmail.com', '8956231471', '$2b$10$dqrU403itv9tYpdi3GMSS.oOFH9rDlXbZgsHJTnuzicRovYJEWw8G', 'vyas234', '2025-04-14 11:08:19', 'facilitator'),
(62, 'HG 798715', 'HG Harisha Pran Prji', 'harishapran@123', '853269741', '$2b$10$dLq/TP2HOlAKiZfq656sxOzM4CIlisLtpQyltCD.VtcRiaT8Lqseq', 'harisha', '2025-04-14 11:09:16', 'facilitator');

-- --------------------------------------------------------

--
-- Table structure for table `studentAttendance`
--

CREATE TABLE `studentAttendance` (
  `AttendanceId` int(11) NOT NULL,
  `AttendanceDate` timestamp NULL DEFAULT current_timestamp(),
  `AttendanceSession` varchar(100) DEFAULT NULL,
  `StudentId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `studentAttendance`
--

INSERT INTO `studentAttendance` (`AttendanceId`, `AttendanceDate`, `AttendanceSession`, `StudentId`) VALUES
(263, '2025-04-20 06:08:43', 'Nachiketa', 265),
(264, '2025-04-20 06:08:43', 'Nachiketa', 266),
(265, '2025-04-20 06:08:43', 'Nachiketa', 267),
(269, '2025-04-21 06:08:43', 'Nachiketa', 271),
(270, '2025-04-21 06:08:43', 'Nachiketa', 272),
(271, '2025-04-21 06:08:43', 'Nachiketa', 273),
(272, '2025-04-20 07:07:09', 'Jagganath', 276),
(273, '2025-04-20 07:07:10', 'DYS-2', 274),
(274, '2025-04-20 07:07:11', 'Nachiketa', 265),
(275, '2025-04-20 09:50:28', 'Nachiketa', 273),
(276, '2025-04-20 09:51:31', 'Nachiketa', 271),
(277, '2025-04-21 09:51:31', 'Nachiketa', 271),
(278, '2025-04-23 09:51:31', 'Nachiketa', 271),
(279, '2025-04-21 05:24:23', 'Nachiketa', 265),
(280, '2025-04-24 05:24:23', 'Nachiketa', 265),
(281, '2025-05-21 05:24:23', 'Nachiketa', 265),
(282, '2025-05-21 05:45:01', 'Arjun', 324),
(283, '2025-04-21 05:48:05', 'Arjun', 269),
(284, '2025-05-25 05:53:21', 'Arjun', 322);

-- --------------------------------------------------------

--
-- Table structure for table `studentbatch`
--

CREATE TABLE `studentbatch` (
  `BatchId` int(11) NOT NULL,
  `GroupName` varchar(100) DEFAULT NULL,
  `BatchCreatedDate` date DEFAULT NULL,
  `Status` varchar(100) DEFAULT NULL,
  `FacilitatorId` varchar(100) DEFAULT NULL,
  `is_start` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `studentbatch`
--

INSERT INTO `studentbatch` (`BatchId`, `GroupName`, `BatchCreatedDate`, `Status`, `FacilitatorId`, `is_start`) VALUES
(35, NULL, '2025-04-14', NULL, 'HG368829', 1),
(36, NULL, '2025-04-14', NULL, 'HGD586232', 1),
(37, NULL, '2025-04-14', NULL, 'HGV442127', 1),
(38, NULL, '2025-04-14', NULL, 'HG573659', 1);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `dob` date DEFAULT NULL,
  `mobile_number` varchar(15) NOT NULL,
  `frontliner_name` varchar(100) DEFAULT NULL,
  `profession` enum('student','job_candidate') NOT NULL,
  `address` text DEFAULT NULL,
  `class_mode` enum('online','offline') DEFAULT NULL,
  `payment_mode` enum('cash','online','referral','unpaid','post-pay') NOT NULL,
  `payment_amount` decimal(10,2) DEFAULT NULL,
  `payment_status` enum('received','not_received') DEFAULT 'not_received',
  `referral_user_id` int(11) DEFAULT NULL,
  `chanting_round` int(11) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL,
  `services` text DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `permanent_address` text DEFAULT NULL,
  `remark` text DEFAULT NULL,
  `skill` varchar(100) DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `interest` text DEFAULT NULL,
  `hobby` text DEFAULT NULL,
  `study_field` varchar(100) DEFAULT NULL,
  `father_occupation` varchar(100) DEFAULT NULL,
  `father_number` varchar(15) DEFAULT NULL,
  `sankalp_camp` tinyint(1) DEFAULT 0,
  `registration_date` datetime DEFAULT current_timestamp(),
  `gender` enum('male','female','other') DEFAULT NULL,
  `student_status` enum('will_come','not_interested','busy','might_come') DEFAULT 'might_come',
  `facilitator_id` int(11) DEFAULT NULL,
  `razorpay_payment_id` varchar(100) DEFAULT NULL,
  `frontliner_id` varchar(255) DEFAULT NULL,
  `calling_id` varchar(36) DEFAULT NULL,
  `student_status_date` datetime DEFAULT NULL,
  `group_name` varchar(100) DEFAULT NULL,
  `batch_id` int(11) DEFAULT NULL,
  `facilitatorId` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `name`, `dob`, `mobile_number`, `frontliner_name`, `profession`, `address`, `class_mode`, `payment_mode`, `payment_amount`, `payment_status`, `referral_user_id`, `chanting_round`, `email`, `photo`, `rating`, `services`, `city`, `state`, `permanent_address`, `remark`, `skill`, `comment`, `interest`, `hobby`, `study_field`, `father_occupation`, `father_number`, `sankalp_camp`, `registration_date`, `gender`, `student_status`, `facilitator_id`, `razorpay_payment_id`, `frontliner_id`, `calling_id`, `student_status_date`, `group_name`, `batch_id`, `facilitatorId`) VALUES
(265, 'Hari', '2025-05-11', '894614722', NULL, 'job_candidate', 'near clock tower ', 'online', 'cash', 200.00, 'received', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-15 11:43:59', NULL, 'might_come', NULL, NULL, 'NIL185406', 'MAD972745', NULL, 'Nachiketa', 38, 'HG573659'),
(266, 'Mohan', '2025-05-12', '825614723', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'received', NULL, 5, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 11:46:59', NULL, 'might_come', NULL, NULL, 'NIL185406', 'MAD972745', NULL, 'Nachiketa', 38, 'HG573659'),
(267, 'dindyal', '2025-04-04', '895314724', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'received', NULL, 3, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-16 11:46:59', NULL, 'might_come', NULL, NULL, 'NIL185406', 'MAD972745', NULL, 'Nachiketa', 38, 'HG573659'),
(268, 'Rounak', '2025-04-03', '899614725', NULL, 'job_candidate', 'near clock tower ', 'online', 'cash', 200.00, 'not_received', NULL, 2, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-16 11:22:59', NULL, 'might_come', NULL, NULL, 'NIL185406', 'MAD972745', NULL, 'Nakul', 36, 'HGD586232'),
(269, 'Tarun', '2025-10-04', '825614726', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'not_received', NULL, 1, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-17 11:21:59', NULL, 'might_come', NULL, NULL, 'NIL185406', 'MAD972745', NULL, 'Arjun', 37, 'HGV442127'),
(270, 'Parikshit', '2025-04-02', '896614727', NULL, 'job_candidate', 'near clock tower ', 'online', 'cash', 200.00, 'not_received', NULL, 12, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-18 11:20:30', NULL, 'might_come', NULL, NULL, 'NIL185406', 'CHA258408', NULL, 'Nakul', 36, 'HGD586232'),
(271, 'Jack', '2025-06-01', '895694728', NULL, 'job_candidate', 'near clock tower ', 'online', 'online', 200.00, 'received', NULL, 3, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-19 11:20:30', NULL, 'might_come', NULL, NULL, 'NIL185406', 'CHA258408', NULL, 'Nachiketa', 35, 'HG368829'),
(272, 'Sourav', '2025-06-02', '895674729', NULL, 'job_candidate', 'near clock tower ', 'online', 'online', 200.00, 'received', NULL, 2, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-20 11:20:30', NULL, 'might_come', NULL, NULL, 'NIL185406', 'CHA258408', NULL, 'Nachiketa', 35, 'HG368829'),
(273, 'Sunil', '2025-06-01', '895146610', NULL, 'job_candidate', 'near clock tower ', 'online', 'online', 200.00, 'received', NULL, 2, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-18 11:21:30', NULL, 'might_come', NULL, NULL, 'NIL185406', 'CHA258408', NULL, 'Nachiketa', 36, 'HGD586232'),
(274, 'pankaj', '2025-06-05', '895644711', NULL, 'job_candidate', 'near clock tower ', 'online', 'cash', 200.00, 'not_received', NULL, 1, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-18 11:23:30', NULL, 'might_come', NULL, NULL, 'NIL185406', 'CHA258408', NULL, 'DYS-2', 36, 'HGD586232'),
(275, 'shayam', '2025-06-10', '895666712', NULL, 'job_candidate', 'near clock tower ', 'online', 'cash', 200.00, 'not_received', NULL, 5, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-19 11:20:30', NULL, 'might_come', NULL, NULL, 'NIL185406', 'NIT106966', NULL, 'Nachiketa', 35, 'HG368829'),
(276, 'keshav', '2025-06-12', '895564713', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'not_received', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-20 11:20:30', NULL, 'might_come', NULL, NULL, 'NIL185406', 'NIT106966', NULL, 'Jagganath', 35, 'HG368829'),
(277, 'surendra', '2025-06-09', '899614714', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'not_received', NULL, 6, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-01-20 11:20:30', NULL, 'might_come', NULL, NULL, 'NIL185406', 'NIT106966', NULL, 'GourangSabha', 35, 'HG368829'),
(313, 'vinay', '2025-06-03', '128797352', NULL, 'student', 'near shubham circle ', 'online', 'cash', 100.00, 'not_received', NULL, 5, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'BAL123410', NULL, 'Shadev', 38, 'HG573659'),
(314, 'vaibhav', '2025-04-12', '128797353', NULL, 'student', 'near shubham circle ', 'online', 'cash', 100.00, 'not_received', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'BAL123410', NULL, 'DYS-4', 36, 'HGD586232'),
(315, 'vikas', '2025-04-12', '741797354', NULL, 'student', 'near shubham circle ', 'online', 'unpaid', 100.00, 'received', NULL, 5, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'BAL123410', NULL, 'Nakul', 37, 'HGV442127'),
(316, 'veenit', '2025-04-12', '741287355', NULL, 'student', 'near shubham circle ', 'online', 'unpaid', 100.00, 'not_received', NULL, 9, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'BAL123410', NULL, 'Jagganath', 35, 'HG368829'),
(317, 'vikrant', '2025-04-12', '748797356', NULL, 'student', 'near shubham circle ', 'online', 'cash', 100.00, 'not_received', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'BAL123410', NULL, 'Arjun', 37, 'HGV442127'),
(318, 'veermadhav', '2025-04-12', '741287356', NULL, 'student', 'near shubham circle ', 'online', 'online', 100.00, 'received', NULL, 7, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'PAR696446', NULL, 'Nakul', 37, 'HGV442127'),
(319, 'shayma', '2025-04-12', '728797358', NULL, 'student', 'near shubham circle ', 'online', 'online', 100.00, 'received', NULL, 2, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'PAR696446', NULL, 'DYS-2', 35, 'HG368829'),
(320, 'jack', '2025-04-12', '741297359', NULL, 'student', 'near shubham circle ', 'online', 'cash', 100.00, 'not_received', NULL, 1, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'PAR696446', NULL, 'DYS-2', 35, 'HG368829'),
(321, 'raj', '2025-04-12', '741287310', NULL, 'student', 'near shubham circle ', 'online', 'cash', 100.00, 'not_received', NULL, 1, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'PAR696446', NULL, 'Nachiketa', 38, 'HG573659'),
(322, 'madhav', '2025-04-12', '741287358', NULL, 'student', 'near shubham circle ', 'online', 'online', 100.00, 'received', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'PAR696446', NULL, 'Arjun', 37, 'HGV442127'),
(323, 'mohan', '2025-04-12', '74128335', NULL, 'student', 'near shubham circle ', 'online', 'cash', 100.00, 'not_received', NULL, 9, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'PAR696446', NULL, 'DYS-2', 35, 'HG368829'),
(324, 'Abhay', '2025-05-12', '825614725', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'received', NULL, 5, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 11:46:59', NULL, 'might_come', NULL, NULL, 'NIL185406', 'MAD972745', NULL, 'Arjun', 38, 'HG573659');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `group_migration`
--
ALTER TABLE `group_migration`
  ADD PRIMARY KEY (`migrationId`);

--
-- Indexes for table `iyfdashboardAccounts`
--
ALTER TABLE `iyfdashboardAccounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `phone_number` (`phone_number`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `studentAttendance`
--
ALTER TABLE `studentAttendance`
  ADD PRIMARY KEY (`AttendanceId`),
  ADD KEY `StudentId` (`StudentId`);

--
-- Indexes for table `studentbatch`
--
ALTER TABLE `studentbatch`
  ADD PRIMARY KEY (`BatchId`),
  ADD KEY `FacilitatorId` (`FacilitatorId`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `mobile_number` (`mobile_number`),
  ADD KEY `facilitator_id` (`facilitator_id`),
  ADD KEY `referral_user_id` (`referral_user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `group_migration`
--
ALTER TABLE `group_migration`
  MODIFY `migrationId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `iyfdashboardAccounts`
--
ALTER TABLE `iyfdashboardAccounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;

--
-- AUTO_INCREMENT for table `studentAttendance`
--
ALTER TABLE `studentAttendance`
  MODIFY `AttendanceId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=285;

--
-- AUTO_INCREMENT for table `studentbatch`
--
ALTER TABLE `studentbatch`
  MODIFY `BatchId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=325;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `studentAttendance`
--
ALTER TABLE `studentAttendance`
  ADD CONSTRAINT `studentAttendance_ibfk_1` FOREIGN KEY (`StudentId`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `studentbatch`
--
ALTER TABLE `studentbatch`
  ADD CONSTRAINT `studentbatch_ibfk_1` FOREIGN KEY (`FacilitatorId`) REFERENCES `iyfdashboardAccounts` (`user_id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`facilitator_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `users_ibfk_2` FOREIGN KEY (`referral_user_id`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
