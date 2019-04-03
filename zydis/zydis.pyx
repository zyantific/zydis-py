# distutils: language=3
# distutils: include_dirs=ZYDIS_INCLUDES

import cython
from pathlib import Path
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

class DecoderMode(IntEnum):
    MINIMAL = ZYDIS_DECODER_MODE_MINIMAL
    AMD_BRANCHES = ZYDIS_DECODER_MODE_AMD_BRANCHES
    KNC = ZYDIS_DECODER_MODE_KNC
    MPX = ZYDIS_DECODER_MODE_MPX
    CET = ZYDIS_DECODER_MODE_CET
    LZCNT = ZYDIS_DECODER_MODE_LZCNT
    TZCNT = ZYDIS_DECODER_MODE_TZCNT
    WBNOINVD = ZYDIS_DECODER_MODE_WBNOINVD
    CLDEMOTE = ZYDIS_DECODER_MODE_CLDEMOTE


class MachineMode(IntEnum):
    LONG_64 = ZYDIS_MACHINE_MODE_LONG_64
    LONG_COMPAT_32 = ZYDIS_MACHINE_MODE_LONG_COMPAT_32
    LONG_COMPAT_16 = ZYDIS_MACHINE_MODE_LONG_COMPAT_16
    LEGACY_32 = ZYDIS_MACHINE_MODE_LEGACY_32
    LEGACY_16 = ZYDIS_MACHINE_MODE_LEGACY_16
    REAL_16 = ZYDIS_MACHINE_MODE_REAL_16


class AddressWidth(IntEnum):
    B16 = ZYDIS_ADDRESS_WIDTH_16
    B32 = ZYDIS_ADDRESS_WIDTH_32
    B64 = ZYDIS_ADDRESS_WIDTH_64


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


