Devise.setup do |config|
  
  # with default "from" parameter.
  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'

   # available as additional gems.
  require 'devise/orm/active_record'
  
  # to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [:email]
 
  # modifying a user and when used to authenticate or find a user. Default is :email.
  config.strip_whitespace_keys = [:email]
  
  # passing skip: :sessions to `devise_for` in your config/routes.rb
  config.skip_session_storage = [:http_auth]
  
   # a value of 20 is already extremely slow: approx. 60 seconds for 1 calculation).
  config.stretches = Rails.env.test? ? 1 : 12
 
  # not when the unconfirmed email is confirmed.
  config.reconfirmable = true

    # Invalidates all the remember me tokens when the user signs out.
  config.expire_all_remember_me_on_sign_out = true

  # Range for password length.
  config.password_length = 6..128

  # to give user feedback and not to assert the e-mail validity.
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # change their passwords.
  config.reset_password_within = 6.hours
  
  # The default HTTP method used to sign out a resource. Default is :delete.
  config.sign_out_via = :delete

   # Note: These might become the new default in future versions of Devise.
  config.responder.error_status = :unprocessable_content
  config.responder.redirect_status = :see_other
config.scoped_views = true 
end
