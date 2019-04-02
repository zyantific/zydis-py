# distutils: language=3
# distutils: include_dirs=ZYDIS_INCLUDES

from libc.stdint cimport (
    int16_t, int32_t, int64_t, int8_t,
    uint16_t, uint32_t, uint64_t, uint8_t,
)

# =========================================================================== #
# [Integer types]                                                             #
# =========================================================================== #

ctypedef uint8_t   ZyanU8
ctypedef uint16_t  ZyanU16
ctypedef uint32_t  ZyanU32
ctypedef uint64_t  ZyanU64
ctypedef size_t    ZyanUSize

ctypedef int8_t    ZyanI8
ctypedef int16_t   ZyanI16
ctypedef int32_t   ZyanI32
ctypedef int64_t   ZyanI64
ctypedef ptrdiff_t ZyanISize

ctypedef ZyanU8    ZyanBool

# =========================================================================== #
# [Status codes]                                                              #
# =========================================================================== #

ctypedef ZyanU32 ZyanStatus

# Modules.
cdef extern from "Zydis/Zydis.h":
    cdef ZyanStatus ZYAN_MODULE_ZYCORE
    cdef ZyanStatus ZYAN_MODULE_ZYDIS
    cdef ZyanStatus ZYAN_MODULE_USER

# Status codes.
cdef extern from "Zydis/Zydis.h":
    # Zycore
    cdef ZyanStatus ZYAN_STATUS_MODULE
    cdef ZyanStatus ZYAN_STATUS_CODE
    cdef ZyanStatus ZYAN_STATUS_SUCCESS
    cdef ZyanStatus ZYAN_STATUS_FAILED
    cdef ZyanStatus ZYAN_STATUS_TRUE
    cdef ZyanStatus ZYAN_STATUS_FALSE
    cdef ZyanStatus ZYAN_STATUS_INVALID_ARGUMENT
    cdef ZyanStatus ZYAN_STATUS_INVALID_OPERATION
    cdef ZyanStatus ZYAN_STATUS_NOT_FOUND
    cdef ZyanStatus ZYAN_STATUS_OUT_OF_RANGE
    cdef ZyanStatus ZYAN_STATUS_INSUFFICIENT_BUFFER_SIZE
    cdef ZyanStatus ZYAN_STATUS_NOT_ENOUGH_MEMORY
    cdef ZyanStatus ZYAN_STATUS_BAD_SYSTEMCALL
    cdef ZyanStatus ZYAN_STATUS_OUT_OF_RESOURCES

    # Zydis
    cdef ZyanStatus ZYDIS_STATUS_NO_MORE_DATA
    cdef ZyanStatus ZYDIS_STATUS_DECODING_ERROR
    cdef ZyanStatus ZYDIS_STATUS_INSTRUCTION_TOO_LONG
    cdef ZyanStatus ZYDIS_STATUS_BAD_REGISTER
    cdef ZyanStatus ZYDIS_STATUS_ILLEGAL_LOCK
    cdef ZyanStatus ZYDIS_STATUS_ILLEGAL_LEGACY_PFX
    cdef ZyanStatus ZYDIS_STATUS_ILLEGAL_REX
    cdef ZyanStatus ZYDIS_STATUS_INVALID_MAP
    cdef ZyanStatus ZYDIS_STATUS_MALFORMED_EVEX
    cdef ZyanStatus ZYDIS_STATUS_MALFORMED_MVEX
    cdef ZyanStatus ZYDIS_STATUS_INVALID_MASK
    cdef ZyanStatus ZYDIS_STATUS_SKIP_TOKEN

# =========================================================================== #
# [Zydis.h]                                                                   #
# =========================================================================== #

cdef extern from "Zydis/Zydis.h":
    ZyanU64 ZydisGetVersion()

# =========================================================================== #
# [Decoder]                                                                   #
# =========================================================================== #

