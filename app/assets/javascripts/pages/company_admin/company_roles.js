window.R = window.R || {};
window.R.pages = window.R.pages || {};

window.R.pages["company_admin_roles-index"] = (function() {
  var CompanyRoles = function() {
    this.addEvents();
  };  

  CompanyRoles.prototype.addEvents = function() {
    var companyAdmin = new R.CompanyAdmin();
  };
  
  return CompanyRoles;

})();
