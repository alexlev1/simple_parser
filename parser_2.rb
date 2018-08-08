require 'mechanize'
require 'nokogiri'

# Стартовая страница с которой начнётся парсинг
MAIN_URL = 'https://kvaros.ru/developers/'
MAIL_REGEXP = '[\w\d]+@[\w\d\-]+.\w+'

# Cюда будем записывать все полученные данные
emails = []

# Создаём "агента", заходим на страницу с которой начинаем парсинг
mech = Mechanize.new { |agent|
  agent.open_timeout = 10
  agent.read_timeout = 10
}

# Счетчик парсинга и последняя страница
count = 1
last_page = 8

# Заходим на страницу
page = mech.get(MAIN_URL + "?PAGEN_2=#{count}")

# Начинаем парсинг
loop do
  links = []

  # Находим все ссылки на профили застройщиков
  page.css('.col3').each { |element| links << element.text }

  links.select { |element| emails << element.match(MAIL_REGEXP).to_s }

  # Выводим сообщение, что страница просмотрена
  puts "Страница #{count} собрана, переходим к следующей..."

  # Увеличиваем счетчик и переходим на следующую страницу
  count += 1

  # Закончить парсинг как только страниц для перехода больше не будет
  if count > last_page
    puts "========================"
    puts "Парсинг завершён!"
    break
  end

  # Переходим на следующую страницу
  page = mech.get(MAIN_URL + "?PAGEN_2=#{count}")
end

# Чистим от пустых значений и дублей итоговый массив
emails.reject(&:empty?).uniq!

# Сохраняем все данные в файл .txt
file = File.new("email_base.txt", "a:UTF-8")
file.puts(emails)
file.close

puts "Данные сохранены в файл"