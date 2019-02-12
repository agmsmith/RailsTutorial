class User < ApplicationRecord
  attr_accessor :remember_token # Token also digested and stored in remember_digest.
  attr_accessor :activation_token # Just kept in-memory, digest is stored in DB.
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

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
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
