require 'spec_helper'

User.send(:_create_system_user!) unless User.system_user.present?
FactoryGirl.create(:boss_badge) unless Badge.find_by_name("boss")

describe "Mailers" do
  context "when testing mailers render correctly" do
    MAP = {EmailBlast => [
        [:weekly_blast, :user, :company_report_weekly, :company_report],
        [:monthly_blast, :user, :company_report_weekly, :company_report],
        [:yearly_blast, :user, :company_report_weekly, :company_report]
      ],
      ReminderNotifier => [
        [:no_invites_and_no_recognitions_reminder, :user],
        [:invited_but_no_recognitions_reminder, :user],
        [:inactive_user_reminder, :user],
        [:has_not_verified_first_warning, :user],
        [:has_not_verified_second_warning, :user],
        [:has_not_verified_third_warning, :user],
        [:has_not_verified_and_is_now_disabled, :user],
        [:company_disabled, :user]
      ],
      SystemNotifier => [
        [:contact_email, :support_email],
      ],
      UserNotifier => [
      [:welcome_email, :user],
      [:password_reset_instructions, :user],
      [:verification_email, :user],
      [:invitation_email, :invited_user],
      # [:new_recognition_for_user, :recognition, :user],
      # [:new_recognition_for_company, :recognition, :company],
      # [:invite_from_recognition_for_user, :recognition, :user],
      # [:invite_from_crosscompany_recognition_for_user, :recognition, :user]
      ],
      RecognitionNotifier => [
        [:new_recognition_for_user, :recognition, :user],
        [:invite_from_recognition_for_user, :recognition, :user],
        [:invite_from_crosscompany_recognition_for_user, :recognition, :user]
      ]
    }

    before(:each) do
      user = FactoryGirl.create(:active_user) 
      company = user.company 
      @args = {
        recognition: FactoryGirl.create(:recognition),
        user: user,
        company: company,
        company_report_weekly: Report::Company.new(company, 1.week.ago, interval: Interval.weekly),
        company_report_monthly: Report::Company.new(company, 1.month.ago, interval: Interval.monthly),
        company_report_yearly: Report::Company.new(company, 1.year.ago, interval: Interval.yearly),
        company_report: Report::Company.new(company),
        invited_user: FactoryGirl.create(:active_user, invited_by: FactoryGirl.create(:active_user)),
        support_email: SupportEmail.create(name: "abc", email: "abc@abc.com", message: "abc")
      }
    end

    MAP.each do |mailer, methods|
      methods.each do |args|
        method = args.shift
        it "should render #{mailer}##{method}" do
          expect {
              args = args.map{|a| @args[a]}
              mailer.send(method, *args)
            }.to_not raise_error
        end
      end
    end
  end
end
