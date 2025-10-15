package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
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

// VM dimensions being requiested
type AllocationRequest struct {
	Region   string `json:"region"`
	MemoryGB int    `json:"memory_gb"`
	Cores    int    `json:"cores"`
}

// AllocationResponse from Phoenix
type AllocationResponse struct {
	Data struct {
		Success   bool   `json:"success"`
		Message   string `json:"message"`
		MachineID string `json:"machine_id,omitempty"`
		Error     string `json:"error,omitempty"`
	} `json:"data"`
}

// APIResponse from Fly.io API
type APIResponse struct {
	Data []Region `json:"data"`
}

var (
	apiBase    = flag.String("api-base", "http://127.0.0.1:3030/", "Base API URL")
	apiURL     = flag.String("api", "http://127.0.0.1:3030/regions", "API endpoint URL")
	filter     = flag.String("filter", "", "Filter by status: online, offline, maintenance")
	jsonOutput = flag.Bool("json", false, "Output in JSON format")
	sortBy     = flag.String("sort", "code", "Sort by: code, location, status")
	verbose    = flag.Bool("verbose", false, "Enable verbose output")
	vmCores    = flag.Int("vm-cores", 0, "Number of CPU cores for VM")
	vmMemory   = flag.Int("vm-memory", 0, "Memory in GB for VM")
	vmRegion   = flag.String("vm-region", "", "Region for VM allocation")
)

func main() {
	flag.Usage = usage

	flag.Parse()

	if len(flag.Args()) == 0 && !hasNonDefaultFlags() {
		flag.Usage()
		return
	}

	if err := run(); err != nil {
		log.Fatalf("Error: %v", err)
	}
}

func usage() {
	fmt.Fprintf(os.Stderr, "Usage: %s [command] [options]\n\n", os.Args[0])
	fmt.Fprintf(os.Stderr, "Commands:\n")
	fmt.Fprintf(os.Stderr, "	regions		List available regions\n")
	fmt.Fprintf(os.Stderr, "	launch		Start VM in a region\n")
	fmt.Fprintf(os.Stderr, "	\nOptions:\n")
	flag.PrintDefaults()
}

func hasNonDefaultFlags() bool {
	return *vmRegion != "" || *vmMemory > 0 || *vmCores > 0 || *filter != "" || *sortBy != "code" || *jsonOutput
}

func run() error {
	if len(flag.Args()) > 0 {
		command := flag.Arg(0)
		switch command {
		case "regions":
			return handleRegionsCommand()

		case "launch":
			return handleLaunchCommand()

		default:
			return fmt.Errorf("unknown command: %s", command)
		}
	}
	return nil
}

func handleRegionsCommand() error {
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

func handleLaunchCommand() error {
	if *vmRegion != "" || *vmMemory > 0 || *vmCores > 0 {
		if err := validateVMRequest(); err != nil {
			log.Fatalf("Error: %v", err)
		}

		if err := requestVMAllocation(); err != nil {
			log.Fatalf("Allocation failed: %v", err)
		}
	} else {
		fmt.Println("DEBUG: No VM flags detected")
	}

	return nil
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

func validateVMRequest() error {
	if *vmRegion == "" {
		return fmt.Errorf("region is required")
	}
	if *vmMemory < 1 || *vmMemory > 256 {
		return fmt.Errorf("memory must be between 1-256 GB")
	}
	if *vmCores < 1 || *vmCores > 32 {
		return fmt.Errorf("cores must be between 1-32")
	}
	return nil
}

func requestVMAllocation() error {
	// Build the URL
	baseURL, err := url.Parse(*apiBase)
	if err != nil {
		return fmt.Errorf("invalid API base URL: %w", err)
	}

	fullURL := baseURL.ResolveReference(&url.URL{Path: "/launch"})

	query := fullURL.Query()
	query.Add("vm_region", *vmRegion)
	query.Add("vm_memory", fmt.Sprintf("%d", *vmMemory))
	query.Add("vm_cores", fmt.Sprintf("%d", *vmCores))
	query.Add("num_candidates", "5")
	fullURL.RawQuery = query.Encode()

	fmt.Printf("Request URL: %s\n", fullURL.String())

	// Create HTTP request
	req, err := http.NewRequest("GET", fullURL.String(), nil)
	if err != nil {
		return fmt.Errorf("failed to create request: %w", err)
	}

	// Set headers
	// req.Header.Set("Content-Type", "application/json")
	req.Header.Set("User-Agent", "fly-cli/0.1.0")

	// Execute request
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("HTTP request failed: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response body: %w", err)
	}

	if *verbose {
		fmt.Printf("\nResponse body: %s\n", body)
	}

	// Check response status
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("API returned status %d: %s\nResponse: %s",
			resp.StatusCode, resp.Status, string(body))
	}

	// Parse response
	var allocationResp AllocationResponse
	if err := json.Unmarshal(body, &allocationResp); err != nil {
		return fmt.Errorf("failed to parse response: %w\nRaw response: %s", err, string(body))
	}

	// Handle response
	if allocationResp.Data.Success {
		fmt.Printf("✅ Allocation successful!\n")
		fmt.Printf("   Machine ID: %s\n", allocationResp.Data.MachineID)
		fmt.Printf("   Message: %s\n", allocationResp.Data.Message)
	} else {
		return fmt.Errorf("allocation failed: %s", allocationResp.Data.Error)
	}

	return nil
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
