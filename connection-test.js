var mysql = require('mysql');

var con = mysql.createConnection({
  host: process.env.DBHOST,
  user: process.env.DBUSER,
  password: process.env.DBPASSWORD,
});

con.connect(function(err) {
  if (err) throw err;
  console.log("Connected!");
});