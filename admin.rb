enable :sessions

before do
  @member = Member.find_by(id: session[:id])
end

author2 = [
  'register', 'pages', 'page-new', 'page-create', 'page-edit/*', 'page-update/*', 'page-destroy/*',
  'top-slider', 'top-slider-new', 'slider-create', 'slider-edit/*', 'slider-update/*', 'slider-destroy/*',
  'sponcers', 'sponcer-new', 'sponcer-create', 'sponcer-edit/*', 'sponcer-update/*', 'sponcer-destroy/*',
  'settings', 'settings-update'
]

author2.each do |path|
  before "/adm-spolt/#{path}" do
    @member = Member.find_by(id: session[:id])
    if @member.author_id == 2
      session[:administrator] = "アクセス権限がありません"
      redirect '/adm-spolt/dashbord'
    end
  end
  end

# login
########################################################
get '/adm-spolt/login' do
  session[:id] = nil   
  @message = session.delete :message
  @notice = session.delete :notice
  session[:message] = nil
  erb :'admin/login', :layout => :'admin/admin-layout'
end

post '/adm-spolt/login' do
  member = Member.find_by(userid: params[:userid])
    if member && member.authenticate(params[:password])
      session[:id] = member['id']
      session[:notice] = "ログインしました"
      redirect "/adm-spolt/dashbord"
      break
    else
      session[:id] = nil
      session[:message] = '入力に誤りがあります'
    end
  redirect '/adm-spolt/login' if session[:id].nil?
end

get '/adm-spolt/logout' do
  if session[:id] != nil
    session.clear
    session[:notice] = "ログアウトしました"
  end
  redirect '/adm-spolt/login'
end

# dashbord
########################################################
get '/adm-spolt/dashbord' do
  @notice = session.delete :notice
  @administrator = session.delete :administrator
  redirect '/adm-spolt/login' if session[:id].nil? #ログインしていなければダッシュボードに入れない
  erb :'admin/dashbord', :layout => :'admin/admin-layout'
end

# member
########################################################
get '/adm-spolt/register' do
  @member = Member.new
  @authors = Author.all.order(id: "asc")
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/register', :layout => :'admin/admin-layout'
end

post '/adm-spolt/register' do
  @authors = Author.all.order(id: "asc")
  @member = Member.new
  @member.author_id = params['author_id']
  @member.userid = params['userid']
  @member.name = params['name']
  @member.password = params['password']
  @member.mail = params['mail']
  if @member.save
    session[:notice] = "管理者を追加しました"
    redirect '/adm-spolt/dashbord'
  else
    # binding.pry
    erb :'admin/register', :layout => :'admin/admin-layout'
    # binding.pry
  end
end

get '/adm-spolt/admin/:userid' do
  @notice = session.delete :notice
  @member = Member.find_by(id: session[:id])
  @authors = Author.all.order(id: "asc")
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/admin-edit', :layout => :'admin/admin-layout'
end

post '/admin/update' do
  @authors = Author.all.order(id: "asc")
  @member = Member.find_by(id: session[:id])
  @member.author_id = params['author_id']
  @member.name = params['name']
  @member.password = params['password']
  @member.mail = params['mail']
  if @member.save
    session[:notice] = "管理者情報を更新しました"
    redirect "/adm-spolt/admin/#{@member.userid}"
  else
    # binding.pry
    erb :'admin/admin-edit', :layout => :'admin/admin-layout'
    # binding.pry
  end
end

# pages
########################################################
get '/adm-spolt/pages' do
  @notice = session.delete :notice
  @pages = Page.all.order(created_at: "desc")
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/pages', :layout => :'admin/admin-layout'
end

get '/adm-spolt/page-new' do
  @page = Page.new
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/page-new', :layout => :'admin/admin-layout'
end

post '/adm-spolt/page-create' do
  @page = Page.new
  @page.title = params['title']
  @page.permalink = params['permalink']
  @page.content = params['content']
  @page.disc = params['disc']
  @page.css = params['css']
  imgUp
  if @image.nil?
  else
  @page.image = @image
  end
  if @page.save
    session[:notice] = "#{@page.title}ページを作成しました"
    redirect "/adm-spolt/pages"
  else
    erb :'admin/page-new', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/page-edit/:id' do
  @page = Page.find(params['id'])
  @notice = session.delete :notice
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/page-edit', :layout => :'admin/admin-layout'
end

