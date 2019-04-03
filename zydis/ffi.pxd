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

    ctypedef enum ZydisElementType:
        ZYDIS_ELEMENT_TYPE_INVALID
        ZYDIS_ELEMENT_TYPE_STRUCT
        ZYDIS_ELEMENT_TYPE_UINT
        ZYDIS_ELEMENT_TYPE_INT
        ZYDIS_ELEMENT_TYPE_FLOAT16
        ZYDIS_ELEMENT_TYPE_FLOAT32
        ZYDIS_ELEMENT_TYPE_FLOAT64
        ZYDIS_ELEMENT_TYPE_FLOAT80
        ZYDIS_ELEMENT_TYPE_LONGBCD
        ZYDIS_ELEMENT_TYPE_CC

    ctypedef enum ZydisCPUFlag:
        ZYDIS_CPUFLAG_CF
        ZYDIS_CPUFLAG_PF
        ZYDIS_CPUFLAG_AF
        ZYDIS_CPUFLAG_ZF
        ZYDIS_CPUFLAG_SF
        ZYDIS_CPUFLAG_TF
        ZYDIS_CPUFLAG_IF
        ZYDIS_CPUFLAG_DF
        ZYDIS_CPUFLAG_OF
        ZYDIS_CPUFLAG_IOPL
        ZYDIS_CPUFLAG_NT
        ZYDIS_CPUFLAG_RF
        ZYDIS_CPUFLAG_VM
        ZYDIS_CPUFLAG_AC
        ZYDIS_CPUFLAG_VIF
        ZYDIS_CPUFLAG_VIP
        ZYDIS_CPUFLAG_ID
        ZYDIS_CPUFLAG_C0
        ZYDIS_CPUFLAG_C1
        ZYDIS_CPUFLAG_C2
        ZYDIS_CPUFLAG_C3

    ctypedef enum ZydisBranchType:
        ZYDIS_BRANCH_TYPE_NONE
        ZYDIS_BRANCH_TYPE_SHORT
        ZYDIS_BRANCH_TYPE_NEAR
        ZYDIS_BRANCH_TYPE_FAR

    ctypedef enum ZydisExceptionClass:
        ZYDIS_EXCEPTION_CLASS_NONE
        ZYDIS_EXCEPTION_CLASS_SSE1
        ZYDIS_EXCEPTION_CLASS_SSE2
        ZYDIS_EXCEPTION_CLASS_SSE3
        ZYDIS_EXCEPTION_CLASS_SSE4
        ZYDIS_EXCEPTION_CLASS_SSE5
        ZYDIS_EXCEPTION_CLASS_SSE7
        ZYDIS_EXCEPTION_CLASS_AVX1
        ZYDIS_EXCEPTION_CLASS_AVX2
        ZYDIS_EXCEPTION_CLASS_AVX3
        ZYDIS_EXCEPTION_CLASS_AVX4
        ZYDIS_EXCEPTION_CLASS_AVX5
        ZYDIS_EXCEPTION_CLASS_AVX6
        ZYDIS_EXCEPTION_CLASS_AVX7
        ZYDIS_EXCEPTION_CLASS_AVX8
        ZYDIS_EXCEPTION_CLASS_AVX11
        ZYDIS_EXCEPTION_CLASS_AVX12
        ZYDIS_EXCEPTION_CLASS_E1
        ZYDIS_EXCEPTION_CLASS_E1NF
        ZYDIS_EXCEPTION_CLASS_E2
        ZYDIS_EXCEPTION_CLASS_E2NF
        ZYDIS_EXCEPTION_CLASS_E3
        ZYDIS_EXCEPTION_CLASS_E3NF
        ZYDIS_EXCEPTION_CLASS_E4
        ZYDIS_EXCEPTION_CLASS_E4NF
        ZYDIS_EXCEPTION_CLASS_E5
        ZYDIS_EXCEPTION_CLASS_E5NF
        ZYDIS_EXCEPTION_CLASS_E6
        ZYDIS_EXCEPTION_CLASS_E6NF
        ZYDIS_EXCEPTION_CLASS_E7NM
        ZYDIS_EXCEPTION_CLASS_E7NM128
        ZYDIS_EXCEPTION_CLASS_E9NF
        ZYDIS_EXCEPTION_CLASS_E10
        ZYDIS_EXCEPTION_CLASS_E10NF
        ZYDIS_EXCEPTION_CLASS_E11
        ZYDIS_EXCEPTION_CLASS_E11NF
        ZYDIS_EXCEPTION_CLASS_E12
        ZYDIS_EXCEPTION_CLASS_E12NP
        ZYDIS_EXCEPTION_CLASS_K20
        ZYDIS_EXCEPTION_CLASS_K21

    ctypedef enum ZydisMaskMode:
        ZYDIS_MASK_MODE_INVALID
        ZYDIS_MASK_MODE_DISABLED
        ZYDIS_MASK_MODE_MERGING
        ZYDIS_MASK_MODE_ZEROING
        ZYDIS_MASK_MODE_CONTROL
        ZYDIS_MASK_MODE_CONTROL_ZEROING

    ctypedef enum ZydisRoundingMode:
        ZYDIS_ROUNDING_MODE_INVALID
        ZYDIS_ROUNDING_MODE_RN
        ZYDIS_ROUNDING_MODE_RD
        ZYDIS_ROUNDING_MODE_RU
        ZYDIS_ROUNDING_MODE_RZ

    ctypedef enum ZydisSwizzleMode:
        ZYDIS_SWIZZLE_MODE_INVALID
        ZYDIS_SWIZZLE_MODE_DCBA
        ZYDIS_SWIZZLE_MODE_CDAB
        ZYDIS_SWIZZLE_MODE_BADC
        ZYDIS_SWIZZLE_MODE_DACB
        ZYDIS_SWIZZLE_MODE_AAAA
        ZYDIS_SWIZZLE_MODE_BBBB
        ZYDIS_SWIZZLE_MODE_CCCC
        ZYDIS_SWIZZLE_MODE_DDDD

    ctypedef enum ZydisPrefixType:
        ZYDIS_PREFIX_TYPE_IGNORED
        ZYDIS_PREFIX_TYPE_EFFECTIVE
        ZYDIS_PREFIX_TYPE_MANDATORY
        ZYDIS_PREFIX_TYPE_MAX_VALUE

    ctypedef enum ZydisConversionMode:
        ZYDIS_CONVERSION_MODE_INVALID,
        ZYDIS_CONVERSION_MODE_FLOAT16,
        ZYDIS_CONVERSION_MODE_SINT8,
        ZYDIS_CONVERSION_MODE_UINT8,
        ZYDIS_CONVERSION_MODE_SINT16,
        ZYDIS_CONVERSION_MODE_UINT16,

    ctypedef enum ZydisOperandType:
        ZYDIS_OPERAND_TYPE_UNUSED
        ZYDIS_OPERAND_TYPE_REGISTER
        ZYDIS_OPERAND_TYPE_MEMORY
        ZYDIS_OPERAND_TYPE_POINTER
        ZYDIS_OPERAND_TYPE_IMMEDIATE

    ctypedef enum ZydisOperandEncoding:
        ZYDIS_OPERAND_ENCODING_NONE
        ZYDIS_OPERAND_ENCODING_MODRM_REG
        ZYDIS_OPERAND_ENCODING_MODRM_RM
        ZYDIS_OPERAND_ENCODING_OPCODE
        ZYDIS_OPERAND_ENCODING_NDSNDD
        ZYDIS_OPERAND_ENCODING_IS4
        ZYDIS_OPERAND_ENCODING_MASK
        ZYDIS_OPERAND_ENCODING_DISP8
        ZYDIS_OPERAND_ENCODING_DISP16
        ZYDIS_OPERAND_ENCODING_DISP32
        ZYDIS_OPERAND_ENCODING_DISP64
        ZYDIS_OPERAND_ENCODING_DISP16_32_64
        ZYDIS_OPERAND_ENCODING_DISP32_32_64
        ZYDIS_OPERAND_ENCODING_DISP16_32_32
        ZYDIS_OPERAND_ENCODING_UIMM8
        ZYDIS_OPERAND_ENCODING_UIMM16
        ZYDIS_OPERAND_ENCODING_UIMM32
        ZYDIS_OPERAND_ENCODING_UIMM64
        ZYDIS_OPERAND_ENCODING_UIMM16_32_64
        ZYDIS_OPERAND_ENCODING_UIMM32_32_64
        ZYDIS_OPERAND_ENCODING_UIMM16_32_32
        ZYDIS_OPERAND_ENCODING_SIMM8
        ZYDIS_OPERAND_ENCODING_SIMM16
        ZYDIS_OPERAND_ENCODING_SIMM32
        ZYDIS_OPERAND_ENCODING_SIMM64
        ZYDIS_OPERAND_ENCODING_SIMM16_32_64
        ZYDIS_OPERAND_ENCODING_SIMM32_32_64
        ZYDIS_OPERAND_ENCODING_SIMM16_32_32
        ZYDIS_OPERAND_ENCODING_JIMM8
        ZYDIS_OPERAND_ENCODING_JIMM16
        ZYDIS_OPERAND_ENCODING_JIMM32
        ZYDIS_OPERAND_ENCODING_JIMM64
        ZYDIS_OPERAND_ENCODING_JIMM16_32_64
        ZYDIS_OPERAND_ENCODING_JIMM32_32_64
        ZYDIS_OPERAND_ENCODING_JIMM16_32_32

    ctypedef enum ZydisOperandVisibility:
        ZYDIS_OPERAND_VISIBILITY_INVALID
        ZYDIS_OPERAND_VISIBILITY_EXPLICIT
        ZYDIS_OPERAND_VISIBILITY_IMPLICIT
        ZYDIS_OPERAND_VISIBILITY_HIDDEN

    ctypedef enum ZydisOperandAction:
        ZYDIS_OPERAND_ACTION_READ
        ZYDIS_OPERAND_ACTION_WRITE
        ZYDIS_OPERAND_ACTION_CONDREAD
        ZYDIS_OPERAND_ACTION_CONDWRITE
        ZYDIS_OPERAND_ACTION_READWRITE
        ZYDIS_OPERAND_ACTION_CONDREAD_CONDWRITE
        ZYDIS_OPERAND_ACTION_READ_CONDWRITE
        ZYDIS_OPERAND_ACTION_CONDREAD_WRITE
        ZYDIS_OPERAND_ACTION_MASK_READ
        ZYDIS_OPERAND_ACTION_MASK_WRITE

    ctypedef enum ZydisInstructionEncoding:
        ZYDIS_INSTRUCTION_ENCODING_LEGACY
        ZYDIS_INSTRUCTION_ENCODING_3DNOW
        ZYDIS_INSTRUCTION_ENCODING_XOP
        ZYDIS_INSTRUCTION_ENCODING_VEX
        ZYDIS_INSTRUCTION_ENCODING_EVEX
        ZYDIS_INSTRUCTION_ENCODING_MVEX

    ctypedef enum ZydisOpcodeMap:
        ZYDIS_OPCODE_MAP_DEFAULT
        ZYDIS_OPCODE_MAP_0F
        ZYDIS_OPCODE_MAP_0F38
        ZYDIS_OPCODE_MAP_0F3A
        ZYDIS_OPCODE_MAP_0F0F
        ZYDIS_OPCODE_MAP_XOP8
        ZYDIS_OPCODE_MAP_XOP9
        ZYDIS_OPCODE_MAP_XOPA

    ctypedef enum ZydisMnemonic:
        pass  # Auto-generated.

    ctypedef ZyanU64 ZydisInstructionAttributes

    ctypedef struct ZydisDecodedOperand:
        pass  # TODO

    ctypedef enum ZydisCPUFlagAction:
        ZYDIS_CPUFLAG_ACTION_NONE
        ZYDIS_CPUFLAG_ACTION_TESTED
        ZYDIS_CPUFLAG_ACTION_TESTED_MODIFIED
        ZYDIS_CPUFLAG_ACTION_MODIFIED
        ZYDIS_CPUFLAG_ACTION_SET_0
        ZYDIS_CPUFLAG_ACTION_SET_1
        ZYDIS_CPUFLAG_ACTION_UNDEFINED

    ctypedef struct AccessedFlags:
        ZydisCPUFlagAction action

    ctypedef struct AVX:
        pass

    ctypedef struct ZydisDecodedInstruction:
        ZydisMachineMode machine_mode
        ZydisMnemonic mnemonic
        ZyanU8 length
        ZydisInstructionEncoding encoding
        ZydisOpcodeMap opcode_map
        ZyanU8 opcode
        ZyanU8 stack_width
        ZyanU8 operand_width
        ZyanU8 address_width
        ZyanU8 operand_count
        ZydisDecodedOperand operands[13371337]  # TODO
        ZydisInstructionAttributes attributes
        AccessedFlags accessed_flags[13371337]  # TODO

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
