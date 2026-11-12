//go:build windows

package wfp

import (
	"encoding/binary"
	"fmt"
	"net"
	"runtime"
	"unsafe"

	"golang.org/x/sys/windows"
)

const (
	rpcCAuthnWinNT = 10

	fwpmProviderFlagPersistent = 0x00000001
	fwpmSubLayerFlagPersistent = 0x00000001
	fwpmFilterFlagPersistent   = 0x00000001

	fwpDataTypeUint8         = 1
	fwpDataTypeUint16        = 2
	fwpDataTypeUint32        = 3
	fwpDataTypeUint64        = 4 // FWP_UINT64: the value is a pointer to a uint64
	fwpDataTypeByteArray16   = 11
	fwpDataTypeByteBlob      = 12
	fwpDataTypeV4AddrMask    = 0x100 // FWP_V4_ADDR_MASK
	fwpDataTypeV6AddrMask    = 0x101 // FWP_V6_ADDR_MASK
	fwpMatchEqual            = 0
	fwpMatchFlagsAllSet      = 6
	fwpConditionFlagLoopback = 0x00000001 // FWP_CONDITION_FLAG_IS_LOOPBACK

	fwpActionBlock  = 0x00001001
	fwpActionPermit = 0x00001002

	fwpEAlreadyExists    = 0x80320009
	fwpEFilterNotFound   = 0x80320003
	fwpEProviderNotFound = 0x80320005
	fwpESubLayerNotFound = 0x80320007

	maxCharonFilters = 256
)

var (
	// CharonProviderGUID tags every WFP object created by Charon.
	CharonProviderGUID = windows.GUID{
		Data1: 0xc4a20701,
		Data2: 0x8b4e,
		Data3: 0x4d19,
		Data4: [8]byte{0x9a, 0x31, 0x00, 0x00, 0xc4, 0xa2, 0x07, 0x01},
	}

	// CharonSubLayerGUID is the dedicated WFP sublayer for Charon kill switch rules.
	CharonSubLayerGUID = windows.GUID{
		Data1: 0xc4a20702,
		Data2: 0x8b4e,
		Data3: 0x4d19,
		Data4: [8]byte{0x9a, 0x31, 0x00, 0x00, 0xc4, 0xa2, 0x07, 0x02},
	}

	// Standard WFP layer and condition field GUIDs from fwpmu.h.
	guidLayerALEAuthConnectV4 = windows.GUID{
		Data1: 0xc38d57d1, Data2: 0x05a7, Data3: 0x4c33,
		Data4: [8]byte{0x90, 0x4f, 0x7f, 0xbc, 0xee, 0xe6, 0x0e, 0x82},
	}
	guidLayerALEAuthConnectV6 = windows.GUID{
		Data1: 0x4a72393b, Data2: 0x319f, Data3: 0x44bc,
		Data4: [8]byte{0x84, 0xc3, 0xba, 0x54, 0xdc, 0xb3, 0xb6, 0xb4},
	}
	guidCondFlags = windows.GUID{
		Data1: 0x632ce23b, Data2: 0x5167, Data3: 0x435c,
		Data4: [8]byte{0x86, 0xd7, 0xe9, 0x03, 0x68, 0x4a, 0xa8, 0x0c},
	}
	guidCondIPProtocol = windows.GUID{
		Data1: 0x3971ef2b, Data2: 0x623e, Data3: 0x4f9a,
		Data4: [8]byte{0x8c, 0xb1, 0x6e, 0x79, 0xb8, 0x06, 0xb9, 0xa7},
	}
	guidCondIPLocalPort = windows.GUID{
		Data1: 0x0c1ba1af, Data2: 0x5765, Data3: 0x453f,
		Data4: [8]byte{0xaf, 0x22, 0xa8, 0xf7, 0x91, 0xac, 0x77, 0x5b},
	}
	guidCondIPRemotePort = windows.GUID{
		Data1: 0xc35a604d, Data2: 0xd22b, Data3: 0x4e1a,
		Data4: [8]byte{0x91, 0xb4, 0x68, 0xf6, 0x74, 0xee, 0x67, 0x4b},
	}
	guidCondIPRemoteAddress = windows.GUID{
		Data1: 0xb235ae9a, Data2: 0x1d64, Data3: 0x49b8,
		Data4: [8]byte{0xa4, 0x4c, 0x5f, 0xf3, 0xd9, 0x09, 0x50, 0x45},
	}
	// FWPM_CONDITION_IP_LOCAL_INTERFACE: the NET_LUID of the local interface.
	guidCondIPLocalInterface = windows.GUID{
		Data1: 0x4cd62a49, Data2: 0x59c3, Data3: 0x4969,
		Data4: [8]byte{0xb7, 0xf3, 0xbd, 0xa5, 0xd3, 0x28, 0x90, 0xa4},
	}
	guidCondALEAppID = windows.GUID{
		Data1: 0xd78e1e87, Data2: 0x8644, Data3: 0x4ea5,
		Data4: [8]byte{0x94, 0x37, 0xd8, 0x09, 0xec, 0xef, 0xc9, 0x71},
	}

	modfwpuclnt                 = windows.NewLazySystemDLL("fwpuclnt.dll")
	procFwpmEngineOpen0         = modfwpuclnt.NewProc("FwpmEngineOpen0")
	procFwpmEngineClose0        = modfwpuclnt.NewProc("FwpmEngineClose0")
	procFwpmTransactionBegin0   = modfwpuclnt.NewProc("FwpmTransactionBegin0")
	procFwpmTransactionCommit0  = modfwpuclnt.NewProc("FwpmTransactionCommit0")
	procFwpmTransactionAbort0   = modfwpuclnt.NewProc("FwpmTransactionAbort0")
	procFwpmProviderAdd0        = modfwpuclnt.NewProc("FwpmProviderAdd0")
	procFwpmProviderDeleteByKey = modfwpuclnt.NewProc("FwpmProviderDeleteByKey0")
	procFwpmSubLayerAdd0        = modfwpuclnt.NewProc("FwpmSubLayerAdd0")
	procFwpmSubLayerDeleteByKey = modfwpuclnt.NewProc("FwpmSubLayerDeleteByKey0")
	procFwpmFilterAdd0          = modfwpuclnt.NewProc("FwpmFilterAdd0")
	procFwpmFilterDeleteByKey0  = modfwpuclnt.NewProc("FwpmFilterDeleteByKey0")
	procFwpmFilterGetByKey0     = modfwpuclnt.NewProc("FwpmFilterGetByKey0")
	procFwpmGetAppIdFromFile0   = modfwpuclnt.NewProc("FwpmGetAppIdFromFileName0")
	procFwpmFreeMemory0         = modfwpuclnt.NewProc("FwpmFreeMemory0")

	modiphlpapi                     = windows.NewLazySystemDLL("iphlpapi.dll")
	procConvertInterfaceIndexToLuid = modiphlpapi.NewProc("ConvertInterfaceIndexToLuid")
)

