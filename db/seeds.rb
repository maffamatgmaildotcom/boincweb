# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
#   
# Create some computers
Computer.create([
  { id: 1, name: "ANNA", ip: "192.168.5.94", port: "31416", password: "deadbeef", selected: true, active: true },
  { id: 2, name: "ELSA", ip: "192.168.5.97", port: "31416", password: "deadbeef", selected: false, active: true },
  { id: 3, name: "GRUMPY", ip: "192.168.5.96", port: "31416", password: "deadbeef", selected: false, active: true },
  { id: 4, name: "OLAF", ip: "192.168.5.91", port: "31416", password: "deadbeef", selected: false, active: true },
  { id: 5, name: "MULAN", ip: "192.168.5.87", port: "31416", password: "deadbeef", selected: false, active: true },
  { id: 6, name: "SVEN", ip: "192.168.5.93", port: "31416", password: "deadbeef", selected: false, active: true },
  { id: 7, name: "MINNIE", ip: "192.168.5.95", port: "31416", password: "deadbeef", selected: false, active: true },
  { id: 8, name: "KRISTOFF", ip: "192.168.5.92", port: "31416", password: "deadbeef", selected: false, active: true }
])
# 
# Note: The 'selected' field indicates whether the computer is currently selected for tasks.
# The 'active' field indicates whether the computer is currently active.
# The 'password' field is used for RPC authentication, and should be set to a secure value in production.
#
# Create some users
# Create some tasks