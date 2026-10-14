create database formation;
use formation;
create table clients (
id int,
prenom varchar(50),
ville varchar(50),
age int);

INSERT INTO clients VALUES (1, 'Awa', 'Kinshasa', 28);
INSERT INTO clients VALUES (2, 'Jean', 'Lubumbashi', 35);
INSERT INTO clients VALUES (3, 'Marie', 'Kinshasa', 22);
INSERT INTO clients VALUES (4, 'Patrick', 'Goma', 41);

SELECT * FROM clients;

Select prenom, ville from clients;
Select * from clients where ville='Kinshasa';
Select * from clients order by age;

Select * from clients where age>25;
Select * from clients where age<25 and ville='Kinshasa';
Select * from clients order by age desc limit 2