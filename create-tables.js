let mysql = require('mysql');

let connection = mysql.createConnection({
    host: process.env.DBHOST,
    user: process.env.DBUSER,
    password: process.env.DBPASSWORD,
});

// connect to the MySQL server
connection.connect(function(err) {
  if (err) {
    return console.error('error: ' + err.message);
  }

  let createdb = `CREATE DATABASE peopledb;
                    USE peopledb
                    CREATE TABLE people(
                        id int not null auto_increment primary key,
                        name varchar(255),
                        email varchar(255));`;

  connection.query(createdb, function(err, results, fields) {
    if (err) {
      console.log(err.message);
    }
  });

  connection.end(function(err) {
    if (err) {
      return console.log(err.message);
    }
  });
});