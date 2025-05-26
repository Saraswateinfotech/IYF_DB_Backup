-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: May 26, 2025 at 06:34 AM
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
-- Database: `u234037150_iyfdashboard`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`u234037150_iyfdashboard`@`127.0.0.1` PROCEDURE `GetAttendanceRatioByGroupAndMonth` (IN `p_group_name` VARCHAR(50), IN `p_month` INT, IN `p_year` INT)   BEGIN
  DECLARE total_students    INT;
  DECLARE attended_students INT;

  -- 1. Count total students in the group
  SELECT COUNT(*) INTO total_students
    FROM users
   WHERE group_name LIKE CONCAT('%', p_group_name, '%');

  -- 2. Count distinct attendance days in the month/year
  SELECT COUNT(DISTINCT AttendanceDate) INTO attended_students
    FROM studentAttendance AS sa
    JOIN users AS u
      ON u.user_id = sa.StudentId
   WHERE u.group_name LIKE CONCAT('%', p_group_name, '%')
     AND MONTH(sa.AttendanceDate) = p_month
     AND YEAR(sa.AttendanceDate)  = p_year
     AND sa.AttendanceSession IS NOT NULL;

  -- 3. Return the ratio
  SELECT CONCAT(attended_students, '/', total_students) AS AttendanceRatio;
END$$

CREATE DEFINER=`u234037150_iyfdashboard`@`127.0.0.1` PROCEDURE `progressReportGroupWise` (IN `p_sessionName` VARCHAR(50), IN `p_selectedYear` INT, IN `p_selectedMonth` INT, IN `p_facilitatorId` VARCHAR(50), IN `p_groupPrefix` VARCHAR(50))   BEGIN
  -- Local variables
  DECLARE v_year  INT;
  DECLARE v_month INT;

  -- Set final year and month, fallback to current if NULL/0
  SET v_year  = IF(p_selectedYear  IS NULL OR p_selectedYear  = 0, YEAR(CURDATE()), p_selectedYear);
  SET v_month = IF(p_selectedMonth IS NULL OR p_selectedMonth = 0, MONTH(CURDATE()), p_selectedMonth);

  -- Main query
  WITH
    dates AS (
      SELECT DISTINCT DATE(AttendanceDate) AS class_date
      FROM u234037150_iyfdashboard.studentAttendance
      WHERE AttendanceSession = p_sessionName
        AND (p_selectedYear IS NOT NULL AND p_selectedYear != 0)
        AND (p_selectedMonth IS NOT NULL AND p_selectedMonth != 0)
        AND YEAR(AttendanceDate)  = v_year
        AND MONTH(AttendanceDate) = v_month
    ),
    students AS (
      SELECT
        u.user_id,
        u.name,
        u.mobile_number,
        u.chanting_round,
        u.facilitatorId
      FROM u234037150_iyfdashboard.users AS u
      WHERE u.facilitatorId = p_facilitatorId
        AND u.group_name LIKE CONCAT(p_groupPrefix, '%')
    )
  SELECT
    s.user_id        AS student_id,
    s.name           AS student_name,
    s.mobile_number,
    s.chanting_round,
    s.facilitatorId,
    CAST(
      CONCAT_WS(
        '/',
        SUM(CASE WHEN sa.StudentId IS NOT NULL THEN 1 ELSE 0 END),
        COUNT(d.class_date)
      )
      AS CHAR(10)
    ) AS GroupRatio
  FROM students AS s
  LEFT JOIN dates AS d ON 1 = 1
  LEFT JOIN u234037150_iyfdashboard.studentAttendance AS sa
    ON sa.StudentId            = s.user_id
   AND DATE(sa.AttendanceDate) = d.class_date
   AND sa.AttendanceSession    = p_sessionName
  GROUP BY
    s.user_id,
    s.name,
    s.mobile_number,
    s.chanting_round,
    s.facilitatorId
  ORDER BY s.name;
END$$

CREATE DEFINER=`u234037150_iyfdashboard`@`127.0.0.1` PROCEDURE `sp_get_all_frontliner_report` ()   BEGIN
  SELECT
    a.user_id,
    a.name,
    a.phone_number,
    COUNT(u.user_id) AS total_register,
    IFNULL(SUM(u.payment_amount), 0) AS total_amount,
    IFNULL(
      SUM(
        CASE 
          WHEN u.payment_status = 'not_received' THEN u.payment_amount 
          ELSE 0 
        END
      ), 0
    ) AS pending_amount,
    IFNULL(
      SUM(
        CASE 
          WHEN YEARWEEK(u.registration_date,1) = YEARWEEK(CURDATE(),1)
          THEN 1 ELSE 0
        END
      ), 0
    ) AS weekly_total_registered_student_number,
    IFNULL(
      SUM(
        CASE 
          WHEN u.student_status = 'will_come'
           AND YEARWEEK(u.registration_date,1) = YEARWEEK(CURDATE(),1)
          THEN 1 ELSE 0
        END
      ), 0
    ) AS weekly_will_come_student_number
  FROM `iyfdashboardAccounts` a
  LEFT JOIN `users` u ON a.user_id = u.frontliner_id
  WHERE a.role = 'frontliner'
  GROUP BY a.user_id, a.name, a.phone_number;
END$$

CREATE DEFINER=`u234037150_iyfdashboard`@`127.0.0.1` PROCEDURE `sp_get_frontlinerdetail_report` (IN `in_frontliner_id` VARCHAR(20))   BEGIN
  SELECT
    COUNT(user_id) AS total_register,
    IFNULL(SUM(payment_amount), 0) AS total_amount,
    IFNULL(
      SUM(
        CASE 
          WHEN payment_status = 'not_received' THEN payment_amount 
          ELSE 0 
        END
      ), 0
    ) AS pending_amount,
    IFNULL(
      SUM(
        CASE 
          WHEN YEARWEEK(registration_date,1) = YEARWEEK(CURDATE(),1)
          THEN 1 ELSE 0
        END
      ), 0
    ) AS weekly_total_registered_student_number,
    IFNULL(
      SUM(
        CASE 
          WHEN student_status = 'will_come'
           AND YEARWEEK(registration_date,1) = YEARWEEK(CURDATE(),1)
          THEN 1 ELSE 0
        END
      ), 0
    ) AS weekly_will_come_student_number
  FROM `users`
  WHERE `frontliner_id` = in_frontliner_id;
END$$

CREATE DEFINER=`u234037150_iyfdashboard`@`127.0.0.1` PROCEDURE `sp_get_stddashboard_report` ()   BEGIN
  SELECT
    COUNT(user_id) AS total_register,
    
    IFNULL(SUM(payment_amount), 0) AS total_amount,
    
    IFNULL(
      SUM(
        CASE
          WHEN payment_status = 'not_received' THEN payment_amount
          ELSE 0
        END
      ),
      0
    ) AS pending_amount,
    
    IFNULL(
      SUM(
        CASE
          WHEN YEARWEEK(registration_date,1) = YEARWEEK(CURDATE(),1)
          THEN 1
          ELSE 0
        END
      ),
      0
    ) AS weekly_total_registered_student_number,
    
    IFNULL(
      SUM(
        CASE
          WHEN LOWER(student_status) = 'will_come'
           AND YEARWEEK(registration_date,1) = YEARWEEK(CURDATE(),1)
          THEN 1
          ELSE 0
        END
      ),
      0
    ) AS weekly_will_come_student_number

  FROM users;
END$$

CREATE DEFINER=`u234037150_iyfdashboard`@`127.0.0.1` PROCEDURE `sp_top_3_frontliners_by_month_year` (IN `month` INT, IN `year` INT)   BEGIN
    -- Reset the row number for every execution
    SET @row_num := 0;

    SELECT 
        @row_num := @row_num + 1 AS sr_no,  -- Increment rank
        a.name AS frontliner_name,  -- Get name from iyfdashboardAccounts table
        COUNT(CASE WHEN u.class_mode = 'offline' THEN 1 END) AS total_offline_registrations,
        COUNT(CASE WHEN u.class_mode = 'online' THEN 1 END) AS total_online_registrations,
        COUNT(CASE WHEN u.class_mode IN ('offline', 'online') THEN 1 END) AS total_registrations  -- Total registrations
    FROM users u
    LEFT JOIN iyfdashboardAccounts a ON u.frontliner_id = a.user_id  -- Join with iyfdashboardAccounts table using frontliner_id = user_id
    WHERE MONTH(u.registration_date) = month 
        AND YEAR(u.registration_date) = year
        AND u.frontliner_id IS NOT NULL  -- Ensure frontliner_id is not NULL
    GROUP BY a.name
    ORDER BY total_registrations DESC  -- Order by total registrations (desc)
    LIMIT 3;  -- Limit to top 3 frontliners
END$$

