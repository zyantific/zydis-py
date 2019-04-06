# distutils: language=3
# distutils: include_dirs=ZYDIS_INCLUDES

from .inttypes cimport *
from .cenums cimport *

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

    ctypedef ZyanU64 ZydisInstructionAttributes
    ctypedef ZyanU8 ZydisOperandActions
    ctypedef ZyanU16 ZydisElementSize

    ctypedef struct ZydisDecodedOperandReg:
        ZydisRegister value

    ctypedef struct ZydisDecodedOperandMemDisp:
        ZyanBool has_displacement
        ZyanI64 value

    ctypedef struct ZydisDecodedOperandMem:
        ZydisMemoryOperandType type
        ZydisRegister segment
        ZydisRegister base
        ZydisRegister index
        ZyanU8 scale
        ZydisDecodedOperandMemDisp disp

    ctypedef struct ZydisDecodedOperandPtr:
        ZyanU16 segment
        ZyanU32 offset

    ctypedef union ZydisDecodedOperandImmVal:
        ZyanU64 u
        ZyanI64 s

    ctypedef struct ZydisDecodedOperandImm:
        ZyanBool is_signed
        ZyanBool is_relative
        ZydisDecodedOperandImmVal value

    ctypedef struct ZydisDecodedOperand:
        ZyanU8 id
        ZydisOperandType type
        ZydisOperandVisibility visibility
        ZydisOperandActions actions
        ZydisOperandEncoding encoding
        ZyanU16 size
        ZydisElementType element_type
        ZydisElementSize element_size
        ZyanU16 element_count
        ZydisDecodedOperandReg reg
        ZydisDecodedOperandMem mem
        ZydisDecodedOperandPtr ptr
        ZydisDecodedOperandImm imm

    ctypedef struct ZydisDecodedInstructionAccessedFlags:
        ZydisCPUFlagAction action

    ctypedef struct ZydisDecodedInstructionAvxMask:
        ZydisMaskMode mode
        ZydisRegister reg

    ctypedef struct ZydisDecodedInstructionAvxBroadcast:
        ZyanBool is_static
        ZydisBroadcastMode mode

    ctypedef struct ZydisDecodedInstructionAvxRounding:
        ZydisRoundingMode mode

    ctypedef struct ZydisDecodedInstructionAvxSwizzle:
        ZydisSwizzleMode mode

    ctypedef struct ZydisDecodedInstructionAvxConversion:
        ZydisConversionMode mode

    ctypedef struct ZydisDecodedInstructionAvx:
        ZydisDecodedInstructionAvxMask mask
        ZydisDecodedInstructionAvxBroadcast broadcast
        ZydisDecodedInstructionAvxRounding rounding
        ZydisDecodedInstructionAvxSwizzle swizzle
        ZydisDecodedInstructionAvxConversion conversion
        ZyanBool has_sea
        ZyanBool has_eviction_hint

    ctypedef struct ZydisDecodedInstructionMeta:
        ZydisInstructionCategory category
        ZydisISASet isa_set
        ZydisISAExt isa_ext
        ZydisBranchType branch_type
        ZydisExceptionClass exception_class

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
        ZydisDecodedInstructionAccessedFlags accessed_flags[13371337]  # TODO
        ZydisDecodedInstructionAvx avx
        ZydisDecodedInstructionMeta meta


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
