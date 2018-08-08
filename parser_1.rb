require 'mechanize'
require 'nokogiri'

# Стартовая страница с которой начнётся парсинг
MAIN_URL = 'https://www.novostroyki.org/zastroyschiki/'
MAIL_REGEXP = 'E-mail[\w\d]+@[\w\d\-]+.\w+'

# Cюда будем записывать все полученные данные
emails = []

# Создаём "агента", заходим на страницу с которой начинаем парсинг
mech = Mechanize.new { |agent|
  agent.open_timeout = 10
  agent.read_timeout = 10
}

# Страница для парсинга
count = 1

# Заходим на страницу
page = mech.get(MAIN_URL + "?page=#{count}")

# Начинаем парсинг
loop do
  links = []

  # Находим все ссылки на профили застройщиков
  page.css('.co-link a').each { |element| links << element[:href] }

  # Проходим по каждому профилю
  links.each do |link|
    page = mech.get(MAIN_URL + "/#{link}")

    # Ищем email застройщика и пишем в базу
    email = nil
    page.css('.company-box-in').each { |element| email = element.text }
    result = /#{MAIL_REGEXP}/.match(email)

    # Добавляем в базу, если есть
    emails.concat(result.to_s.split("E-mail")) unless result.nil?
  end

  # Выводим сообщение, что страница просмотрена
  puts "Страница #{count} собрана, переходим к следующей..."

  # Увеличиваем счетчик и переходим на следующую страницу
  count += 1

  # Закончить парсинг как только страниц для перехода больше не будет
  if count > 105
    puts "========================"
    puts "Парсинг завершён!"
    break
  end

  # Переходим на следующую страницу
  page = mech.get(MAIN_URL + "?page=#{count}")
end

# Чистим от пустых значений и дублей итоговый массив
emails.reject(&:empty?).uniq!

# Сохраняем все данные в файл .txt
time = Time.now
file = File.new("email_base_#{time}.txt", "w:UTF-8")
file.puts(emails)
file.close

puts "Данные сохранены в файл"