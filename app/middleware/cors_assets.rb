class CorsAssets
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    if env['REQUEST_URI'].present?
      if env['REQUEST_URI'].match(/^\/assets\//)
        headers["Access-Control-Allow-Origin"] = "https://www.yammer.com"
        headers["Access-Control-Allow-Headers"] = "Origin, X-Requested-With, Content-Type, Accept"
      elsif env['REQUEST_URI'].match(/proxy\.html/) || env['REQUEST_URI'].match(/xdomain\.js/)
      end
    end
    headers['P3P'] = "policyref=\"https://recognizeapp.com/w3c/p3p.xml\", CP=\"CURa ADMa DEVa TAIa PSAa PSDa IVAa IVDa CONo OUR IND DSP IDC COR\""    
    [status, headers, response]
  end


end