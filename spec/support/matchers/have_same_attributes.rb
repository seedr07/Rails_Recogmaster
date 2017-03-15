#Checks an ActiveRecord model's attributes match those
#of the hash passed in.  The hash passed in can be just a hash
#or another active record model.
#This will skip id, created_at, and updated_at, and deleted_at fields
RSpec::Matchers.define :have_same_attributes_of do |expected|
  match do |actual|
    check_attributes(actual, expected)
  end

  def check_attributes(actual, expected)
    [:id, :created_at, :updated_at, :deleted_at].each do |col|
      #handle both the symbol and string keys
      [col, col.to_s].each do |f|
        actual.delete(f)
        expected.delete(f)
      end
    end
    
    actual == expected
  end
end