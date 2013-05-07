#
# User is the Devise managed user model for the application.
#
class User < ActiveRecord::Base
  
  has_many :posts, :dependent => :destroy
  has_many :authentications, :dependent => :destroy
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :omniauthable,
         :recoverable, :rememberable, :trackable,
         :validatable, :token_authenticatable,
         :confirmable, :lockable, :timeoutable, :validate_on_invite => true
  
  before_create :process_email
  
  before_validation :process_email
  
  validates :email,
           :format => { :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
  
  validates :domain,
            :format => { :with => /^@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i }
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  # ActiveAdmin permissions
  attr_accessible :alpha_invites, :beta_invites, :forever_account_value, :permissioned_requests_served, :nonpermissioned_requests_served, :can_post, :as => :admin
  
  # Downcase the email and store the email's domain in a separate
  # column.
  def process_email
    if self.email.nil?
      return
    end
    self.email.downcase!
    domain = self.email.split("@")[1]
    if domain
      self.domain = "@" + domain
    end
  end
  
  #prevents users from getting account access via
  #invitation system
  #https://github.com/scambra/devise_invitable/wiki/Disabling-devise-recoverable,-if-invitation-was-not-accepted
  def send_reset_password_instructions
    super if invitation_token.nil?
  end

  def apply_omniauth(omniauth, confirmable)
    authentications.build(
        :provider => omniauth['provider'],
        :uid      => omniauth['uid']
    #      :token    => omniauth['credentials']['token'],
    #  :secret   => omniauth['credentials']['secret']
    )
    if (!confirmable)
      self.confirmed_at, self.confirmation_sent_at = Time.now
    end
  end
  
end