post '/adm-spolt/page-update/:id' do
  @page = Page.find(params['id'])
  @page.title = params['title']
  @page.permalink = params['permalink']
  @page.content = params['content']
  @page.disc = params['disc']
  @page.css = params['css']
  imgUp
  if @image.nil?
  else
  @page.image = @image
  end
  if @page.save
    session[:notice] = "#{@page.title}ページを更新しました"
    redirect "/adm-spolt/page-edit/#{params['id']}"
  else
    erb :'admin/page-edit', :layout => :'admin/admin-layout'
  end
  
end

get '/adm-spolt/page-destroy/:id' do
  page = Page.find(params['id'])
  pageTitle = page.title
  page.destroy
  session[:notice] = "#{pageTitle}ページを削除しました"
  redirect '/adm-spolt/login' if session[:id].nil?
  redirect "/adm-spolt/pages"
end

# competition
########################################################
get '/adm-spolt/competition' do
  @competitions = Competition.all.order(created_at: 'desc')
  @notice = session.delete :notice
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/competition', :layout => :'admin/admin-layout'
end

get '/adm-spolt/competition-new' do
  @competition = Competition.new
  @c_count = CompeKind.count
  @events = Event.all.order(id: "asc")
  @prefs = Pref.all.order(id: "asc")
  @generations = Generation.all.order(id: "asc")
  @tags = Tag.all.order(id: "asc")
  @compe_types = CompeKind.all
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/competition-new', :layout => :'admin/admin-layout'
end

post '/adm-spolt/competition-new' do
  @c_count = CompeKind.count
  @events = Event.all.order(id: "asc")
  @prefs = Pref.all.order(id: "asc")
  @generations = Generation.all.order(id: "asc")
  @tags = Tag.all.order(id: "asc")
  @compe_types = CompeKind.all
  @competition = Competition.new
  @competition.compe_kind_id = params['compe_kind_id']
  @competition.compe_date = params['compe_date']
  @competition.compe_end = params['compe_end']
  @competition.title = params['title']
  @competition.content = params['content']
  @competition.disc = params['disc']
  @competition.excerpt = params['excerpt']
  @competition.event_id = params['event_id']
  @competition.pref_id = params['pref_id']
  @competition.generation_id = params['generation_id']
  @competition.tag_id = params['tag_id']
  if @competition.save
    session[:notice] = "大会情報・結果を作成しました"
    redirect "/adm-spolt/competition"
  else
    erb :'admin/competition-new', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/competition-edit/:id' do
  @compe_types = CompeKind.all
  @events = Event.all.order(id: "asc")
  @prefs = Pref.all.order(id: "asc")
  @generations = Generation.all.order(id: "asc")
  @tags = Tag.all.order(id: "asc")
  @competition = Competition.find(params['id'])
  @notice = session.delete :notice
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/competition-edit', :layout => :'admin/admin-layout'
end

post '/adm-spolt/competition-update/:id' do
  @c_count = CompeKind.count
  @events = Event.all.order(id: "asc")
  @prefs = Pref.all.order(id: "asc")
  @generations = Generation.all.order(id: "asc")
  @tags = Tag.all.order(id: "asc")
  @compe_types = CompeKind.all
  @competition = Competition.find(params['id'])
  @competition.compe_kind_id = params['compe_kind_id']
  @competition.compe_date = params['compe_date']
  @competition.compe_end = params['compe_end']
  @competition.title = params['title']
  @competition.content = params['content']
  @competition.disc = params['disc']
  @competition.excerpt = params['excerpt']
  @competition.event_id = params['event_id']
  @competition.pref_id = params['pref_id']
  @competition.generation_id = params['generation_id']
  @competition.tag_id = params['tag_id']
  if @competition.save
    session[:notice] = "大会情報・結果を更新しました"
    redirect "/adm-spolt/competition-edit/#{@competition.id}}"
  else
    erb :'admin/competition-edit', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/competition-destroy/:id' do
  @compe = Competition.find(params['id'])
  session[:notice] = "大会情報・結果を削除しました"
  @compe.destroy
  redirect '/adm-spolt/login' if session[:id].nil?
  redirect "/adm-spolt/competition"
end

# event category
########################################################
get '/adm-spolt/cat-events' do
  @event = Event.new
  @events = Event.all.order(id: "asc")
  @notice = session.delete :notice
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/cat-events', :layout => :'admin/admin-layout'
end

post '/adm-spolt/events-new' do
  @events = Event.all.order(id: "asc")
  @event = Event.new
  @event.id = params['id']
  @event.name = params['name']
  @event.slug = params['slug']
  imgUp
  if @image.nil?
  else
  @event.image = @image
  end
  if @event.save
  session[:notice] = "競技種目カテゴリ：#{@event.name}を追加しました"
  redirect '/adm-spolt/cat-events'
  else
    erb :'admin/cat-events', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/event-edit/:id' do
  @event = Event.find(params['id'])
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/event-edit', :layout => :'admin/admin-layout'
end

