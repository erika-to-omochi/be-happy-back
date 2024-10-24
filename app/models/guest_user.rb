class GuestUser < ApplicationRecord
  validates :session_id, presence: true, uniqueness: true
end
