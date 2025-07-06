use vedicmatch;

db.createUser({
  user: "vedicAdmin",
  pwd: "V3dic@SecurePwd!",
  roles: [
    { role: "readWrite", db: "vedicmatch" }
  ]
});
