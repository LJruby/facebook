require 'fb_graph2'
FbGraph2.debug!

#https://developers.facebook.com/tools/explorer/
$gapitoken = '...' #valid only for 2h

$params = {fields: ["from", "message", "story", "name", "description", "likes", "comments", "attachments"]}
after_param = [0]

user = FbGraph2::User.me($gapitoken)

$file = File.open("home_page_posts.csv","a+")

def string_in_file(text)
  $file.rewind
  $file.each do |line|
    if line.include?(text)
      return true
    end
  end
  return false
end

def append_file(content)
  content.each do |co|
    unless string_in_file(co["id"])
      $file << "#{co["from"]["name"]};\"=HYPERLINK(\"\"https://facebook.com/#{co["id"]}\"\")\";#{co["created_time"]};"
        ["message","story","name","description"].each do |fi|
          if co[fi].nil?
            $file << ";"
          else
            $file << "#{co[fi].gsub(/\s/," ")};"
          end
        end
      $file << "\n"
    end
  end
end

begin
  begin
    page = user.home(params=$params.merge(after: after_param.last)).collection
    sleep(5)
  end while after_param.include?(page.after)
  append_file(page)
  after_param << page.after
end until after_param.last.nil?

puts "Dodaj znajomych, aby zobaczyć więcej zdarzeń
Jeżeli dodasz więcej znajomych, w aktualnościach zostanie wyświetlonych więcej zdarzeń :)"
