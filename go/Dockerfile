FROM golang:1

WORKDIR /usr/src/app
COPY oidc.go go.mod go.sum .
RUN go mod tidy
RUN go build oidc.go
CMD ["/usr/bin/sleep", "1000d"]
