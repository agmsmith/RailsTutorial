class Micropost < ApplicationRecord
  belongs_to :user # Has a user_id field that identifies our owner.
  default_scope -> { order(created_at: :desc) } # Sort by newest date first.
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end
