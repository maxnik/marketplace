module PriceInCents

  def price=(price)
    write_attribute(:price, (price.to_s.gsub(',', '.').to_f * 100).round)
  end

  def price
    unless read_attribute(:price).blank?
      float_price = read_attribute(:price)  / 100.0
      (float_price.round == float_price) ? float_price.to_i : float_price
    end
  end

end
