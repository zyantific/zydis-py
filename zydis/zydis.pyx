# distutils: language=3
# distutils: include_dirs=ZYDIS_INCLUDES

from enum import IntFlag
from typing import Generator, List, Tuple, Dict, Set, Optional

import cython

from .ffi cimport *
from .pyenums import *

# =========================================================================== #
# [Zydis.h]                                                                   #
# =========================================================================== #

cpdef Version version():
    return Version(ZydisGetVersion())

cdef class Version:
    cdef ZyanU64 version

    def __cinit__(self, ZyanU64 numeric_version):
        self.version = numeric_version

    @property
    def major(self):
        return self.version >> 48 & 0xFFFF

    @property
    def minor(self):
        return self.version >> 32 & 0xFFFF

    @property
    def patch(self):
        return self.version >> 16 & 0xFFFF

    @property
    def rev(self):
        return self.version & 0xFFFF

    def __str__(self):
        return f'{self.major}.{self.minor}.{self.patch}.{self.rev}'

    def __repr__(self):
        return f'ZydisVersion(0x{self.version:X})'

# =========================================================================== #
# [Status code & exceptions]                                                  #
# =========================================================================== #

cdef inline int is_success(ZyanStatus status):
    return status & 0x80000000 == 0


cdef class StatusCode:
    cdef ZyanStatus status

    def __cinit__(self, ZyanStatus status):
        self.status = status

    @property
    def raw_code(self):
        return int(self.status)

    @property
    def success(self):
        return is_success(self.status)

    @property
    def module(self):
        return (self.status >> 20) & 0x7FF

    @property
    def code(self):
        return StatusCodeId(self.status & 0xFFFFF)

    def __str__(self):
        return (
            f'success: {self.success}, module: {self.module}, '
            f'code: {self.code}'
        )

    def __repr__(self):
        return f'StatusCode({self.status})'


cdef class ZydisError(Exception):
    cdef StatusCode code

    def __cinit__(self, StatusCode code):
        self.code = code

    @property
    def status_code(self):
        return self.code

    def __str__(self):
        return f'Zydis error: {self.code!s}'

    def __repr__(self):
        return f'<ZydisError({self.code!r})>'


cdef inline int raise_if_err(ZyanStatus status) except -1:
    if is_success(status):
        return 0
    raise ZydisError(StatusCode(status))

# =========================================================================== #
# [Manually ported enums]                                                     #
# =========================================================================== #

# Some enums must be ported manually (as opposed to the majority generated
# from the C sources via `utils/genenums.py`) because they are defined as
# `#define`s.

class StatusCodeId(IntEnum):
    # Zycore
    STATUS_SUCCESS = ZYAN_STATUS_SUCCESS & 0xFFFFF
    STATUS_FAILED = ZYAN_STATUS_FAILED & 0xFFFFF
    STATUS_TRUE = ZYAN_STATUS_TRUE & 0xFFFFF
    STATUS_FALSE = ZYAN_STATUS_FALSE & 0xFFFFF
    STATUS_INVALID_ARGUMENT = ZYAN_STATUS_INVALID_ARGUMENT & 0xFFFFF
    STATUS_INVALID_OPERATION = ZYAN_STATUS_INVALID_OPERATION & 0xFFFFF
    STATUS_NOT_FOUND = ZYAN_STATUS_NOT_FOUND & 0xFFFFF
    STATUS_OUT_OF_RANGE = ZYAN_STATUS_OUT_OF_RANGE & 0xFFFFF
    STATUS_INSUFFICIENT_BUFFER_SIZE = \
        ZYAN_STATUS_INSUFFICIENT_BUFFER_SIZE & 0xFFFFF
    STATUS_NOT_ENOUGH_MEMORY = ZYAN_STATUS_NOT_ENOUGH_MEMORY & 0xFFFFF
    STATUS_BAD_SYSTEMCALL = ZYAN_STATUS_BAD_SYSTEMCALL & 0xFFFFF
    STATUS_OUT_OF_RESOURCES = ZYAN_STATUS_OUT_OF_RESOURCES & 0xFFFFF

    # Zydis
    NO_MORE_DATA = ZYDIS_STATUS_NO_MORE_DATA & 0xFFFFF
    DECODING_ERROR = ZYDIS_STATUS_DECODING_ERROR & 0xFFFFF
    INSTRUCTION_TOO_LONG = ZYDIS_STATUS_INSTRUCTION_TOO_LONG & 0xFFFFF
    BAD_REGISTER = ZYDIS_STATUS_BAD_REGISTER & 0xFFFFF
    ILLEGAL_LOCK = ZYDIS_STATUS_ILLEGAL_LOCK & 0xFFFFF
    ILLEGAL_LEGACY_PFX = ZYDIS_STATUS_ILLEGAL_LEGACY_PFX & 0xFFFFF
    ILLEGAL_REX = ZYDIS_STATUS_ILLEGAL_REX & 0xFFFFF
    INVALID_MAP = ZYDIS_STATUS_INVALID_MAP & 0xFFFFF
    MALFORMED_EVEX = ZYDIS_STATUS_MALFORMED_EVEX & 0xFFFFF
    MALFORMED_MVEX = ZYDIS_STATUS_MALFORMED_MVEX & 0xFFFFF
    INVALID_MASK = ZYDIS_STATUS_INVALID_MASK & 0xFFFFF
    SKIP_TOKEN = ZYDIS_STATUS_SKIP_TOKEN & 0xFFFFF


