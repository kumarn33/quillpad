class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  BLACKLISTED_SUBDOMAINS = %w(user users blog blogs post posts comment comments mail email www
  application page pages profile profiles admin administrator root)

  devise :database_authenticatable, :rememberable, :validatable

  has_many :posts
  validates :subdomain, uniqueness: true
  validates :subdomain, exclusion: { in: BLACKLISTED_SUBDOMAINS }
  validates :subdomain, length: { in: 3..20 }
  validates :subdomain, format: { with: /\A[a-z0-9]+\z/ }
  before_validation :set_random_username

  def set_random_username
    return if self.subdomain.present?

    10.times do
      str = SecureRandom.urlsafe_base64(8).downcase
      yes = User.exists?(subdomain: str)

      if !yes
        self.subdomain = str
        break
      end
    end
  end
end
