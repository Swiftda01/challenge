require 'sinatra'
require 'sinatra/reloader' if development?
require './lib/profile'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

set :application_id, 'a18f1d3329c860b911bf27af8af6f1f9498e54a99368d998de180ebdce512fde'
set :secret, 'fe51809b72955e5ad2029f82d5e9a5861770e7fb9a5c73d643de6ddbadd02a01'
set :redirect_uri, 'http://localhost:4567/callback'
set :site_url, 'https://wegotcoders.com'
set :session_secret, 'secret'
enable :sessions

get '/check_prime' do

  if signed_in?
    @profile = trainee.get_profile
  end

  def check_prime(number)   
    for i in 2..(number - 1)
      if (number % i) == 0
        return "The number you submitted is NOT a prime."
      else
        return "The number you submitted is a prime!"
      end
    end
  end

  @result = check_prime(params[:number].to_i)

  erb :check_prime, :layout => :main
end

get '/primes' do

  if signed_in?
    @profile = trainee.get_profile
  end

  @sum = Primes.sum_to(params[:limit].to_i)

  erb :primes, :layout => :main
end

get '/multiples' do


  if signed_in?
    @profile = trainee.get_profile
  end

  @multiples_arr = []

  for i in (1..1000)
    if i % params[:multiple].to_i == 0
      @multiples_arr << i
    end
  end

  @multiples_sum = @multiples_arr.inject(:+)


  erb :multiples, :layout => :main
end

get '/' do

  if signed_in?
    @profile = trainee.get_profile
  end

  @info = Hash.new
  @info["about"] = "I am an ambitious and motivated individual who is currently working for the Civil Service but looking to pursue a career in web development.
Since graduating from Loughborough University in 2010 - where I studied Politics and Economics - I have gone on to work in a variety of different positions within the financial, legal, and retail service industries. This experience has allowed me to build my professional and communication skills, which I am now looking to utilize within a more rewarding and suitable role.
"
  @info["why_apply"] = "We Got Coders stood out to me because of its small class size and culture of immersive and collaborative learning. The curriculum aligns flawlessly with my programming interests and career goals, and the prospect of being able to go straight into employment afterwards appeals to me greatly. I operate best when I'm working in a structured environment with like-minded, motivated people, and We Got Coders offers a great opportunity to do this. I would also like to study in a peaceful location without the stress of having to find short-term accommodation and the distraction of commuting to class every day."
  @info["where_in_1"] = "In 1 year's time I would like to be a confident and capable Ruby developer, working for a professional organisation and gaining the practical experience needed in order to take my knowledge of the subject to the next level. I would also like to be working on my own personal projects in order to build up an attractive portfolio which I could be proud to present to employers. Finally, I would like to have the confidence and grounding to go on to learn other programming languages in order to make myself a more versatile and employable developer."
  @info["web_track_completedness"] = "100%"
  @info["ruby_track_completedness"] = "100%"
  @info["js_track_completedness"] = "100%"

  @dob = @profile["dob"].gsub!(/-/, "")
  @dob_form = Date.parse(@dob).strftime("%d/%m/%Y")

  erb :index, :layout => :main
end

post '/update' do
  response = trainee.update_profile(params)

  if @errors = response["errors"]
    erb :error, :layout => :main
  else
    redirect '/'
  end
end

include Sinatra::OauthRoutes

def trainee
  @trainee ||= WeGotCoders::Trainee.new(settings.site_url, session[:access_token])
end
