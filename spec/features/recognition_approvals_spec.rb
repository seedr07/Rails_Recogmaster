require 'spec_helper'

describe "Recognitions", type: :feature, js: true do
  include RecognitionsHelper
  Capybara::Session.send(:include, RecognitionsHelper::Session)

  let(:user) { login_as(:active_user) }
  let(:recipient) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:email_prefix)}@#{user.network}")}
  let!(:recognition) { FactoryGirl.create(:recognition, recipients: [recipient.email]) }

  before(:each) do
    User._create_system_user! unless User.system_user and User.system_user.persisted?
  end

  def approval_link(recognition)
    page.find("#recognition-approval-#{recognition.id} .approval_link")
  end

  shared_examples "recognition that can be approved" do
    it 'should +1' do
      visit destination
      approval_link(recognition).click
      wait_until_ajax_completes
      expect(approval_link(recognition)[:class]).to eq("approval_link approved")
      expect(approval_link(recognition).text).to eq("+1")
    end
  end

  shared_examples "recognition that can be unapproved" do
    it 'remove +1' do
      visit destination
      approval_link(recognition).click
      wait_until_ajax_completes
      expect(approval_link(recognition)[:class]).to eq("approval_link unapproved")
      expect(approval_link(recognition).text).to eq("+")
    end
  end

  shared_examples "the different cases for approving and unapproving recognitions" do
    context 'from the stream page' do
      let(:destination) { root_path }
      context "when unapproved" do
        it_behaves_like "recognition that can be approved"
      end

      context "when approved" do
        before { RecognitionApproval.create!(recognition: recognition, giver: user)}
        it_behaves_like "recognition that can be unapproved"
      end
    end

    context 'from the recognition show page' do
      let(:destination) { recognition_path(recognition) }
      context "when unapproved" do
        it_behaves_like "recognition that can be approved"
      end

      context "when approved" do
        before { RecognitionApproval.create!(recognition: recognition, giver: user)}
        it_behaves_like "recognition that can be unapproved"
      end

    end

    context 'from the recipients user profile page' do
      let(:destination) { user_path(recognition.recipients.first) }
      context "when unapproved" do
        it_behaves_like "recognition that can be approved"
      end

      context "when approved" do
        before { RecognitionApproval.create!(recognition: recognition, giver: user)}
        it_behaves_like "recognition that can be unapproved"
      end
    end
  end

  context "when logged in as same company" do
    it_behaves_like "the different cases for approving and unapproving recognitions"
  end

  context "when logged in user is in different company" do
    let(:cross_company_recipient) { FactoryGirl.create(:active_user) }
    let(:user) { login_as(:active_user) }
    let(:coworker) { FactoryGirl.create(:active_user, email: "#{FactoryGirl.generate(:email_prefix)}@#{user.network}") }
    let!(:recognition) {FactoryGirl.create(:recognition, sender: coworker, recipients: [cross_company_recipient.email])}

    it_behaves_like "the different cases for approving and unapproving recognitions"

  end
end