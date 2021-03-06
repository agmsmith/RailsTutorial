class Micropost < ApplicationRecord
  belongs_to :user # Has a user_id field that identifies our owner.
  default_scope -> { order(created_at: :desc) } # Sort by newest date first.
  mount_uploader :picture, PictureUploader # Hooks in functionality, like deleting picture when micropost is deleted.
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate :picture_size

  private

  # Validates the size of an uploaded picture.
  def picture_size
    if picture.size > 5.megabytes
      errors.add(:picture, "should be less than 5MB")
    end
  end

end
