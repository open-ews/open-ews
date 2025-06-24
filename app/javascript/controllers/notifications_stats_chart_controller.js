import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

export default class extends Controller {
  static values = {
    months: Array,
    notificationCounts: Array,
  }

  connect() {
    const options = {
      chart: {
        type: "line",
        height: 300,
        toolbar: {
          show: false,
        },
      },
      series: [
        {
          name: "Notifications",
          data: this.notificationCountsValue,
        },
      ],
      xaxis: {
        categories: this.monthsValue,
      },
      yaxis: {
        title: {
          text: "Number of Notifications",
        },
      },
      stroke: {
        curve: "smooth",
        width: 3,
      },
      colors: ["#206bc4"],
      grid: {
        borderColor: "#e6e6e6",
      },
      tooltip: {
        x: {
          show: false,
        },
        y: {
          formatter: function (val) {
            return val + " notifications"
          },
        },
      },
    }

    const chart = new ApexCharts(this.element, options)
    chart.render()
  }
}
