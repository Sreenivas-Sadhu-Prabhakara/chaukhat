package backend

import "fmt"

// Input is a framing job: outer dimensions in centimetres, plus the chosen
// molding (priced per metre of perimeter), glass and mount (priced per square
// metre of area), and fixed labour.
type Input struct {
	HeightCm   float64 `json:"heightCm"`
	WidthCm    float64 `json:"widthCm"`
	MoldingRate float64 `json:"moldingRate"` // ₹ per metre
	GlassRate  float64 `json:"glassRate"`   // ₹ per sq metre
	MountRate  float64 `json:"mountRate"`   // ₹ per sq metre
	Labour     float64 `json:"labour"`      // ₹ fixed
}

// Result is the itemised quote.
type Result struct {
	PerimeterM  float64 `json:"perimeterM"`
	AreaSqM     float64 `json:"areaSqM"`
	MoldingCost float64 `json:"moldingCost"`
	GlassCost   float64 `json:"glassCost"`
	MountCost   float64 `json:"mountCost"`
	Total       float64 `json:"total"`
}

// Headline is the quoted total.
func (r Result) Headline() float64 { return r.Total }

// Label is a coarse size band for history.
func (r Result) Label() string {
	if r.AreaSqM >= 0.5 {
		return "large"
	}
	return "small"
}

// Validate reports whether the Input is well formed.
func (in Input) Validate() error {
	if in.HeightCm <= 0 || in.WidthCm <= 0 {
		return fmt.Errorf("height and width must be positive")
	}
	if in.MoldingRate < 0 || in.GlassRate < 0 || in.MountRate < 0 || in.Labour < 0 {
		return fmt.Errorf("rates and labour cannot be negative")
	}
	return nil
}

// Evaluate prices the frame: molding by perimeter, glass and mount by area.
func Evaluate(in Input) Result {
	perimeter := 2 * (in.HeightCm + in.WidthCm) / 100 // metres
	area := (in.HeightCm * in.WidthCm) / 10000        // sq metres
	molding := perimeter * in.MoldingRate
	glass := area * in.GlassRate
	mount := area * in.MountRate
	return Result{
		PerimeterM:  perimeter,
		AreaSqM:     area,
		MoldingCost: molding,
		GlassCost:   glass,
		MountCost:   mount,
		Total:       molding + glass + mount + in.Labour,
	}
}