class Attribute(IntFlag):
    HAS_MODRM = ZYDIS_ATTRIB_HAS_MODRM
    HAS_SIB = ZYDIS_ATTRIB_HAS_SIB
    HAS_REX = ZYDIS_ATTRIB_HAS_REX
    HAS_XOP = ZYDIS_ATTRIB_HAS_XOP
    HAS_VEX = ZYDIS_ATTRIB_HAS_VEX
    HAS_EVEX = ZYDIS_ATTRIB_HAS_EVEX
    HAS_MVEX = ZYDIS_ATTRIB_HAS_MVEX
    IS_RELATIVE = ZYDIS_ATTRIB_IS_RELATIVE
    IS_PRIVILEGED = ZYDIS_ATTRIB_IS_PRIVILEGED
    CPUFLAG_ACCESS = ZYDIS_ATTRIB_CPUFLAG_ACCESS
    CPU_STATE_CR = ZYDIS_ATTRIB_CPU_STATE_CR
    CPU_STATE_CW = ZYDIS_ATTRIB_CPU_STATE_CW
    FPU_STATE_CR = ZYDIS_ATTRIB_FPU_STATE_CR
    FPU_STATE_CW = ZYDIS_ATTRIB_FPU_STATE_CW
    XMM_STATE_CR = ZYDIS_ATTRIB_XMM_STATE_CR
    XMM_STATE_CW = ZYDIS_ATTRIB_XMM_STATE_CW
    ACCEPTS_LOCK = ZYDIS_ATTRIB_ACCEPTS_LOCK
    ACCEPTS_REP = ZYDIS_ATTRIB_ACCEPTS_REP
    ACCEPTS_REPE = ZYDIS_ATTRIB_ACCEPTS_REPE
    ACCEPTS_REPZ = ZYDIS_ATTRIB_ACCEPTS_REPZ
    ACCEPTS_REPNE = ZYDIS_ATTRIB_ACCEPTS_REPNE
    ACCEPTS_REPNZ = ZYDIS_ATTRIB_ACCEPTS_REPNZ
    ACCEPTS_BND = ZYDIS_ATTRIB_ACCEPTS_BND
    ACCEPTS_XACQUIRE = ZYDIS_ATTRIB_ACCEPTS_XACQUIRE
    ACCEPTS_XRELEASE = ZYDIS_ATTRIB_ACCEPTS_XRELEASE
    ACCEPTS_HLE_WITHOUT_LOCK = ZYDIS_ATTRIB_ACCEPTS_HLE_WITHOUT_LOCK
    ACCEPTS_BRANCH_HINTS = ZYDIS_ATTRIB_ACCEPTS_BRANCH_HINTS
    ACCEPTS_SEGMENT = ZYDIS_ATTRIB_ACCEPTS_SEGMENT
    HAS_LOCK = ZYDIS_ATTRIB_HAS_LOCK
    HAS_REP = ZYDIS_ATTRIB_HAS_REP
    HAS_REPE = ZYDIS_ATTRIB_HAS_REPE
    HAS_REPZ = ZYDIS_ATTRIB_HAS_REPZ
    HAS_REPNE = ZYDIS_ATTRIB_HAS_REPNE
    HAS_REPNZ = ZYDIS_ATTRIB_HAS_REPNZ
    HAS_BND = ZYDIS_ATTRIB_HAS_BND
    HAS_XACQUIRE = ZYDIS_ATTRIB_HAS_XACQUIRE
    HAS_XRELEASE = ZYDIS_ATTRIB_HAS_XRELEASE
    HAS_BRANCH_NOT_TAKEN = ZYDIS_ATTRIB_HAS_BRANCH_NOT_TAKEN
    HAS_BRANCH_TAKEN = ZYDIS_ATTRIB_HAS_BRANCH_TAKEN
    HAS_SEGMENT = ZYDIS_ATTRIB_HAS_SEGMENT
    HAS_SEGMENT_CS = ZYDIS_ATTRIB_HAS_SEGMENT_CS
    HAS_SEGMENT_SS = ZYDIS_ATTRIB_HAS_SEGMENT_SS
    HAS_SEGMENT_DS = ZYDIS_ATTRIB_HAS_SEGMENT_DS
    HAS_SEGMENT_ES = ZYDIS_ATTRIB_HAS_SEGMENT_ES
    HAS_SEGMENT_FS = ZYDIS_ATTRIB_HAS_SEGMENT_FS
    HAS_SEGMENT_GS = ZYDIS_ATTRIB_HAS_SEGMENT_GS
    HAS_OPERANDSIZE = ZYDIS_ATTRIB_HAS_OPERANDSIZE
    HAS_ADDRESSSIZE = ZYDIS_ATTRIB_HAS_ADDRESSSIZE

