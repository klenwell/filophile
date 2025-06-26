FactoryBot.define do
  factory :upload_row do
    association :upload
    row_index { Faker::Number.number(digits: 2) }
    values { Array.new(5) { Faker::Lorem.word } }
  end
end
