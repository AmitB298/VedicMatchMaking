use admin
db.createUser({
  user: "admin",
  pwd: "MyStrongPassword123!",
  roles: [ { role: "root", db: "admin" } ]
})
