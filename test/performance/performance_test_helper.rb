require 'authlogic/test_case'
require File.expand_path('../../../spec/support/user_session_helper', __FILE__)

#ensure roles
%w{Admin CompanyAdmin TeamLeader Employee}.each do |role|
  Role.create :name => role.underscore unless Role.respond_to?(role.downcase.to_sym)
end    
Role.create :name => "system_user" unless Role.respond_to?(:system_user)

#Create badges if not already there
Badge::SET.each{|b| FactoryGirl.create("#{b}_badge") unless Badge.exists?(name: b.to_s) }

#create system user
User.send(:_create_system_user!)