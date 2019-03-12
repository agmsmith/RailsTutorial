class User < ApplicationRecord
  has_many :microposts, dependent: :destroy  # Related micropost records, delete them on self destruct.
  has_many :active_relationships,
    class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_relationships,
    class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  attr_accessor :remember_token # Token also digested and stored in remember_digest.
  attr_accessor :activation_token # Just kept in-memory, digest is stored in DB.
  attr_accessor :reset_token # For resetting passwords, digest is stored in DB.

  before_create :create_activation_digest # New records get a random token+digest.
  before_save :downcase_email # For comparison consistency, always use lower case email.

  validates :name,
    presence: true,
    length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,
    presence: true,
    length: { maximum: 255 },
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password,
    presence: true,
    length: { minimum: 6 },
    allow_nil: true

  # Returns the hash digest of the given string (usually a password).
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token (base64 string, for URL safety using -_ rather than
  # +/ characters, whole thing is 22 characters long).
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remember a user in the database for use in persistent sessions.  Creates a
  # random token (saved in @remember_token) and saves the cryptographic digest
  # of it in the database.  Returns true if save worked.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Forget the user (remove token from database).
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Returns true if the digest named by the attribute (:remember, :activation,
  # or :reset for password reset) matches the given token string.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Activates an account.  User does it in response to a verification e-mail.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email(protocol_for_mailed_link)
    UserMailer.account_activation(self, protocol_for_mailed_link).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
      reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email(protocol_for_mailed_link)
    UserMailer.password_reset(self, protocol_for_mailed_link).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # Defines a proto-feed, return a collection (or maybe an iterator) of
  # Microposts relevant to this user.  See "Following users" for the full
  # implementation later on.
  def feed
    Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
  end

  # Follows a given user.
  def follow(other_user)
    following << other_user
  end

  # Unfollows a user.
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Returns true if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private

    def create_activation_digest
      # Create the token and digest, needed for new Users creation.
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

    def downcase_email
      email.downcase!
    end

end
