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
      sort_by = params[:sort_by] || "purchases"
      sort_direction = params[:sort_direction] || "descending"
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

        eis_to_ses_node = eis.create_join(
            ses,
            eis.create_on(eis[:entity_id].eq ses[:id])
        )

        match_node = ses[:name].matches (search + "%")
        ipcs_where_node = where_node.and(match_node)
        eis_where_node = where_node.and(match_node).and(eis[:value_type].eq "N_FIRST_ITEM_PURCHASES")
      else
        ipcs_to_ses_node = nil
        eis_to_ses_node = nil
        ipcs_where_node = where_node
        eis_where_node = where_node.and(eis[:value_type].eq "N_FIRST_ITEM_PURCHASES")
      end

      case sort_direction
        when "descending"
          sort_method = :desc
        when "ascending"
          sort_method = :asc
        else
          raise ArgumentError, "Invalid sort direction #{sort_direction.dump}"
      end

      total_column_node = Arel::Nodes::SqlLiteral.new("total")

      ipcs_scope =
          ItemPurchaseCount
              .select(ipcs[:item_id], (ipcs[:value].sum.as total_column_node))
              .joins(ipcs_to_stats_node, ipcs_to_ses_node)
              .group(ipcs[:item_id])
              .order(total_column_node.send(sort_method))
              .preload(:item)

      eis_scope =
          EntityInteger
              .select(eis[:entity_id], (eis[:value].sum.as total_column_node))
              .joins(eis_to_stats_node, eis_to_ses_node)
              .group(eis[:entity_id])
              .order(total_column_node.send(sort_method))

      case sort_by
        when "purchases"
          item_purchases =
              ipcs_scope
                  .where(ipcs_where_node)
                  .limit(N_POPULAR_ITEMS)

          item_ids = item_purchases.map do |item_purchase|
            item_purchase.item.id
          end

          first_item_purchases =
              eis_scope
                  .where(eis_where_node.and(eis[:entity_id].in item_ids))
                  .to_a

        when "purchases-first"
          first_item_purchases =
              eis_scope
                  .where(eis_where_node)
                  .limit(N_POPULAR_ITEMS)

          first_item_ids = first_item_purchases.map do |first_item_purchase|
            first_item_purchase.entity_id
          end

          item_purchases =
              ipcs_scope
                  .where(ipcs_where_node.and(ipcs[:item_id].in first_item_ids))
                  .to_a

          # Take the set intersection here to ensure that the array is sorted based on first item purchase totals.
          item_ids = first_item_ids & item_purchases.map do |item_purchase|
            item_purchase.item.id
          end

        else
          raise ArgumentError, "Invalid sort criterion #{sort_by.dump}"
      end

      top_purchasers_by_item_id = Hash[item_ids.map { |item_id| [item_id, []] }]

      purchase_count = 0

      ItemPurchaseCount
          .select(ipcs[:item_id], ipcs[:purchaser_id], (ipcs[:value].sum.as total_column_node))
          .joins(ipcs_to_stats_node)
          .where(where_node.and(ipcs[:item_id].in item_ids))
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
            if purchase_count == N_TOP_PURCHASERS * item_purchases.size
        end
      end

      item_purchases_by_item_id = Hash[
          item_purchases.map do |item_purchase|
            [item_purchase.item_id, item_purchase]
          end
      ]

      first_item_totals_by_item_id = Hash[
          first_item_purchases.map do |first_item_purchase|
            [first_item_purchase.entity_id, first_item_purchase.total.to_i]
          end
      ]

      total_purchases =
          # Convert to an array to prevent `first` from ordering by `id`.
          ItemPurchaseCount
              .select(ipcs[:value].sum.as total_column_node)
              .joins(ipcs_to_stats_node)
              .where(where_node)
              .to_a.first.total

      total_first_purchases =
          # Convert to an array to prevent `first` from ordering by `id`.
          EntityInteger
              .select(eis[:value].sum.as total_column_node)
              .joins(eis_to_stats_node)
              .where(where_node.and(eis[:value_type].eq "N_FIRST_ITEM_PURCHASES"))
              .to_a.first.total.to_i

      item_stats = item_ids.map do |item_id|
        item_purchase = item_purchases_by_item_id[item_id]
        is = ItemStat.new
        item = item_purchase.item
        item_id = item.id

        is.id = "#{item_id.to_s}_#{region || "all"}_#{params[:start_time] || "0"}"
        is.item = item
        is.top_purchasers = top_purchasers_by_item_id[item_id]
        is.n_purchases = item_purchase.total
        is.total_purchases = total_purchases
        is.n_first_purchases = first_item_totals_by_item_id[item_id]
        is.total_first_purchases = total_first_purchases

        is
      end

      render json: item_stats
    end
  end
end
