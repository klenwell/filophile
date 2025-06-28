FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "User Name #{n}" }
    sequence(:uid) { |n| "uid#{n}" }
    provider { "google_oauth2" }
    admin { false }
  end
end
