require 'mechanize'
require 'nokogiri'

# Константы
REGEXP = '2 этаж'
MAIN_URL = 'https://houmy.ru'

# Cюда будем записывать все полученные данные
result = []

# 1. Открываем файл, достаём все ссылки и помещаем их в массив
file_path = "links.txt"

f = File.new(file_path, "r:UTF-8")
lines = f.readlines
f.close

# Массив для разбора
array_links = []

lines.each do |link|
  array_links << link
end

count = 1

# 2. В цикле, берём одну ссылку из массива, заходим на страницу, ищем нужную ссылку, забираем данные
array_links.each do | url_for_parse |
  # Создаём "агента", заходим на страницу с которой начинаем парсинг
  mech = Mechanize.new { |agent|
    agent.open_timeout = 10
    agent.read_timeout = 10
  }

  # Заходим на страницу

  puts url_for_parse
  page = mech.get(url_for_parse)

  # Начинаем парсинг
  node = page.css(".project__plan-item-img").select{ |element| element['alt'] =~ /#{REGEXP}/ }

  # Ссылка с которой будем работать
  link = nil
  url = nil

  node.each do |n|
    link = n.attributes['src'].to_s
  end

  # 2.1 Если ссылка есть, склеиваем её с первым URL и помещаем в массив результат
  if link.nil?
    url = 'Пусто'
  # 2.2 Если ссылки нет, отправляем результат "пусто"
  else
    url = MAIN_URL + link.to_s
  end

  result << url

  # Отмечаем, что всё получилось
  puts "Посмотрели ссылку ##{count}..."
  count += 1
end

# 3. Записывае result в файл plan.txt
# Сохраняем все данные в файл .txt
file = File.new("links_img.txt", "a:UTF-8")
file.puts(result)
file.close

puts "Данные сохранены в файл"
