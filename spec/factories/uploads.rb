FactoryBot.define do
  factory :upload do
    association :user
    filename { Faker::File.file_name(dir: 'uploads') }
    content_hash { Digest::SHA256.hexdigest(Faker::Lorem.sentence) }
    row_count { Faker::Number.between(from: 1, to: 1000) }
    column_count { Faker::Number.between(from: 1, to: 100) }
    uploaded_at { Time.current }
  end
end
