# distutils: language=3
# distutils: include_dirs=ZYDIS_INCLUDES

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
        return self.status & 0xFFFFF

    def __str__(self):
        return (
            f'success: {self.success}, module: {self.module}, '
            f'code: {self.code}'
        )

    def __repr__(self):
        return f'StatusCode({self.status})'


cdef class ZydisError(Exception):
    cpdef StatusCode code

    def __cinit__(self, StatusCode code):
        self.code = code

    def __str__(self):
        return f'Zydis error: {self.code!s}'

    def __repr__(self):
        return f'<ZydisError({self.code!r})>'


cdef inline int raise_if_err(ZyanStatus status) except -1:
    if is_success(status):
        return 0
    raise ZydisError(StatusCode(status))

# =========================================================================== #
# [Decoder]                                                                   #
# =========================================================================== #


@cython.freelist(16)
cdef class Operand:
    cdef DecodedInstruction instr
    cdef int index

    def __cinit__(self, instr, index):
        self.instr = instr
        self.index = index

    def __str__(self):
        return STATIC_FORMATTER.format_operand(self)


@cython.freelist(16)
cdef class DecodedInstruction:
    cdef ZydisDecodedInstruction instr

    @property
    def mnemonic(self):
        return self.instr.mnemonic

    @property
    def length(self):
        return self.instr.length

    @property
    def opcode(self):
        return self.instr.opcode

    @property
    def stack_width(self):
        return self.instr.stack_width

    @property
    def operand_width(self):
        return self.instr.stack_width

    @property
    def address_width(self):
        return self.instr.address_width

    @property
    def attributes(self):
        return self.instr.attributes

    @property
    def operands(self):
        return [Operand(self, i) for i in range(self.instr.operand_count)]

    def __str__(self):
        return STATIC_FORMATTER.format_instr(self)

    def __repr__(self):
        instr_txt = STATIC_FORMATTER.format_instr(self)
        return f'<{self.__class__.__name__} "{instr_txt}" at 0x{id(self):x}>'


cdef class Decoder:
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
        raise_if_err(ZydisDecoderEnableMode(
            &self.decoder, mode.value, enabled
        ))

    cpdef DecodedInstruction decode_one(self, bytes data):
        cdef DecodedInstruction instr = DecodedInstruction()
        raise_if_err(ZydisDecoderDecodeBuffer(
            &self.decoder,
            <const unsigned char*>data,
            len(data),
            &instr.instr,
        ))
        return instr

    def decode_all(self, bytes data):
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


cdef class Formatter:
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
):
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
