class Upload < ApplicationRecord
  belongs_to :user
  has_many :upload_rows, dependent: :destroy
  has_one_attached :original_file

  validates :filename, presence: true
  validates :content_hash, presence: true, uniqueness: true
  validates :row_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :column_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :uploaded_at, presence: true
end