CREATE DEFINER=`u234037150_iyfdashboard`@`127.0.0.1` PROCEDURE `studentClassReport` (IN `in_student_id` INT)   BEGIN
  SELECT 
    u.user_id            AS student_id,
    u.name               AS student_name,
    u.mobile_number,
    u.group_name,
    DATE(att.AttendanceDate) AS class_date,
    CASE 
      WHEN sa.StudentId IS NOT NULL THEN 'Present'
      ELSE 'Absent'
    END                     AS status,
    sa.AttendanceSession,
  
    -- build "present/total" as VARCHAR
    CONCAT(
      CAST(
        SUM(CASE WHEN sa.StudentId IS NOT NULL THEN 1 ELSE 0 END)
          OVER (PARTITION BY u.user_id)
        AS CHAR
      ),
      '/',
      CAST(
        COUNT(*) OVER (PARTITION BY u.user_id)
        AS CHAR
      )
    ) AS group_ratio

  FROM (
    -- all (group × date) where a class happened
    SELECT 
      DATE(sa.AttendanceDate) AS AttendanceDate,
      u.group_name
    FROM u234037150_iyfdashboard.studentAttendance AS sa
    JOIN u234037150_iyfdashboard.users AS u 
      ON sa.StudentId = u.user_id
    GROUP BY DATE(sa.AttendanceDate), u.group_name
  ) AS att

  JOIN u234037150_iyfdashboard.users AS u 
    ON u.group_name = att.group_name

  LEFT JOIN u234037150_iyfdashboard.studentAttendance AS sa 
    ON sa.StudentId            = u.user_id
   AND DATE(sa.AttendanceDate) = att.AttendanceDate

  WHERE u.user_id = in_student_id

  ORDER BY att.AttendanceDate;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `facilitator_student_comments`
--

