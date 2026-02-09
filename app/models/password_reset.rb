class PasswordReset < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user_id, :token, :expired_at, :ip_address

  before_validation :generate_random_token

  scope :not_expired, -> { where("expired_at > ?", Time.now) }

  #####################
  ### Class methods ###
  #####################

  def self.send_to(email, ip_address)
    if (user = User.find_by_email(email))
      reset = create!(user: user, ip_address: ip_address, expired_at: 1.hour.from_now)
      UserMailer.password_reset(reset).deliver_now
    end
  end

  def self.proceed(token)
    reset = not_expired.find_by_token(token) and reset.proceed
  end

  ######################
  ### Public methods ###
  ######################

  def proceed
    touch(:completed_at) && user
  end

  def generate_random_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def to_param
    token
  end
end
