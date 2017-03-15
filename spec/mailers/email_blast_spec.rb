require 'spec_helper'

include RecognitionsHelper

User.send(:_create_system_user!) unless User.system_user.present?
FactoryGirl.create(:boss_badge) unless Badge.find_by_name("boss")

describe "EmailBlast" do
  let(:user) { FactoryGirl.create(:active_user) }
  let!(:company_report) { Report::Company.new(user.company, 1.week.ago, Time.now, interval: Interval.weekly)}
  let!(:all_time_company_report) { Report::Company.new(user.company) }  

  describe "Weekly" do

    it "runs basic email without error" do
      expect {
        EmailBlast.weekly_blast(user, company_report, all_time_company_report).deliver        
      }.to change{ActionMailer::Base.deliveries.length}.by(1)
    end
  end

  describe "Achievements" do
    let(:user) { FactoryGirl.create(:active_user_with_achievements_company) }
    let(:company) { user.company}
    let(:company_admin) { company.company_admins.first }
    let(:mail) { EmailBlast.weekly_blast(user, company_report, all_time_company_report) }
    let(:mail_html) { Nokogiri::HTML(mail.body.encoded) }
    let(:achievement_badge) { company.company_badges.achievements.first}

    it "has correct stats for achievements" do
      recognition = recognize!(User.system_user, user, badge: achievement_badge)

      expect(user.company.company_badges.achievements.size).to eq(2) #sanity check
      expect{mail.deliver}.to change{ActionMailer::Base.deliveries.length}.by(1)
      expect(mail_html.css("h2").last.text).to eq("Achievement Progress")
      expect(mail_html.css("#recognize-achievement-table tr").first.text).to match("1\r\n")
      expect(mail_html.css("#recognize-your-achievements").first.text).to match(/#{achievement_badge.short_name}/)
      expect(mail_html.css("#recognize-your-achievements img").first[:src]).to eq(achievement_badge.permalink(size: 100))
      uri = URI.parse(mail_html.css("#recognize-your-achievements a").first[:href])
      url = uri.to_s.gsub("?"+uri.query, '')
      expect(url).to eq(recognition.permalink)

      expect(mail_html.css("#recognize-all-achievements img").length).to eq(company.company_badges.achievements.size)

    end
  end
end