// LuidByName returns the NET_LUID of the network interface called name, for
// Gate.SetTUNLookup. It fails while the interface does not exist.
func LuidByName(name string) (uint64, error) {
	ifc, err := net.InterfaceByName(name)
	if err != nil {
		return 0, err
	}
	var luid uint64
	r0, _, _ := procConvertInterfaceIndexToLuid.Call(uintptr(ifc.Index), uintptr(unsafe.Pointer(&luid)))
	if r0 != 0 {
		return 0, fmt.Errorf("ConvertInterfaceIndexToLuid(%s) failed: %d", name, r0)
	}
	return luid, nil
}

type fwpmDisplayData0 struct {
	Name        *uint16
	Description *uint16
}

type fwpByteBlob struct {
	Size uint32
	Data *byte
}

type fwpmProvider0 struct {
	ProviderKey  windows.GUID
	DisplayData  fwpmDisplayData0
	Flags        uint32
	ProviderData fwpByteBlob
	ServiceName  *uint16
}

type fwpmSubLayer0 struct {
	SubLayerKey  windows.GUID
	DisplayData  fwpmDisplayData0
	Flags        uint32
	ProviderKey  *windows.GUID
	ProviderData fwpByteBlob
	Weight       uint16
}

type fwpValue0 struct {
	Type  uint32
	_     uint32
	Value uintptr
}

type fwpV4AddrAndMask struct {
	Addr uint32
	Mask uint32
}

type fwpV6AddrAndMask struct {
	Addr         [16]byte
	PrefixLength uint8
}

type fwpmFilterCondition0 struct {
	FieldKey       windows.GUID
	MatchType      uint32
	ConditionValue fwpValue0
}

type fwpmAction0 struct {
	Type       uint32
	FilterType windows.GUID
}

type fwpmFilter0 struct {
	FilterKey           windows.GUID
	DisplayData         fwpmDisplayData0
	Flags               uint32
	ProviderKey         *windows.GUID
	ProviderData        fwpByteBlob
	LayerKey            windows.GUID
	SubLayerKey         windows.GUID
	Weight              fwpValue0
	NumFilterConditions uint32
	FilterCondition     *fwpmFilterCondition0
	Action              fwpmAction0
	// RawContext and ProviderContextKey are one 16 byte union in FWPM_FILTER0.
	// Charon uses neither, so the union is kept as two zero words.
	RawContext      uint64
	_               uint64
	Reserved        *windows.GUID
	FilterId        uint64
	EffectiveWeight fwpValue0
}

