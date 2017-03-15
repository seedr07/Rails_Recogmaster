class CompanyAdmin::BaseController < ApplicationController
  include CompanyAdminConcern
  layout "company_admin"

end