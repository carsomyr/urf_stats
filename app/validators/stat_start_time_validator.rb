# -*- coding: utf-8 -*-
#
# Copyright 2015 Roy Liu
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

require "date"

class StatStartTimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, "must be of type `DateTime`") \
      if value.is_a?(DateTime)

    case record.interval
      when "minute"
        n_seconds_multiple = 60
      when "hour"
        n_seconds_multiple = 3600
      when "day"
        n_seconds_multiple = 3600
      else
        raise "Control should never reach here"
    end

    record.errors.add(attribute, "must be on a #{record.interval} boundary") \
      if value.to_time.to_i % n_seconds_multiple != 0
  end
end