post '/adm-spolt/event-update/:id' do
  @event = Event.find(params['id'])
  @event.name = params['name']
  @event.slug = params['slug']
  imgUp
  if @image.nil?
  else
  @event.image = @image
  end
  if @event.save
    session[:notice] = "競技種目カテゴリ：#{@event.name}を更新しました"
    redirect '/adm-spolt/cat-events'
  else
    erb :'admin/event-edit', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/event-destroy/:id' do
  @event = Event.find(params['id'])
  session[:notice] = "競技種目カテゴリ：#{@event.name}を削除しました"
  @event.destroy
  redirect '/adm-spolt/login' if session[:id].nil?
  redirect '/adm-spolt/cat-events'
end

# prefecture category
########################################################
get '/adm-spolt/cat-prefs' do
  @pref = Pref.new
  @prefs = Pref.all.order(id: "asc")
  @areas = Area.all.order(id: "asc")
  @notice = session.delete :notice
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/cat-prefs', :layout => :'admin/admin-layout'
end

post '/adm-spolt/pref-new' do
  @prefs = Pref.all.order(id: "asc")
  @areas = Area.all.order(id: "asc")
  @pref = Pref.new
  @pref.id = params['id']
  @pref.name = params['name']
  @pref.slug = params['slug']
  imgUp
  if @image.nil?
  else
  @pref.image = @image
  end
  if @pref.save
    session[:notice] = "地域カテゴリ：#{@pref.name}を追加しました"
    redirect '/adm-spolt/cat-prefs'
  else
    erb :'admin/cat-prefs', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/pref-edit/:id' do
  @pref = Pref.find(params['id'])
  @areas = Area.all
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/pref-edit', :layout => :'admin/admin-layout'
end

post '/adm-spolt/pref-update/:id' do
  @areas = Area.all
  @pref = Pref.find(params['id'])
  @pref.name = params['name']
  @pref.slug = params['slug']
  imgUp
  if @image.nil?
  else
  @pref.image = @image
  end
  if @pref.save
    session[:notice] = "地域カテゴリ：#{@pref.name}を更新しました"
    redirect '/adm-spolt/cat-prefs'
  else
    erb :'admin/pref-edit', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/pref-destroy/:id' do
  @pref = Pref.find(params['id'])
  session[:notice] = "地域カテゴリ：#{@pref.name}を削除しました"
  @pref.destroy

  redirect '/adm-spolt/login' if session[:id].nil?
  redirect '/adm-spolt/cat-prefs'
end

#generation category
########################################################
get '/adm-spolt/cat-generations' do
  @generation = Generation.new
  @generations = Generation.all.order(id: "asc")
  @notice = session.delete :notice
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/cat-generations', :layout => :'admin/admin-layout'
end

post '/adm-spolt/generations-new' do
  @generations = Generation.all.order(id: "asc")
  @generation = Generation.new
  @generation.id = params['id']
  @generation.name = params['name']
  @generation.slug = params['slug']
  imgUp
  if @image.nil?
  else
  @generation.image = @image
  end
  if @generation.save
    session[:notice] = "年代カテゴリ：#{@generation.name}を追加しました"
    redirect '/adm-spolt/cat-generations'
  else
    erb :'admin/cat-generations', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/generation-edit/:id' do
  @generation = Generation.find(params['id'])
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/generation-edit', :layout => :'admin/admin-layout'
end

post '/adm-spolt/generation-update/:id' do
  @generation = Generation.find(params['id'])
  @generation.name = params['name']
  @generation.slug = params['slug']
  imgUp
  if @image.nil?
  else
  @generation.image = @image
  end
  if @generation.save
    session[:notice] = "年代カテゴリ：#{@generation.name}を更新しました"
    redirect '/adm-spolt/cat-generations'
  else
    erb :'admin/generation-edit', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/generation-destroy/:id' do
  @generation = Generation.find(params['id'])
  session[:notice] = "年代カテゴリ：#{@generation.name}を削除しました"
  @generation.destroy
  redirect '/adm-spolt/login' if session[:id].nil?
  redirect '/adm-spolt/cat-generations'
end

# competition tags
########################################################
get '/adm-spolt/competition-tags' do
  @tag = Tag.new
  @tags = Tag.all.order(id: "asc")
  @notice = session.delete :notice
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/competition-tags', :layout => :'admin/admin-layout'
end

