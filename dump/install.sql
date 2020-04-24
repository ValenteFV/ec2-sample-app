CREATE DATABASE peopledb;
USE peopledb
CREATE TABLE people(
  id int not null auto_increment primary key,
  name varchar(255),
  email varchar(255)
);
