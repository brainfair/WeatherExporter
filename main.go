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

var apiKey = os.Getenv("OWM_API_KEY")

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

func init() {
	prometheus.MustRegister(WeatherTemp)
	prometheus.MustRegister(WeatherTempMin)
	prometheus.MustRegister(WeatherTempMax)
}

func recordMetrics() {
	go func() {
		for {
			w, err := owm.NewCurrent("C", "En", apiKey)
			if err != nil {
				log.Fatalln(err)
			}
			w.CurrentByName("Tallinn")
			//fmt.Println(w.Main.Temp)

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
	http.ListenAndServe(":2112", nil)
}
