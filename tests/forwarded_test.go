package test

import (
	"testing"
)

func TestForwardedExample(t *testing.T) {
	testCloudFront(t, "forwarded")
}
