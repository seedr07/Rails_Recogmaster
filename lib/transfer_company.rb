$c1 = Company.where(domain: "qfcrew.com.not.real.tld").first
$c2 = Company.where(domain: "qantas.com.au.not.real.tld").first
$migrate_emails = false

def log(msg="")
  Rails.logger.info "TRANSFER: " + msg.to_s
  puts msg
end

class TransferCompany
  attr_reader :company1, :company2, :migrate_emails, :results

  def self.transfer!(company1, company2, migrate_emails)
    msg = <<-MSG

      ########################################################################################
      #                                                                                      
      #
      #    Transferring #{company1.domain} to #{company2.domain}                    
      #
      #                                                                                      
      ########################################################################################

    MSG

    log msg
    new(company1, company2, migrate_emails).transfer!
  end

  def initialize(company1, company2, migrate_emails)
    @company1 = company1
    @company2 = company2
    @migrate_emails = migrate_emails
    @results = []
  end

  def transfer!
    company1_counts = counts(company1)
    company2_counts = counts(company2)

    company1.users.each do |user|
      results << TransferUser.transfer!(user, company2, migrate_emails)
    end

    parallel_users_found = results.select{|result| result.found_parallel_user? }
    recognitions_moved_to_parallel_users = parallel_users_found.map{|result| result.affected_recognitions}.flatten
    moved_users = results.select{|result| result.moved_user? }
    recognitions_massaged_to_moved_user = moved_users.map{|result| result.affected_recognitions}.flatten

    log 
    log " --------------------------------------- "
    log "Results: "
    log "\t BEFORE: Company1: #{company1_counts.inspect} - Company2: #{company2_counts.inspect}"
    log "\t AFTER: Company1: #{counts(company1)} - Company2: #{counts(company2)}"
    log ""
    log "\t Found #{parallel_users_found.length} parallel users in the new company"
    log "\t - this affected: #{recognitions_moved_to_parallel_users.length} recognitions"
    log "\t Found #{moved_users.length} users that had to be moved"
    log "\t - this affected: #{recognitions_massaged_to_moved_user.length} recognitions"
  end

  private
  def counts(company)
    company.reload
    {users: company.users.length, sent_recognitions: company.sent_recognitions.length}
  end
end

class TransferUser
  attr_reader :user, :new_company, :migrate_email

  def self.transfer!(user, new_company, migrate_email)
    new(user, new_company, migrate_email).transfer!
  end

  def initialize(user, new_company, migrate_email)
    @user = user
    @new_company = new_company
    @migrate_email = migrate_email
  end

  def transfer!
    if(user_exists_in_new_company?)
      transfer_to_parallel_user!
    else
      move_user!
    end
  end

  def transfer_to_parallel_user!
    log ""
    log "#{user.email}"
    log "\tUser FOUND in new company"
    log "\tReassigning recognitions to existing user"

    before_points = points(parallel_user_in_new_company)
    affected_recognitions = transfer_sent_recognitions!(parallel_user_in_new_company)
    transfer_received_recognitions!(parallel_user_in_new_company)
    transfer_recognition_approvals!(parallel_user_in_new_company)
    parallel_user_in_new_company.update_all_points!
    user.update_all_points!

    log "\tPoints: #{before_points} -> #{points(parallel_user_in_new_company)}"
    log 

    return FoundParallelUserTransferStatus.new(user, affected_recognitions)
  end

  def move_user!
    log ""
    log "#{user.email}"
    log "\tUser NOT FOUND in new company"
    log "\tMoving user to new company and massaging recognitions"

    before_points = points(user)
    update_user_attributes_to_new_company!
    affected_recognitions = transfer_sent_recognitions!
    user.update_all_points!

    log "\tPoints: #{before_points} -> #{points(user)}"

    return MovedUserTransferStatus.new(user, affected_recognitions)    
  end

  private

  def points(this_user)
    this_user.reload
    {total_points: this_user.total_points, interval_points: this_user.interval_points}
  end

  def update_user_attributes_to_new_company!
    user.email = new_email if migrate_email
    user.network = new_network
    user.company_id = new_company_id    
    user.save!(validate: false)  
  end

  def transfer_sent_recognitions!(user_that_will_own_recognitions=user)
    affected_recognitions = user.sent_recognitions
    log "\tTransferring #{affected_recognitions.length} sent recognitions"
    affected_recognitions.each do |recognition|
      recognition.sender_id = user_that_will_own_recognitions.id
      recognition.sender_company_id = new_company_id
      recognition.save!
    end
    return affected_recognitions
  end

  def transfer_received_recognitions!(user_that_will_own_recognitions)
    affected_recognition_recipients = user.recognition_recipients
    log "\tTransferring #{affected_recognition_recipients.length} received recognitions"

    affected_recognition_recipients.each do |rr| 
      log "\t Transferring recognition recipient: #{rr.recipient.email}  for recognition: #{rr.recognition_id} - badge: #{rr.recognition.badge.short_name} - #{rr.recognition.created_at}"
    end

    affected_recognition_recipients.each do |recognition_recipient|
      recognition_recipient.user_id = user_that_will_own_recognitions.id
      recognition_recipient.recipient_company_id = user_that_will_own_recognitions.company.id
      recognition_recipient.recipient_network = user.network
      recognition_recipient.save!
    end
    return affected_recognition_recipients
  end

  def transfer_recognition_approvals!(user_that_will_own_approvals)
    user.given_recognition_approvals.update_all(giver_id: user_that_will_own_approvals.id)
  end

  def new_email
    return "#{prefix}@#{new_network}"
  end

  def new_network
    new_company.domain
  end

  def new_company_id
    new_company.id
  end

  def prefix
    prefix = user.email.split("@").first    
  end

  def user_exists_in_new_company?
    parallel_user_in_new_company.present?
  end

  def parallel_user_in_new_company
    @parallel_user ||= User.where(email: "#{prefix}@#{new_network}").first
  end

end

class TransferStatus
  FOUND_PARALLEL_USER=1
  MOVED_USER=2

  attr_reader :user, :affected_recognitions, :status

  def initialize(user, affected_recognitions, status)
    @user = user
    @affected_recognitions = affected_recognitions
    @status = status
  end

  def found_parallel_user?
    status == FOUND_PARALLEL_USER
  end

  def moved_user?
    status == MOVED_USER
  end

end

class FoundParallelUserTransferStatus < TransferStatus
  def initialize(user, affected_recognitions)
    super(user, affected_recognitions, FOUND_PARALLEL_USER)
  end
end

class MovedUserTransferStatus < TransferStatus
  def initialize(user, affected_recognitions)
    super(user, affected_recognitions, MOVED_USER)
  end
end