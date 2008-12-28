# Реализует простейшую транслитерацию
#   "вот мы и здесь".translify => "vot my i zdes"
#   "vot my i zdes".detranslify => "вот мы и здесь"
module RuTils::Transliteration::Simple
  TABLE_LOWER = {
     "і"=>"i","ґ"=>"g","ё"=>"yo","№"=>"#","є"=>"e",
     "ї"=>"yi","а"=>"a","б"=>"b",
     "в"=>"v","г"=>"g","д"=>"d","е"=>"e","ж"=>"zh",
     "з"=>"z","и"=>"i","й"=>"y","к"=>"k","л"=>"l",
     "м"=>"m","н"=>"n","о"=>"o","п"=>"p","р"=>"r",
     "с"=>"s","т"=>"t","у"=>"u","ф"=>"f","х"=>"h",
     "ц"=>"ts","ч"=>"ch","ш"=>"sh","щ"=>"sch","ъ"=>"'",
     "ы"=>"yi","ь"=>"","э"=>"e","ю"=>"yu","я"=>"ya"
  }.sort do | one, two|
    two[1].size <=> one[1].size
  end
  
  TABLE_UPPER =  {
    "Ґ"=>"G","Ё"=>"YO","Є"=>"E","Ї"=>"YI","І"=>"I",
    "А"=>"A","Б"=>"B","В"=>"V","Г"=>"G",
     "Д"=>"D","Е"=>"E","Ж"=>"ZH","З"=>"Z","И"=>"I",
     "Й"=>"Y","К"=>"K","Л"=>"L","М"=>"M","Н"=>"N",
     "О"=>"O","П"=>"P","Р"=>"R","С"=>"S","Т"=>"T",
     "У"=>"U","Ф"=>"F","Х"=>"H","Ц"=>"TS","Ч"=>"CH",
     "Ш"=>"SH","Щ"=>"SCH","Ъ"=>"'","Ы"=>"YI","Ь"=>"",
     "Э"=>"E","Ю"=>"YU","Я"=>"YA",
  }.sort do | one, two|
     two[1].size <=> one[1].size
  end

  TABLE = TABLE_UPPER + TABLE_LOWER
  
  # Заменяет кириллицу в строке на латиницу. Немного специфично потому что поддерживает
  # комби-регистр (Щука -> Shuka)
  def self.translify(str)
    chars = str.split(//)    
    
    lowers = TABLE_LOWER.map{|e| e[0] }
    uppers = TABLE_UPPER.map{|e| e[0] }
    
    hashtable = {}
    TABLE.each do | item |
      next unless item[0] && item[1]
      hashtable[item[0]] = item[1]
    end
    
    result = ''
    chars.each_with_index do | char, index |
      if uppers.include?(char) && lowers.include?(chars[index+1])
        # Combined case. Here we deal with Latin letters so there is no problem to use
        # Ruby's builtin upcase_downcase
        ch = hashtable[char].downcase.capitalize
        result << ch
      elsif uppers.include?(char)
        result << hashtable[char]        
      elsif lowers.include?(char)
        result << hashtable[char]
      else
        result << char
      end
    end
    return result
  end

  # Транслитерирует строку, делая ее пригодной для применения как имя директории или URL
  def self.dirify(string)
    st = self.translify(string)
    st.gsub!(/(\s\&\s)|(\s\&amp\;\s)/, ' and ') # convert & to "and"
    st.gsub!(/\W/, ' ')  #replace non-chars
    st.gsub!(/(_)$/, '') #trailing underscores
    st.gsub!(/^(_)/, '') #leading unders
    st.strip.translify.gsub(/(\s)/,'-').downcase.squeeze('-')
  end
end