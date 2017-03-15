#
# Subclasses must implement: 
#
#    + remove_users
#    + add_users
#    + has_person?(user)
#
class Teams::BaseUpdater
  include ActiveModel::Model

  attr_accessor :people, :team
  attr_reader :attributes

  def initialize(attributes={})
    super
    @attributes ||= attributes
    @people = User.where(id: attributes["people"])
  end

  def persisted?
    true
  end  

  def save
    remove_users
    add_users
    after_save
  end

  private
  def after_save
  end
end