func charonFilterGUID(index int) windows.GUID {
	return windows.GUID{
		Data1: 0xc4a20710 + uint32(index),
		Data2: 0x8b4e,
		Data3: 0x4d19,
		Data4: [8]byte{0x9a, 0x31, 0x00, 0x00, 0xc4, 0xa2, 0x07, 0x10},
	}
}

// RealEngine implements Engine against the Windows Filtering Platform API
// (fwpuclnt.dll). Requires administrator or LocalSystem privileges.
type RealEngine struct{}

func NewRealEngine() *RealEngine {
	return &RealEngine{}
}

func openEngine() (uintptr, error) {
	var engine uintptr
	r0, _, _ := procFwpmEngineOpen0.Call(
		0,
		rpcCAuthnWinNT,
		0,
		0,
		uintptr(unsafe.Pointer(&engine)),
	)
	if r0 != 0 {
		return 0, fmt.Errorf("FwpmEngineOpen0 failed: 0x%08x", uint32(r0))
	}
	return engine, nil
}

func closeEngine(engine uintptr) {
	if engine != 0 {
		_, _, _ = procFwpmEngineClose0.Call(engine)
	}
}

func (e *RealEngine) ApplyFilters(specs []FilterSpec) error {
	if len(specs) > maxCharonFilters {
		return fmt.Errorf("too many WFP filters (%d > %d)", len(specs), maxCharonFilters)
	}
	engine, err := openEngine()
	if err != nil {
		return err
	}
	defer closeEngine(engine)

	r0, _, _ := procFwpmTransactionBegin0.Call(engine, 0)
	if r0 != 0 {
		return fmt.Errorf("FwpmTransactionBegin0 failed: 0x%08x", uint32(r0))
	}
	abort := func() {
		_, _, _ = procFwpmTransactionAbort0.Call(engine)
	}

	// Remove any previous Charon filters first inside the same transaction.
	for i := 0; i < maxCharonFilters; i++ {
		key := charonFilterGUID(i)
		rc, _, _ := procFwpmFilterDeleteByKey0.Call(engine, uintptr(unsafe.Pointer(&key)))
		if rc != 0 && uint32(rc) != fwpEFilterNotFound {
			abort()
			return fmt.Errorf("FwpmFilterDeleteByKey0 failed: 0x%08x", uint32(rc))
		}
	}

	// Ensure persistent Provider exists.
	provName, _ := windows.UTF16PtrFromString("Charon VPN")
	provDesc, _ := windows.UTF16PtrFromString("Charon Persistent Kill Switch Provider")
	prov := fwpmProvider0{
		ProviderKey: CharonProviderGUID,
		DisplayData: fwpmDisplayData0{Name: provName, Description: provDesc},
		Flags:       fwpmProviderFlagPersistent,
	}
	rc, _, _ := procFwpmProviderAdd0.Call(engine, uintptr(unsafe.Pointer(&prov)), 0)
	if rc != 0 && uint32(rc) != fwpEAlreadyExists {
		abort()
		return fmt.Errorf("FwpmProviderAdd0 failed: 0x%08x", uint32(rc))
	}

	// Ensure persistent SubLayer exists.
	subName, _ := windows.UTF16PtrFromString("Charon Kill Switch Sublayer")
	subDesc, _ := windows.UTF16PtrFromString("Charon Persistent WFP Filters")
	sub := fwpmSubLayer0{
		SubLayerKey: CharonSubLayerGUID,
		DisplayData: fwpmDisplayData0{Name: subName, Description: subDesc},
		Flags:       fwpmSubLayerFlagPersistent,
		ProviderKey: &CharonProviderGUID,
		Weight:      0xFFF0,
	}
	rc, _, _ = procFwpmSubLayerAdd0.Call(engine, uintptr(unsafe.Pointer(&sub)), 0)
	if rc != 0 && uint32(rc) != fwpEAlreadyExists {
		abort()
		return fmt.Errorf("FwpmSubLayerAdd0 failed: 0x%08x", uint32(rc))
	}

	for i, sp := range specs {
		if err := addFilter(engine, i, sp); err != nil {
			abort()
			return err
		}
	}

	rc, _, _ = procFwpmTransactionCommit0.Call(engine)
	if rc != 0 {
		abort()
		return fmt.Errorf("FwpmTransactionCommit0 failed: 0x%08x", uint32(rc))
	}
	return nil
}

