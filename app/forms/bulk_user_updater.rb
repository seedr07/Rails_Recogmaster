class BulkUserUpdater
  include ActiveModel::Model

  attr_reader :company, :user, :users_to_create, :users_to_update, :params, :id
  validate :all_users_are_valid

  UPDATEABLE_ATTRS = [:first_name, :last_name, :email, :network, :job_title]

  def initialize(company, user)
    @company = company
    @user = user
  end

  def update(_params)
    @params = _params
    setup_users_to_create
    setup_users_to_update

    if valid?
      User.transaction do 
        users_to_create.map(&:save!)
        users_to_update.map(&:save!)
      end
      return true
    else
      return false
    end
  end

  def can_edit?(field)
    case field
    when :department
      user.director? && user.company.in_family?
    else
      return true
    end
  end

  def persisted?
    true
  end

  def self.attributes_for_json
    [:created_users, :updated_users]
  end

  def created_users
    valid? ? users_to_create.select(&:persisted?).map{|u| {id: u.id, email: u.email, temporary_id: u.new_record_temporary_id}} : []
  end

  def updated_users
    valid? ? users_to_update.map{|u| {id: u.id, email: u.email}} : []
  end

  private

  def setup_users_to_create
    set = params[:bulk_user_updater].inject([]) do |array, (slug, user_params)|
      if user_params[:create].present? && user_params[:create] == "1"
        user = User.new(user_params.slice(*UPDATEABLE_ATTRS))
        user.company = Company.find_by(domain: user_params[:network]) || @user.company# force company to the department param
        user.network = user.company.domain # force network
        user.skip_same_domain_check = true # allow external users to be added via bulk user form
        user.new_record_temporary_id = user_params[:id]
        array << user
      end
      array
    end
    @users_to_create = UserCollection.new(set)    
  end

  def setup_users_to_update
    set = params[:bulk_user_updater].inject([]) do |array, (slug, user_params)|
      if user_params[:update].present? && user_params[:update] == "1"
        user = User.find(user_params[:id])

        if user_params[:network].present? && user.network != user_params[:network]
          new_company = Company.find_by(domain: user_params[:network])# force company to the department param
          user.move_company_to!(new_company)
          user.reload
        end

        user.skip_same_domain_check = true # allow external users to be added via bulk user form
        user.assign_attributes(user_params.slice(*UPDATEABLE_ATTRS))
        array << user
      end
      array
    end
    @users_to_update = UserCollection.new(set)
  end

  def all_users_are_valid
    if (users_to_update && !users_to_update.valid?) || (users_to_create && !users_to_create.valid?)
      #FIXME: UPDATE TRANSLATION
      errors.add(:base, I18n.t('activerecord.models.bulk_user_updater.errors.all_users_are_valid', default: "Save did not complete due to the errors below."))
      # hack to get json resource to report errors on the respective collection
      errors.add(:users_to_create, "") unless users_to_create.valid?
      errors.add(:users_to_update, "") unless users_to_update.valid?
    end
  end

  class UserCollection < Array
    def valid?
      @valid ||= each(&:valid?) && !errors.present?
    end

    def errors
      @errors ||= inject({}){|hash, u| 
        id = u.persisted? ? u.to_param : u.new_record_temporary_id
        hash[id] = u.errors if u.errors.present?
        hash
      }
    end
  end
end