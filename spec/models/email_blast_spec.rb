require 'spec_helper'
 
describe EmailBlast do
  describe 'monthly_blast' do
    before do
      @user = FactoryGirl.create(:active_user) 
      @reporter = Report::Company.new(@user.company, 1.month.ago, interval: Interval.monthly) 
      @mail = EmailBlast.monthly_blast(@user, @reporter, Report::Company.new(@user.company)) 
    end
 
    #ensure that the subject is correct
    it 'renders the subject' do
      @mail.subject.should == "#{@user.company.name.humanize} monthly recognition update"
    end
 
    #ensure that the receiver is correct
    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end
 
    #ensure that the sender is correct
    it 'renders the sender email' do
      @mail.from.should == ['donotreply@recognizeapp.com']
    end
 
    #ensure that the @name variable appears in the email body
    it 'assigns @name' do
      @mail.body.encoded.should match(@user.first_name)
    end
 
  end
  describe 'weekly_blast' do
    before do
      @user = FactoryGirl.create(:active_user) 
      @reporter = Report::Company.new(@user.company, 1.week.ago, interval: Interval.weekly) 
      @mail = EmailBlast.weekly_blast(@user, @reporter, Report::Company.new(@user.company)) 
    end
 
    #ensure that the subject is correct
    it 'renders the subject' do
      @mail.subject.should == "#{@user.company.name.humanize} weekly recognition update"
    end
 
    #ensure that the receiver is correct
    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end
 
    #ensure that the sender is correct
    it 'renders the sender email' do
      @mail.from.should == ['donotreply@recognizeapp.com']
    end
 
    #ensure that the @name variable appears in the email body
    it 'assigns @name' do
      @mail.body.encoded.should match(@user.first_name)
    end
 
  end

  describe 'daily_blast' do
    before do
      @user = FactoryGirl.create(:active_user) 
      @reporter = Report::Company.new(@user.company, 1.day.ago, interval: Interval.daily) 
      @mail = EmailBlast.daily_blast(@user, @reporter) 

    end
 
    #ensure that the subject is correct
    it 'renders the subject' do
      @mail.subject.should == "#{@user.company.name.humanize} daily recognitions"
    end
 
    #ensure that the receiver is correct
    it 'renders the receiver email' do
      @mail.to.should == [@user.email]
    end

    it "has content you would expect" do
      @mail.body.should include("chrome/logo-blue.png")
      @mail.body.should include("Recognitions sent in the past day")
      @mail.body.should include("contact us")
      @mail.body.should include("<strong>unsubscribe</strong>")
    end
 
    #ensure that the sender is correct
    it 'renders the sender email' do
      @mail.from.should == ['donotreply@recognizeapp.com']
    end
 
    #ensure that the @name variable appears in the email body
    it 'assigns @name' do
      @mail.body.encoded.should match(@user.first_name)
    end    
  end
end