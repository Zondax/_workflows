package version

import (
	"testing"
)

func TestVersionValuesExist(t *testing.T) {
	if GitVersion == "" {
		t.Error("GitVersion should not be empty")
	}

	if GitRevision == "" {
		t.Error("GitRevision should not be empty")
	}
}
