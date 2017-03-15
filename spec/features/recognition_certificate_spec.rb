require 'spec_helper'

describe 'recognitions#certificate', js: true do
  include DateTimeHelper

  let(:sender) { FactoryGirl.create(:active_user)}
  let(:recipient) { FactoryGirl.create(:active_user)}
  let(:recognition) {FactoryGirl.create(:recognition, sender: sender, recipients: [recipient])}

  before do
    visit recognition_path(recognition)
    page.find(".view-certificate-link").click
  end

  it "should show the correct content" do
    expect(page).to have_content(recipient.full_name)
    expect(page).to have_content(localize_datetime(recognition.created_at, :slash_date))
    expect(page).to have_content(sender.full_name)
    expect(page).to have_content(recognition.message)
  end

end