module github.com/hidnira-lab/charon/server/charonsync

go 1.26.5

require github.com/hidnira-lab/charon/core v0.0.0

require (
	golang.org/x/crypto v0.59.0 // indirect
	golang.org/x/sys v0.50.0 // indirect
	google.golang.org/protobuf v1.36.12 // indirect
)

replace github.com/hidnira-lab/charon/core => ../../core
