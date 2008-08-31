class IdMailer < ActionMailer::Base
  def login(email, base_uri, auth_uri)
    recipients email
    from "negatif@gmail.com"
    subject "EmailID login to #{base_uri}"
    body :email => email,
         :base_uri => base_uri,
         :auth_uri => auth_uri
  end
end
