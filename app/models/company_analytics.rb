# activated user: user who has sent at least 1 recognition
# engaged user: user who has sent at least 1 recognition within the last week
# activated company: company who has sent at least 1 recognition
# engaged company: company who has sent at least 1 recognition within the last week
module CompanyAnalytics
  ANALYTICS_MAP = {
    id: Proc.new{|c| c.id},
    domain: Proc.new{|c| c.domain},
    sent_recognition_count: Proc.new{|c| c.sent_recognitions.size},
    user_count: Proc.new{|c| c.users.size},
    activated_user_count: Proc.new{|c| c.activated_users.size},
    engaged_user_count_this_week: Proc.new{|c| c.engaged_users(1.week.ago, 1).size},
    engaged_user_count_this_month: Proc.new{|c| c.engaged_users(1.month.ago, 1).size},
    is_activated: Proc.new{|c| c.activated?},
    activated_at: Proc.new{|c| c.recognitions.non_system.last.created_at rescue nil},
    is_engaged: Proc.new{|c| c.engaged?},
    is_churned: Proc.new{|c| c.churned?}
  }
  
  module ClassMethods
    def analytics_map=(map)
      @@analytics_map ||= map
    end
    
    def analytics_map
      @@analytics_map
    end

    def analytics_updated_at
      analytics_data.updated_at
    end
    
    def analytics_cache_key
      "all-analytics-data"
    end

    def analytics_data
        Data.new(self)
    end   

    
    def generate_data!
      data_scope do
        h = {}
        Company.all.each{|c| h[c.id] = c.analytics_hash}
        return h
      end
    end
    
    # this methods allows you to wrap it with a scope(or lack of scope)
    def data_scope
      if Company.columns.map(&:name).include?("deleted_at")
        yield
      else
        Company.unscoped do
          Recognition.unscoped do
            User.unscoped do
              yield
            end
          end
        end
      end
    end# end scoped method

  end
  
  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      base.analytics_map = ANALYTICS_MAP
    end
  end
  
  def analytics_hash
    Company.analytics_map.inject({}){|hash,data| k,v = data;hash[k] = v.call(self);hash}    
  end
  
  def activated?(threshold = 1)
    recognition_scope.size >= threshold
  end
  
  def engaged?(time_threshold = 1.week.ago, recognition_threshold = 1)
    recognition_scope.where("created_at > ?", time_threshold).size >= recognition_threshold
  end
  
  def churned?(time_threshold = 1.month.ago)
    activated? && (recognition_scope.maximum(:created_at) < time_threshold)
  end
  
  def activated_users(threshold=1)

    recognition_scope.group(:sender_id).count.select{|userid,count| count>=threshold}      

  end
  
  def engaged_users(time_threshold = 1.week.ago, recognition_threshold = 1)
    recognition_scope.
    where("created_at > ?",time_threshold).
    group(:sender_id).
    count.
    select{|userid,count| count>=recognition_threshold}
  end  

  def recognition_scope
    if Recognition.columns.map(&:name).include?("sender_company_id")
      scoped = Recognition.where(sender_company_id: self.id)
    else
      scope = Recognition.where(company_id: self.id)
    end
  end
  
  class Data
    include CacheKeyManager

    # parent is the class responsible for getting the data
    # must respond to #analytics_data
    attr_accessor :datasource
    def initialize(datasource)
      self.datasource = datasource
    end

    def data
      Rails.cache.fetch(ckm_cache_key(self.datasource.analytics_cache_key)) do      
        datasource.generate_data!
      end
    end

    def updated_at
      Time.at(ckm_cache_key_timestamp(self.datasource.analytics_cache_key).to_i)      
    end

    def report_name
      "CompanyAnalytics"
    end

    def report_data
      self.datasource.data_scope do
        {
            new_companies_this_week: new_companies_this_week.size,
            new_users_this_week: User.where("users.created_at > ?", 1.week.ago).size,
            new_recognitions_this_week: Recognition.where("recognitions.created_at > ?", 1.week.ago).size,
            new_approvals_this_week: RecognitionApproval.where("recognition_approvals.created_at > ?", 1.week.ago).size,
            num_activated_companies_this_week: activated_companies_this_week.size,
            num_engaged_companies_this_week_1: engaged_companies_this_week(1).size,
            num_engaged_companies_this_week_5: engaged_companies_this_week(5).size,
            num_engaged_companies_this_week_10: engaged_companies_this_week(10).size
        }
        #{
        #  total_companies: Company.count,
        #  total_users: User.count,
        #  total_recognitions: Recognition.user_sent.non_system.count,
        #  num_activated_companies: activated_companies.size,
        #  num_engaged_companies_this_week: engaged_companies_this_week.size,
        #  num_engaged_companies_this_month: engaged_companies_this_month.size
        #}

      end
    end

    # callback after data is loaded into Reporter
    def refresh!
      ckm_touch(self.datasource.analytics_cache_key)
      self.data
    end

    def new_companies_this_week
      Company.where("companies.created_at > ?", 1.week.ago)
    end

    def activated_companies_this_week
      data.select{|companyid, hash| hash[:activated_at].present? && hash[:activated_at] > 1.week.ago}
    end

    def activated_companies(threshold=1)
      data.select{|companyid,hash| hash[:activated_user_count] >= threshold}
    end

    def activated_companies_by_recognition_count(threshold=1)
      data.select{|companyid,hash| hash[:is_activated] && hash[:sent_recognition_count] >= threshold}
    end

    def churned_companies_by_activated_users(threshold=i)
      data.select{|companyid,hash| hash[:is_churned] && hash[:activated_user_count] >= threshold}
    end

    def churned_companies_by_sent_recognitions(threshold=i)
      data.select{|companyid,hash| hash[:is_churned] && hash[:sent_recognition_count] >= threshold}
    end
    
    def engaged_companies_this_week(threshold=1)
      data.select{|companyid,hash| hash[:engaged_user_count_this_week] >= threshold}
    end

    def engaged_companies_this_month(threshold=1)
      data.select{|companyid,hash| hash[:engaged_user_count_this_month] >= threshold}
    end
  end
end
