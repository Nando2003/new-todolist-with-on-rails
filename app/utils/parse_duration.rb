class ParseDuration
  def self.parse(duration_string)
    return nil unless duration_string.is_a?(String)

    match = duration_string.match(/(\d+)([smhd])/)
    return nil unless match

    value = match[1].to_i
    unit = match[2]

    case unit
      when "s"
        return value
      when "m"
        return value * 60
      when "h"
        return value * 3600
      when "d"
        return value * 86400
      else
        return nil
    end
  end
end