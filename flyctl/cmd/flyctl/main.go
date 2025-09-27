package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"sort"
	"text/tabwriter"
	"time"
)

// Region represents a Fly.io region
type Region struct {
	ID        string    `json:"id"`
	Code      string    `json:"code"`
	Location  string    `json:"location"`
	Status    string    `json:"status"`
	Machines  []Machine `json:"machines"`
	UpdatedAt time.Time `json:"updated_at"`
}

// Machine represents a Fly.io machine
type Machine struct {
	ID         string    `json:"id"`
	Name       string    `json:"name"`
	Status     string    `json:"status"`
	Cores      int       `json:"cores"`
	MemoryGB   int       `json:"memory_gb"`
	RegionCode string    `json:"region_code"`
	UpdatedAt  time.Time `json:"updated_at"`
}

// APIResponse from Fly.io API
type APIResponse struct {
	Data []Region `json:"data"`
}

var (
	apiURL     = flag.String("api", "http://localhost:4010/fly-kv/regions", "API endpoint URL")
	verbose    = flag.Bool("verbose", false, "Enable verbose output")
	jsonOutput = flag.Bool("json", false, "Output in JSON format")
	sortBy     = flag.String("sort", "code", "Sort by: code, location, status")
	filter     = flag.String("filter", "", "Filter by status: online, offline, maintenance")
)

func main() {
	flag.Parse()

	if err := run(); err != nil {
		log.Fatalf("Error: %v", err)
	}
}

func run() error {
	regions, err := fetchRegions()
	if err != nil {
		return err
	}

	// Apply filtering
	if *filter != "" {
		regions = filterRegions(regions, *filter)
	}

	// Apply sorting
	sortRegions(regions, *sortBy)

	// Output results
	if *jsonOutput {
		return outputJSON(regions)
	}
	return outputTable(regions)
}

func fetchRegions() ([]Region, error) {
	resp, err := http.Get(*apiURL)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch regions: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API returned status %d", resp.StatusCode)
	}

	var apiResponse APIResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResponse); err != nil {
		return nil, fmt.Errorf("failed to decode JSON: %w", err)
	}

	return apiResponse.Data, nil
}

func filterRegions(regions []Region, status string) []Region {
	var filtered []Region
	for _, region := range regions {
		if region.Status == status {
			filtered = append(filtered, region)
		}
	}
	return filtered
}

func sortRegions(regions []Region, by string) {
	switch by {
	case "location":
		sort.Slice(regions, func(i, j int) bool {
			if regions[i].Location != regions[j].Location {
				return regions[i].Location < regions[j].Location
			}
			return regions[i].Code < regions[j].Code
		})
	case "status":
		statusOrder := map[string]int{"online": 1, "maintenance": 2, "offline": 3}
		sort.Slice(regions, func(i, j int) bool {
			prioI := statusOrder[regions[i].Status]
			prioJ := statusOrder[regions[j].Status]
			if prioI != prioJ {
				return prioI < prioJ
			}
			return regions[i].Code < regions[j].Code
		})
	default: // code
		sort.Slice(regions, func(i, j int) bool {
			return regions[i].Code < regions[j].Code
		})
	}
}

func outputJSON(regions []Region) error {
	encoder := json.NewEncoder(os.Stdout)
	encoder.SetIndent("", "  ")
	return encoder.Encode(regions)
}

func outputTable(regions []Region) error {
	w := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
	fmt.Fprintf(w, "CODE\tLOCATION\tSTATUS\tMACHINES\tLAST UPDATE\n")

	for _, region := range regions {
		updateTime := region.UpdatedAt.Format("2006-01-02 15:04")
		fmt.Fprintf(w, "%s\t%s\t%s\t%d\t%s\n",
			region.Code,
			region.Location,
			region.Status,
			len(region.Machines),
			updateTime,
		)
	}
	return w.Flush()
}