func addFilter(engine uintptr, idx int, sp FilterSpec) error {
	namePtr, _ := windows.UTF16PtrFromString(sp.Name)
	layerKey := guidLayerALEAuthConnectV4
	if sp.Layer == LayerConnectV6 {
		layerKey = guidLayerALEAuthConnectV6
	}
	act := uint32(fwpActionBlock)
	if sp.Action == ActionPermit {
		act = fwpActionPermit
	}

	var conds []fwpmFilterCondition0
	var v4Mask fwpV4AddrAndMask
	var v6Mask fwpV6AddrAndMask
	var appBlob *fwpByteBlob

	// The address masks are handed to WFP as uintptr values inside FWP_VALUE0,
	// which hides them from the garbage collector. Pin them so they cannot
	// move or be freed before FwpmFilterAdd0 returns.
	var pin runtime.Pinner
	defer pin.Unpin()
	pin.Pin(&v4Mask)
	pin.Pin(&v6Mask)
	luid := sp.LocalInterfaceLUID
	pin.Pin(&luid)

	if luid != 0 {
		conds = append(conds, fwpmFilterCondition0{
			FieldKey:  guidCondIPLocalInterface,
			MatchType: fwpMatchEqual,
			ConditionValue: fwpValue0{
				Type:  fwpDataTypeUint64,
				Value: uintptr(unsafe.Pointer(&luid)),
			},
		})
	}

	if sp.Loopback {
		conds = append(conds, fwpmFilterCondition0{
			FieldKey:  guidCondFlags,
			MatchType: fwpMatchFlagsAllSet,
			ConditionValue: fwpValue0{
				Type:  fwpDataTypeUint32,
				Value: uintptr(fwpConditionFlagLoopback),
			},
		})
	}
	if sp.Protocol != 0 {
		conds = append(conds, fwpmFilterCondition0{
			FieldKey:  guidCondIPProtocol,
			MatchType: fwpMatchEqual,
			ConditionValue: fwpValue0{
				Type:  fwpDataTypeUint8,
				Value: uintptr(sp.Protocol),
			},
		})
	}
	if sp.LocalPort != 0 {
		conds = append(conds, fwpmFilterCondition0{
			FieldKey:  guidCondIPLocalPort,
			MatchType: fwpMatchEqual,
			ConditionValue: fwpValue0{
				Type:  fwpDataTypeUint16,
				Value: uintptr(sp.LocalPort),
			},
		})
	}
	if sp.RemotePort != 0 {
		conds = append(conds, fwpmFilterCondition0{
			FieldKey:  guidCondIPRemotePort,
			MatchType: fwpMatchEqual,
			ConditionValue: fwpValue0{
				Type:  fwpDataTypeUint16,
				Value: uintptr(sp.RemotePort),
			},
		})
	}
	if sp.RemotePfx.IsValid() {
		addr := sp.RemotePfx.Addr()
		if addr.Is4() {
			b4 := addr.As4()
			bits := sp.RemotePfx.Bits()
			var mask uint32
			if bits > 0 {
				mask = ^uint32(0) << (32 - bits)
			}
			v4Mask = fwpV4AddrAndMask{
				Addr: binary.BigEndian.Uint32(b4[:]),
				Mask: mask,
			}
			conds = append(conds, fwpmFilterCondition0{
				FieldKey:  guidCondIPRemoteAddress,
				MatchType: fwpMatchEqual,
				ConditionValue: fwpValue0{
					Type:  fwpDataTypeV4AddrMask,
					Value: uintptr(unsafe.Pointer(&v4Mask)),
				},
			})
		} else if addr.Is6() {
			v6Mask = fwpV6AddrAndMask{
				Addr:         addr.As16(),
				PrefixLength: uint8(sp.RemotePfx.Bits()),
			}
			conds = append(conds, fwpmFilterCondition0{
				FieldKey:  guidCondIPRemoteAddress,
				MatchType: fwpMatchEqual,
				ConditionValue: fwpValue0{
					Type:  fwpDataTypeV6AddrMask,
					Value: uintptr(unsafe.Pointer(&v6Mask)),
				},
			})
		}
	}
	if sp.AppPath != "" {
		pathUTF16, err := windows.UTF16PtrFromString(sp.AppPath)
		if err == nil {
			rc, _, _ := procFwpmGetAppIdFromFile0.Call(
				uintptr(unsafe.Pointer(pathUTF16)),
				uintptr(unsafe.Pointer(&appBlob)),
			)
			if rc == 0 && appBlob != nil {
				defer procFwpmFreeMemory0.Call(uintptr(unsafe.Pointer(&appBlob)))
				conds = append(conds, fwpmFilterCondition0{
					FieldKey:  guidCondALEAppID,
					MatchType: fwpMatchEqual,
					ConditionValue: fwpValue0{
						Type:  fwpDataTypeByteBlob,
						Value: uintptr(unsafe.Pointer(appBlob)),
					},
				})
			}
		}
	}

	var condPtr *fwpmFilterCondition0
	if len(conds) > 0 {
		condPtr = &conds[0]
	}

	flt := fwpmFilter0{
		FilterKey:   charonFilterGUID(idx),
		DisplayData: fwpmDisplayData0{Name: namePtr, Description: namePtr},
		Flags:       fwpmFilterFlagPersistent,
		ProviderKey: &CharonProviderGUID,
		LayerKey:    layerKey,
		SubLayerKey: CharonSubLayerGUID,
		Weight: fwpValue0{
			Type:  fwpDataTypeUint8,
			Value: uintptr(sp.Weight),
		},
		NumFilterConditions: uint32(len(conds)),
		FilterCondition:     condPtr,
		Action: fwpmAction0{
			Type: act,
		},
	}

	var filterID uint64
	rc, _, _ := procFwpmFilterAdd0.Call(
		engine,
		uintptr(unsafe.Pointer(&flt)),
		0,
		uintptr(unsafe.Pointer(&filterID)),
	)
	if rc != 0 {
		return fmt.Errorf("FwpmFilterAdd0(%s) failed: 0x%08x", sp.Name, uint32(rc))
	}
	return nil
}

