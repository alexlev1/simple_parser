require 'mechanize'
require 'nokogiri'

emails = []

# Создаём агента, заходим на страницу с которой начинаем парсинг
mech = Mechanize.new { |agent|
  agent.open_timeout = 10
  agent.read_timeout = 10
}

page = mech.get('https://www.novostroyki.org/zastroyschiki/gk_pik/')

loop do
  # Находим все профили застройщиков на странице
  # to do

  # Проходим по каждому профилю
  # to do

  # Ищем email застройщика и пишем в базу
  node = nil
  page.css('.company-box-in').each { |element| node = element.text }
  result = /E-mail\w+@\w+.\w+/.match(node)

  # Добавляем в базу, если есть
  emails.concat(result.to_s.split("E-mail")) unless result.nil?

  # Закончить парсинг как только все номера закончатся
  break
end

# Чистим от пустых значений и дублей итоговый массив
puts emails.reject(&:empty?).uniq

# Записываем в txt файл
# to do