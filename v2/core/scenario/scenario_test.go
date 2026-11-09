package scenario

import (
	"path/filepath"
	"testing"
)

// Every file in v2/scenarios must load and pass. These are the tests the owner
// reviews: the subtest name is the file name, the failure says which step.
func TestAllScenarios(t *testing.T) {
	files, err := filepath.Glob(filepath.Join("..", "..", "scenarios", "*.json"))
	if err != nil {
		t.Fatal(err)
	}
	if len(files) == 0 {
		t.Fatal("no scenario files found, is the path right?")
	}
	for _, path := range files {
		t.Run(filepath.Base(path), func(t *testing.T) {
			sc, err := Load(path)
			if err != nil {
				t.Fatal(err)
			}
			if err := Run(sc); err != nil {
				t.Fatalf("%s\n\n%s", sc.Name, err)
			}
		})
	}
}
