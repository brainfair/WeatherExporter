FROM golang:latest
WORKDIR /src
COPY main.go .
RUN GO111MODULE=off go get -d -v github.com/briandowns/openweathermap \
&& GO111MODULE=off go get -d -v github.com/prometheus/client_golang/prometheus \
&& GO111MODULE=off go get -d -v github.com/prometheus/client_golang/prometheus/promhttp \
&& GO111MODULE=off CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /src/app .
CMD ["./app"]  