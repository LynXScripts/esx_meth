USE `lacity`;

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
	('meth', 'Meth', 50, 0, 1),
	('packed_meth', 'Packed Meth', 50, 0, 1)
;

INSERT INTO `licenses` (`type`, `label`) VALUES
	('meth_processing', 'Meth Processing License')
;
