require 'pathname'
require 'rubygems'
require 'openid'

class ServerController < ApplicationController
  include ServerHelper
  include OpenID::Server
  layout nil
  
  # OpenID server entrypoint
  def index
    begin
      request = server.decode_request(params)
    rescue ProtocolError => e
      render_text e.to_s
      return
    end

    unless request # no openid.mode was given
      render :layout => "home"
    end
    
    if request.kind_of?(CheckIDRequest)
      root = request.trust_root
      @email = email_from_user(request.identity_url)
      hash = hash_for_email(@email)
      auth_url = "#{BASE_URI}ok/#{hash}"
      
      # send email
      IdMailer.deliver_login(@email, root, auth_url)

      # save in session
      session[:request] = request
      session[:email] = @email

      # should rather redirect
      render :action => "sent", :layout => "home"
      return
    end
  
    response = server.handle_request(request)
    render_response(response)
  end
  
  def sent
    @email = session[:email]
    render :layout => "home"
  end
  
  # return from email with a hash
  def ok
  
    # compare given hash to session hash
    if hash_for_email(session[:email]) != params[:hash]
      render :text => "Wrong hash, sorry"
      return
    end
    
    request = session[:request]
    session[:request] = nil
    response = request.answer(true)
    add_sreg(request, response)
    return render_response(response)
  end
  
  # user uri
  def page
    @email = "#{params[:email]}.#{params[:tld]}" # stupid routes forced us, master!
    render :text => "Incorrect email format" unless is_email(@email)
    
    # Yadis content-negotiation: we want to return the xrds if asked for.
    # This is not technically correct, and should eventually be updated
    # to do real Accept header parsing and logic.  Though I expect it will work
    # 99% of the time.
    accept = request.env['HTTP_ACCEPT']
    if accept and accept.include?('application/xrds+xml')
      return render_xrds
    end

    # Content negotiation failed, so just render the user page
    # Also add the Yadis location header, so that they don't have
    # to parse the html unless absolutely necessary.
    @xrds_url = "/auth/#{@email}/xrds"
    response.headers['X-XRDS-Location'] = @xrds_url
    render :layout => "home"
  end

  def xrds
    render_xrds
  end

  protected
 
  def render_xrds
    yadis = <<EOS
<?xml version="1.0" encoding="UTF-8"?>
<xrds:XRDS
    xmlns:xrds="xri://$xrds"
    xmlns:openid="http://openid.net/xmlns/1.0"
    xmlns="xri://$xrd*($v*2.0)">
  <XRD>
    <Service priority="1">
      <Type>http://openid.net/signon/1.0</Type>
      <Type>http://openid.net/sreg/1.0</Type>
      <URI>#{url_for(:controller => 'server')}</URI>
    </Service>
  </XRD>
</xrds:XRDS>
EOS
    response.headers['content-type'] = 'application/xrds+xml'
    render :text => yadis
  end

  def render_response(response)    
    web_response = server.encode_response(response)
    case web_response.code
      when HTTP_OK
        render :text => web_response.body, :status => 200           
      when HTTP_REDIRECT
        redirect_to web_response.redirect_url
      else
        render :text => web_response.body, :status => 400
    end   
  end
  
  def server
    if @server.nil?
      dir = Pathname.new(RAILS_ROOT).join('db').join('openid-store')
      store = OpenID::FilesystemStore.new(dir)
      @server = Server.new(store)
    end
    @server
  end
end
