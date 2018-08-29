require 'mechanize'
require 'httparty'
require 'nokogiri'

count = 1

# Стартовая страница с которой начнётся парсинг
MAIL_REGEXP = '[\w\d]+@[\w\d\-]+.\w+'

# Cюда будем записывать все полученные данные
emails = []

# Создаём "агента", заходим на страницу с которой начинаем парсинг
mech = Mechanize.new { |agent|
  agent.open_timeout = 10
  agent.read_timeout = 10
  agent.user_agent_alias = 'Windows Chrome'
}

# Начинаем парсинг
while count < 8521 do
  url = "http://firms.ners.ru/#{count}.html"

  begin
    page = mech.get(url)
  rescue Mechanize::ResponseCodeError => e
    puts "Агентство #{count} #{e.response_code}"
  end

  links = []

  # Находим все ссылки на профили застройщиков
  page.css('.contact-info').each { |element| links << element.text }

  result = links.select { |element| element[/#{MAIL_REGEXP}/]}

  emails.concat(result)

  count += 1
end

result = emails.uniq!

# Сохраняем все данные в файл .txt
file = File.new("email_base_agency_2.txt", "a:UTF-8")
file.puts(emails)
file.close

puts "Данные сохранены в файл"