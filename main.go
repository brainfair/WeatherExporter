/*Package main is collect weather from openweathermap and export them to /metrics endpoint for prometheus
 */
package main

import (
	"log"
	"net/http"
	"os"
	"time"

	owm "github.com/briandowns/openweathermap"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

//grab variables from env
var apiKey = os.Getenv("OWM_API_KEY")
var location = os.Getenv("OWM_LOCATION")
var exporterPort = os.Getenv("EXPORTER_PORT")

//prometheus metrics
var (
	WeatherTemp = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "owm_current_temp",
		Help: "current temp average",
	})
	WeatherTempMin = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "owm_current_temp_min",
		Help: "current temp min",
	})
	WeatherTempMax = prometheus.NewGauge(prometheus.GaugeOpts{
		Name: "owm_current_temp_max",
		Help: "current temp max",
	})
)

//init prometheus metrics
func init() {
	prometheus.MustRegister(WeatherTemp)
	prometheus.MustRegister(WeatherTempMin)
	prometheus.MustRegister(WeatherTempMax)
}

//func recordMetrics collect weather and set prometheus Gauge
func recordMetrics() {
	go func() {
		for {
			w, err := owm.NewCurrent("C", "En", apiKey)
			if err != nil {
				log.Fatalln(err)
			}
			w.CurrentByName(location)

			//set metrics
			WeatherTemp.Set(w.Main.Temp)
			WeatherTempMin.Set(w.Main.TempMin)
			WeatherTempMax.Set(w.Main.TempMax)

			time.Sleep(2 * time.Second)

		}
	}()
}

func main() {
	recordMetrics()

	http.Handle("/metrics", promhttp.Handler())
	http.ListenAndServe(exporterPort, nil)
}
