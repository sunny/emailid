require 'digest/md5'
require 'openid'

module ServerHelper

  protected

  def is_email(email)
    /^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$/i =~ email
  end
  
  def hash_for_email(email)
    Digest::SHA1.hexdigest "#{ApplicationController::SECRET}#{ApplicationController::BASE_URI}#{email} ftw"[0..12]
  end
  
  def email_from_user(uri)
    uri.split('/').last
  end
  
  def add_sreg(request, response)
    required = request.query['openid.sreg.required']
    optional = request.query['openid.sreg.optional']
    policy_url = request.query['openid.sreg.policy_url']
    if required or optional or policy_url 
      response.add_fields('sreg', {
        'email' => email_from_user(request.identity_url),
      })
    end
  end
end
