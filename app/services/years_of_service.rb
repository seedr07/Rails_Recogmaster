class YearsOfService

  def self.notify_all_anniversaries
    new.notify_all_anniversaries
  end

  def initialize
  end

  def get_todays_anniversaries(company)
  	anniversaries = []
  	today = Date.today
  	company.users.each do |user|
  		user_doesnt_have_start_date = user.start_date.nil?
  		start_date = user.start_date.to_date unless user_doesnt_have_start_date
  		if(!(user_doesnt_have_start_date))
	  		if(valid_anniversary?(today, start_date))
	  			anniversaries << user
	  		end
	  	end
  	end
  	return anniversaries
  end

  def notify_all_anniversaries
    Company.all.each do |company|
      notify_anniversaries(company)
    end
  end

  def notify_anniversaries(company)
    if(1 <= Date.today.cwday && Date.today.cwday <= 5)
      anniversaries_hash = get_anniversaries_hash(company)
      anniversaries_hash.each do |notified_user_id, anniversary_array|
        AnniversaryNotifier.notify_anniversaries(User.find_by_id(notified_user_id), anniversary_array).deliver unless anniversary_array.empty?
      end
    end 
  end

  def get_anniversaries_hash(company)
    email_recipients = get_email_recipients(company)
  	todays_anniversaries = get_todays_anniversaries(company)
    matched_team_recipients = TeamRecipientsManager.match_email_recipients_to_anniversary(email_recipients, todays_anniversaries)
    matched_role_recipients = RoleRecipientsManager.match_email_recipients_to_anniversary(email_recipients, todays_anniversaries)
    return (matched_team_recipients.merge(matched_role_recipients){|key, a_val, b_val| a_val | b_val })
  end

  def get_email_recipients(company)
    return RoleRecipientsManager.get_email_recipients(company).merge(TeamRecipientsManager.get_email_recipients(company))
  end


  class RoleRecipientsManager

    def self.get_email_recipients(company)
      email_recipients = {}
      anniversary_notifieds = company.anniversary_notifieds
      role_ids = anniversary_notifieds[:role_ids]
      role_ids.each do |role_id|
        user_ids = company.get_user_ids_by_role_id(role_id)
        user_ids.each do |user_id|
          email_recipients[user_id] = []
        end
      end
      return email_recipients
    end

    def self.match_email_recipients_to_anniversary(email_recipients, todays_anniversaries)
      todays_anniversaries.each do |todays_anniversary_user|
        company = todays_anniversary_user.company
        role_ids = company.anniversary_notifieds[:role_ids]
        role_ids.each do |role_id|
          user_ids = company.get_user_ids_by_role_id(role_id)
          user_ids.each do |user_id|
            email_recipients[user_id].push(todays_anniversary_user) unless email_recipients[user_id].include?(todays_anniversary_user)
          end
        end
      end
      return email_recipients
    end

  end

  class TeamRecipientsManager

    def self.get_email_recipients(company)
      email_recipients = {}
      anniversary_notifieds = company.anniversary_notifieds
      team_ids = anniversary_notifieds[:team_ids]
      team_ids.each do |team_id|
        team = Team.find_by_id(team_id)
        team.managers.each do |manager|
          email_recipients[manager.id] = []
        end
      end
      return email_recipients
    end

    def self.match_email_recipients_to_anniversary(email_recipients, todays_anniversaries)
      todays_anniversaries.each do |todays_anniversary_user|
        todays_anniversary_user.teams.each do |team|
          team.managers.each do |manager|
            if(email_recipients.include?(manager.id))
              email_recipients[manager.id].push(todays_anniversary_user) unless email_recipients[manager.id].include?(todays_anniversary_user)
            end
          end
        end
      end
      return email_recipients
    end

  end


  private

  
  def valid_anniversary?(today, start_date)
  	if(today.day == start_date.day && today.month == start_date.month)
  		return true
  	end 
  	if(start_date.month == 2 && start_date.day == 29 && today.month == 2 && today.day == 28)
  		return true
  	end
    if(today.cwday == 1)
      sunday = today - 1.day
      saturday = today - 2.days
      if(sunday.day == start_date.day && sunday.month == start_date.month)
        return true
      end
      if(saturday.day == start_date.day && saturday.month == start_date.month)
        return true
      end
    end
  	return false
  end

end
