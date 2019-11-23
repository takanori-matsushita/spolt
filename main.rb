require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/cookies'
require 'sinatra/base'
require 'erb'
require 'active_record'
require 'action_mailer'
require 'bcrypt'
require 'fileutils'
require 'easy_breadcrumbs'
require 'date'
require 'pg'
require 'pry'
require './class'
require './admin'

# not_found do
#   "not found"
# end

# error do
#   "sorry"
# end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

def imgUp
  if params[:img].nil?
  else
  @image = params[:img][:filename]
  FileUtils.mv(params[:img][:tempfile], "./public/images/#{@image}")
  end
end

def client
  PG::connect(
  :host => "",
  :user => 'matsushitatakanori',
  :password => '6fpwr1a3',
  :dbname => "spolt_2899_db")
  end

# front-page
########################################################
get '/' do
  @sliders = Slider.all
  @c_infos = Competition.all.where(compe_kind_id: 1).order(created_at: "desc").limit(5)
  @c_results = Competition.all.where(compe_kind_id: 2).order(updated_at: "desc").limit(5)
  @events = Event.all
  @generations = Generation.all
  @area1 = Pref.all.where(area_id: 1).order(id: "asc")
  @area2 = Pref.all.where(area_id: 2).order(id: "asc")
  @area3 = Pref.all.where(area_id: 3).order(id: "asc")
  @area4 = Pref.all.where(area_id: 4).order(id: "asc")
  @area5 = Pref.all.where(area_id: 5).order(id: "asc")
  @area6 = Pref.all.where(area_id: 6).order(id: "asc")
  @area7 = Pref.all.where(area_id: 7).order(id: "asc")
  @news = New.all.order(created_at: "desc").limit(5)
  @notice5 = New.all.where(newscategory_id: 1).order(created_at: "desc").limit(5)
  @release5 = New.all.where(newscategory_id: 2).order(created_at: "desc").limit(5)
  @topics5 = New.all.where(newscategory_id: 3).order(created_at: "desc").limit(5)
  @cat_news = Newscategory.all.order(id: "asc")
  erb :index
end

# compe-info
########################################################
get '/compe-info' do
  @compe = Competition.all.where(compe_kind_id: 1).order(created_at: "desc")
  erb :competemp
end

get '/compe-info/:id' do
  @compe = Competition.find(params['id'])
  @setting = Setting.first
  erb :compe_single
end

get '/cat-event-info' do

end

get '/cat-pref-info' do

end

get '/cat-generation-info' do

end

# compe-result
########################################################
get '/compe-result' do
  @compe = Competition.all.where(compe_kind_id: 2).order(updated_at: "desc")
  erb :competemp
end

get '/compe-result/:id' do
  @compe = Competition.find(params['id'])
  @setting = Setting.first
  erb :compe_single
end

get '/cat-event-result' do

end

get '/cat-pref-result' do

end

get '/cat-generation-result' do

end

# category-event
########################################################
get '/cat-event/:slug' do
  event = Event.find_by(slug: params[:slug])
  @compe = event.competitions
  erb :competemp
end

# news
########################################################
get '/news' do
  @new = New.all.order(created_at: "desc")
  @title = "ニュース一覧"
  @p = "ニュース一覧です。"
  erb :newslist
end

get '/news/notice' do
  @new = New.all.where(newscategory_id: 1).order(created_at: "desc")
  @title = "お知らせ一覧"
  @p = "お知らせ情報一覧です。"
  erb :newslist
end

get '/news/notice/:id' do
  @new = New.find(params['id'])
  erb :news_single
end

get '/news/release' do
  @new = New.all.where(newscategory_id: 2).order(created_at: "desc")
  @title = "リリース一覧"
  @p = "リリース情報一覧です。"
  erb :newslist
end

get '/news/release/:id' do
  @new = New.find(params['id'])
  erb :news_single
end

get '/news/topics' do
  @new = New.all.where(newscategory_id: 3).order(created_at: "desc")
  @title = "トピックス一覧"
  @p = "トピックス情報一覧です。"
  erb :newslist
end

get '/news/topics/:id' do
  @new = New.find(params['id'])
  erb :news_single
end

# search
########################################################
get '/search' do
  @searchs = Competition.where("title like ? or content like ?","%#{params['q']}%","%#{params['q']}%").order(updated_at: "desc")
  @word = params['q']
  erb :search
end

get '/refine' do
  pref = params['pref_id']
  event = params['event_id']
  generation = params['generation_id']
  if generation.nil? && event.nil?
  @searchs = Competition.where(pref_id: pref)
  elsif pref.nil? && generation.nil?
  @searchs = Competition.where(event_id: event)
  elsif pref.nil? && event.nil?
  @searchs = Competition.where(generation_id: generation)
  elsif pref.nil?
    @searchs = Competition.where(event_id: event).where(generation_id: generation)
  elsif event.nil?
    @searchs = Competition.where(pref_id: pref).where(generation_id: generation)
  elsif generation.nil?
    @searchs = Competition.where(pref_id: pref).where(event_id: event)
  else
    @searchs = Competition.where(pref_id: pref).where(event_id: event).where(generation_id: generation)
  end
  @word = "test"
  erb :search
end

# pages
########################################################
get '/sponcered' do
  erb :sponcered
end

post '/sponcered/confirm' do
  @company = params['company']
  @zip = params['zip']
  @address = params['address']
  @position = params['position']
  @name = params['name']
  @furi = params['furi']
  @mail = params['mail']
  @tel = params['tel']
  @fax = params['fax']
  @content = params['content']
  erb :sponcered
end

post '/sponcered/thanks' do
  company = params['company']
  zip = params['zip']
  address = params['address']
  position = params['position']
  name = params['name']
  furi = params['furi']
    mail = params['mail']
    tel = params['tel']
    fax = params['fax']
    content = params['content']
    SponcerMailer.send_sponcer(company, zip, address, position, name, furi, mail, tel, fax, content).deliver
    SponcerMailer.send_admin(company, zip, address, position, name, furi, mail, tel, fax, content).deliver
    erb :sponcered
  end

  get '/sponcered/*' do
    redirect '/sponcered'
  end

  get '/inquiry' do
    erb :inquiry
end

post '/inquiry/thanks' do
  name = params['name']
  mail = params['mail']
  title = params['title']
  content = params['content']
  InquiryMailer.send_user(name, mail, title, content).deliver
  InquiryMailer.send_admin(name, mail, title, content).deliver
  erb :inquiry
end

get '/inquiry/*' do
  redirect '/inquiry'
end

get '/:permalink' do
  @page = Page.find_by(permalink: params['permalink'])
  erb :page
end