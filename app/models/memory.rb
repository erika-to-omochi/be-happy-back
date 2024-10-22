class Memory < ApplicationRecord
  belongs_to :user
  validates :content, presence: true, length: { maximum: 1000 }
  attribute :is_secret, :boolean, default: false
end
