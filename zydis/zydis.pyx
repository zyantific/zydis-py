# distutils: language=3
# distutils: include_dirs=ZYDIS_INCLUDES

from ffi cimport *
from enum import IntEnum

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

cdef class DecodedInstruction:
    cdef ZydisDecodedInstruction instr

    @property
    def length(self):
        return self.instr.length


cdef class Decoder:
    cdef ZydisDecoder decoder

    def __cinit__(
        self,
        ZydisMachineMode machine_mode = ZYDIS_MACHINE_MODE_LONG_64,
        ZydisAddressWidth address_width = ZYDIS_ADDRESS_WIDTH_64,
    ):
        raise_if_err(ZydisDecoderInit(
            &self.decoder,
            machine_mode,
            address_width,
        ))

    cpdef DecodedInstruction decode_one(self, bytes data):
        cdef const unsigned char* data_ptr = data
        cdef DecodedInstruction instr = DecodedInstruction()
        raise_if_err(ZydisDecoderDecodeBuffer(
            &self.decoder, data_ptr, len(data), &instr.instr
        ))
        return instr

    def decode_all(self, bytes data):
        while len(data) != 0:
            insn = self.decode_one(data)
            data = data[insn.length:]
            yield insn

    def decode_and_format_all(
        self,
        bytes data,
        Formatter formatter = Formatter(),
    ):
        for insn in self.decode_all(data):
            yield insn, formatter.format(insn)

# =========================================================================== #
# [Decoder]                                                                   #
# =========================================================================== #

cdef class Formatter:
    cdef ZydisFormatter formatter

    def __cinit__(
        self,
        ZydisFormatterStyle style = ZYDIS_FORMATTER_STYLE_INTEL,
    ):
        raise_if_err(ZydisFormatterInit(&self.formatter, style))

    cpdef str format(self, DecodedInstruction instr):
        cdef char[256] buffer
        raise_if_err(ZydisFormatterFormatInstruction(
            &self.formatter, &instr.instr, buffer, sizeof(buffer), 0
        ))
        return buffer.decode('utf8')

# =========================================================================== #
