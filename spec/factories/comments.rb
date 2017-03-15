FactoryGirl.define do
  factory :comment do
    commenter_id 1
    content "MyText"
    commentable_id 1
    commentable_type "Recognition"
  end
end
