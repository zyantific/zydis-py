# distutils: language=3
# distutils: include_dirs=ZYDIS_INCLUDES

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
        ZYDIS_DECODER_MODE_MINIMAL
        ZYDIS_DECODER_MODE_AMD_BRANCHES
        ZYDIS_DECODER_MODE_KNC
        ZYDIS_DECODER_MODE_MPX
        ZYDIS_DECODER_MODE_CET
        ZYDIS_DECODER_MODE_LZCNT
        ZYDIS_DECODER_MODE_TZCNT
        ZYDIS_DECODER_MODE_WBNOINVD
        ZYDIS_DECODER_MODE_CLDEMOTE

    ctypedef enum ZydisMachineMode:
        ZYDIS_MACHINE_MODE_LONG_64
        ZYDIS_MACHINE_MODE_LONG_COMPAT_32
        ZYDIS_MACHINE_MODE_LONG_COMPAT_16
        ZYDIS_MACHINE_MODE_LEGACY_32
        ZYDIS_MACHINE_MODE_LEGACY_16
        ZYDIS_MACHINE_MODE_REAL_16

    ctypedef enum ZydisAddressWidth:
        ZYDIS_ADDRESS_WIDTH_16
        ZYDIS_ADDRESS_WIDTH_32
        ZYDIS_ADDRESS_WIDTH_64

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
    ctypedef enum ZydisFormatterStyle:
        ZYDIS_FORMATTER_STYLE_ATT
        ZYDIS_FORMATTER_STYLE_INTEL
        ZYDIS_FORMATTER_STYLE_INTEL_MASM

    ctypedef enum ZydisFormatterProperty:
        ZYDIS_FORMATTER_PROP_FORCE_SIZE
        ZYDIS_FORMATTER_PROP_FORCE_SEGMENT
        ZYDIS_FORMATTER_PROP_FORCE_RELATIVE_BRANCHES
        ZYDIS_FORMATTER_PROP_FORCE_RELATIVE_RIPREL
        ZYDIS_FORMATTER_PROP_PRINT_BRANCH_SIZE
        ZYDIS_FORMATTER_PROP_DETAILED_PREFIXES
        ZYDIS_FORMATTER_PROP_ADDR_BASE
        ZYDIS_FORMATTER_PROP_ADDR_SIGNEDNESS
        ZYDIS_FORMATTER_PROP_ADDR_PADDING_ABSOLUTE
        ZYDIS_FORMATTER_PROP_ADDR_PADDING_RELATIVE
        ZYDIS_FORMATTER_PROP_DISP_BASE
        ZYDIS_FORMATTER_PROP_DISP_SIGNEDNESS
        ZYDIS_FORMATTER_PROP_DISP_PADDING
        ZYDIS_FORMATTER_PROP_IMM_BASE
        ZYDIS_FORMATTER_PROP_IMM_SIGNEDNESS
        ZYDIS_FORMATTER_PROP_IMM_PADDING
        ZYDIS_FORMATTER_PROP_UPPERCASE_PREFIXES
        ZYDIS_FORMATTER_PROP_UPPERCASE_MNEMONIC
        ZYDIS_FORMATTER_PROP_UPPERCASE_REGISTERS
        ZYDIS_FORMATTER_PROP_UPPERCASE_TYPECASTS
        ZYDIS_FORMATTER_PROP_UPPERCASE_DECORATORS
        ZYDIS_FORMATTER_PROP_DEC_PREFIX
        ZYDIS_FORMATTER_PROP_DEC_SUFFIX
        ZYDIS_FORMATTER_PROP_HEX_UPPERCASE
        ZYDIS_FORMATTER_PROP_HEX_PREFIX
        ZYDIS_FORMATTER_PROP_HEX_SUFFIX

    ctypedef enum ZydisNumericBase:
        ZYDIS_NUMERIC_BASE_DEC
        ZYDIS_NUMERIC_BASE_HEX

    ctypedef enum ZydisSignedness:
        ZYDIS_SIGNEDNESS_AUTO
        ZYDIS_SIGNEDNESS_SIGNED
        ZYDIS_SIGNEDNESS_UNSIGNED

    ctypedef enum ZydisPadding:
        ZYDIS_PADDING_DISABLED
        ZYDIS_PADDING_AUTO

    ctypedef enum ZydisFormatterFunction:
        ZYDIS_FORMATTER_FUNC_PRE_INSTRUCTION
        ZYDIS_FORMATTER_FUNC_POST_INSTRUCTION
        ZYDIS_FORMATTER_FUNC_FORMAT_INSTRUCTION
        ZYDIS_FORMATTER_FUNC_PRE_OPERAND
        ZYDIS_FORMATTER_FUNC_POST_OPERAND
        ZYDIS_FORMATTER_FUNC_FORMAT_OPERAND_REG
        ZYDIS_FORMATTER_FUNC_FORMAT_OPERAND_MEM
        ZYDIS_FORMATTER_FUNC_FORMAT_OPERAND_PTR
        ZYDIS_FORMATTER_FUNC_FORMAT_OPERAND_IMM
        ZYDIS_FORMATTER_FUNC_PRINT_MNEMONIC
        ZYDIS_FORMATTER_FUNC_PRINT_REGISTER
        ZYDIS_FORMATTER_FUNC_PRINT_ADDRESS_ABS
        ZYDIS_FORMATTER_FUNC_PRINT_ADDRESS_REL
        ZYDIS_FORMATTER_FUNC_PRINT_DISP
        ZYDIS_FORMATTER_FUNC_PRINT_IMM
        ZYDIS_FORMATTER_FUNC_PRINT_TYPECAST
        ZYDIS_FORMATTER_FUNC_PRINT_SEGMENT
        ZYDIS_FORMATTER_FUNC_PRINT_PREFIXES
        ZYDIS_FORMATTER_FUNC_PRINT_DECORATOR

    ctypedef enum ZydisDecorator:
        ZYDIS_DECORATOR_INVALID
        ZYDIS_DECORATOR_MASK
        ZYDIS_DECORATOR_BC
        ZYDIS_DECORATOR_RC
        ZYDIS_DECORATOR_SAE
        ZYDIS_DECORATOR_SWIZZLE
        ZYDIS_DECORATOR_CONVERSION
        ZYDIS_DECORATOR_EH

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

    ZyanStatus ZydisFormatterSetProperty(
        ZydisFormatter* formatter,
        ZydisFormatterProperty property,
        ZyanUPointer value,
    )

    ZyanStatus ZydisFormatterSetHook(
        ZydisFormatter* formatter,
        ZydisFormatterFunction type,
        const void** callback,
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