# =========================================================================== #
# [Decoder]                                                                   #
# =========================================================================== #

@cython.freelist(16)
cdef class Operand:
    """Instruction operand, such as `eax` or `[rbp+0x30]`."""
    cdef DecodedInstruction instr
    cdef int index

    def __cinit__(self, instr, index):
        self.instr = instr
        self.index = index

    cdef inline ZydisDecodedOperand* _get_op(self):
        return &self.instr.instr.operands[self.index]

    def __str__(self):
        return STATIC_FORMATTER.format_operand(self)

    def __repr__(self):
        return f'<{self.__class__.__name__} "{self!s}" at 0x{id(self):x}>'


cdef class RegOperand(Operand):
    """Register operand, such as `rax`."""
    @property
    def register(self) -> Register:
        return Register(self._get_op().reg.value)


cdef class MemOperand(Operand):
    """Memory operand, such as `[rbp+30]`."""
    @property
    def type(self) -> MemoryOperandType:
        return MemoryOperandType(self._get_op().mem.type)

    @property
    def segment(self) -> Register:
        return Register(self._get_op().mem.segment)

    @property
    def base(self) -> Register:
        return Register(self._get_op().mem.base)

    @property
    def index(self) -> Register:
        return Register(self._get_op().mem.index)

    @property
    def disp(self) -> Optional[int]:
        if self._get_op().mem.disp.has_displacement:
            return self._get_op().mem.disp.value
        return None

    @property
    def scale(self) -> int:
        return self._get_op().mem.scale


cdef class PtrOperand(Operand):
    """Pointer operand (used in far jumps/calls)."""
    @property
    def segment(self) -> Register:
        return Register(self._get_op().ptr.segment)

    @property
    def offset(self) -> int:
        return self._get_op().ptr.offset


