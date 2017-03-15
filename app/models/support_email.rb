class SupportEmail < ActiveRecord::Base
  
  self.inheritance_column = :_type_disabled
  
  attr_accessible :email, :message, :name, :type, :phone
  
  validates :name, :message, presence: true
  validates :phone, presence: true, if: ->{ type.to_s.downcase == "sales"}
  validates :email, presence: true, if: ->{ type.to_s.downcase == "support"}
  
  after_save :notify_management

  # NOTE: as of 1/19/2016, rails v4.1.14
  #       there seems to be a bug that reverses after_commit ordering
  #       https://github.com/rails/rails/issues/20911
  #
  #       The proper ordering is save phone to user and then notify close
  #       (so it picks up the users phone number during upsert)
  #
  #       For now, reverse the order, and raise exception if version changes
  #       so we now to double check this ordering on every upgrade until fixed
  raise "DoubleCheckRailsBugForAfterCommitReverseOrdering" unless Rails.version == "4.1.14"

  after_commit :notify_closeio # should run second
  after_commit :save_phone_to_user, if: ->{ phone.present? } #should run first

  # after_commit :send_autoreply, if: ->{ ok_to_send_autoreply? }
    
  protected
  def notify_management
    SystemNotifier.delay(queue: 'priority').contact_email(self)
  end

  def notify_closeio
    user = User.find_or_initialize_by(email: email)

    Recognize::Application.closeio.upsert_contact(user)

  rescue => e
    ExceptionNotifier.notify_exception(e, {data: {email: email}})
  end

  # def send_autoreply
  #   EmailTemplateReply.delay.send_sales_reply(email)
  # end

  def save_phone_to_user
    user = User.find_by(email: self.email)
    user.update_column(:phone, self.phone) if user.present?
  end

  def ok_to_send_autoreply?
    result = Rails.configuration.local_config['send_closeio_autoreplies']
    result &&= type.to_s.downcase == "sales"
    return result
  end
end
