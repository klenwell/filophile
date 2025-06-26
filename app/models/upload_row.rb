class UploadRow < ApplicationRecord
  belongs_to :upload

  validates :row_index, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :values, presence: true
end
