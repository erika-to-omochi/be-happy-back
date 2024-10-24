class Memory < ApplicationRecord
  belongs_to :user, optional: true
  validates :content, presence: true, length: { maximum: 1000 }
end
