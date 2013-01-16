CREATE TABLE `hw_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(40) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `dt_created` datetime NOT NULL,
  `last_login` datetime NOT NULL,
  `ip` varchar(15) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1208 DEFAULT CHARSET=utf8;

CREATE TABLE `hw_services` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cpu_id` int(11) NOT NULL,
  `dt` datetime NOT NULL,
  `type` varchar(128) NOT NULL,
  `name` varchar(128) NOT NULL,
  `txt_record` text NOT NULL,
  `port` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cpu_id` (`cpu_id`,`type`,`name`)
) ENGINE=MyISAM AUTO_INCREMENT=9282 DEFAULT CHARSET=utf8;

CREATE TABLE `hw_cpus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `guid` varchar(40) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `hostname` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `nickname` varchar(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `ip` varchar(15) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `port` varchar(5) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `dt_created` datetime NOT NULL,
  `dt_updated` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=1833 DEFAULT CHARSET=utf8;
