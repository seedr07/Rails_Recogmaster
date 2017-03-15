require 'spec_helper'

describe SmsNotifier do 
  describe 'permissions' do
    let(:company) { c = Company.new; c.allow_sms_notifications = company_setting; c}
    let(:user) { u  = User.new; u.build_email_setting(allow_sms_notifications: user_setting); u.company = company; u}
    let(:notifier) { SmsNotifier.new(user, "The message") }

    context "when both company and user do not allow" do
      let(:company_setting) { false }
      let(:user_setting) { false}

      it "should not allow sending of sms" do
        expect(notifier.allowed_to_be_sent?).to be_false
      end
    end

    context "when company does not allow and user does" do
      let(:company_setting) { false }
      let(:user_setting) { true }

      it "should not allow sending of sms" do
        expect(notifier.allowed_to_be_sent?).to be_false
      end
    end

    context "when user does not allow and company does" do
      let(:company_setting) { true }
      let(:user_setting) { false }

      it "should not allow sending of sms" do
        expect(notifier.allowed_to_be_sent?).to be_false
      end
    end

    context "when both user and company allow" do
      let(:company_setting) { true }
      let(:user_setting) { true }

      it "should not allow sending of sms" do
        user.phone = "+15554151234"
        expect(notifier.allowed_to_be_sent?).to be_true
      end
    end


  end
end