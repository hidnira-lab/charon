// Package service hosts the LocalSystem Windows service (charon-service) and
// wires the core Driver to the Windows WFP gate, Xray supervisor, DPAPI store,
// TUN stats reader, and named pipe IPC server.
package service

import (
	"sync"
	"time"
)

// RealClock implements driver.Clock using the system monotonic/wall clock and
// time.AfterFunc timers.
type RealClock struct {
	mu     sync.Mutex
	timers map[string]*time.Timer
}

// NewRealClock creates a RealClock.
func NewRealClock() *RealClock {
	return &RealClock{
		timers: make(map[string]*time.Timer),
	}
}

func (c *RealClock) NowMs() int64 {
	return time.Now().UnixMilli()
}

func (c *RealClock) SetTimer(name string, afterMs int64, fn func()) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if old, ok := c.timers[name]; ok {
		old.Stop()
	}
	c.timers[name] = time.AfterFunc(time.Duration(afterMs)*time.Millisecond, fn)
}

func (c *RealClock) CancelTimer(name string) {
	c.mu.Lock()
	defer c.mu.Unlock()
	if old, ok := c.timers[name]; ok {
		old.Stop()
		delete(c.timers, name)
	}
}

// StopAll cancels all pending timers when the service shuts down.
func (c *RealClock) StopAll() {
	c.mu.Lock()
	defer c.mu.Unlock()
	for name, tm := range c.timers {
		tm.Stop()
		delete(c.timers, name)
	}
}
