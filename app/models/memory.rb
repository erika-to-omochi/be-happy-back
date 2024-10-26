class Memory < ApplicationRecord
  belongs_to :user, optional: true
  validates :content, presence: true, length: { maximum: 1000 }
  validates :name, presence: true, length: { maximum: 50 }
end
