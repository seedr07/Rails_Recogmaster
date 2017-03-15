# NOTE: With the advent of subcompanies, I had checked that the user belonged to the network they were accessing
#            in this module.  The impetus behind this idea was that if a user switches networks(eg moved to a subcompany)
#            they would automatically be redirected.  But this is a horrible idea, because it puts business logic in this module.
#            Instead, just check its a domain that exists so that we can easily and dry'ly throw a 404 for incorrect domains
#            but still pass it through and let controllers do their job for redirection
class DomainConstraint 
  def matches?(request)
    params = request.path_parameters
    
    if params[:network] == "uploads"
      matches = false
    elsif Company.where(domain: params[:network]).exists?
      matches = true
    else
      matches = false
    end
        
  end
end