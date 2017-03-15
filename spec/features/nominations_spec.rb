require 'spec_helper'

describe "Nominations", type: :feature, js: true do

  # before(:each) do
  #   User._create_system_user! unless User.system_user and User.system_user.persisted?
  #   @user = login_as(:active_user)
  #   @domain = @user.company.domain
  #   @recipient = FactoryGirl.create(:active_user, email: "a#{FactoryGirl.generate(:count)}@#{@domain}")
  # end

  # describe 'sending nomination badge' do
  #   it 'does not notify recipient' do
  #     pending
  #   end

  #   it 'nomination badge does not show up on stream page' do
  #     pending
  #   end

  #   it 'nomination badge is not shared on Yammer and other social metrics' do
  #     pending
  #   end

  #   it 'sender cannot send recipient another nomination of the same badge until time interval is up' do
  #     pending
  #   end

  #   it 'nomination badge shows up in Company Admin' do
  #     pending
  #   end

  #   it 'nomination is set by an interval' do
  #     pending
  #   end
  # end

  # let!(:user) { login_as(:active_user, "abcd") }
  # let!(:company) { user.company }

  # context "logged in as admin" do
  #   before do
  #   end

  #   it "can see button to create Nomination from Recognitions#new" do
  #     pending
  #   end

  #   it "can mark a badge as Nomination badge" do
  #     pending
  #   end
  # end

  # context "not logged in as admin" do
  #   before do
  #   end

  #   it "cannot see button to create Nomination from Recognitions#new" do
  #     pending
  #   end
  # end
end
