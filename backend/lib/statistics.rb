# frozen_string_literal: true

module Statistics
  def self.z_score(target_value, data_list)
    mean = data_list.sum.to_f / data_list.size
    variance = data_list.sum { |v| (v - mean)**2 } / data_list.size
    std_dev = Math.sqrt(variance)
    (target_value - mean) / std_dev
  end
end
