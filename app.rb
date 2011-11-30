require 'sinatra'

set :email_username, ENV['SENDGRID_USERNAME'] || 'app1796376@heroku.com'
set :email_password, ENV['SENDGRID_PASSWORD'] || '8nmbqqgb'
set :email_address,  'CIS Visa <help@cisvisa.com>'
set :email_service,  ENV['EMAIL_SERVICE'] || 'sendgrid.net'

def send_email(recipient, subject, body)
  require 'pony'
  Pony.mail(
    :from => settings.email_address,
    :to => recipient,
    :subject => subject,
    :body => body,
    :port => '587',
    :via => :smtp,
    :via_options => {
    :address              => 'smtp.' + settings.email_service,
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => settings.email_username,
    :password             => settings.email_password,
    :authentication       => :plain,
  })
end

post '/referral' do
  raise 'Error sending email' unless send_email('leads@cisvisa.com', 'New Lead', [<<EOF])
Well howdelydoodelydoo,

You've received a new lead.  Here's the lowdown:
Name:   #{params[:name]}
Email:  #{params[:email]}
Phone:  #{params[:phone]}
Langs:  #{params[:languages]}
Locale: #{params[:locale]}
Info:  
#{params[:information]}
EOF
  redirect "/#{params[:locale]}/referralmade.html"
end
