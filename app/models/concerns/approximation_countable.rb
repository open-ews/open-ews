  module ApproximationCountable
    extend ActiveSupport::Concern

    class_methods do
      # https://wiki.postgresql.org/wiki/Count_estimate
      def approximate_count
        explain_result = connection.execute("EXPLAIN (FORMAT JSON) #{all.to_sql}")
        json_result = JSON.parse(explain_result.first["QUERY PLAN"])
        json_result.dig(0, "Plan", "Plan Rows").to_i
      end
    end
  end
