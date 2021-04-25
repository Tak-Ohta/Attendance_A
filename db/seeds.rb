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

User.create!(name: "上長A",
              email: "superior-a@email.com",
              affiliation: "エンジニアリング部",
              employee_number: 2,
              uid: "2",
              password: "password",
              password_confirmation: "password",
              superior: true,
              admin: false)

30.times do |n|
  name = Faker::Name.name
  email = "sample-#{n+3}@email.com"
  affiliation = "エンジニアリング部"
  employee_number = n + 3
  uid = n + 3
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

BasePoint.create!(base_number: 1,
                  base_name: "新宿",
                  attendance_type: "出勤")