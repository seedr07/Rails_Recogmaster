# This is a dangerous class as it can create a user and add to any company
# It should only be used by trusted clients
# The authorization of this should be handled by said client.
class ExternalUserCreator
  attr_reader :params, :user

  def self.create(params)
    new(params).create
  end

  def initialize(params)
    @params = params
  end

  def create
    return self if user_exists?

    unless company = company_exists_for_desired_network?
      company = create_company
    end

    @user = User.new(params)
    @user.network = network if network.present?
    @user.company = Company.find_by(domain: network) if network.present?
    @user.skip_name_validation = true
    @user.skip_same_domain_check = true # allow external users to be added
    @user.save
    @user.roles << Role.company_admin if company.users.size == 0
    self
  end

  private
  def user_exists?
    @user ||= User.find_by(email: params[:email], network: network)
  end

  def network
    params[:network] || params[:email].to_s.split("@").last
  end

  def create_company
    Company.create!(domain: network)
  end

  def company_exists_for_desired_network?
    Company.find_by(domain: network) if network.present?
  end

end