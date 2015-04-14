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

require "urf_stats"

module UrfStats
  class Accumulator
    attr_reader :parent
    attr_reader :children

    def initialize(parent = nil, &block)
      @parent = parent
      @children = []

      instance_exec(&block) \
        if block
    end

    def accumulate(o)
      children.each { |child| child.accumulate(o) }

      self
    end

    def save!
      children.each { |child| child.save! }

      nil
    end
  end
end
