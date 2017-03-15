class Authentication < ActiveRecord::Base
  attr_accessible :provider, :uid, :user_id, :credentials
  belongs_to :user, inverse_of: :authentications
  validates :uid, :provider, :presence => true
  validates_uniqueness_of :uid, :scope => :provider  
  
  serialize :credentials
  after_create :update_yammer_id

  protected
  def update_yammer_id
    if self.provider == "yammer"
      self.user.update_attribute(:yammer_id, self.uid)
    end
  end
end