cdef class ImmOperand(Operand):
    """Immediate operand, e.g. `0x1337`."""
    @property
    def is_signed(self) -> bool:
        return bool(self._get_op().imm.is_signed)

    @property
    def is_relative(self) -> bool:
        return bool(self._get_op().imm.is_relative)

    @property
    def value(self) -> int:
        cdef ZydisDecodedOperand* op = self._get_op()
        return (
            op.imm.value.s
            if op.imm.is_signed else
            op.imm.value.u
        )


cdef dict OP_INIT_MAP = {
    ZYDIS_OPERAND_TYPE_IMMEDIATE: ImmOperand,
    ZYDIS_OPERAND_TYPE_REGISTER: RegOperand,
    ZYDIS_OPERAND_TYPE_MEMORY: MemOperand,
    ZYDIS_OPERAND_TYPE_POINTER: PtrOperand,
}


cdef class DecodedInstructionRaw:
    cdef DecodedInstruction instr

    def __cinit__(self, DecodedInstruction instr):
        self.instr = instr

    @property
    def prefixes(self) -> List[Tuple[ZydisPrefixType, int]]:
        cdef ZydisDecodedInstructionRaw_* raw = &self.instr.instr.raw
        return [
            (PrefixType(raw.prefixes[i].type), raw.prefixes[i].value)
            for i in range(raw.prefix_count)
        ]

    @property
    def rex(self) -> Dict:
        return dict(self.instr.instr.raw.rex)

    @property
    def xop(self) -> Dict:
        return dict(self.instr.instr.raw.xop)

    @property
    def vex(self) -> Dict:
        return dict(self.instr.instr.raw.vex)

    @property
    def evex(self) -> Dict:
        return dict(self.instr.instr.raw.evex)

    @property
    def mvex(self) -> Dict:
        return dict(self.instr.instr.raw.mvex)

    @property
    def modrm(self) -> Dict:
        return dict(self.instr.instr.raw.modrm)

    @property
    def sib(self) -> Dict:
        return dict(self.instr.instr.raw.sib)

    @property
    def disp(self) -> Dict:
        return dict(self.instr.instr.raw.disp)

    @property
    def imm1(self) -> Dict:
        return dict(self.instr.instr.raw.imm[0])

    @property
    def imm2(self) -> Dict:
        return dict(self.instr.instr.raw.imm[1])


@cython.final
@cython.freelist(16)
cdef class DecodedInstruction:
    """Information about a decoded instruction."""
    cdef ZydisDecodedInstruction instr

    @property
    def machine_mode(self) -> MachineMode:
        return MachineMode(self.instr.machine_mode)

    @property
    def mnemonic(self) -> Mnemonic:
        return Mnemonic(self.instr.mnemonic)

    @property
    def length(self) -> int:
        return self.instr.length

    @property
    def encoding(self) -> InstructionEncoding:
        return InstructionEncoding(self.instr.encoding)

    @property
    def opcode(self) -> int:
        return self.instr.opcode

    @property
    def stack_width(self) -> int:
        return self.instr.stack_width

    @property
    def operand_width(self) -> int:
        return self.instr.stack_width

    @property
    def address_width(self) -> int:
        return self.instr.address_width

    @property
    def attributes(self) -> Attribute:
        return Attribute(self.instr.attributes)

    cpdef inline Operand get_nth_operand(self, int n):
        return OP_INIT_MAP[self.instr.operands[n].type](self, n)

    @property
    def operands(self) -> List[Operand]:
        return [
            self.get_nth_operand(i)
            for i in range(self.instr.operand_count)
        ]

    @property
    def explicit_operands(self) -> Operand:
        return [
            op
            for op in self.operands
            if (<Operand>op).instr.instr.operands[
                   (<Operand>op).index
            ].visibility == ZYDIS_OPERAND_VISIBILITY_EXPLICIT
        ]

    @property
    def accessed_flags(self) -> Dict[CPUFlag, CPUFlagAction]:
        return {
            CPUFlag(i): CPUFlagAction(self.instr.accessed_flags[i].action)
            for i in range(<int>ZYDIS_CPUFLAG_MAX_VALUE)
            if self.instr.accessed_flags[i].action != ZYDIS_CPUFLAG_ACTION_NONE
        }

    @property
    def read_flags(self) -> Set[CPUFlag]:
        return {
            k
            for k, v in self.accessed_flags.items()
            if v == CPUFlagAction.SET_1
        }

    @property
    def meta(self):
        return dict(self.instr.meta)

    @property
    def avx(self):
        return dict(self.instr.avx)

    @property
    def raw(self):
        return DecodedInstructionRaw(self)

    def __str__(self) -> str:
        return STATIC_FORMATTER.format_instr(self)

    def __repr__(self) -> str:
        return f'<{self.__class__.__name__} "{self!s}" at 0x{id(self):x}>'


