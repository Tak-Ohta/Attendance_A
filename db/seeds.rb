# coding: utf-8

User.create!(name: "Admin User",
            email: "admin@email.com",
            affiliation: "管理部",
            employee_number: 1,
            uid: "1",
            password: "password",
            password_confirmation: "password",
            superior: true,
            admin: true)

30.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+2}@email.com"
  affiliation = "エンジニアリング部"
  employee_number = n + 2
  uid = n + 2
  password = "password"
  password_confirmation = "password"
  superior = false
  admin = false
  User.create!(name: name,
      email: email,
      affiliation: affiliation,
      employee_number: employee_number,
      uid: uid,
      password: password,
      password_confirmation: password,
      superior: superior,
      admin: admin)
end