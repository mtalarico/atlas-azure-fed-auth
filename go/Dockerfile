FROM golang:1

WORKDIR /usr/src/app
COPY oidc.go go.mod go.sum
RUN go mod tidy
RUN go build oidc.go

FROM python:3

CMD ["python", "-c", "import time; time.sleep(8640000)"]
