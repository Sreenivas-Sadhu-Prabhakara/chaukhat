package backend

import (
	"encoding/json"
	"math"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestEvaluate_FrameQuote(t *testing.T) {
	// 40x50 cm frame, molding ₹120/m, glass ₹800/sqm, mount ₹300/sqm, labour ₹150.
	// perimeter = 2*(0.9)=1.8 m ; area = 2000/10000=0.2 sqm
	// molding=216 ; glass=160 ; mount=60 ; total=216+160+60+150=586
	r := Evaluate(Input{HeightCm: 40, WidthCm: 50, MoldingRate: 120, GlassRate: 800, MountRate: 300, Labour: 150})
	if math.Abs(r.PerimeterM-1.8) > 1e-9 || math.Abs(r.AreaSqM-0.2) > 1e-9 {
		t.Fatalf("geometry wrong: %+v", r)
	}
	if math.Abs(r.Total-586) > 1e-9 {
		t.Fatalf("total=%v want 586", r.Total)
	}
}

func TestValidate(t *testing.T) {
	if err := (Input{HeightCm: 40, WidthCm: 50}).Validate(); err != nil {
		t.Fatalf("valid rejected: %v", err)
	}
	for i, bad := range []Input{{HeightCm: 0, WidthCm: 5}, {HeightCm: 5, WidthCm: 5, GlassRate: -1}} {
		if err := bad.Validate(); err == nil {
			t.Fatalf("bad %d accepted", i)
		}
	}
}

func TestEvaluateEndpoint(t *testing.T) {
	srv := NewServer(nil)
	body := `{"heightCm":40,"widthCm":50,"moldingRate":120,"glassRate":800,"mountRate":300,"labour":150}`
	rec := httptest.NewRecorder()
	srv.ServeHTTP(rec, httptest.NewRequest(http.MethodPost, "/evaluate", strings.NewReader(body)))
	if rec.Code != http.StatusOK {
		t.Fatalf("status %d", rec.Code)
	}
	var r Result
	json.Unmarshal(rec.Body.Bytes(), &r)
	if math.Abs(r.Total-586) > 1e-9 {
		t.Fatalf("total=%v want 586", r.Total)
	}
}
