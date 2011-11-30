require './app'

run Sinatra::Application

#use Rack::Static, 
#  :urls => ["/stylesheets", "/images", "/javascripts"],
#  :root => "public"
#
#run Rack::File.new("public")
#
#run lambda { |env|
#  [
#    200, 
#    {
#      'Content-Type'  => 'text/html', 
#      'Cache-Control' => 'public, max-age=86400' 
#    },
#    File.open('public/index.html', File::RDONLY)
#  ]
#}