// RemoveAllCharonObjects deletes every Charon filter, then CharonSubLayerGUID,
// then CharonProviderGUID inside a single WFP transaction.
func (e *RealEngine) RemoveAllCharonObjects() error {
	engine, err := openEngine()
	if err != nil {
		return err
	}
	defer closeEngine(engine)

	r0, _, _ := procFwpmTransactionBegin0.Call(engine, 0)
	if r0 != 0 {
		return fmt.Errorf("FwpmTransactionBegin0 failed: 0x%08x", uint32(r0))
	}
	abort := func() {
		_, _, _ = procFwpmTransactionAbort0.Call(engine)
	}

	for i := 0; i < maxCharonFilters; i++ {
		key := charonFilterGUID(i)
		rc, _, _ := procFwpmFilterDeleteByKey0.Call(engine, uintptr(unsafe.Pointer(&key)))
		if rc != 0 && uint32(rc) != fwpEFilterNotFound {
			abort()
			return fmt.Errorf("FwpmFilterDeleteByKey0 failed: 0x%08x", uint32(rc))
		}
	}

	rc, _, _ := procFwpmSubLayerDeleteByKey.Call(engine, uintptr(unsafe.Pointer(&CharonSubLayerGUID)))
	if rc != 0 && uint32(rc) != fwpESubLayerNotFound {
		abort()
		return fmt.Errorf("FwpmSubLayerDeleteByKey0 failed: 0x%08x", uint32(rc))
	}

	rc, _, _ = procFwpmProviderDeleteByKey.Call(engine, uintptr(unsafe.Pointer(&CharonProviderGUID)))
	if rc != 0 && uint32(rc) != fwpEProviderNotFound {
		abort()
		return fmt.Errorf("FwpmProviderDeleteByKey0 failed: 0x%08x", uint32(rc))
	}

	rc, _, _ = procFwpmTransactionCommit0.Call(engine)
	if rc != 0 {
		abort()
		return fmt.Errorf("FwpmTransactionCommit0 failed: 0x%08x", uint32(rc))
	}
	return nil
}

func (e *RealEngine) ListCharonFilters() ([]FilterSpec, error) {
	engine, err := openEngine()
	if err != nil {
		return nil, err
	}
	defer closeEngine(engine)

	var found []FilterSpec
	for i := 0; i < maxCharonFilters; i++ {
		key := charonFilterGUID(i)
		var ptr *fwpmFilter0
		rc, _, _ := procFwpmFilterGetByKey0.Call(
			engine,
			uintptr(unsafe.Pointer(&key)),
			uintptr(unsafe.Pointer(&ptr)),
		)
		if rc == 0 && ptr != nil {
			name := windows.UTF16PtrToString(ptr.DisplayData.Name)
			procFwpmFreeMemory0.Call(uintptr(unsafe.Pointer(&ptr)))
			found = append(found, FilterSpec{Name: name, Persistent: true})
		}
	}
	return found, nil
}