post '/adm-spolt/competition-tag-new' do
  @tags = Tag.all.order(id: "asc")
  @tag = Tag.new
  @tag.id = params['id']
  @tag.name = params['name']
  @tag.slug = params['slug']
  if @tag.save
    session[:notice] = "タグ：#{@tag.name}を追加しました"
    redirect '/adm-spolt/competition-tags'
  else
    erb :'admin/competition-tags', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/competition-tag-edit/:id' do
  @tag = Tag.find(params['id'])
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/competition-tag-edit', :layout => :'admin/admin-layout'
end

post '/adm-spolt/competition-tag-update/:id' do
  @tag = Tag.find(params['id'])
  @tag.name = params['name']
  @tag.slug = params['slug']
  if @tag.save
    session[:notice] = "タグ：#{@tag.name}を更新しました"
    redirect '/adm-spolt/competition-tags'
  else
    erb :'admin/competition-tag-edit', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/competition-tag-destroy/:id' do
  @tag = Tag.find(params['id'])
  session[:notice] = "タグ：#{@tag.name}を削除しました"
  @tag.destroy
  redirect '/adm-spolt/login' if session[:id].nil?
  redirect '/adm-spolt/competition-tags'
end

# news
########################################################
get '/adm-spolt/news' do
  @news = New.all.order(created_at: "desc")
  @notice = session.delete :notice
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/news', :layout => :'admin/admin-layout'
end

get '/adm-spolt/news-new' do
  @news = New.new
  @cat_news = Newscategory.all.order(id: "asc")
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/news-new', :layout => :'admin/admin-layout'
end

post '/adm-spolt/news-create' do
  @cat_news = Newscategory.all.order(id: "asc")
  @news = New.new
  @news.title = params['title']
  @news.content = params['content']
  @news.disc = params['disc']
  @news.excerpt = params['excerpt']
  @news.newscategory_id = params['cat_id']
  if @news.save
    session[:notice] = "ニュース：#{@news.title}を作成しました"
    redirect '/adm-spolt/news'
  else
    erb :'admin/news-new', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/news-edit/:id' do
  @news = New.find(params['id'])
  @cat_news = Newscategory.all.order(id: "asc")
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/news-edit', :layout => :'admin/admin-layout'
end

post '/adm-spolt/news-update/:id' do
  @cat_news = Newscategory.all.order(id: "asc")
  @news = New.find(params['id'])
  @news.title = params['title']
  @news.content = params['content']
  @news.disc = params['disc']
  @news.excerpt = params['excerpt']
  @news.newscategory_id = params['cat_id']
  if @news.save
    session[:notice] = "ニュース：#{@news.title}を更新しました"
    redirect "/adm-spolt/news"
  else
    erb :'admin/news-edit', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/news-destroy/:id' do
  @news = New.find(params['id'])
  session[:notice] = "ニュース：#{@news.title}を削除しました"
  @news.destroy
  redirect '/adm-spolt/login' if session[:id].nil?
  redirect '/adm-spolt/news'
end

# news-category
########################################################
get '/adm-spolt/cat-news' do
  @cat = Newscategory.new
  @cat_news = Newscategory.all.order(id: "asc")
  @notice = session.delete :notice
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/cat-news', :layout => :'admin/admin-layout'
end

post '/adm-spolt/cat-news-create' do
  @cat_news = Newscategory.all.order(id: "asc")
  @cat = Newscategory.new
  @cat.name = params['name']
  @cat.slug = params['slug']
  if @cat.save
    session[:notice] = "ニュースカテゴリ：#{@news.title}を作成しました"
    redirect '/adm-spolt/cat-news'
  else
    erb :'admin/cat-news', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/cat-news-edit/:id' do
  @cat = Newscategory.new
  @cat_news = Newscategory.find(params['id'])
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/cat-news-edit', :layout => :'admin/admin-layout'
end

post '/adm-spolt/cat-news-update/:id' do
  @cat_news = Newscategory.find(params['id'])
  @cat_news.name = params['name']
  @cat_news.slug = params['slug']
  if @cat_news.save
    session[:notice] = "ニュースカテゴリ：#{@news.title}を更新しました"
    redirect '/adm-spolt/cat-news'
  else
    erb :'admin/cat-news-edit', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/cat-news-destroy/:id' do
  @news = Newscategory.find(params['id'])
  session[:notice] = "ニュースカテゴリ：#{@news.title}を作成しました"
  @news.destroy
  redirect '/adm-spolt/login' if session[:id].nil?
  redirect '/adm-spolt/cat-news'
end

# top-slider
########################################################
get '/adm-spolt/top-slider' do
  @sliders = Slider.all.order(updated_at: "desc")
  @notice = session.delete :notice
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/top-slider', :layout => :'admin/admin-layout'
end

