module Api
  module V2
    module Documentation
      def core_description
        <<-TEXT
          # Recognize Api

          <a name="overview" class='anchor'></a>
          ## Overview
            - The Recognize Api is a RESTful api that is organized around resources such as Users and Recognitions. 
            - Requests must be authenticated via an access token. See Authentication.
            - Responses contain metadata about the response as well as the entity or a collection of entities.

          <a name="base_endpoint" class='anchor'></a>
          ## Base Endpoint

            + Production: https://recognizeapp.com/api/v2
            + Sandbox: https://demo.recognizeapp.com/api/v2

          <a name="authentication" class='anchor'></a>
          ## Authentication
            - Recognize api requests must be authenticated via an OAuth2 token or via a trusted application token.
            - The token must be passed as the header:
                
                  Authentication: Bearer {token}

            - If authenticating with a trusted application token, the header 'X-Auth-Email' must also be sent to identify 
              the current user:

                   X-Auth-Email: sandra@example.com

            - Password Credentials Grant: http://oauthlib.readthedocs.org/en/latest/oauth2/grants/password.html

              <script type='text/javascript'>
              function open_resource() {
                var endpoint = $(event.target).attr('href');
                var str = "a[href='"+ endpoint + "']"
                $(".top-level-endpoints").find(str).trigger('click');
                $(endpoint).find(".content").css({display: "block"})
              }
              </script>
              See more: <a href="#resource_auth" onclick="open_resource()">Here</a>

                   /auth?email=<email>&password=<password>


          <a name="core_response" class='anchor'></a>
          ## Core Response
                
                { "ok" => String, "type" => String }

            + "ok" is one of "success" or "error".
            + "type" is the entity specification of the rest of the payload. 

          <a name="entities" class='anchor'></a>
          ## Response Entities

            Entities describe the structure of the payload that is sent in a response and is specified by the "type" attribute.
            The actual data of the response will be accessible via a key that is correlated to the request. Eg. "user" or "recognitions".

          ### Collection Entity
            
            A response that describes a collection or list of entities.
              
              "page" => Integer - the number of the page
              "count" => Integer
              "total_pages" => Integer
              "total_count" => Integer

          ### Recognition Entity
              
          A response that describes a recognition.

          ```javascript
          #{ Api::V2::Endpoints::Recognitions::Entity.documentation }
          ```

          ### User Entity
              
          A response that describes a user.

          ```javascript
          #{ Api::V2::Endpoints::Users::Entity.documentation }
          ```

        TEXT
      end
    end
  end
end