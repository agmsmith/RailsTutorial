class Relationship < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :followed, class_name: 'User'
  validates :follower_id, presence: true
  validates :followed_id, presence: true

  validate :do_not_follow_self

  private

  # Validates that you don't follow yourself.
  def do_not_follow_self
    if follower_id == followed_id
      errors.add(:do_not_follow_self, "should not have yourself as a follower")
    end
  end

end