get '/adm-spolt/top-slider-new' do
  @slider = Slider.new
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/top-slider-new', :layout => :'admin/admin-layout'
end

post '/adm-spolt/slider-create' do
  @slider = Slider.new
  @slider.title = params['title']
  imgUp
  @slider.image = @image
  @slider.content = params['content']
  @slider.url = params['url']
  if @slider.save
    session[:notice] = "スライダー：#{@slider.title}を追加しました"
    redirect '/adm-spolt/top-slider'
  else
    erb :'admin/top-slider-new', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/slider-edit/:id' do
  @slider = Slider.find(params['id'])
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/top-slider-edit', :layout => :'admin/admin-layout'
end

post '/adm-spolt/slider-update/:id' do
  @slider = Slider.find(params['id'])
  @slider.title = params['title']
  imgUp
  @slider.image = @image
  @slider.content = params['content']
  @slider.url = params['url']
  if @slider.save
    session[:notice] = "スライダー：#{@slider.title}を更新しました"
    redirect '/adm-spolt/top-slider'
  else
    erb :'admin/top-slider-edit', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/slider-destroy/:id' do
  @slider = Slider.find(params['id'])
  session[:notice] = "スライダー：#{@slider.title}を削除しました"
  @slider.destroy
  redirect '/adm-spolt/login' if session[:id].nil?
  redirect '/adm-spolt/top-slider'
end

# sponcer
########################################################
get '/adm-spolt/sponcers' do
  @sponcers = Sponcer.all.order(created_at: "desc")
  @notice = session.delete :notice
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/sponcers', :layout => :'admin/admin-layout'
end

get '/adm-spolt/sponcer-new' do
  @sponcer = Sponcer.new
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/sponcer-new', :layout => :'admin/admin-layout'
end

post '/adm-spolt/sponcer-create' do
  @sponcer = Sponcer.new
  @sponcer.title = params['title']
  imgUp
  @sponcer.image = @image
  @sponcer.url = params['url']
  if @sponcer.save
    session[:notice] = "スポンサー：#{@sponcer.title}を追加しました"
    redirect '/adm-spolt/sponcers'
  else
    erb :'admin/sponcer-new', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/sponcer-edit/:id' do
  @sponcer = Sponcer.find(params['id'])
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/sponcer-edit', :layout => :'admin/admin-layout'
end

post '/adm-spolt/sponcer-update/:id' do
  @sponcer = Sponcer.find(params['id'])
  @sponcer.title = params['title']
  imgUp
  @sponcer.image = @image
  @sponcer.url = params['url']
  if @sponcer.save
    session[:notice] = "スポンサー：#{@sponcer.title}を更新しました"
    redirect '/adm-spolt/sponcers'
  else
    erb :'admin/sponcer-edit', :layout => :'admin/admin-layout'
  end
end

get '/adm-spolt/sponcer-destroy/:id' do
  @sponcer = Sponcer.find(params['id'])
  session[:notice] = "スポンサー：#{@sponcer.title}を削除しました"
  @sponcer.destroy
  redirect '/adm-spolt/login' if session[:id].nil?
  redirect '/adm-spolt/sponcers'
end

# settings
########################################################
get '/adm-spolt/settings' do
  @setting = Setting.first
  @notice = session.delete :notice
  redirect '/adm-spolt/login' if session[:id].nil?
  erb :'admin/settings', :layout => :'admin/admin-layout'
end

post '/adm-spolt/settings-update' do
  @setting = Setting.first
  if params[:logo].nil?
  else
  @logo = params[:logo][:filename]
  FileUtils.mv(params[:logo][:tempfile], "./public/images/#{@logo}")
  end
  if params[:icon].nil?
  else
  @icon = params[:icon][:filename]
  FileUtils.mv(params[:icon][:tempfile], "./public/images/#{@icon}")
  end
  if params[:ogp].nil?
  else
  @ogp = params[:ogp][:filename]
  FileUtils.mv(params[:ogp][:tempfile], "./public/images/#{@ogp}")
  end
  @setting.title = params['title']
  @setting.disc = params['disc']
  if @logo.nil?
  else
  @setting.logo = @logo
  end
  if @icon.nil?
  else
  @setting.icon = @icon
  end
  if @ogp.nil?
  else
  @setting.ogpimage = @ogp
  end
  @setting.fb_app_id = params['fb_app_id']
  @setting.fb_account = params['fb_account']
  @setting.tw_style = params['tw_style']
  @setting.tw_account = params['tw_account']
  @setting.save
  session[:notice] = "設定を更新しました"
  redirect '/adm-spolt/login' if session[:id].nil?
  redirect '/adm-spolt/settings'
end

###################### admin end ######################