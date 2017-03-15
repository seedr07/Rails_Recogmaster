RSpec::Matchers.define :have_image do |image_path|
  match do 
    page.should have_xpath("//img[@src=\"#{image_path}\"]")
  end
end