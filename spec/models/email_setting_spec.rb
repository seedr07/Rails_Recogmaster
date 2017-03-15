require 'spec_helper'

describe EmailSetting do
  context "when working with a basic instane of EmailSetting" do 

    subject { EmailSetting.new }
    
    it { should validate_presence_of :user_id }
    it { should validate_inclusion_of :global_unsubscribe, in: [true, false] }
    it { should validate_inclusion_of :new_recognition, in: [true, false] }
    it { should validate_inclusion_of :weekly_updates, in: [true, false] }
    
  end
end
