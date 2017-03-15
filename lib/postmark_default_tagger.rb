module PostmarkDefaultTagger
  class ActionMailer::Base
    def mail_with_tag(opts)
      opts[:tag] = `hostname`.gsub(/\n/,'-')+Rails.env.to_s
      mail_without_tag(opts)
    end
    alias_method_chain :mail, :tag
  end
end