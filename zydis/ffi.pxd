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
    ctypedef ZyanU32 ZydisCPUFlags
    ctypedef ZyanU8 ZydisFPUFlags

    cdef struct ZydisDecodedOperandReg_:
        ZydisRegister value

    cdef struct ZydisDecodedOperandMemDisp_:
        ZyanBool has_displacement
        ZyanI64 value

    cdef struct ZydisDecodedOperandMem_:
        ZydisMemoryOperandType type
        ZydisRegister segment
        ZydisRegister base
        ZydisRegister index
        ZyanU8 scale
        ZydisDecodedOperandMemDisp_ disp

    cdef struct ZydisDecodedOperandPtr_:
        ZyanU16 segment
        ZyanU32 offset

    cdef union ZydisDecodedOperandImmValue_:
        ZyanU64 u
        ZyanI64 s

    cdef struct ZydisDecodedOperandImm_:
        ZyanBool is_signed
        ZyanBool is_relative
        ZydisDecodedOperandImmValue_ value

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
        ZydisDecodedOperandReg_ reg
        ZydisDecodedOperandMem_ mem
        ZydisDecodedOperandPtr_ ptr
        ZydisDecodedOperandImm_ imm

    cdef struct ZydisDecodedInstructionAccessedFlags_:
        ZydisCPUFlagAction action

    cdef struct ZydisDecodedInstructionAvxMask_:
        ZydisMaskMode mode
        ZydisRegister reg

    cdef struct ZydisDecodedInstructionAvxBroadcast_:
        ZyanBool is_static
        ZydisBroadcastMode mode

    cdef struct ZydisDecodedInstructionAvxRounding_:
        ZydisRoundingMode mode

    cdef struct ZydisDecodedInstructionAvxSwizzle_:
        ZydisSwizzleMode mode

    cdef struct ZydisDecodedInstructionAvxConversion_:
        ZydisConversionMode mode

    cdef struct ZydisDecodedInstructionAvx_:
        ZydisDecodedInstructionAvxMask_ mask
        ZydisDecodedInstructionAvxBroadcast_ broadcast
        ZydisDecodedInstructionAvxRounding_ rounding
        ZydisDecodedInstructionAvxSwizzle_ swizzle
        ZydisDecodedInstructionAvxConversion_ conversion
        ZyanBool has_sae
        ZyanBool has_eviction_hint

    cdef struct ZydisDecodedInstructionMeta_:
        ZydisInstructionCategory category
        ZydisISASet isa_set
        ZydisISAExt isa_ext
        ZydisBranchType branch_type
        ZydisExceptionClass exception_class

    cdef struct ZydisDecodedInstructionRawPrefixes_:
        ZydisPrefixType type
        ZyanU8 value

    cdef struct ZydisDecodedInstructionRawRex_:
        ZyanU8 W
        ZyanU8 R
        ZyanU8 X
        ZyanU8 B
        ZyanU8 offset

    cdef struct ZydisDecodedInstructionRawXop_:
        ZyanU8 R
        ZyanU8 X
        ZyanU8 B
        ZyanU8 m_mmmm
        ZyanU8 W
        ZyanU8 vvvv
        ZyanU8 L
        ZyanU8 pp
        ZyanU8 offset

    cdef struct ZydisDecodedInstructionRawVex_:
        ZyanU8 R
        ZyanU8 X
        ZyanU8 B
        ZyanU8 m_mmmm
        ZyanU8 W
        ZyanU8 vvvv
        ZyanU8 L
        ZyanU8 pp
        ZyanU8 offset
        ZyanU8 size

    cdef struct ZydisDecodedInstructionRawEvex_:
        ZyanU8 R
        ZyanU8 X
        ZyanU8 B
        ZyanU8 R2
        ZyanU8 mmm
        ZyanU8 W
        ZyanU8 vvvv
        ZyanU8 pp
        ZyanU8 z
        ZyanU8 L2
        ZyanU8 L
        ZyanU8 b
        ZyanU8 V2
        ZyanU8 aaa
        ZyanU8 offset

    cdef struct ZydisDecodedInstructionRawMvex_:
        ZyanU8 R
        ZyanU8 X
        ZyanU8 B
        ZyanU8 R2
        ZyanU8 mmmm
        ZyanU8 W
        ZyanU8 vvvv
        ZyanU8 pp
        ZyanU8 E
        ZyanU8 SSS
        ZyanU8 V2
        ZyanU8 kkk
        ZyanU8 offset

    cdef struct ZydisDecodedInstructionModRm_:
        ZyanU8 mod
        ZyanU8 reg
        ZyanU8 rm
        ZyanU8 offset

    cdef struct ZydisDecodedInstructionRawSib_:
        ZyanU8 scale
        ZyanU8 index
        ZyanU8 base
        ZyanU8 offset

    cdef struct ZydisDecodedInstructionRawDisp_:
        ZyanI64 value
        ZyanU8 size
        ZyanU8 offset

    cdef union ZydisDecodedInstructionRawImmValue_:
       ZyanU64 u
       ZyanI64 s

    cdef struct ZydisDecodedInstructionRawImm_:
       ZyanBool is_signed
       ZyanBool is_relative
       ZydisDecodedInstructionRawImmValue_ value
       ZyanU8 size
       ZyanU8 offset

    cdef struct ZydisDecodedInstructionRaw_:
        ZyanU8 prefix_count
        ZydisDecodedInstructionRawPrefixes_ prefixes[15]
        ZydisDecodedInstructionRawRex_ rex
        ZydisDecodedInstructionRawXop_ xop
        ZydisDecodedInstructionRawVex_ vex
        ZydisDecodedInstructionRawEvex_ evex
        ZydisDecodedInstructionRawMvex_ mvex
        ZydisDecodedInstructionModRm_ modrm
        ZydisDecodedInstructionRawSib_ sib
        ZydisDecodedInstructionRawDisp_ disp
        ZydisDecodedInstructionRawImm_ imm[2]

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
        ZydisDecodedOperand operands[10]
        ZydisInstructionAttributes attributes
        ZydisDecodedInstructionAccessedFlags_ accessed_flags[26]
        ZydisCPUFlags cpu_flags_read
        ZydisCPUFlags cpu_flags_written
        ZydisFPUFlags fpu_flags_read
        ZydisFPUFlags fpu_flags_written
        ZydisDecodedInstructionAvx_ avx
        ZydisDecodedInstructionMeta_ meta
        ZydisDecodedInstructionRaw_ raw


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
# [Utils]                                                                     #
# =========================================================================== #

cdef extern from "Zydis/Zydis.h":
    ZyanStatus ZydisCalcAbsoluteAddress(
        const ZydisDecodedInstruction* instruction,
        const ZydisDecodedOperand* operand,
        ZyanU64 runtime_address,
        ZyanU64* result_address,
    )

# =========================================================================== #
