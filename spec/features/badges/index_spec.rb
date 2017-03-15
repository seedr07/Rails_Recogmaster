require 'spec_helper'

describe "Badge index", js: true do
  let(:user) { FactoryGirl.create(:company_admin) }
  let(:badge_description) {"This is a great badge"}
  let(:fake_image_path) {"some-image.com/some-url"}
  let(:badge) {
    badge = Badge.new
    badge.id = 1
    badge.short_name = "Cool peer badge"
    badge.description = badge_description
    badge.stub(:permalink).and_return(fake_image_path)
    badge
  }

  let(:achievement) {
    badge = Badge.new
    badge.id = 2
    badge.short_name = "Awesome Achievement"
    badge.description = badge_description
    badge.stub(:permalink).and_return(fake_image_path)
    badge.is_achievement = true
    badge.achievement_interval_id = Interval.monthly.interval_code
    badge
  }

  let(:admin_badge) {
    badge = Badge.new
    badge.id = 3
    badge.short_name = "Admin Badge"
    badge.description = badge_description
    badge.stub(:permalink).and_return(fake_image_path)
    badge.restricted = true
    badge
  }

  before(:each) do
    setup_spec if respond_to?(:setup_spec)
    login_as(user)
    visit company_badges_path(network: user.network)
  end

  context "When company has custom badges" do
    let(:setup_spec) {
      Rails.cache.stub(:write).and_return([])
      Company.any_instance.stub(:custom_badges_enabled_at).and_return(Time.now)
      Company.any_instance.stub(:badges).and_return([badge])
      Company.any_instance.stub_chain(:badges, :enabled).and_return([badge, achievement, admin_badge])
      Company.any_instance.stub_chain(:badges, :enabled, :achievements).and_return( [achievement] )
      Company.any_instance.stub_chain(:badges, :enabled, :admin).and_return( [admin_badge] )      
      Company.any_instance.stub_chain(:badges, :enabled, :normal).and_return( [badge] )      
      Company.any_instance.stub_chain(:badges, :enabled, :find).and_return( achievement )      
      
    }

    it 'shows badge graphics' do
      badge_imgs = all(".badge-page-item img")
      expect(badge_imgs.length).to eq(3)
      badge_imgs.each do |img|
        expect(img["src"]).to eq("/images/"+fake_image_path)
      end
    end

    it 'shows badge titles' do
      expect(page).to have_content("Cool peer badge")
      expect(page).to have_content("Admin Badge")
      expect(page).to have_content("Awesome Achievement")
      Badge.all.each do |badge|
        expect(page).to_not have_content(badge.short_name)
      end
    end

    it "shows badge descriptions" do
      expect(page).to have_content badge_description, count: 3
    end

    it "shows achievement badge detail" do
      expect(page).to have_content("Receiving interval")
      expect(page).to have_content("Monthly")
      expect(page).to have_content("10")
      expect(page).to have_content("Receiving limit")
    end

    context "when following link to show page" do
      before do
        FactoryGirl.create(:recognition, recipients: [user], badge_id: achievement.id)
        click_on "Awesome Achievement"        
      end

      it "should be on show page" do
        expect(page.current_path) == company_badge_path(id: achievement.id, network: user.network)
      end

      it "should show achievement badge" do
        expect(page).to have_content("Awesome Achievement")
        expect(page).to have_content("Recognitions")
      end
      
    end
  end

  context "When company has free package" do

    it "should show all the badges" do
      expect(page).to have_content("Thumbs up")
      expect(page).to have_content("Brilliant")
      expect(page).to have_content("Boss")
    end
  end

end