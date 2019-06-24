import unittest
from zydis import *


class FormatterTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.insn = Decoder().decode_one(b'\xB8\x37\x13\x00\x00')
        self.formatter = Formatter()

    def test_format_insn(self):
        insn = self.formatter.format_instr(self.insn)
        assert insn == 'mov eax, 0x1337'

    def test_format_op1(self):
        op1 = self.formatter.format_operand(self.insn.operands[0])
        assert op1 == 'eax'

    def test_format_op2(self):
        op1 = self.formatter.format_operand(self.insn.operands[1])
        assert op1 == '0x1337'
