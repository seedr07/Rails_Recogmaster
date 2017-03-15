require 'spec_helper'

describe "Badge show", js: true do
  let(:user) { FactoryGirl.create(:company_admin) }
  let(:badge) { Badge.user_badges.last }
  let(:recipients) { 5.times.map{|i| User.new(email: Time.now.to_f.to_s).tap{|user| user.company_id=1} } }
  let(:recognitions) {  1.times.map{|i| mock_recognition }}

  def mock_recognition
    recognition = Recognition.new(badge_id: badge.id, message: Time.now.to_f.to_s, recipients: recipients, sender: user)     
    recognition.sender_company = user.company
    recognition.created_at = Time.now
    recognition.slug = "abc"
    recognition
  end

  before(:each) do
    login_as(user)
    Company.any_instance.stub(:recognitions_for_badge).and_return(recognitions)
    Company.any_instance.stub_chain(:badges, :enabled, :find).and_return(badge)
    visit company_badge_path(badge, network: user.network)
  end

  it 'show recognitions' do
    recognitions.each do |recognition|
      expect(page).to have_content recognition.message
    end
  end

  it "have badge information" do
    expect(page).to have_content badge.short_name.capitalize
    expect(page).to have_content badge.description
    expect(page).to have_content "Recognitions"
    expect(find(".badge-page-item img")["src"]).to eq(badge.permalink(200))
  end


end