require 'spec_helper'

describe EmailTemplateReply do 
  let!(:user) { FactoryGirl.create(:active_user) }

  describe 'Sales Template Reply' do
    it 'returns a valid template' do
      template = EmailTemplateReply.get_sales_reply_template
      expect(template.id).to be_present
      expect(template.name).to be_present
      expect(template.body).to be_present
    end

    context "when sales reply template is bad" do 

      before { ExceptionNotification::Rack.new(Recognize::Application, email: {:email_prefix => "[PREFIX] ", :sender_address => "whatever@whatever.com", :exception_recipients => %w(noone@noone.com)}) }
      after { ExceptionNotifier.class_variable_set("@@notifiers", {}) }

      it 'sends an exception email when no template is found' do

        EmailTemplateReply.stub(get_sales_reply_template: nil)
        expect{
          EmailTemplateReply.send_sales_reply(user)
        }.to change{ActionMailer::Base.deliveries.length}.by(1)

        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.subject).to match(/NoMatchingTemplateError/)
      end
    end

    context "when sales reply template is ok " do
      it "should not have exception notifer activated" do
        # sanity check for the hack I do above to turn on exception notifications for just one test
        expect(ExceptionNotifier.class_variable_get("@@notifiers")).to be_empty
      end
    end

    context "interpolation" do
    end
  end
end