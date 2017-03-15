class YammerManagerNotifier
  attr_reader :employee, :msg, :opts

  def self.notify!(employee_or_id, msg, opts={})
    new(employee_or_id, msg, opts).notify!
  end

  def initialize(employee_or_id, msg, opts)
    @employee = employee_or_id.kind_of?(User) ? employee_or_id : User.find(employee_or_id)
    @msg = msg
    @opts = opts
  end

  def notify!
    return false unless can_notify?
    return nil unless managers.present?
    
    managers.each do |manager|
      notify_manager(manager)
    end
  end

  private

  def can_notify?
    employee.company.allow_yammer_manager_recognition_notification? &&
    employee.auth_with_yammer?
  end

  def relationships
    @relationships ||= employee.yammer_client.get("/api/v1/relationships?user_id=#{employee.yammer_id}")
  end

  def managers
    relationships["superiors"]
  end

  def notify_manager(manager)
    msg_opts =  {direct_to_id: manager["id"]}
    msg_opts[:og_url] = opts[:og_url]
    employee.yammer_client.create_message(msg, msg_opts)
  end

end