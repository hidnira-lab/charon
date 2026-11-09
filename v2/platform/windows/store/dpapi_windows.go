//go:build windows

package store

import (
	"fmt"
	"unsafe"

	"golang.org/x/sys/windows"
)

const (
	cryptProtectUIForbidden  = 0x1
	cryptProtectLocalMachine = 0x4
)

type dataBlob struct {
	cbData uint32
	pbData *byte
}

var (
	modcrypt32             = windows.NewLazySystemDLL("crypt32.dll")
	procCryptProtectData   = modcrypt32.NewProc("CryptProtectData")
	procCryptUnprotectData = modcrypt32.NewProc("CryptUnprotectData")
)

func bytesToBlob(b []byte) dataBlob {
	if len(b) == 0 {
		return dataBlob{}
	}
	return dataBlob{
		cbData: uint32(len(b)),
		pbData: &b[0],
	}
}

// dpapiEncrypt encrypts plaintext using Windows DPAPI at machine scope
// (CRYPTPROTECT_LOCAL_MACHINE | CRYPTPROTECT_UI_FORBIDDEN) so the LocalSystem
// service can decrypt it at boot before any user logs in (WIN7).
func dpapiEncrypt(plaintext []byte) ([]byte, error) {
	in := bytesToBlob(plaintext)
	var out dataBlob
	r0, _, err := procCryptProtectData.Call(
		uintptr(unsafe.Pointer(&in)),
		0,
		0,
		0,
		0,
		uintptr(cryptProtectLocalMachine|cryptProtectUIForbidden),
		uintptr(unsafe.Pointer(&out)),
	)
	if r0 == 0 {
		return nil, fmt.Errorf("CryptProtectData: %w", err)
	}
	defer windows.LocalFree(windows.Handle(unsafe.Pointer(out.pbData)))

	cipher := make([]byte, out.cbData)
	copy(cipher, unsafe.Slice(out.pbData, out.cbData))
	return cipher, nil
}

// dpapiDecrypt decrypts ciphertext produced by dpapiEncrypt.
func dpapiDecrypt(ciphertext []byte) ([]byte, error) {
	if len(ciphertext) == 0 {
		return nil, fmt.Errorf("empty DPAPI ciphertext")
	}
	in := bytesToBlob(ciphertext)
	var out dataBlob
	r0, _, err := procCryptUnprotectData.Call(
		uintptr(unsafe.Pointer(&in)),
		0,
		0,
		0,
		0,
		uintptr(cryptProtectLocalMachine|cryptProtectUIForbidden),
		uintptr(unsafe.Pointer(&out)),
	)
	if r0 == 0 {
		return nil, fmt.Errorf("CryptUnprotectData: %w", err)
	}
	defer windows.LocalFree(windows.Handle(unsafe.Pointer(out.pbData)))

	plain := make([]byte, out.cbData)
	copy(plain, unsafe.Slice(out.pbData, out.cbData))
	return plain, nil
}