# --------------------------------------------------------------------------- #
# [Types]                                                                     #
# --------------------------------------------------------------------------- #

cdef extern from "Zydis/Zydis.h":
    ctypedef struct ZydisDecoder:
        pass  # Opaque.

    ctypedef enum ZydisDecoderMode:
        pass  # TODO

    ctypedef enum ZydisMachineMode:
        ZYDIS_MACHINE_MODE_LONG_64,
        ZYDIS_MACHINE_MODE_LONG_COMPAT_32,
        ZYDIS_MACHINE_MODE_LONG_COMPAT_16,
        ZYDIS_MACHINE_MODE_LEGACY_32,
        ZYDIS_MACHINE_MODE_LEGACY_16,
        ZYDIS_MACHINE_MODE_REAL_16,

    ctypedef enum ZydisAddressWidth:
        ZYDIS_ADDRESS_WIDTH_16,
        ZYDIS_ADDRESS_WIDTH_32,
        ZYDIS_ADDRESS_WIDTH_64,

    ctypedef struct ZydisDecodedInstruction:
        # TODO
        ZyanU8 length

# --------------------------------------------------------------------------- #
# [Functions]                                                                 #
# --------------------------------------------------------------------------- #

cdef extern from "Zydis/Zydis.h":
    ZyanStatus ZydisDecoderInit(
        ZydisDecoder* decoder,
        ZydisMachineMode machine_mode,
        ZydisAddressWidth address_width
    )

    ZyanStatus ZydisDecoderEnableMode(
        ZydisDecoder* decoder,
        ZydisDecoderMode mode,
        ZyanBool enabled,
    )

    ZyanStatus ZydisDecoderDecodeBuffer(
        const ZydisDecoder* decoder,
        const void* buffer,
        ZyanUSize length,
        ZydisDecodedInstruction* instruction,
    )

# =========================================================================== #
# [Formatter]                                                                 #
# =========================================================================== #

# --------------------------------------------------------------------------- #
# [Types]                                                                     #
# --------------------------------------------------------------------------- #

cdef extern from "Zydis/Zydis.h":
    cpdef enum ZydisFormatterStyle_:
        ZYDIS_FORMATTER_STYLE_ATT
        ZYDIS_FORMATTER_STYLE_INTEL
        ZYDIS_FORMATTER_STYLE_INTEL_MASM

    ctypedef ZydisFormatterStyle_ ZydisFormatterStyle

    ctypedef struct ZydisFormatter:
        pass  # Opaque.

# --------------------------------------------------------------------------- #
# [Functions]                                                                 #
# --------------------------------------------------------------------------- #

cdef extern from "Zydis/Zydis.h":
    ZyanStatus ZydisFormatterInit(
        ZydisFormatter* formatter,
        ZydisFormatterStyle style,
    )

    ZyanStatus ZydisFormatterFormatInstruction(
        const ZydisFormatter* formatter,
        const ZydisDecodedInstruction* instruction,
        char* buffer,
        ZyanUSize length,
        ZyanU64 runtime_address,
    )

    ZyanStatus ZydisFormatterFormatInstructionEx(
        const ZydisFormatter* formatter,
        const ZydisDecodedInstruction* instruction,
        char* buffer,
        ZyanUSize length,
        ZyanU64 runtime_address,
        void* user_data,
    )

    ZyanStatus ZydisFormatterFormatOperand(
        const ZydisFormatter* formatter,
        const ZydisDecodedInstruction* instruction,
        ZyanU8 index,
        char* buffer,
        ZyanUSize length,
        ZyanU64 runtime_address,
    )

    ZyanStatus ZydisFormatterFormatOperandEx(
        const ZydisFormatter* formatter,
        const ZydisDecodedInstruction* instruction,
        ZyanU8 index,
        char* buffer,
        ZyanUSize length,
        ZyanU64 runtime_address,
        void* user_data,
    )

# =========================================================================== #