CREATE TABLE `facilitator_student_comments` (
  `id` int(11) NOT NULL,
  `facilitator_id` varchar(50) NOT NULL,
  `student_id` int(11) NOT NULL,
  `comment_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Stores array of {date, comment} objects' CHECK (json_valid(`comment_data`)),
  `last_updated` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `facilitator_student_comments`
--

INSERT INTO `facilitator_student_comments` (`id`, `facilitator_id`, `student_id`, `comment_data`, `last_updated`) VALUES
(1, 'HG573659', 267, '[{\"date\":\"2025-05-22T21:27:11.253Z\",\"comment\":\"kkkkkk\"},{\"date\":\"2025-05-22T21:27:04.851Z\",\"comment\":\"knknn\"},{\"date\":\"2025-05-22T21:26:47.085Z\",\"comment\":\"knkhk\"}]', '2025-05-22 08:56:55'),
(4, 'HG573659', 265, '[{\"date\":\"2025-05-22T21:30:10.993Z\",\"comment\":\"nooooooo\"}]', '2025-05-22 08:59:55'),
(5, 'HG573659', 324, '[{\"date\":\"2025-05-22T21:30:25.797Z\",\"comment\":\"okkkkkkkk\"}]', '2025-05-22 09:00:10'),
(40, 'HG573659', 266, '[{\"date\":\"2025-05-22T15:39:54.356Z\",\"comment\":\"rtgtr thty \"},{\"date\":\"2025-05-22T15:39:44.799Z\",\"comment\":\"fhgnghnghnh \"},{\"date\":\"2025-05-22T15:39:39.111Z\",\"comment\":\"gffnfgngfn\"},{\"date\":\"2025-05-22T15:32:30.841Z\",\"comment\":\"dfbfbfgbgfbfgnnnnnnnnnnnnnnnnnnnnnnnnnnnnnfrthbh rthth rrtbth tr tg rt t h h t t t t tr tthtynyth rreg whrh rh etnytnruyetysrhtrh wrh rth trhthyjukikiut 6 uyujrujj yt yjjuyjuy,i,ire4wetbe rt yh6juuyki reyw y \"},{\"date\":\"2025-05-22T15:30:45.224Z\",\"comment\":\"yjtjtyjjyyyyyyyyyyyyyyyyyy\"},{\"date\":\"2025-05-22T15:30:36.707Z\",\"comment\":\"cxvdfvdfbd\"},{\"date\":\"2025-05-22T15:06:28.007Z\",\"comment\":\"nknknjk\"},{\"date\":\"2025-05-22T15:06:24.203Z\",\"comment\":\"njnjn\"},{\"date\":\"2025-05-22T14:39:10.096Z\",\"comment\":\"juhjbjbjbj\"},{\"date\":\"2025-05-22T14:39:04.451Z\",\"comment\":\"mkkkkkk\"},{\"date\":\"2025-05-22T14:38:58.431Z\",\"comment\":\"mmmmm\"},{\"date\":\"2025-05-22T14:38:50.830Z\",\"comment\":\"bjhbj\"},{\"date\":\"2025-05-22T14:38:45.404Z\",\"comment\":\"jbjhbkj\"},{\"date\":\"2025-05-22T14:36:36.758Z\",\"comment\":\"nvhvjhv\"},{\"date\":\"2025-05-22T14:36:33.648Z\",\"comment\":\"bhjhjhjjh\"}]', '2025-05-22 15:39:42'),
(55, 'HG368829', 277, '[{\"date\":\"2025-05-23T17:13:31.558Z\",\"comment\":\"juhygfyfyv\"},{\"date\":\"2025-05-23T17:13:28.924Z\",\"comment\":\"ghjvjgjy\"},{\"date\":\"2025-05-23T17:13:02.018Z\",\"comment\":\"khuiboo\"},{\"date\":\"2025-05-23T17:12:57.664Z\",\"comment\":\"ghfygyguy\"}]', '2025-05-23 17:13:23');

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

--
-- Dumping data for table `group_migration`
--

INSERT INTO `group_migration` (`migrationId`, `migrationDateTime`, `devoteeId`, `priviousGroup`, `currentGroup`) VALUES
(18, '2025-04-25 11:10:03', 267, 'Nachiketa', 'Shadev'),
(19, '2025-04-25 11:10:42', 327, 'Nachiketa', 'Arjun'),
(20, '2025-04-25 13:05:55', 265, 'Nachiketa', 'Nakul'),
(21, '2025-04-25 13:33:13', 326, 'Nachiketa', 'Shadev'),
(22, '2025-04-25 13:42:03', 321, 'Nachiketa', 'Nakul'),
(23, '2025-04-26 13:06:09', 266, 'Nachiketa', 'GourangSabha'),
(24, '2025-04-29 07:30:34', 265, 'Nakul', 'Arjun'),
(25, '2025-04-30 08:25:14', 267, 'Shadev', 'Arjun'),
(26, '2025-04-30 08:28:01', 321, 'Nakul', 'Arjun');

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
(37, 'HG604238', 'HG Mohan Murari Prji', 'mohit193@gmail.com', '8956231470', '$2b$10$/eeNN90kYyD/LueFfHICOevwL3sz8MMZEDUcFlRr8yncYMD3FUIcG', 'aa', '2025-04-14 07:48:55', 'facilitator'),
(38, 'HG938474', 'HG Naveen Narad Prij', 'naveen23@gmail.com', '8956231460', '$2b$10$AtL/X92fYZfytFcc6RXbo.obysYIlH2yDzoILX5lV6Q5D/0JDWtmq', 'naveen123@g123', '2025-04-14 07:57:24', 'facilitator'),
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
(62, 'HG 798715', 'HG Harisha Pran Prji', 'harishapran@123', '853269741', '$2b$10$dLq/TP2HOlAKiZfq656sxOzM4CIlisLtpQyltCD.VtcRiaT8Lqseq', 'harisha', '2025-04-14 11:09:16', 'facilitator'),
(63, 'RAD178563', 'Radheshyam Anand Prji', 'shayam34@gamil.com', '895623147', '$2b$10$O0tdvPulrbj4MAX3Ksx13.Wt4XAx2thM0iLXjFfL7jclB4wCLnoaa', 'Shayam123', '2025-04-29 06:54:31', 'facilitator'),
(64, 'ADI516509', 'Aditya prji ', 'Aditya@gmail.com', '7894561232', '$2b$10$vemtMGYUk/ZsLMDCd.NEU.42F1YgpLdkMbTY0F3naEaUalNS.rUia', 'Aditya@123', '2025-04-29 06:55:53', 'facilitator'),
(65, 'BHA843784', 'Bhavya', 'Bhavya@gmail.com', '8523697410', '$2b$10$x4q8MdX5x.3VTsnhUY1CreixNBssJufIiZl.LRZkjwSj4ZfNp2NSK', 'Bhavya@123', '2025-04-29 07:14:23', 'frontliner'),
(67, 'DSC875373', 'dscdc', 'user25252eg@gmail.com', '5725725722', '$2b$10$DyYnhfERzjXZqjp1tOhLDOjSIDrMlvEV2jDZU/9o8fZuastlKgw0e', '72228282', '2025-04-29 11:04:51', 'facilitator'),
(68, 'WDW529262', 'wdwd', 'liladharkumawat007@gmail.com', '9966338800', '$2b$10$oh9z8TOVMPcq83PmLK9eIOrEBGnS5E6Kxf9hGDlldxccxMeZQsG0S', '123456', '2025-04-29 11:19:19', 'facilitator'),
(69, 'SCS266186', 'scsdd', 'bemico7466@hedotu.com', '6546516565', '$2b$10$sbnE4ThaSNCqWC3uHVK4C.Cps9TuUZYrq41fChlsF3ir5J7mGRKwG', '165454854', '2025-04-29 11:40:41', 'frontliner'),
(70, 'ABH815509', 'Abhinav', 'vipin.vi0333@gmail.com', '8956231476', '$2b$10$zLR79ZUcBwEg6K0WV2RSAe9wb02NNFN/Z0z7Jn1ujQBfxon43jZB2', 'Vipin@123', '2025-04-30 08:32:12', 'frontliner'),
(71, 'MAD427947', 'MadhavNitai', 'iskconjaipur@gmail.com', '8523697415', '$2b$10$tmuWIQji093PcUJbIHkXdeAP0cNdyJSePYh1FttapWOLCIhqEA6zK', 'Madhav@123', '2025-04-30 12:08:43', 'facilitator'),
(73, '8757828727', 'ccccdc', 'usergrergbtr88@gmail.com', '8757828727', '$2b$10$7cF8KUmLXwQB/Hm28n3VK.x8jMCZ0nILDgzooEypvHQzcqWb0tne.', 'jtyjtyjy', '2025-04-30 17:15:09', 'facilitator'),
(74, '5086508539', 'scdc', 'cekit85982@firain.com', '5086508539', '$2b$10$ScE8jk0YjYKkgbgd1BentunYF7rTQYcDR4q5owj4SmyI/Q5l1yxmO', 'zvcdsvds', '2025-04-30 17:17:36', 'facilitator'),
(75, '8465254154', 'sd', 'user@gmail.com', '8465254154', '$2b$10$.GgCg.Mk/ZhJnDbZWq0bGuUeqjUus.NnNqmSN6uTc3U6t3BfnjwSq', 'edvdsv', '2025-05-01 08:34:33', 'facilitator'),
(76, '6546541641', 'dsvv', 'usesdvdsvbr@gmail.com', '6546541641', '$2b$10$k8B4d509kBaoR3CoEZxTa.2BSukBtXQfd/A03qHLD8DOWB88nHOOK', 'svdv', '2025-05-01 08:36:10', 'frontliner'),
(77, '5498255252', 'sessssssssssss', 'user5694@gmail.com', '5498255252', '$2b$10$gTdZaUVArgH6UWuKslvrTOxuRx1RY1gwaOBmjL.6lKXCYDWjI7vEi', '595959vfd', '2025-05-01 08:37:15', 'frontliner'),
(78, '8638787110', 'ascece', 'rogoxic619@firain.com', '8638787110', '$2b$10$CZNmBsGQydz2EmJiDzATeOTdzzmrv9mZ5Um3bJ3rEt8nBgohfbflO', 'efgeggef', '2025-05-02 09:31:19', 'frontliner'),
(79, '4272727225', 'sdv', 'userdrfhtf41714@gmail.com', '4272727225', '$2b$10$xj8/TvhJ..GBG81tOSEzCebWTf1/n.1At6GiKotIHd.UDTTBLqoCO', '5252hgngh', '2025-05-02 09:39:23', 'frontliner'),
(80, '8535838638', 'wedwe', 'user58hty@gmail.com', '8535838638', '$2b$10$AxDtJEg0PxLYtayW6Ep3uubjWcoAoEYe/mETTgriyl1llGXPXJs9C', 'vrtrtrt', '2025-05-02 09:40:34', 'facilitator'),
(81, '8522552525', 'dfbdfn', 'coordinatoruser@gmail.com', '8522552525', '$2b$10$s804NJQ1L3.eI43XVTL4veVDlLygwIbtWnsi753pMRI6Sk8VEXaZq', 'dvververb', '2025-05-02 09:41:26', 'Coordinator'),
(82, '4257252525', 'scsd', 'userdfbgb@gmail.com', '4257252525', '$2b$10$kPRjgXosEnLMPiJ0Y1b1eekucnXReY6J/nhROrHQvtSOYP//eeaRq', '123456', '2025-05-02 09:48:39', 'facilitator'),
(84, '4257252511', 'dcdc', 'userdfbgfbbg@gmail.com', '4257252511', '$2b$10$jJY9xmPJ7KYR6GfLlS1aKOX6QCjsAWPdKRxb5YdoIaLc1xSBjFyNO', '123456', '2025-05-02 09:49:43', 'facilitator'),
(85, '5353336383', 'Coordinator fbbb', 'userCoordinator@gmail.com', '5353336383', '$2b$10$YcWMRwyDg91aeM/jNU0SqOVzE0xYDCZHAWylu/329f1eT.BEvgavG', '123456', '2025-05-02 09:53:46', 'facilitator'),
(86, '5353336183', 'fgj', 'userCoordfinator@gmail.com', '5353336183', '$2b$10$8OJc/JHMz5nJGSPwkAkI6.zu8xr9tvuVZLwluyW4D79WuTcLIrk46', '123456', '2025-05-02 09:54:30', 'facilitator'),
(87, '2832828282', 'dfvfvfdv', 'usersdgdg@gmail.com', '2832828282', '$2b$10$LBzMz.fFOrOWeRKWpclkh.94xBKhb0TC52uWyWYKrxpXFo.h2053e', '123456', '2025-05-02 09:58:10', 'coordinator'),
(88, '8283268683', 'scdsc', 'userrgd@gmail.com', '8283268683', '$2b$10$ZBrcU8WkcQsCUDY/HagAAeJ7qILCqccxBhfLdjbB5HeITVcooEwZK', '987456', '2025-05-02 10:00:20', 'Coordinator'),
(89, '1642614246', 'ascsc', 'userascsc@gmail.com', '1642614246', '$2b$10$YtUHtShsNDP1leU3thfWeelCgHGL6P5RdeHgoC.IKjC64dGlyDqvW', '987456', '2025-05-02 10:02:14', 'Coordinator'),
(90, '6295988998', 'dvcs', 'userdscsdc5@gmail.com', '6295988998', '$2b$10$PLyUP4RL8JSSb.0j22l6Y.yGRrmXf56f5fqiEtJdVqr51xVttbaje', '987456', '2025-05-02 10:02:55', 'facilitator'),
(91, '6295988900', 'aaa', 'userdscsdc5.0@gmail.com', '6295988900', '$2b$10$uKOyyAsAPnbWJUXYDHXL2OhiNp40Bp52xJBbu2boKBXhDgdtcF9eS', '987456', '2025-05-02 10:03:21', 'facilitator'),
(92, '7222282828', 'dhdd', 'userfoog@gmail.com', '7222282828', '$2b$10$24hb838uMvAqS15OSraMK.SVu9tSpRGsteUAebIs4x.p3r9kZDm0u', '852963', '2025-05-02 10:05:09', 'Coordinator'),
(93, '7222282800', 'fkmg', 'userfoog71@gmail.com', '7222282800', '$2b$10$GaveZHsSuRgJ1syeZa/QE.8EFXDe3whLwG8wU441SAomUHncEvLsS', '741852', '2025-05-02 10:05:39', 'facilitator'),
(94, '7222282801', 'dfvfv', 'xiroc70313@exitings.com', '7222282801', '$2b$10$JIvuvpMRdCgJyFJQUer7medW.UtSBoVbz6zMn9UhVwFwFwhWpJpAu', '123456', '2025-05-02 10:07:11', 'facilitator'),
(95, '4242525252', 'cjch', 'userbio@gmail.com', '4242525252', '$2b$10$MWqZg88AAxs4NIXDR9/ZbeKYlZnv.wEhfsuPc8OiBfvncNtUwtVUG', '123456', '2025-05-02 10:11:12', 'frontliner'),
(96, '3416546846', 'ram', 'userram123@gmail.com', '3416546846', '$2b$10$m3fpN3ip/pqDqdSQDXTzkuxXfKyj6dKOcGSwafNw3O6SlmHsV12Gu', '123456', '2025-05-02 13:35:25', 'frontliner'),
(97, '6465848948', 'vvv', 'cogel97563@nutrv.com', '6465848948', '$2b$10$PVYMOeGiqtq2kR3407F6RulBtAYmixy4LcvlTSu.N.SZi4WNYfuTC', '123456', '2025-05-03 06:12:41', 'facilitator'),
(98, '5425282828', 'grgre', 'usersdfdsv@gmail.com', '5425282828', '$2b$10$c0Lh8VdaSGLKB/WDCfr4pe2RmnwPxaVGuiO8XGMBM3peewcpg8ZYG', '123456', '2025-05-05 10:17:18', 'frontliner'),
(99, '8948144912', 'wf', 'user522@gmail.com', '8948144912', '$2b$10$vb7NBRwtaIfIkU8qQGnjTO4K8AjWJmfR2WOCmrwUtsHVq0HPkOIgq', '123456', '2025-05-05 10:17:53', 'frontliner'),
(100, '5852829824', 'sdvds', 'usersv252@gmail.com', '5852829824', '$2b$10$i/4SwhCZeBAFy23b1MNOwe3Kc3RSGoOYc6vF2HrxKPcNoDS6K1QI2', 'sdv', '2025-05-05 10:20:52', 'frontliner'),
(101, '2525553263', 'vdfv', 'sharevsvsvf@gmail.com', '2525553263', '$2b$10$pCHNzOzf2/HZmiA2d16GvuBM.7IrrLDVGhQVi7wKzw0v1/ZZq5IqS', '123456', '2025-05-05 10:22:29', 'Coordinator'),
(102, '7838886383', 'sd', 'sharevsvsvddf@gmail.com', '7838886383', '$2b$10$Ai/iM.DW6DGuOB5eNqKIUehJu55aKi./wcO9vKdvqZ9zHxMFJV4CC', '123456', '2025-05-05 10:22:58', 'facilitator');

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
(271, '2025-04-21 06:08:43', 'Nachiketa', 273),
(273, '2025-04-20 07:07:10', 'DYS-2', 274),
(274, '2025-04-20 07:07:11', 'Nachiketa', 265),
(275, '2025-04-20 09:50:28', 'Nachiketa', 273),
(279, '2025-04-21 05:24:23', 'Nachiketa', 265),
(280, '2025-04-24 05:24:23', 'Nachiketa', 265),
(281, '2025-05-21 05:24:23', 'Nachiketa', 265),
(285, '2025-06-21 05:24:23', 'Nachiketa', 265),
(286, '2025-06-21 05:24:23', 'Nachiketa', 327),
(287, '2025-06-22 05:24:23', 'Nachiketa', 265),
(288, '2025-04-25 11:36:24', 'Shadev', 267),
(289, '2025-04-25 11:40:00', 'Arjun', 322),
(290, '2025-04-28 00:01:45', 'Shadev', 326),
(291, '2025-04-28 05:12:25', 'Nakul', 270),
(292, '2025-04-29 07:21:52', 'Nachiketa', 273),
(297, '2025-04-29 07:21:56', 'DYS-1', 332),
(298, '2025-04-29 07:23:37', 'DYS-1', 341),
(299, '2025-04-29 07:23:38', 'DYS-1', 339),
(300, '2025-04-29 07:23:39', 'DYS-1', 337),
(301, '2025-04-29 07:23:40', 'DYS-1', 329),
(302, '2025-04-29 07:23:41', 'DYS-1', 328),
(303, '2025-04-29 07:23:42', 'DYS-1', 342),
(304, '2025-04-29 07:26:21', 'DYS-2', 328),
(305, '2025-04-29 07:29:23', 'Nakul', 270),
(306, '2025-04-29 14:10:41', 'DYS-3', 328),
(307, '2025-04-29 16:48:29', 'Shadev', 326),
(309, '2025-04-30 07:56:36', 'DYS-1', 334),
(310, '2025-04-30 07:56:37', 'DYS-1', 338),
(311, '2025-04-30 08:02:52', 'DYS-1', 345),
(313, '2025-04-30 08:24:07', 'Nakul', 270),
(315, '2025-04-30 08:24:09', 'Arjun', 269),
(316, '2025-04-30 08:24:09', 'GourangSabha', 266),
(317, '2025-04-30 08:45:55', 'Shadev', 313),
(318, '2025-04-30 10:37:04', 'Shadev', 326),
(322, '2025-04-30 11:53:13', 'Nachiketa', 271),
(323, '2025-04-30 11:57:02', 'Nachiketa', 271),
(324, '2025-04-30 12:09:46', 'DYS-1', 348),
(325, '2025-04-30 12:09:47', 'DYS-1', 347),
(326, '2025-04-30 12:09:48', 'DYS-1', 343),
(327, '2025-04-30 12:09:48', 'DYS-1', 333),
(328, '2025-05-08 12:50:26', 'DYS-1', 417),
(329, '2025-05-09 11:44:45', 'Shadev', 326),
(330, '2025-05-09 11:45:21', 'Shadev', 326),
(331, '2025-05-10 08:07:43', 'Shadev', 326),
(332, '2025-05-10 08:07:49', 'Jagganath', 276),
(333, '2025-05-13 17:48:40', 'Shadev', 326),
(334, '2025-05-13 17:49:26', 'Nachiketa', 272),
(335, '2025-05-13 17:49:28', 'Nachiketa', 271),
(336, '2025-05-13 17:49:31', 'DYS-3', 274),
(337, '2025-05-22 13:58:45', 'DYS-1', 421),
(338, '2025-05-22 16:52:05', 'DYS-3', 332),
(339, '2025-05-22 16:52:33', 'DYS-5', 332),
(340, '2025-05-22 17:00:54', 'DYS-6', 274),
(341, '2025-05-22 17:01:13', 'DYS-1', 270),
(342, '2025-05-22 17:05:36', 'DYS-6', 274),
(343, '2025-05-22 17:05:49', 'DYS-3', 270),
(344, '2025-05-22 17:06:12', 'DYS-5', 270),
(345, '2025-05-22 17:11:36', 'DYS-2', 417),
(346, '2025-05-22 17:21:00', 'DYS-1', 401),
(347, '2025-05-22 17:21:00', 'DYS-1', 340),
(348, '2025-05-22 17:21:00', 'Arjun', 265),
(349, '2025-05-23 10:36:02', 'DYS-1', 418),
(350, '2025-05-23 10:52:40', 'DYS-1', 419),
(351, '2025-05-23 11:35:02', 'DYS-1', 412),
(352, '2025-05-23 11:41:50', 'Shadev', 326),
(353, '2025-05-23 14:02:36', 'DYS-1', 426),
(354, '2025-05-23 16:06:55', 'DYS-1', 388),
(355, '2025-05-24 06:22:08', 'DYS-4', 270),
(356, '2025-05-24 06:29:28', 'DYS-5', 270),
(357, '2025-05-24 06:30:29', 'DYS-6', 270),
(358, '2025-05-24 06:59:08', 'DYS-6', 421),
(359, '2025-05-24 07:00:17', 'DYS-1', 424),
(360, '2025-05-24 07:52:26', 'DYS-6', 426),
(361, '2025-05-24 07:53:46', 'DYS-4', 418),
(362, '2025-05-24 07:54:30', 'DYS-3', 418),
(363, '2025-05-24 08:10:12', 'DYS-6', 418),
(364, '2025-05-24 09:31:58', 'DYS-4', 274),
(365, '2025-05-24 09:34:49', 'DYS-5', 424),
(366, '2025-05-24 09:41:46', 'DYS-6', 426),
(367, '2025-05-24 12:42:33', 'DYS-6', 274),
(368, '2025-05-24 12:47:30', 'DYS-6', 419),
(369, '2025-05-24 13:10:02', 'DYS-1', 423),
(370, '2025-05-26 05:59:07', NULL, 388),
(371, '2025-05-26 05:59:32', NULL, 426),
(372, '2025-05-26 05:59:56', 'DYS-1', 425),
(373, '2025-05-26 06:16:32', NULL, 274),
(374, '2025-05-26 06:17:07', 'DYS-1', 422),
(375, '2025-05-26 06:19:16', NULL, 269),
(376, '2025-05-26 06:20:02', 'DYS-1', 420),
(377, '2025-05-26 06:20:31', 'DYS-5', 424),
(378, '2025-05-26 06:21:02', 'Jagganath', 276),
(379, '2025-05-26 06:25:42', 'DYS-6', 270);

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
(35, NULL, '2025-04-14', NULL, 'HG604238', 1),
(36, NULL, '2025-04-14', NULL, 'VIM920063', 1),
(37, NULL, '2025-04-14', NULL, 'HGV442127', 1),
(38, NULL, '2025-04-14', NULL, 'HG573659', 1),
(39, NULL, '2025-04-28', NULL, 'HGV442127', 1),
(40, NULL, '2025-04-29', NULL, 'HG604238', 1),
(41, NULL, '2025-04-30', NULL, 'HG 930923', 1),
(42, NULL, '2025-04-30', NULL, 'MAD427947', 1),
(43, NULL, '2025-05-19', NULL, 'VIM920063', 0),
(44, NULL, '2025-05-19', NULL, 'HG 930923', 0);

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `task_id` int(11) NOT NULL,
  `user_id` varchar(50) NOT NULL,
  `task_text` text DEFAULT NULL,
  `end_time` datetime NOT NULL,
  `create_date` datetime DEFAULT current_timestamp(),
  `status` enum('pending','completed') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`task_id`, `user_id`, `task_text`, `end_time`, `create_date`, `status`) VALUES
(21, 'HG573659', 'bjbj', '2025-05-15 09:10:00', '2025-05-05 14:40:34', 'pending'),
(29, 'HG433572', 'new task upadate \n\n\n\n', '2025-05-07 10:38:00', '2025-05-07 13:08:05', 'pending'),
(54, 'HG433572', 'new', '2025-05-16 18:23:00', '2025-05-07 19:49:33', 'pending'),
(57, 'CHA258408', 'Hwjwuwujwwj\nWmjwjw\nWkwjw', '2025-05-08 02:14:00', '2025-05-08 05:44:40', 'completed'),
(58, 'CHA258408', 'Me wjwuwwjwu22', '2025-05-08 04:14:00', '2025-05-08 05:44:51', 'pending'),
(60, 'HG573659', 'check ', '2025-05-08 13:07:00', '2025-05-08 15:33:08', 'pending'),
(61, 'HG573659', 'new', '2025-05-08 11:05:00', '2025-05-08 15:33:48', 'completed'),
(62, 'HG573659', 'nimai ', '2025-05-08 12:04:00', '2025-05-08 15:35:00', 'completed'),
(63, 'HG573659', 'df', '2025-04-18 08:30:00', '2025-05-08 15:40:40', 'completed'),
(64, 'HG573659', 'dsf', '2025-05-08 12:22:00', '2025-05-08 15:49:25', 'completed'),
(65, 'HG573659', 'Vkbdondjx', '2025-05-08 10:35:00', '2025-05-08 16:05:32', 'completed'),
(68, 'HHX372882', 'sdcdsvd', '2025-05-08 12:29:00', '2025-05-08 17:59:46', 'pending'),
(69, 'HHX372882', 'dvfdvfv', '2025-05-08 12:31:00', '2025-05-08 18:01:38', 'pending'),
(70, 'HHX372882', 'ewcvf', '2025-05-08 12:31:00', '2025-05-08 18:02:01', 'completed'),
(71, 'HHX372882', 'd  d VFBGBGHG', '2025-05-08 07:04:00', '2025-05-08 18:03:52', 'completed'),
(72, 'HHX372882', 'swdw', '2025-05-08 13:17:00', '2025-05-08 18:47:27', 'pending'),
(74, 'HHX372882', 'dfbfbfdbf', '2025-05-09 08:09:00', '2025-05-09 13:39:22', 'completed'),
(75, 'HHX372882', 'dvdfbfdb ', '2025-05-09 08:10:00', '2025-05-09 13:40:25', 'pending'),
(76, 'HHX372882', 'sdvcdsvdsvdsdfbgfbgf ', '2025-05-09 02:40:00', '2025-05-09 13:40:41', 'completed'),
(77, 'HHX372882', 'cvbgbgfsddbd', '2025-05-09 02:41:00', '2025-05-09 13:41:09', 'completed'),
(78, 'HHX372882', 'dfb', '2025-05-09 08:11:00', '2025-05-09 13:41:27', 'completed'),
(80, 'HG368829', 'kjbkjbkjnkj', '2025-05-09 13:47:00', '2025-05-09 19:17:37', 'pending'),
(81, 'HG368829', 'vhgvhgvhvjhv', '2025-05-09 13:47:00', '2025-05-09 19:17:51', 'pending'),
(82, 'HG368829', 'kbjbjbjbjbj', '2025-05-09 13:49:00', '2025-05-09 19:19:19', 'pending'),
(84, 'HHX372882', 'jjghhhhh', '2025-05-23 13:00:00', '2025-05-10 14:30:17', 'completed'),
(85, 'HHX372882', 'gbngfngngghhg ddddd', '2025-05-09 21:02:00', '2025-05-10 14:31:41', 'completed'),
(87, 'HHX372882', 'cfbfgngfnfgn g dthtfht ftghgf ', '2025-05-10 09:06:00', '2025-05-10 14:32:25', 'completed'),
(88, 'HHX372882', 'cxbcvnn g', '2025-05-10 09:06:00', '2025-05-10 14:34:16', 'completed'),
(89, 'HHX372882', 'wok', '2025-05-10 16:10:00', '2025-05-10 14:34:55', 'completed'),
(90, 'HHX372882', 'ghtj ytjyj ghjy     hjkyukukuyk ', '2025-05-17 10:23:00', '2025-05-10 15:53:35', 'completed');

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
  `student_status` varchar(100) DEFAULT NULL,
  `facilitator_id` int(11) DEFAULT NULL,
  `razorpay_payment_id` varchar(100) DEFAULT NULL,
  `frontliner_id` varchar(255) DEFAULT NULL,
  `calling_id` varchar(36) DEFAULT NULL,
  `student_status_date` datetime DEFAULT NULL,
  `group_name` varchar(100) DEFAULT NULL,
  `batch_id` int(11) DEFAULT NULL,
  `facilitatorId` varchar(100) DEFAULT NULL,
  `location_url` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `name`, `dob`, `mobile_number`, `frontliner_name`, `profession`, `address`, `class_mode`, `payment_mode`, `payment_amount`, `payment_status`, `referral_user_id`, `chanting_round`, `email`, `photo`, `rating`, `services`, `city`, `state`, `permanent_address`, `remark`, `skill`, `comment`, `interest`, `hobby`, `study_field`, `father_occupation`, `father_number`, `sankalp_camp`, `registration_date`, `gender`, `student_status`, `facilitator_id`, `razorpay_payment_id`, `frontliner_id`, `calling_id`, `student_status_date`, `group_name`, `batch_id`, `facilitatorId`, `location_url`) VALUES
(265, ' dsvdsvdsvds fvbfrbvfdbdf', '2025-05-07', '894614722', NULL, 'job_candidate', 'near clock tower ', 'online', 'cash', 200.00, 'received', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 13:43:59', NULL, 'will_come', NULL, NULL, 'NIL185406', 'GOV630188', '2025-05-01 11:34:34', 'Arjun', 38, 'HG573659', NULL),
(266, 'Mohan', '2025-05-12', '825614723', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'received', NULL, 5, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 11:46:59', NULL, 'will_come', NULL, NULL, 'NIL185406', 'GOV630188', '2025-04-26 10:37:10', 'GourangSabha', 38, 'HG573659', NULL),
(267, 'dindyal ', '2025-03-24', '895314724', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'received', NULL, 3, 'user@gmail.com', NULL, 16, NULL, 'no', 'State', 'gggggggg', 'vv', 'dsvds', 'dg1', 'ggggggggggg', 'vd', 'd', 'dgvfdvdvdv', 'dg', 1, '2025-04-13 23:16:59', 'male', 'will_come', NULL, NULL, 'NIL185406', 'GOV630188', '2025-05-01 11:32:33', 'Arjun', 38, 'HG573659', NULL),
(268, 'Rounak', '2025-04-03', '899614725', NULL, 'job_candidate', 'near clock tower ', 'online', 'cash', 200.00, 'received', NULL, 2, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-16 11:22:59', NULL, 'will_come', NULL, NULL, 'NIL185406', 'HGD586232', '2025-04-30 16:32:27', 'Nakul', 36, 'HGD586232', NULL),
(269, 'Tarun', '2025-10-04', '825614726', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'received', NULL, 1, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-17 11:21:59', NULL, 'will_come', NULL, NULL, 'NIL185406', 'MAD972745', '2025-04-30 12:29:58', NULL, 37, 'HGV442127', NULL),
(270, 'Parikshit', '2025-04-02', '896614727', NULL, 'job_candidate', 'near clock tower ', 'online', 'cash', 200.00, 'received', NULL, 12, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-18 11:20:30', NULL, 'will_come', NULL, NULL, 'NIL185406', 'GOV630188', '2025-05-01 11:33:03', 'DYS-6', 43, 'VIM920063', NULL),
(271, 'Jack', '2025-05-28', '895694728', 'dvvdv', 'job_candidate', 'near clock tower ', 'online', 'online', 200.00, 'received', NULL, 3, 'userdsvdv@gmail.com', NULL, 1, NULL, 'dvd', 'dv', 'vdv', 'b', 'dvd', 'bd', 'dv', 'vd', 'dv', 'vd', 'vd', 5, '2025-06-18 13:20:30', 'male', 'will_come', NULL, NULL, 'NIL185406', 'GOV630188', '2025-05-05 15:32:43', 'Nachiketa', 35, 'HG368829', 'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3560.3016556978523!2d75.74786918046898!3d26.830356193211035!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x396db57ac44ce2e3%3A0xd3f1209a49690'),
(272, 'Sourav', '2025-06-02', '895674729', NULL, 'job_candidate', 'near clock tower ', 'online', 'online', 200.00, 'received', NULL, 2, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-20 11:20:30', NULL, 'busy', NULL, NULL, 'NIL185406', 'GOV630188', '2025-05-06 13:32:39', 'Nachiketa', 35, 'HG368829', NULL),
(273, 'Sunil', '2025-06-01', '895146610', NULL, 'job_candidate', 'near clock tower ', 'online', 'online', 200.00, 'received', NULL, 2, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-18 11:21:30', NULL, 'will_come', NULL, NULL, 'NIL185406', 'GOV630188', '2025-05-06 09:29:02', 'Nachiketa', 36, 'HGD586232', NULL),
(274, 'pankaj', '2025-06-05', '895644711', NULL, 'job_candidate', 'near clock tower ', 'online', 'cash', 200.00, 'received', NULL, 1, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-18 11:23:30', NULL, 'will_come', NULL, NULL, 'NIL185406', 'GOV630188', '2025-05-06 09:07:10', NULL, 36, 'HGD586232', NULL),
(275, 'shayam', '2025-06-10', '895666712', NULL, 'job_candidate', 'near clock tower ', 'online', 'cash', 200.00, 'received', NULL, 5, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-19 11:20:30', NULL, 'busy', NULL, NULL, 'NIL185406', 'GOU136850', '2025-04-26 09:48:25', 'Nachiketa', 35, 'HG368829', NULL),
(276, 'keshav', '2025-06-12', '895564713', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'received', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-06-20 11:20:30', NULL, 'might_come', NULL, NULL, 'NIL185406', 'GOU136850', NULL, 'Jagganath', 35, 'HG368829', NULL),
(277, 'surendra', '2025-06-09', '899614714', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'received', NULL, 6, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-01-20 11:20:30', NULL, 'might_come', NULL, NULL, 'NIL185406', 'GOU136850', NULL, 'GourangSabha', 35, 'HG368829', NULL),
(313, 'vinay dfvdvdvd', '2025-06-02', '128797352', NULL, 'student', 'near shubham circle ', 'online', 'cash', 100.00, 'received', NULL, 5, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 09:34:13', NULL, 'not_interested', NULL, NULL, 'ROH634115', 'BAL123410', '2025-05-06 10:11:31', 'Shadev', 38, 'HG573659', NULL),
(314, 'vaibhav', '2025-04-12', '128797353', NULL, 'student', 'near shubham circle ', 'online', 'cash', 100.00, 'received', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'not_interested', NULL, NULL, 'ROH634115', 'BAL123410', '2025-05-06 10:11:20', 'DYS-4', 36, 'HGD586232', NULL),
(315, 'vikas', '2025-04-12', '741797354', NULL, 'student', 'near shubham circle ', 'online', 'unpaid', 100.00, 'received', NULL, 5, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'not_interested', NULL, NULL, 'ROH634115', 'BAL123410', '2025-05-06 10:10:50', 'Nakul', 37, 'HGV442127', NULL),
(316, 'veenit', '2025-04-12', '741287355', NULL, 'student', 'near shubham circle ', 'online', 'unpaid', 100.00, 'received', NULL, 9, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'not_interested', NULL, NULL, 'ROH634115', 'BAL123410', '2025-05-06 10:11:07', 'Jagganath', 35, 'HG368829', NULL),
(317, 'vikrant', '2025-04-12', '748797356', NULL, 'student', 'near shubham circle ', 'online', 'cash', 100.00, 'received', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'not_interested', NULL, NULL, 'ROH634115', 'BAL123410', '2025-05-06 10:10:38', 'Arjun', 37, 'HGV442127', NULL),
(318, 'veermadhav', '2025-04-12', '741287356', NULL, 'student', 'near shubham circle ', 'online', 'online', 100.00, 'received', NULL, 7, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'might_come', NULL, NULL, 'ROH634115', 'HG604238', '2025-04-30 16:49:13', 'Nakul', 37, 'HGV442127', NULL),
(319, 'shayma', '2025-04-12', '728797358', NULL, 'student', 'near shubham circle ', 'online', 'online', 100.00, 'received', NULL, 2, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'might_come', NULL, NULL, 'ROH634115', 'CHA258408', '2025-05-03 15:24:45', 'DYS-2', 35, 'HG368829', NULL),
(320, 'jack', '2025-04-12', '741297359', NULL, 'student', 'near shubham circle ', 'online', 'cash', 100.00, 'received', NULL, 1, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'GOV630188', '2025-05-01 07:02:05', 'DYS-3', 35, 'HG368829', NULL),
(321, 'raj', '2025-04-12', '741287310', NULL, 'student', 'near shubham circle ', 'online', 'cash', 100.00, 'received', NULL, 1, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'not_interested', NULL, NULL, 'ROH634115', 'HG604238', '2025-04-30 16:49:02', 'Arjun', 38, 'HG573659', NULL),
(322, 'madhav', '2025-04-12', '741287358', NULL, 'student', 'near shubham circle ', 'online', 'online', 100.00, 'received', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'will_come', NULL, NULL, 'ROH634115', 'HG604238', '2025-04-29 11:24:30', 'Arjun', 37, 'HGV442127', NULL),
(323, 'mohan', '2025-04-12', '74128335', NULL, 'student', 'near shubham circle ', 'online', 'cash', 100.00, 'received', NULL, 9, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 15:04:13', NULL, 'might_come', NULL, NULL, 'ROH634115', 'HG604238', '2025-04-28 23:09:32', 'DYS-3', 35, 'HG368829', NULL),
(324, 'Abhay', '2025-05-12', '825614725', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'received', NULL, 5, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 11:46:59', NULL, 'will_come', NULL, NULL, 'NIL185406', 'MAD972745', '2025-04-30 12:30:12', 'Arjun', 38, 'HG573659', NULL),
(325, 'Rohan', '2025-04-05', 'p', NULL, 'student', 'Mansrover', 'offline', 'online', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-23 05:54:49', NULL, 'will_come', NULL, 'pay_QMOHzuv4EEpk3o', 'NIT106966', 'BHA843784', NULL, 'new', NULL, NULL, NULL),
(326, 'HariHar', '2025-05-11', '894614459', NULL, 'job_candidate', 'near clock tower ', 'online', 'cash', 200.00, 'received', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, 'Goloka Vrindavan', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-09-15 11:43:59', NULL, 'will_come', NULL, NULL, 'NIL185406', 'MAD972745', '2025-05-02 09:04:31', 'Shadev', 38, 'HG573659', NULL),
(327, 'navyogendra', '2025-05-12', '825618695', NULL, 'job_candidate', 'near clock tower ', 'online', 'unpaid', 200.00, 'received', NULL, 5, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-14 11:46:59', NULL, 'will_come', NULL, NULL, 'NIL185406', 'MAD972745', '2025-05-06 09:23:28', 'Arjun', 38, 'HG573659', NULL),
(328, 'Shubham', '2025-04-05', '895623147', NULL, 'student', 'clock tower', 'offline', 'online', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-25 14:45:43', NULL, 'busy', NULL, 'pay_QNKP2l0O0ATWcp', 'CHA258408', 'HG368829', '2025-04-25 15:21:02', 'DYS-3', 40, 'HG604238', NULL),
(329, 'nihal', '2025-04-12', '785412369', NULL, 'job_candidate', 'new clock 2', 'offline', 'unpaid', 200.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-25 14:50:07', NULL, 'wefergregr', NULL, NULL, 'CHA258408', 'GOV630188', '2025-05-12 15:29:07', 'DYS-1', 40, 'HG604238', NULL),
(330, 'vvvvvvvvvvvvvvvv', NULL, '8585858585', NULL, 'student', NULL, 'online', 'cash', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-28 12:03:38', NULL, 'will_come', NULL, NULL, 'GOV986886', 'GOV630188', '2025-05-03 11:33:56', 'new', NULL, NULL, NULL),
(331, 'cdcd', '2025-04-30', '8338553535', NULL, 'job_candidate', NULL, 'online', 'cash', 200.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-28 12:08:26', NULL, NULL, NULL, NULL, 'GOV986886', 'BHA843784', NULL, 'new', NULL, NULL, NULL),
(332, 'lll', NULL, '5282828280', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-28 12:11:48', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'DYS-5', 39, 'HGV442127', NULL),
(333, 'dscdsc', NULL, '2853853583', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-28 14:58:54', NULL, NULL, NULL, NULL, 'GOU136850', 'GOU136850', NULL, 'Nachiketa', 42, 'MAD427947', NULL),
(334, 'scdscsc', NULL, '5353636632', NULL, 'student', NULL, 'offline', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-28 15:14:43', NULL, NULL, NULL, NULL, 'GOV630188', 'GOV630188', NULL, 'DYS-1', 40, 'HG604238', NULL),
(335, 'dsc', NULL, '7527257278', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-28 15:18:36', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'new', NULL, NULL, NULL),
(336, 'sdcs', '2025-04-30', '7283283225', NULL, 'student', NULL, 'offline', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-28 15:20:50', NULL, 'busy', NULL, NULL, 'GOU136850', 'GOU136850', '2025-05-03 08:28:41', 'new', NULL, NULL, NULL),
(337, 'ccc', '2025-04-23', '5778558528', NULL, 'job_candidate', NULL, 'offline', 'cash', 200.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-28 15:22:02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'DYS-1', 40, 'HG604238', NULL),
(338, 'dvdvdv', NULL, '6569484860', NULL, 'job_candidate', NULL, 'offline', 'cash', 200.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-28 15:23:24', NULL, NULL, NULL, NULL, 'GOU136850', 'GOU136850', NULL, 'DYS-1', 40, 'HG604238', NULL),
(339, 'dsc', NULL, '4383787327', NULL, 'student', NULL, 'offline', 'unpaid', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-28 15:23:52', NULL, NULL, NULL, NULL, 'GOU136850', 'GOU136850', NULL, 'DYS-1', 40, 'HG604238', NULL),
(340, 'dgr', '2025-04-30', '5272572556', NULL, 'student', NULL, 'offline', 'online', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-28 15:25:08', NULL, NULL, NULL, 'pay_QOR3Wz7UEv1bfJ', 'GOU136850', 'GOU136850', NULL, 'DYS-1', 43, 'VIM920063', NULL),
(341, 'Rohit', '2025-04-19', '7845962310', NULL, 'job_candidate', NULL, 'online', 'online', 200.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-29 07:09:15', NULL, NULL, NULL, 'pay_QOmlLRJ6TMxoQt', 'HG433572', 'HG433572', NULL, 'DYS-1', 40, 'HG604238', NULL),
(342, 'nitin ', '2025-04-12', '7894561230', NULL, 'student', NULL, 'online', 'cash', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-29 07:15:50', NULL, NULL, NULL, NULL, 'BHA843784', 'BHA843784', NULL, 'DYS-1', 40, 'HG604238', NULL),
(343, 'harsh', '2025-04-12', '8956213470', NULL, 'student', NULL, 'online', 'online', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-30 07:09:40', NULL, 'not_interested', NULL, 'pay_QPBItjMxFd36gZ', 'CHA258408', 'GOV630188', '2025-05-06 13:51:55', 'Nachiketa', 42, 'MAD427947', NULL),
(345, 'navneet12', '2025-04-11', '8956231470', NULL, 'job_candidate', NULL, 'online', 'cash', 200.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-30 07:13:05', NULL, 'will_come', NULL, NULL, 'CHA258408', 'GOV630188', '2025-05-06 13:52:49', 'DYS-1', 41, 'HG 930923', NULL),
(347, 'ISKCON Jaipur', '2025-04-19', '8956231475', NULL, 'student', NULL, 'offline', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-30 08:55:57', NULL, NULL, NULL, NULL, 'HG573659', 'HG573659', NULL, 'Nachiketa', 42, 'MAD427947', NULL),
(348, 'fghgf', NULL, '6969699696', NULL, 'student', NULL, 'offline', 'online', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-30 16:11:23', NULL, NULL, NULL, 'pay_QPEuYM4wWZWGJt', 'HG433572', 'HG433572', NULL, 'Nachiketa', 42, 'MAD427947', NULL),
(349, 'giriraj', NULL, '9214321623', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-30 12:27:18', NULL, NULL, NULL, NULL, 'HG573659', 'HG573659', NULL, 'new', NULL, NULL, NULL),
(350, 'Rohan', NULL, '434343434', NULL, 'student', NULL, 'online', 'unpaid', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-30 12:27:54', NULL, 'will_come', NULL, NULL, 'HG573659', 'HG573659', NULL, 'new', NULL, NULL, NULL),
(351, 'Rohan9', NULL, '9214321623dddd', NULL, 'student', NULL, 'offline', 'unpaid', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-30 12:28:21', NULL, 'will_come', NULL, NULL, 'HG573659', 'HG573659', NULL, 'new', NULL, NULL, NULL),
(352, 'dvv', NULL, '7845258963', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-04-30 18:25:01', NULL, NULL, NULL, NULL, 'HG433572', 'HG433572', NULL, 'new', NULL, NULL, NULL),
(353, 'dgrdhg', NULL, '9588943248', NULL, 'student', NULL, 'online', 'cash', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-01 13:08:46', NULL, 'will_come', NULL, NULL, 'ROH634115', 'GOV630188', '2025-05-03 08:50:39', 'new', NULL, NULL, NULL),
(354, 'dfgdb', NULL, '4563543580', NULL, 'student', NULL, 'online', 'cash', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-01 13:19:05', NULL, 'busy', NULL, NULL, 'GOV986886', '3416546846', '2025-05-02 13:27:05', 'new', NULL, NULL, NULL),
(355, 'Alok', NULL, '4563543555', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-01 13:19:05', NULL, 'will_come', NULL, NULL, 'GOV986886', 'GOV630188', '2025-05-03 11:33:56', 'new', NULL, NULL, NULL),
(356, 'Mukund', NULL, '4563543563', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-01 13:19:05', NULL, 'will_come', NULL, NULL, 'GOV986886', 'GOV630188', '2025-05-03 11:33:56', 'new', NULL, NULL, NULL),
(357, 'Rohan', '2025-05-03', '8956234710', NULL, 'job_candidate', NULL, 'offline', 'cash', 200.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-01 08:45:51', NULL, 'will_come', NULL, NULL, 'CHA258408', 'CHA258408', '2025-05-01 09:27:37', 'new', NULL, NULL, NULL),
(358, 'Rohan', '2025-05-10', '895472310', NULL, 'job_candidate', NULL, 'offline', 'online', 200.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-01 08:56:45', NULL, 'not_interested', NULL, 'pay_QPbf91SZlTcVXR', 'CHA258408', 'CHA258408', NULL, 'new', NULL, NULL, NULL),
(359, 'dfbgfbfdbfd', NULL, '8956159521', NULL, 'student', 'zxz', 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-01 19:38:58', NULL, 'will_come', NULL, NULL, 'CHA258408', 'GOV630188', '2025-05-02 07:44:14', 'new', NULL, NULL, NULL),
(360, 'ascfdsv', NULL, '4649999590', NULL, 'student', 'sxcs', 'offline', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-01 19:39:41', NULL, 'will Come', NULL, NULL, 'CHA258408', 'GOV630188', '2025-05-12 15:30:01', 'new', NULL, NULL, NULL),
(361, 'dcdc', NULL, '6356589590', NULL, 'job_candidate', NULL, 'offline', 'cash', 200.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-01 19:40:08', NULL, 'will Come', NULL, NULL, 'CHA258408', 'GOV630188', '2025-05-12 15:32:40', 'new', NULL, NULL, NULL),
(362, 'vaibhav', NULL, '8965321470', NULL, 'job_candidate', NULL, 'online', 'cash', 200.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-01 14:13:18', NULL, 'will_come', NULL, NULL, 'BAL123410', 'CHA258408', '2025-05-02 07:18:54', 'new', NULL, NULL, NULL),
(363, 'madhav', '2025-05-03', '8953147059', NULL, 'job_candidate', NULL, 'online', 'cash', 200.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-01 14:14:38', NULL, 'will_come', NULL, NULL, 'BAL123410', 'CHA258408', '2025-05-02 07:18:27', 'new', NULL, NULL, NULL),
(364, 'chintamani ', '2025-05-03', '8957462130', NULL, 'student', NULL, 'offline', 'online', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 06:10:44', NULL, 'will_come', NULL, 'pay_QPxMt8GmcYg4YI', 'GOV986886', 'CHA258408', '2025-05-02 06:12:49', 'new', NULL, NULL, NULL),
(365, 'madhusudhan', NULL, '8956741230', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 06:15:05', NULL, NULL, NULL, NULL, 'GOV986886', 'GOV630188', NULL, 'new', NULL, NULL, NULL),
(366, 'harsh', NULL, '8521479036', NULL, 'job_candidate', NULL, 'online', 'cash', 200.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 06:16:14', NULL, 'not_interested', NULL, NULL, 'GOV986886', 'CHA258408', '2025-05-02 07:19:29', 'new', NULL, NULL, NULL),
(369, 'Rohit', NULL, '8521479049', NULL, 'job_candidate', NULL, 'online', 'online', 200.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 06:23:50', NULL, 'busy', NULL, 'pay_QPxajnuTwwG1rs', 'GOV986886', 'CHA258408', '2025-05-02 07:19:13', 'new', NULL, NULL, NULL),
(372, 'yugyugyu', NULL, '8521479000', NULL, 'student', NULL, 'online', 'cash', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 13:06:02', NULL, NULL, NULL, NULL, 'ROH634115', 'GOV630188', NULL, 'new', NULL, NULL, NULL),
(374, 'Govind2', NULL, '8956753214', NULL, 'student', NULL, 'online', 'online', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 07:42:08', NULL, NULL, NULL, 'pay_QPyvS2A3fh1lmd', 'CHA258408', 'CHA258408', NULL, 'new', NULL, NULL, NULL),
(380, 'ewfe', NULL, '8521479041', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 13:15:01', NULL, NULL, NULL, NULL, 'ROH634115', 'HAR409147', NULL, 'new', NULL, NULL, NULL),
(381, 'cds', NULL, '2828282820', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 13:16:07', NULL, NULL, NULL, NULL, 'ROH634115', 'HAR409147', NULL, 'new', NULL, NULL, NULL),
(382, 'erg', NULL, '4528283283', NULL, 'student', NULL, 'offline', 'online', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 13:16:59', NULL, NULL, NULL, 'pay_QPz0a0JQ5XGKcg', 'ROH634115', 'HAR409147', NULL, 'new', NULL, NULL, NULL),
(388, 'egr', NULL, '8521479111', NULL, 'student', NULL, 'offline', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 14:45:15', NULL, 'not_interested', NULL, NULL, 'ROH634115', 'HAR409147', '2025-05-03 10:24:43', NULL, 43, 'VIM920063', NULL),
(391, 'vihan', NULL, '7412879735', NULL, 'student', NULL, 'online', 'online', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 13:00:15', NULL, NULL, NULL, 'pay_QQ4LTNeB34mV5p', 'CHA258408', 'CHA258408', NULL, 'new', NULL, NULL, NULL),
(392, 'chinmay', NULL, '9875984210', NULL, 'job_candidate', NULL, 'online', 'unpaid', 200.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 14:00:42', NULL, 'will_come', NULL, NULL, '3416546846', '3416546846', '2025-05-02 14:03:35', 'new', NULL, NULL, NULL),
(393, 'hit', NULL, '8974651230', NULL, 'student', NULL, 'online', 'unpaid', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-02 14:21:27', NULL, 'will_come', NULL, NULL, '3416546846', '3416546846', '2025-05-03 08:32:58', 'new', NULL, NULL, NULL),
(394, 'Alok', NULL, '8974512302', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-03 08:54:50', NULL, 'not_interested', NULL, NULL, 'ROH634115', 'HAR409147', '2025-05-03 10:25:30', 'new', NULL, NULL, NULL),
(395, 'viplav', NULL, '8965743210', NULL, 'job_candidate', NULL, 'online', 'cash', 200.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-03 08:56:36', NULL, 'not_interested', NULL, NULL, 'ROH634115', 'HAR409147', '2025-05-03 10:25:42', 'new', NULL, NULL, NULL),
(396, 'Ashok', NULL, '8569765240', NULL, 'job_candidate', NULL, 'online', 'online', 200.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-03 09:02:52', NULL, 'will_come', NULL, 'pay_QQJDGWnBn6TSQ4', 'MAD972745', 'HAR409147', '2025-05-03 11:35:04', 'new', NULL, NULL, NULL),
(397, 'Ashuthosh', '2025-05-02', '8975684231', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-03 10:58:13', NULL, 'will_come', NULL, NULL, 'MAD972745', 'HAR409147', '2025-05-03 11:35:04', 'new', NULL, NULL, NULL),
(398, 'nakul', NULL, '8975842130', NULL, 'student', NULL, 'offline', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-03 11:11:54', NULL, 'will_come', NULL, NULL, 'MAD972745', 'HAR409147', '2025-05-03 11:35:04', 'new', NULL, NULL, NULL),
(401, 'Lochan', NULL, '6969699698', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-03 13:04:28', NULL, 'will_come', NULL, NULL, 'MAD972745', 'HAR409147', '2025-05-03 08:51:02', 'DYS-1', 43, 'VIM920063', NULL),
(403, 'dcs', NULL, '8965741258', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-03 08:49:39', NULL, NULL, NULL, NULL, 'HHX372882', 'HHX372882', NULL, 'new', NULL, NULL, NULL),
(405, 'Goura', NULL, '4565985412', NULL, 'student', NULL, 'online', 'unpaid', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-03 14:44:22', NULL, 'not_interested', NULL, NULL, '3416546846', 'NIT914777', '2025-05-03 14:51:35', 'new', NULL, NULL, NULL),
(406, '34t43te', NULL, '4844644544', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-03 18:28:22', NULL, 'will_come', NULL, NULL, 'HAR409147', 'CHA258408', '2025-05-03 18:32:42', 'new', NULL, NULL, NULL),
(409, 'dgtrg', '2001-01-01', '7412879738', NULL, 'student', 'd', 'online', 'online', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-05 11:32:21', NULL, NULL, NULL, 'pay_QRERzzQQwx6B9x', 'HG573659', 'HG573659', NULL, 'new', NULL, NULL, NULL),
(411, 'Hari', '2025-05-10', '9214321628', NULL, 'student', 'hi hvdas here', 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-06 07:36:08', NULL, NULL, NULL, NULL, 'HG433572', 'HG433572', NULL, 'new', NULL, NULL, NULL),
(412, 'abay', NULL, '7412879733', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-06 07:42:48', NULL, 'Might Come', NULL, NULL, 'ROH634115', 'HG604238', '2025-05-08 18:17:52', 'DYS-1', 43, 'VIM920063', NULL),
(413, 'ww', NULL, '5335353533', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-06 13:29:04', NULL, 'will_come', NULL, NULL, 'HAR409147', 'NIL185406', '2025-05-06 13:35:26', 'new', NULL, NULL, NULL),
(414, 'ss', NULL, '4245722333', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-06 13:30:18', NULL, 'might_come', NULL, NULL, 'HAR409147', 'NIL185406', '2025-05-06 13:46:29', 'new', NULL, NULL, NULL),
(415, 'sc', NULL, '8686868686', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-06 13:30:44', NULL, 'will_come', NULL, NULL, 'HAR409147', 'ROH634115', '2025-05-06 13:47:38', 'new', NULL, NULL, NULL),
(416, 'govind', NULL, '8985663299', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-06 09:05:54', NULL, 'will_come', NULL, NULL, 'ROH634115', 'GOV630188', '2025-05-06 09:08:02', 'new', NULL, NULL, NULL),
(417, 'tarun', '2025-05-10', '4565985456', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-06 09:47:33', NULL, 'ddfg dh dfhg ', NULL, NULL, 'ROH634115', 'GOV630188', '2025-05-08 18:21:20', 'DYS-2', 42, 'MAD427947', NULL),
(418, 'fffffffff', NULL, '8653656566', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-12 15:30:56', NULL, 'will Come', NULL, NULL, 'GOV986886', 'ROH634115', '2025-05-12 15:32:02', 'DYS-6', 43, 'VIM920063', NULL),
(419, 'sd', NULL, '0616565150', NULL, 'student', 'guyh', 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-12 18:36:32', NULL, NULL, NULL, NULL, 'GOV986886', 'NIL185406', NULL, 'DYS-6', 43, 'VIM920063', NULL),
(420, 'vvdfv', NULL, '2165651545', NULL, 'job_candidate', NULL, 'online', 'cash', 200.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-12 18:58:35', NULL, NULL, NULL, NULL, 'GOV986886', 'NIL185406', NULL, 'DYS-1', 43, 'VIM920063', NULL),
(421, 'dcewvve', NULL, '4545464560', NULL, 'student', NULL, 'online', 'online', 100.00, 'received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-19 11:39:22', NULL, 'will Come', NULL, 'pay_QWgQcT8t87ONdW', '3416546846', '3416546846', '2025-05-19 11:40:29', 'DYS-6', 43, 'VIM920063', NULL),
(422, 'dgdd', NULL, '4545645658', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-23 04:57:05', NULL, NULL, NULL, NULL, 'CHA258408', 'CHA258408', NULL, 'DYS-1', 43, 'VIM920063', NULL),
(423, 'cdddvd', NULL, '4545354553', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-23 04:57:53', NULL, NULL, NULL, NULL, 'CHA258408', 'CHA258408', NULL, 'DYS-1', 43, 'VIM920063', NULL),
(424, 'gfdbf', NULL, '5655476546', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-23 04:58:43', NULL, NULL, NULL, NULL, 'CHA258408', 'CHA258408', NULL, 'DYS-5', 43, 'VIM920063', NULL),
(425, 'vdvdf', NULL, '6465464645', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-23 04:59:51', NULL, NULL, NULL, NULL, 'CHA258408', 'CHA258408', NULL, 'DYS-1', 43, 'VIM920063', NULL),
(426, 'fffdvf', NULL, '4645646456', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-23 05:00:37', NULL, NULL, NULL, NULL, 'CHA258408', 'CHA258408', NULL, NULL, 43, 'VIM920063', NULL),
(427, 'dfvdf', NULL, '4546546454', NULL, 'student', NULL, 'online', 'cash', 100.00, 'not_received', NULL, 0, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, '2025-05-23 05:02:34', NULL, NULL, NULL, NULL, 'CHA258408', 'CHA258408', NULL, 'new', NULL, NULL, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `facilitator_student_comments`
--
ALTER TABLE `facilitator_student_comments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `facilitator_id` (`facilitator_id`,`student_id`);

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
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`task_id`),
  ADD KEY `user_id` (`user_id`);

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
-- AUTO_INCREMENT for table `facilitator_student_comments`
--
ALTER TABLE `facilitator_student_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT for table `group_migration`
--
ALTER TABLE `group_migration`
  MODIFY `migrationId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `iyfdashboardAccounts`
--
ALTER TABLE `iyfdashboardAccounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=103;

--
-- AUTO_INCREMENT for table `studentAttendance`
--
ALTER TABLE `studentAttendance`
  MODIFY `AttendanceId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=380;

--
-- AUTO_INCREMENT for table `studentbatch`
--
ALTER TABLE `studentbatch`
  MODIFY `BatchId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `task_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=92;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=428;

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
-- Constraints for table `tasks`
--
ALTER TABLE `tasks`
  ADD CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `iyfdashboardAccounts` (`user_id`);

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
