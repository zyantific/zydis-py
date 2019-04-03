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

    ctypedef struct ZydisDecodedOperand:
        pass  # TODO

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
