package vault

import "golang.org/x/crypto/argon2"

// Argon2idKey derives keyLen bytes from the passphrase with Argon2id (RFC 9106),
// using golang.org/x/crypto. memoryKiB is the memory in KiB, as in the header.
func Argon2idKey(password, salt []byte, iterations, memoryKiB uint32, parallelism uint8, keyLen uint32) []byte {
	return argon2.IDKey(password, salt, iterations, memoryKiB, parallelism, keyLen)
}