cdef class Decoder:
    cdef ZydisDecoder decoder

    def __cinit__(
        self,
        machine_mode = MachineMode.LONG_64,
        address_width = AddressWidth.B64,
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
        cdef const unsigned char* data_ptr = data
        cdef DecodedInstruction instr = DecodedInstruction()
        raise_if_err(ZydisDecoderDecodeBuffer(
            &self.decoder, data_ptr, len(data), &instr.instr
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

class FormatterStyle(IntEnum):
    ATT = ZYDIS_FORMATTER_STYLE_ATT
    INTEL = ZYDIS_FORMATTER_STYLE_INTEL
    INTEL_MASM = ZYDIS_FORMATTER_STYLE_INTEL_MASM


class FormatterProperty(IntEnum):
    FORCE_SIZE = ZYDIS_FORMATTER_PROP_FORCE_SIZE
    FORCE_SEGMENT = ZYDIS_FORMATTER_PROP_FORCE_SEGMENT
    FORCE_RELATIVE_BRANCHES = ZYDIS_FORMATTER_PROP_FORCE_RELATIVE_BRANCHES
    FORCE_RELATIVE_RIPREL = ZYDIS_FORMATTER_PROP_FORCE_RELATIVE_RIPREL
    PRINT_BRANCH_SIZE = ZYDIS_FORMATTER_PROP_PRINT_BRANCH_SIZE
    DETAILED_PREFIXES = ZYDIS_FORMATTER_PROP_DETAILED_PREFIXES
    ADDR_BASE = ZYDIS_FORMATTER_PROP_ADDR_BASE
    ADDR_SIGNEDNESS = ZYDIS_FORMATTER_PROP_ADDR_SIGNEDNESS
    ADDR_PADDING_ABSOLUTE = ZYDIS_FORMATTER_PROP_ADDR_PADDING_ABSOLUTE
    ADDR_PADDING_RELATIVE = ZYDIS_FORMATTER_PROP_ADDR_PADDING_RELATIVE
    DISP_BASE = ZYDIS_FORMATTER_PROP_DISP_BASE
    DISP_SIGNEDNESS = ZYDIS_FORMATTER_PROP_DISP_SIGNEDNESS
    DISP_PADDING = ZYDIS_FORMATTER_PROP_DISP_PADDING
    IMM_BASE = ZYDIS_FORMATTER_PROP_IMM_BASE
    IMM_SIGNEDNESS = ZYDIS_FORMATTER_PROP_IMM_SIGNEDNESS
    IMM_PADDING = ZYDIS_FORMATTER_PROP_IMM_PADDING
    UPPERCASE_PREFIXES = ZYDIS_FORMATTER_PROP_UPPERCASE_PREFIXES
    UPPERCASE_MNEMONIC = ZYDIS_FORMATTER_PROP_UPPERCASE_MNEMONIC
    UPPERCASE_REGISTERS = ZYDIS_FORMATTER_PROP_UPPERCASE_REGISTERS
    UPPERCASE_TYPECASTS = ZYDIS_FORMATTER_PROP_UPPERCASE_TYPECASTS
    UPPERCASE_DECORATORS = ZYDIS_FORMATTER_PROP_UPPERCASE_DECORATORS
    DEC_PREFIX = ZYDIS_FORMATTER_PROP_DEC_PREFIX
    DEC_SUFFIX = ZYDIS_FORMATTER_PROP_DEC_SUFFIX
    HEX_UPPERCASE = ZYDIS_FORMATTER_PROP_HEX_UPPERCASE
    HEX_PREFIX = ZYDIS_FORMATTER_PROP_HEX_PREFIX
    HEX_SUFFIX = ZYDIS_FORMATTER_PROP_HEX_SUFFIX


class NumericBase(IntEnum):
    DEC = ZYDIS_NUMERIC_BASE_DEC
    HEX = ZYDIS_NUMERIC_BASE_HEX


class Signedness(IntEnum):
    AUTO = ZYDIS_SIGNEDNESS_AUTO
    SIGNED = ZYDIS_SIGNEDNESS_SIGNED
    UNSIGNED = ZYDIS_SIGNEDNESS_UNSIGNED


class Padding(IntEnum):
    DISABLED = ZYDIS_PADDING_DISABLED
    AUTO = ZYDIS_PADDING_AUTO


class FormatterFunction(IntEnum):
    PRE_INSTRUCTION = ZYDIS_FORMATTER_FUNC_PRE_INSTRUCTION
    POST_INSTRUCTION = ZYDIS_FORMATTER_FUNC_POST_INSTRUCTION
    FORMAT_INSTRUCTION = ZYDIS_FORMATTER_FUNC_FORMAT_INSTRUCTION
    PRE_OPERAND = ZYDIS_FORMATTER_FUNC_PRE_OPERAND
    POST_OPERAND = ZYDIS_FORMATTER_FUNC_POST_OPERAND
    FORMAT_OPERAND_REG = ZYDIS_FORMATTER_FUNC_FORMAT_OPERAND_REG
    FORMAT_OPERAND_MEM = ZYDIS_FORMATTER_FUNC_FORMAT_OPERAND_MEM
    FORMAT_OPERAND_PTR = ZYDIS_FORMATTER_FUNC_FORMAT_OPERAND_PTR
    FORMAT_OPERAND_IMM = ZYDIS_FORMATTER_FUNC_FORMAT_OPERAND_IMM
    PRINT_MNEMONIC = ZYDIS_FORMATTER_FUNC_PRINT_MNEMONIC
    PRINT_REGISTER = ZYDIS_FORMATTER_FUNC_PRINT_REGISTER
    PRINT_ADDRESS_ABS = ZYDIS_FORMATTER_FUNC_PRINT_ADDRESS_ABS
    PRINT_ADDRESS_REL = ZYDIS_FORMATTER_FUNC_PRINT_ADDRESS_REL
    PRINT_DISP = ZYDIS_FORMATTER_FUNC_PRINT_DISP
    PRINT_IMM = ZYDIS_FORMATTER_FUNC_PRINT_IMM
    PRINT_TYPECAST = ZYDIS_FORMATTER_FUNC_PRINT_TYPECAST
    PRINT_SEGMENT = ZYDIS_FORMATTER_FUNC_PRINT_SEGMENT
    PRINT_PREFIXES = ZYDIS_FORMATTER_FUNC_PRINT_PREFIXES
    PRINT_DECORATOR = ZYDIS_FORMATTER_FUNC_PRINT_DECORATOR


class Decorator(IntEnum):
    INVALID = ZYDIS_DECORATOR_INVALID
    MASK = ZYDIS_DECORATOR_MASK
    BC = ZYDIS_DECORATOR_BC
    RC = ZYDIS_DECORATOR_RC
    SAE = ZYDIS_DECORATOR_SAE
    SWIZZLE = ZYDIS_DECORATOR_SWIZZLE
    CONVERSION = ZYDIS_DECORATOR_CONVERSION
    EH = ZYDIS_DECORATOR_EH


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
# [Auto generated enums]                                                      #
# =========================================================================== #

cdef make_enum(name, prefix):
    header_dir = '../zydis-c/include/Zydis/Generated'
    file = f'Enum{name}.h'
    path = Path(__file__).parent / header_dir / file

    with path.open('r') as f:
        lines = [x.strip() for x in f]

    prefix_len = len(prefix)
    enum_vals = [
        line[prefix_len:-1]  # -1 cuts away the ,
        for line in lines
        if line.startswith(prefix)
    ]

    assert enum_vals, enum_vals
    return IntEnum(name, enum_vals)


Mnemonic = make_enum('Mnemonic', 'ZYDIS_MNEMONIC_')
ISAExt = make_enum('ISAExt', 'ZYDIS_ISA_EXT_')
ISASet = make_enum('ISASet', 'ZYDIS_ISA_SET_')
InstructionCategory = make_enum('InstructionCategory', 'ZYDIS_CATEGORY_',)
Register = make_enum('Register', 'ZYDIS_REGISTER_')

# =========================================================================== #