@cython.final
cdef class Decoder:
    """Decode byte arrays into machine interpretable structs."""
    cdef ZydisDecoder decoder

    def __cinit__(
        self,
        machine_mode = MachineMode.LONG_64,
        address_width = AddressWidth._64,
    ):
        raise_if_err(ZydisDecoderInit(
            &self.decoder,
            machine_mode.value,
            address_width.value,
        ))

    cpdef void enable_mode(self, mode, ZyanBool enabled):
        # Supporting minimal mode would require lots of checks
        # everywhere in order to assure no uninitialized memory is
        # accessed.
        assert mode != DecoderMode.MINIMAL, \
            "Minimal mode is currently not supported in the Py bindings"

        raise_if_err(ZydisDecoderEnableMode(
            &self.decoder, mode.value, enabled
        ))

    cpdef DecodedInstruction decode_one(self, bytes data):
        """
        Decode a single instruction, returning a `DecodedInstruction` struct.
        """
        cdef DecodedInstruction instr = DecodedInstruction()
        raise_if_err(ZydisDecoderDecodeBuffer(
            &self.decoder,
            <const unsigned char*>data,
            len(data),
            &instr.instr,
        ))
        return instr

    def decode_all(self, bytes data) -> Generator[
        DecodedInstruction, None, None
    ]:
        """
        Generator lazily decoding all instructions in the given bytes object,
        yielding `DecodedInstruction` instances.
        """
        while len(data) != 0:
            instr = self.decode_one(data)
            data = data[instr.length:]
            yield instr

# =========================================================================== #
# [Formatter]                                                                 #
# =========================================================================== #

@cython.final
cdef class Formatter:
    """Formats `DecodedInstruction`s to human readable test."""
    cdef ZydisFormatter formatter

    def __cinit__(self, style = FormatterStyle.INTEL):
        raise_if_err(ZydisFormatterInit(&self.formatter, style))

    cpdef str format_instr(self, DecodedInstruction instr):
        cdef char[256] buffer
        raise_if_err(ZydisFormatterFormatInstruction(
            &self.formatter, &instr.instr, buffer, sizeof(buffer), 0
        ))
        return buffer.decode('utf8')

    cpdef str format_operand(self, Operand operand):
        cdef char[256] buffer
        raise_if_err(ZydisFormatterFormatOperand(
            &self.formatter,
            &operand.instr.instr,
            operand.index,
            buffer,
            sizeof(buffer),
            0
        ))
        return buffer.decode('utf8')

# =========================================================================== #
# [Convenience / helpers]                                                     #
# =========================================================================== #

cdef Decoder STATIC_DECODER = Decoder()
cdef Formatter STATIC_FORMATTER = Formatter()


def decode_and_format_all(
    bytes data,
    *,
    Decoder decoder = STATIC_DECODER,
    Formatter formatter = STATIC_FORMATTER,
) -> Generator[Tuple[DecodedInstruction, str], None, None]:
    """
    Generator lazily decoding and formatting all instructions in the given
    bytes object, yielding `(DecodedInstruction, str)` pairs. `Decoder`
    and `Formatter` can be explicitly specified via the `decoder` /
    `formatter` arguments. If omitted, a shared decoder / formatter
    (with default settings) is used.
    """
    for instr in decoder.decode_all(data):
        yield instr, formatter.format_instr(instr)


# =========================================================================== #
