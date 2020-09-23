# ActiveRecord
########################################################
# ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# ActiveRecord::Base.establish_connection(:development)
ActiveRecord::Base.establish_connection(
  adapter: "postgresql",
  database: ENV['DB_NAME2'],
  host: "",
  username: ENV['DB_USER'],
  password: ENV['DB_PASSWORD'],
  encoding: "utf8"
)

class Member < ActiveRecord::Base
  has_secure_password
  belongs_to :author
  validates :userid, {presence: {message: "ユーザーIDを入力して下さい"}, uniqueness: {message: "そのユーザーIDは使用されているため、指定できません"}}
  validates :password, {presence: {message: "パスワードを入力して下さい"}, confirmation: {message: "パスワードが一致しません"}}
  validates :password_confirmation, {presence: {message: "パスワードを入力して下さい"}}
end

class Author < ActiveRecord::Base
  has_many :members
end

class Page < ActiveRecord::Base
  validates :title, {presence: {message: "タイトルを入力して下さい"}}
  validates :permalink, {presence: {message: "パーマリンクを入力して下さい"}, uniqueness: {message: "入力されたパーマリンクはすでに使われているため、指定できません"}}
end

class Competition < ActiveRecord::Base
  belongs_to :compe_kind
  belongs_to :event
  belongs_to :pref
  belongs_to :generation
  belongs_to :tag
  validates :title, {presence: {message: "タイトルを入力して下さい"}}
  validates :event_id, {presence: {message: "競技種目を選択して下さい"}}
  validates :pref_id, {presence: {message: "地域を選択して下さい"}}
  validates :generation_id, {presence: {message: "年代を選択して下さい"}}
  validates :compe_kind_id, {presence: {message: "投稿の種類を選択して下さい"}}
end

class CompeKind < ActiveRecord::Base
  has_many :competitions
end

class Event < ActiveRecord::Base
  has_many :competitions
  validates :name, {presence: {message: "名前を入力して下さい"}}
  validates :slug, {presence: {message: "スラッグを入力して下さい"}, uniqueness: {message: "入力されたスラッグはすでに使われているため、指定できません"}}
end

class Pref < ActiveRecord::Base
  belongs_to :area
  has_many :competitions
  validates :name, {presence: {message: "名前を入力して下さい"}}
  validates :slug, {presence: {message: "スラッグを入力して下さい"}, uniqueness: {message: "入力されたスラッグはすでに使われているため、指定できません"}}
end

class Area < ActiveRecord::Base
  has_many :prefs
end

class Generation < ActiveRecord::Base
  has_many :competitions
  validates :name, {presence: {message: "名前を入力して下さい"}}
  validates :slug, {presence: {message: "スラッグを入力して下さい"}, uniqueness: {message: "入力されたスラッグはすでに使われているため、指定できません"}}
end

class Tag <ActiveRecord::Base
  has_many :competitions
  validates :name, {presence: {message: "名前を入力して下さい"}}
  validates :slug, {presence: {message: "スラッグを入力して下さい"}, uniqueness: {message: "入力されたスラッグはすでに使われているため、指定できません"}}
end

class New < ActiveRecord::Base
  belongs_to :newscategory
  validates :title, {presence: {message: "タイトルを入力して下さい"}}
  validates :newscategory_id, {presence: {message: "ニュースカテゴリを選択して下さい"}}
end

class Newscategory < ActiveRecord::Base
  has_many :news
  validates :name, {presence: {message: "タイトルを入力して下さい"}}
  validates :slug, {presence: {message: "スラッグを入力して下さい"}, uniqueness: {message: "入力されたスラッグはすでに使われているため、指定できません"}}
end

class Slider < ActiveRecord::Base
  validates :title, {presence: {message: "タイトルを入力して下さい"}}
  validates :image, {presence: {message: "画像を挿入して下さい"}}
end

class Sponcer < ActiveRecord::Base
  validates :title, {presence: {message: "タイトルを入力して下さい"}}
  validates :image, {presence: {message: "画像を挿入して下さい"}}
end

class Setting < ActiveRecord::Base
end

# ActionMailer
########################################################
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  address:   ENV['MAILER_ADDRESS'],
  port:      ENV['MAILER_PORT'],
  domain:    ENV['MAILER_DOMAIN'],
  user_name: ENV['MAILER_USER_NAME'],
  password:  ENV['MAILER_PASSWORD']
}
ActionMailer::Base.view_paths = File.expand_path('views/mailer')
class InquiryMailer < ActionMailer::Base
  def send_user(name, mail, title, content)
    @name = name
    @mail = mail
    @title = title
    @content = content
    mail(
      to:      @mail,
      from:    ENV['SEND_USER_FROM'],
      subject: 'すぽると｜お問い合わせありがとうございます',
    ) do |format|
      format.text
    end
  end
  
  def send_admin(name, mail, title, content)
    @name = name
    @mail = mail
    @title = title
    @content = content
    mail(
      to:      ENV['SEND_ADMIN_TO'],
      from:    ENV['SEND_ADMIN_FROM'],
      subject: 'すぽると｜サイトよりお問い合わせがありました',
    ) do |format|
      format.text
    end
  end
end

class SponcerMailer < ActionMailer::Base
  def send_sponcer(company, zip, address, position, name, furi, mail, tel, fax, content)
    @company = company
    @zip = zip
    @address = address
    @position = position
    @name = name
    @furi = furi
    @mail = mail
    @tel = tel
    @fax = fax
    @content = content
    mail(
      to:      @mail,
      from:    ENV['SEND_USER_FROM'],
      subject: 'すぽると｜お問い合わせありがとうございます',
    ) do |format|
      format.text
    end
  end

  def send_admin(company, zip, address, position, name, furi, mail, tel, fax, content)
    @company = company
    @zip = zip
    @address = address
    @position = position
    @name = name
    @furi = furi
    @mail = mail
    @tel = tel
    @fax = fax
    @content = content
    mail(
      to:      ENV['SEND_ADMIN_TO'],
      from:    ENV['SEND_ADMIN_FROM'],
      subject: 'すぽると｜サイトよりスポンサー掲載依頼がありました',
    ) do |format|
      format.text
    end
  end
end