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

module Api
  class ItemStatsController < ApiController
    N_POPULAR_ITEMS = 20
    N_TOP_PURCHASERS = 5

    def index
      region = params[:region]
      start_time = params[:start_time]
      start_time &&= DateTime.strptime(start_time, "%s")
      search = params[:search]

      ipcs = ItemPurchaseCount.arel_table
      eis = EntityInteger.arel_table
      ses = Riot::Api::StaticEntity.arel_table
      stats = Stat.arel_table

      where_node = ipcs.create_true

      if region || start_time
        ipcs_to_stats_node = ipcs.create_join(
            stats,
            ipcs.create_on(ipcs[:stat_id].eq stats[:id])
        )

        eis_to_stats_node = eis.create_join(
            stats,
            eis.create_on(eis[:stat_id].eq stats[:id])
        )

        where_node = where_node.and(stats[:region].eq region) \
          if region

        where_node = where_node.and(stats[:start_time].eq start_time) \
          if start_time
      else
        ipcs_to_stats_node = nil
        eis_to_stats_node = nil
      end

      if search
        ipcs_to_ses_node = ipcs.create_join(
            ses,
            ipcs.create_on(ipcs[:item_id].eq ses[:id])
        )

        ipcs_where_node = where_node.and(ses[:name].matches (search + "%"))
      else
        ipcs_to_ses_node = nil
        ipcs_where_node = where_node
      end

      total_column_node = Arel::Nodes::SqlLiteral.new("total")

      popular_item_purchases =
          ItemPurchaseCount
              .select(ipcs[:item_id], (ipcs[:value].sum.as total_column_node))
              .joins(ipcs_to_stats_node, ipcs_to_ses_node)
              .where(ipcs_where_node)
              .group(ipcs[:item_id])
              .order(total_column_node.desc)
              .limit(N_POPULAR_ITEMS)
              .preload(:item)

      popular_item_ids = popular_item_purchases.map do |popular_item_purchase|
        popular_item_purchase.item.id
      end

      top_purchasers_by_item_id = Hash[popular_item_ids.map { |item_id| [item_id, []] }]

      purchase_count = 0

      ItemPurchaseCount
          .select(ipcs[:item_id], ipcs[:purchaser_id], (ipcs[:value].sum.as total_column_node))
          .joins(ipcs_to_stats_node)
          .where(where_node.and(ipcs[:item_id].in popular_item_ids))
          .group(ipcs[:item_id], ipcs[:purchaser_id])
          .order(total_column_node.desc)
          .preload(:purchaser)
          .each do |ipc|
        top_purchasers = top_purchasers_by_item_id[ipc.item_id]

        if top_purchasers.size < N_TOP_PURCHASERS
          top_purchasers.push(ipc.purchaser)
          purchase_count += 1

          # Break out because we know that further processing is impossible.
          break \
            if purchase_count == N_TOP_PURCHASERS * popular_item_purchases.size
        end
      end

      total_purchases =
          # Convert to an array to prevent `first` from ordering by `id`.
          ItemPurchaseCount
              .select(ipcs[:value].sum.as total_column_node)
              .joins(ipcs_to_stats_node)
              .where(where_node)
              .to_a.first.total

      first_item_purchases =
          EntityInteger
              .select(eis[:entity_id], (eis[:value].sum.as total_column_node))
              .joins(eis_to_stats_node)
              .where(where_node.and(eis[:value_type].eq "N_FIRST_ITEM_PURCHASES"))
              .group(eis[:entity_id])

      first_item_totals_by_item_id = Hash[popular_item_ids.map { |item_id| [item_id, 0] }]

      total_first_purchases = first_item_purchases.reduce(0) do |n_purchases, first_item_purchase|
        # Somehow the total is a `BigDecimal`?
        total = first_item_purchase.total.to_i

        first_item_totals_by_item_id[first_item_purchase.entity_id] = total

        n_purchases + total
      end

      item_stats = popular_item_purchases.map do |popular_item_purchase|
        is = ItemStat.new
        item = popular_item_purchase.item
        item_id = item.id

        is.id = "#{item_id.to_s}_#{region || "all"}_#{params[:start_time] || "0"}"
        is.item = item
        is.top_purchasers = top_purchasers_by_item_id[item_id]
        is.n_purchases = popular_item_purchase.total
        is.total_purchases = total_purchases
        is.n_first_purchases = first_item_totals_by_item_id[item_id]
        is.total_first_purchases = total_first_purchases

        is
      end

      render json: item_stats
    end
  end
end
