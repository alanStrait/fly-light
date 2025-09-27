BINARY_NAME = flyctl
VERSION = 0.1.0

build:
	go build -o $(BINARY_NAME) -ldflags "-X main.version=$(VERSION)"

install:
	go install

test:
	go test -v ./...

clean:
	rm -f $(BINARY_NAME)

.PHONY: build install test clean
