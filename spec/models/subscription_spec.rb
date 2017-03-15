 require 'spec_helper'

describe Subscription do

  context "when working with a subscription" do 

    subject { Subscription.new }
    
    it { should belong_to :user }
    it { should belong_to :company }
  end  
end
