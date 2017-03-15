module Report
  module CacheManager
    module Company
      extend ActiveSupport::Concern

      included do
        include CacheKeyManager  
      end

      def ckm_lookup_key(key)
        "#{report_cache_key}-#{key}"
      end

      def report_cache_key
        key = "Report::Company::#{company.id}::#{from.to_i}::#{to.to_i}"
        key << "::#{opts[:interval]}" if opts[:interval]
        key << "::#{opts[:start_date]}" if opts[:start_date]
        key << "::#{opts[:end_date]}" if opts[:end_date]
        key << "::#{opts[:team_id]}" if opts[:team_id]
        key << "::#{opts[:badge_id]}" if opts[:badge_id]
        key << "::#{opts[:limit]}" if opts[:limit]
        key << "::#{max_recognition_recipient_id}"
        key
      end

      def self.clear_report_caches!(company)
        Rails.cache.delete_matched("Report::Company::#{company.id}")
      end

      def self.prime_current_interval!(company)
        interval = Interval.new(company.reset_interval)
        from, to = interval.start, interval.end
        Report::Company.new(company, from, to).leaders
        company.badges.each do |badge|
          Report::Company.new(company, from, to, badge_id: badge.id).leaders
        end
      end

      def self.bust_and_reprime_report_caches!(company_id)
        company = ::Company.find(company_id)
        self.clear_report_caches!(company)
        self.prime_current_interval!(company)
      end

      REPRIME_INTERVAL = 30.minutes
      def self.should_reprime?(company)
        company.received_recognitions.where("recognitions.created_at > ?", REPRIME_INTERVAL.ago).size > 0
      end

      def self.bust_and_reprime_all_report_caches_if_necessary!
        ::Company.all.each do |c|
          self.delay(queue: 'priority_caching').bust_and_reprime_report_caches!(c.id) if self.should_reprime?(c)
        end
      end
    end
  end
end