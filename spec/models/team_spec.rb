require 'spec_helper'

describe Team do

  context "when working with a team" do 

    subject { Team.new }
    
    it { should validate_presence_of :company_id }
    it { should validate_presence_of :name }
    it { should belong_to :company }
    it { should have_many :user_teams }
    it { should have_many :users }
    it { should have_many :team_managers }
  end  

  context "when saving a team" do
    before do
      @name = "human resources #{FactoryGirl.generate(:count)}"
      @team = FactoryGirl.build(:team, name: @name)
      @team.save
    end
    
    it "should be persisted" do
      @team.persisted?.should be_true
    end

    it "should capitalize the first letter" do
      @team.reload
      @team.name.should_not == @name
      @team.name.should == @name.capitalize
    end
    
    it "should not decapitalize any other letters" do
      @name = "creative Advertising"
      @team = FactoryGirl.build(:team, name: @name)
      @team.save
      @team.persisted?.should be_true
      @team.reload
      @team.name.should == "Creative Advertising"
      
    end
  end
end
