from libc.stdint cimport (
    int16_t, int32_t, int64_t, int8_t,
    uint16_t, uint32_t, uint64_t, uint8_t,
    uintptr_t, intptr_t,
)

# =========================================================================== #
# [Integer types]                                                             #
# =========================================================================== #

ctypedef uint8_t   ZyanU8
ctypedef uint16_t  ZyanU16
ctypedef uint32_t  ZyanU32
ctypedef uint64_t  ZyanU64
ctypedef size_t    ZyanUSize
ctypedef uintptr_t ZyanUPointer

ctypedef int8_t    ZyanI8
ctypedef int16_t   ZyanI16
ctypedef int32_t   ZyanI32
ctypedef int64_t   ZyanI64
ctypedef ptrdiff_t ZyanISize
ctypedef intptr_t  ZyanIPointer

ctypedef ZyanU8    ZyanBool

# =========================================================================== #
