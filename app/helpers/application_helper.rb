# frozen_string_literal: true

module ApplicationHelper
  def normalize_to_scale(value, max_value, min_value)
    # Ensure that max_value is greater than min_value to avoid division by zero
    # raise ArgumentError, 'max_value must be greater than min_value' if max_value <= min_value

    # Calculate the normalized value on a scale from 1 to 10
    normalized = (((value - min_value) * 9) / ((max_value - min_value) + 1))

    # Ensure the result is within the range [1, 10]
    normalized.clamp(1, 10)
  end
end
