FactoryGirl.define do

  factory :attachment do |a|
    file {File.new(File.join(Rails.root, 'spec', 'factories', 'sampleimage.jpg'))}
    owner {|b| FactoryGirl.create(:user)}
    
    factory :avatar_attachment do |pa|
    end
  end

  
end