import unittest
from zydis import *


class DecoderTestCase(unittest.TestCase):
    def test_int3(self):
        decoder = Decoder()
        insn = decoder.decode_one(b'\xCC')

        assert insn.length == 1
        assert insn.mnemonic == Mnemonic.INT3
        assert insn.attributes == Attribute.CPUFLAG_ACCESS
        assert insn.explicit_operands == []
        assert len(insn.operands) == 2
        assert insn.opcode == 0xCC
        assert insn.encoding == InstructionEncoding.LEGACY

        meta = insn.meta
        assert meta['category'] == InstructionCategory.INTERRUPT
        assert meta['isa_set'] == ISASet.I86
        assert meta['branch_type'] == BranchType.NONE


