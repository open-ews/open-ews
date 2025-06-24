import { Controller } from "@hotwired/stimulus"
import ApexCharts from "apexcharts"

export default class extends Controller {
  static values = {
    months: Array,
    notificationCounts: Array,
    title: String,
  }

  connect() {
    const numberFormatter = new Intl.NumberFormat()

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
          name: this.titleValue,
          data: this.notificationCountsValue,
        },
      ],
      xaxis: {
        categories: this.monthsValue,
      },
      yaxis: {
        title: {
          text: this.titleValue,
        },
        labels: {
          formatter: function (val) {
            return numberFormatter.format(val)
          },
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
            return numberFormatter.format(val)
          },
        },
      },
    }

    const chart = new ApexCharts(this.element, options)
    chart.render()
  }
}
