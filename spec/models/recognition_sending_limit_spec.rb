require 'spec_helper'

describe "Recognition Sending Limits" do
  let(:company) { FactoryGirl.create(:company_with_users) }
  let(:admin) { company.company_admin }
  let(:badge) { company.company_badges.first }
  let(:badge_sending_scope) { Recognition::LimitScope.id_from_name(:recognition) }
  let(:global_sending_scope) { Recognition::LimitScope.id_from_name(:recognition) }
  let(:default_sending_scope) { Recognition::LimitScope.id_from_name(:recognition) }
  let(:recipients) { [FactoryGirl.generate(:email)] }

  def build_recognition(_opts = {})
    opts = {sender: admin, badge_id: badge.id, recipients: recipients}

    Recognition.new(opts.merge(_opts)) 
    
  end

  before do
    company.update_columns({
      default_recognition_limit_frequency: default_recognition_limit_frequency,
      default_recognition_limit_interval_id: default_recognition_limit_interval_id,
      default_recognition_limit_scope_id: default_sending_scope,
      recognition_limit_frequency: recognition_limit_frequency,
      recognition_limit_interval_id: recognition_limit_interval_id,
      recognition_limit_scope_id: global_sending_scope,
    })
    badge.update_columns({
      sending_frequency: badge_limit_frequency,
      sending_interval_id: badge_limit_interval_id,
      sending_limit_scope_id: badge_sending_scope
    })
  end

  context "when default, global, and explicit badge limit are set" do
    # default: 1x/day
    let(:default_recognition_limit_frequency) { 1 }
    let(:default_recognition_limit_interval_id) { Interval.daily.to_i }

    # global: 2x/day
    let(:recognition_limit_frequency) { 2 }
    let(:recognition_limit_interval_id) { Interval.daily.to_i }

    # badge: 3x/day
    let(:badge_limit_frequency) { 3 }
    let(:badge_limit_interval_id) { Interval.daily.to_i }

    it "has global setting taking precedence" do
      # first one should succeed
      expect(build_recognition(message: "msg1").save).to be_true

      # second one should succeed
      expect(build_recognition(message: "msg2").save).to be_true

      # third one should fail
      expect(build_recognition(message: "msg3").save).to be_false

    end
  end

  context "when default, and global are set, but no explicit badge limit is set, and default is greater than global" do 
    # default: 1x/day
    let(:default_recognition_limit_frequency) { 4 }
    let(:default_recognition_limit_interval_id) { Interval.daily.to_i }

    # global: 2x/day
    let(:recognition_limit_frequency) { 2 }
    let(:recognition_limit_interval_id) { Interval.daily.to_i }

    # badge: none
    let(:badge_limit_frequency) { nil }
    let(:badge_limit_interval_id) { nil }

    it "has global setting taking precedence" do
      # first one should succeed
      expect(build_recognition(message: "msg1").save).to be_true

      # second one should succeed
      expect(build_recognition(message: "msg2").save).to be_true

      # third one should fail
      recognition = build_recognition(message: "msg3")
      expect(recognition.save).to be_false
      expect(recognition.errors.count).to eq(1)

    end
  end

  context "when default, and global are set, but no explicit badge limit is set, and default is less than global" do 
    # default: 1x/day
    let(:default_recognition_limit_frequency) { 1 }
    let(:default_recognition_limit_interval_id) { Interval.daily.to_i }

    # global: 2x/day
    let(:recognition_limit_frequency) { 2 }
    let(:recognition_limit_interval_id) { Interval.daily.to_i }

    # badge: none
    let(:badge_limit_frequency) { nil }
    let(:badge_limit_interval_id) { nil }

    it "has default badge setting taking precedence" do
      # first one should succeed
      expect(build_recognition(message: "msg1").save).to be_true

      # second one should fail
      recognition = build_recognition(message: "msg2")
      expect(recognition.save).to be_false
      expect(recognition.errors.count).to eq(1)

      # third one should fail
      expect(build_recognition(message: "msg3").save).to be_false

    end
  end

  context "when default and explicit badge limit are set, but not global" do
    # default: 1x/day
    let(:default_recognition_limit_frequency) { 1 }
    let(:default_recognition_limit_interval_id) { Interval.daily.to_i }

    # global: none
    let(:recognition_limit_frequency) { nil }
    let(:recognition_limit_interval_id) { nil }

    # badge: 3x/day
    let(:badge_limit_frequency) { 3 }
    let(:badge_limit_interval_id) { Interval.daily.to_i }

    it "has explicit badge setting taking precedence" do
      # first one should succeed
      expect(build_recognition(message: "msg1").save).to be_true

      # second one should succeed
      expect(build_recognition(message: "msg2").save).to be_true

      # third one should succeed
      expect(build_recognition(message: "msg3").save).to be_true

      # fourth one should fail
      expect(build_recognition(message: "msg4").save).to be_false

    end    
  end

  context "when scope is set to user" do
    let(:badge_sending_scope) { Recognition::LimitScope.id_from_name(:user) }
    let(:global_sending_scope) { Recognition::LimitScope.id_from_name(:user) }
    let(:default_sending_scope) { Recognition::LimitScope.id_from_name(:user) }
    let(:num_recipients) { 3 }
    let(:recipients) { num_recipients.times.map{FactoryGirl.generate(:email)} }

    context "when default, global, and explicit badge values are set" do
      # default: 1x/day
      let(:default_recognition_limit_frequency) { 1 }
      let(:default_recognition_limit_interval_id) { Interval.daily.to_i }

      # global: 2x/day
      let(:recognition_limit_frequency) { 2 }
      let(:recognition_limit_interval_id) { Interval.daily.to_i }

      # badge: 3x/day
      let(:badge_limit_frequency) { 3 }
      let(:badge_limit_interval_id) { Interval.daily.to_i }      
  
      it "should not allow setting more recipients than allowed by global setting" do
        recognition = build_recognition(message: "msg1")
        expect(recognition.save).to be_false        
        expect(recognition.errors.count).to eq(1)
      end      
  
    end
  
  end
end