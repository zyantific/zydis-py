# distutils: language=3
# distutils: include_dirs=ZYDIS_INCLUDES

from .inttypes cimport *
from .cenums cimport *

# =========================================================================== #
# [Status codes]                                                              #
# =========================================================================== #

ctypedef ZyanU32 ZyanStatus

# --------------------------------------------------------------------------- #
# [#define enums]                                                             #
# --------------------------------------------------------------------------- #

# These are not actually enums, but we declare them as such, with their
# underlying type as C type. When defining them as defines/constants,
# Cython generates bad C code.

# Modules.
cdef extern from "Zydis/Zydis.h":
    ctypedef enum XX_ZyanStatusModule "ZyanStatus":
        ZYAN_MODULE_ZYCORE
        ZYAN_MODULE_ZYDIS
        ZYAN_MODULE_USER

    # Zycore status codes.
    ctypedef enum XX_ZyanStatusCode "ZyanStatus":
        ZYAN_STATUS_SUCCESS
        ZYAN_STATUS_FAILED
        ZYAN_STATUS_TRUE
        ZYAN_STATUS_FALSE
        ZYAN_STATUS_INVALID_ARGUMENT
        ZYAN_STATUS_INVALID_OPERATION
        ZYAN_STATUS_NOT_FOUND
        ZYAN_STATUS_OUT_OF_RANGE
        ZYAN_STATUS_INSUFFICIENT_BUFFER_SIZE
        ZYAN_STATUS_NOT_ENOUGH_MEMORY
        ZYAN_STATUS_BAD_SYSTEMCALL
        ZYAN_STATUS_OUT_OF_RESOURCES

    # Zydis status codes.
    ctypedef enum XX_ZydisStatusCode "ZyanStatus":
        ZYDIS_STATUS_NO_MORE_DATA
        ZYDIS_STATUS_DECODING_ERROR
        ZYDIS_STATUS_INSTRUCTION_TOO_LONG
        ZYDIS_STATUS_BAD_REGISTER
        ZYDIS_STATUS_ILLEGAL_LOCK
        ZYDIS_STATUS_ILLEGAL_LEGACY_PFX
        ZYDIS_STATUS_ILLEGAL_REX
        ZYDIS_STATUS_INVALID_MAP
        ZYDIS_STATUS_MALFORMED_EVEX
        ZYDIS_STATUS_MALFORMED_MVEX
        ZYDIS_STATUS_INVALID_MASK
        ZYDIS_STATUS_SKIP_TOKEN

# =========================================================================== #
# [Zydis.h]                                                                   #
# =========================================================================== #

cdef extern from "Zydis/Zydis.h":
    ZyanU64 ZydisGetVersion()

# =========================================================================== #
# [Decoder]                                                                   #
# =========================================================================== #

cdef extern from "Zydis/Zydis.h":
    ctypedef ZyanU64 ZydisInstructionAttributes

# --------------------------------------------------------------------------- #
# [#define enums]                                                             #
# --------------------------------------------------------------------------- #

cdef extern from "Zydis/Zydis.h":
    ctypedef enum XX_ZydisInstrAttrib "ZydisInstructionAttributes":
        ZYDIS_ATTRIB_HAS_MODRM
        ZYDIS_ATTRIB_HAS_SIB
        ZYDIS_ATTRIB_HAS_REX
        ZYDIS_ATTRIB_HAS_XOP
        ZYDIS_ATTRIB_HAS_VEX
        ZYDIS_ATTRIB_HAS_EVEX
        ZYDIS_ATTRIB_HAS_MVEX
        ZYDIS_ATTRIB_IS_RELATIVE
        ZYDIS_ATTRIB_IS_PRIVILEGED
        ZYDIS_ATTRIB_CPUFLAG_ACCESS
        ZYDIS_ATTRIB_CPU_STATE_CR
        ZYDIS_ATTRIB_CPU_STATE_CW
        ZYDIS_ATTRIB_FPU_STATE_CR
        ZYDIS_ATTRIB_FPU_STATE_CW
        ZYDIS_ATTRIB_XMM_STATE_CR
        ZYDIS_ATTRIB_XMM_STATE_CW
        ZYDIS_ATTRIB_ACCEPTS_LOCK
        ZYDIS_ATTRIB_ACCEPTS_REP
        ZYDIS_ATTRIB_ACCEPTS_REPE
        ZYDIS_ATTRIB_ACCEPTS_REPZ
        ZYDIS_ATTRIB_ACCEPTS_REPNE
        ZYDIS_ATTRIB_ACCEPTS_REPNZ
        ZYDIS_ATTRIB_ACCEPTS_BND
        ZYDIS_ATTRIB_ACCEPTS_XACQUIRE
        ZYDIS_ATTRIB_ACCEPTS_XRELEASE
        ZYDIS_ATTRIB_ACCEPTS_HLE_WITHOUT_LOCK
        ZYDIS_ATTRIB_ACCEPTS_BRANCH_HINTS
        ZYDIS_ATTRIB_ACCEPTS_SEGMENT
        ZYDIS_ATTRIB_HAS_LOCK
        ZYDIS_ATTRIB_HAS_REP
        ZYDIS_ATTRIB_HAS_REPE
        ZYDIS_ATTRIB_HAS_REPZ
        ZYDIS_ATTRIB_HAS_REPNE
        ZYDIS_ATTRIB_HAS_REPNZ
        ZYDIS_ATTRIB_HAS_BND
        ZYDIS_ATTRIB_HAS_XACQUIRE
        ZYDIS_ATTRIB_HAS_XRELEASE
        ZYDIS_ATTRIB_HAS_BRANCH_NOT_TAKEN
        ZYDIS_ATTRIB_HAS_BRANCH_TAKEN
        ZYDIS_ATTRIB_HAS_SEGMENT
        ZYDIS_ATTRIB_HAS_SEGMENT_CS
        ZYDIS_ATTRIB_HAS_SEGMENT_SS
        ZYDIS_ATTRIB_HAS_SEGMENT_DS
        ZYDIS_ATTRIB_HAS_SEGMENT_ES
        ZYDIS_ATTRIB_HAS_SEGMENT_FS
        ZYDIS_ATTRIB_HAS_SEGMENT_GS
        ZYDIS_ATTRIB_HAS_OPERANDSIZE
        ZYDIS_ATTRIB_HAS_ADDRESSSIZE

# --------------------------------------------------------------------------- #
# [Types]                                                                     #
# --------------------------------------------------------------------------- #

cdef extern from "Zydis/Zydis.h":
    ctypedef struct ZydisDecoder:
        pass  # Opaque.

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