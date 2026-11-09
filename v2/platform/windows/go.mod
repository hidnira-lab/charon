module github.com/hidnira-lab/charon/platform/windows

go 1.26.5

require (
	github.com/Microsoft/go-winio v0.6.4
	github.com/hidnira-lab/charon/core v0.0.0
	golang.org/x/sys v0.49.0
)

require google.golang.org/protobuf v1.36.12

replace github.com/hidnira-lab/charon/core => ../../core
