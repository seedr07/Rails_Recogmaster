class ExternalUserImporter
  attr_reader :inviter, :company, :users_data

  def self.from_csv(inviter, csv)
    users = CSV.readlines(csv)
    new(inviter, users).import!
  end

  def initialize(inviter, users_data, opts={})
    @inviter = inviter
    @company = @inviter.company
    @users_data = users_data
  end

  def import!
    users_data.each do |user_data|
      company.add_external_user!(inviter, normalize_data(user_data))
    end
  end

  private
  def normalize_data(user_data)
    user_data.kind_of?(Array) ? 
      {first_name: user_data[0], last_name: user_data[1], email: user_data[2]} :
      user_data
  end

end