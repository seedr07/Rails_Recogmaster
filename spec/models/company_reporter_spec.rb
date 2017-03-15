require 'spec_helper'
require 'support/sample_data'
describe CompanyReporter do
  before(:all) do
    Recognize::Application.config.skip_init_db = true

    @num_users, @num_recognitions = 10,10
    @domain = "company#{FactoryGirl.generate(:count)}.com"
    
    @all_sample_data = {}
    Timecop.freeze(2.months.ago)
    @sample_data = SampleData::Generator.new(@domain, @num_users, @num_recognitions)
    @sample_data.generate!
    @all_sample_data[:yearly] = @sample_data
    
    Timecop.return
    Timecop.freeze(2.weeks.ago)
    @sample_data = SampleData::Generator.new(@domain, @num_users, @num_recognitions)
    @sample_data.generate!
    @all_sample_data[:monthly] = @sample_data

    Timecop.return
    @sample_data = SampleData::Generator.new(@domain, @num_users, @num_recognitions)
    @sample_data.generate!
    @all_sample_data[:weekly] = @sample_data

    @reporter = CompanyReporter.new(Company.find_by_domain(@domain))
  end
  
  after(:all) do
    Recognize::Application.config.skip_init_db = false
  end

  context "when testing reportable data without a time restriction" do
    before do  
    end
    
    it "should return proper data about recognitions" do
      @reporter.total_recognitions.should == @num_recognitions*3+1
      @reporter.top_recognitions.length.should == @num_recognitions*3+1
    end
    
    it "should limit top recognitions" do
      @reporter.top_recognitions(limit: 3).length.should == 3
    end
    
    it "should limit top badges" do
      @reporter.top_badges(limit: 3).length.should == 3
    end
    
    it "should return top badges" do
      badges = @reporter.top_badges
      prev = nil
      badges.each do |badge_id, badge_data|
        (badge_data[:count] <= prev).should be_true unless prev.nil?
        prev = badge_data[:count]
      end
    end
    
    it "should return top teams" do
      teams = @reporter.top_teams
      prev = nil
      teams.each do |team|
        (team.total_points <= prev).should be_true unless prev.nil?
        prev = team.total_points
      end
    end
    
    it "should limit top teams" do
      @reporter.top_teams(limit: 3).length.should == 3
    end
  end
  
  context "when testing reportable data within the past month" do
    it "should only return recognitions from the past month" do
      @reporter.top_recognitions(since: 1.month.ago).length.should == @num_recognitions*2
    end
    
    it "should only return top badges from the past month" do
      expected = (@all_sample_data[:weekly].recognitions+@all_sample_data[:monthly].recognitions).uniq{|r| r.badge_id}
      @reporter.top_badges(since: 1.month.ago, limit: 100000).length.should == expected.length
    end
    
    it "should only return the number of recognitions since the past month" do
      expected = @all_sample_data[:monthly].recognitions.length+@all_sample_data[:weekly].recognitions.length
      @reporter.recognitions_since(1.month.ago).length.should == expected
    end
  end

  context "when testing reportable data within the past week" do
    it "should only return recognitions from the past week" do
      @reporter.top_recognitions(since: 1.week.ago).length.should == @num_recognitions
    end

    it "should only return top badges from the past week" do
      @reporter.top_badges(since: 1.week.ago, limit: 10000).length.should == @all_sample_data[:weekly].recognitions.collect{|r| r.badge_id}.uniq.length
    end

    it "should only return the number of recognitions since the past week" do
      @reporter.recognitions_since(1.week.ago).length.should == @all_sample_data[:weekly].recognitions.length
    end
    
  end
end
