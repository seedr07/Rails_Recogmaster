require 'test_helper'
require 'rails/performance_test_help'
require 'performance/performance_test_helper'

class RecognitionApprovalsPerformanceTest < ActionDispatch::PerformanceTest
  # Refer to the documentation for all available options
  # self.profile_options = { :runs => 5, :metrics => [:wall_time, :memory]
  #                          :output => 'tmp/performance', :formats => [:flat] }
  
  include UserSessionHelper
  include Authlogic::TestCase
  
  def setup
    Role.employee
    @user1 = FactoryGirl.create(:active_user)
    @user2 = FactoryGirl.create(:active_user, email: "user2@#{@user1.company.domain}")
    @user3 = FactoryGirl.create(:active_user, email: "user3@#{@user1.company.domain}")
    @recognition = @user1.recognize!(@user2, Badge.user_badges.first, "whatever")
    login(@user3)
  end
  
  def test_approving
    post recognition_approvals_path(@recognition)
  end
end
