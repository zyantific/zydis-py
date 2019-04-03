from pycparser import c_parser, c_ast, parse_file, c_generator
import os
import sys


ast = parse_file(
    '../zydis-c/include/Zydis/Zydis.h',
    use_cpp=True,
    cpp_path='gcc', cpp_args=[
        '-E',
        '-I../zydis',
        '-I../zydis-c/include',
        '-I../zydis-c/dependencies/zycore/include',
        '-Ipycparser/utils/fake_libc_include',
    ]
)

cgen = c_generator.CGenerator()


class CSharpEnumVisitor(c_ast.NodeVisitor):
    def visit_Enum(self, node):
        enum_list = node.children()[0][1]
        enum_vals = enum_list.enumerators
        common_prefix = os.path.commonprefix([x.name for x in enum_vals])
        print(f'public enum {node.name[:-1]}')
        print('{')
        for val in enum_vals:
            if val.name.endswith('_REQUIRED_BITS'):
                continue

            xval = ''
            if val.value:
                expr = cgen.visit(val.value)
                expr = expr.replace(common_prefix, '')
                xval = f' = {expr}'

            print(f'    {val.name[len(common_prefix):]}{xval},')

        print('}\n')


class CythonPxdEnumVisitor(c_ast.NodeVisitor):
    def visit_Enum(self, node):
        enum_list = node.children()[0][1]
        enum_vals = enum_list.enumerators

        print(f'    ctypedef enum {node.name[:-1]}:')
        for val in enum_vals:
            if val.name.endswith('_REQUIRED_BITS'):
                continue
            print(f'        {val.name}')
        print('')


# non-exhaustive, ...
PY_KEYWORDS = ['if', 'for', 'while']


class CythonPyxEnumVisitor(c_ast.NodeVisitor):
    def visit_Enum(self, node):
        enum_list = node.children()[0][1]
        enum_vals = enum_list.enumerators
        common_prefix = os.path.commonprefix([x.name for x in enum_vals])
        assert node.name[:5] == 'Zydis'
        print(f'class {node.name[5:-1]}(IntEnum):')
        for val in enum_vals:
            if val.name.endswith('_REQUIRED_BITS'):
                continue
            short_name = val.name[len(common_prefix):]
            if short_name[0].isdigit() or short_name.lower() in PY_KEYWORDS:
                short_name = f'_{short_name}'
            print(f'    {short_name} = {val.name}')
        print('')


if sys.argv[1] == 'cs':
    CSharpEnumVisitor().visit(ast)
elif sys.argv[1] == 'pyx':
    print('# THIS FILE IS AUTO-GENERATED USING utils/genenums.py!')
    print('# distutils: language=3')
    print('# distutils: include_dirs=ZYDIS_INCLUDES\n')
    print('from enum import IntEnum')
    print('from .cenums cimport *\n')
    vis = CythonPyxEnumVisitor()
    vis.visit(ast)
elif sys.argv[1] == 'pxd':
    print('# THIS FILE IS AUTO-GENERATED USING utils/genenums.py!\n')
    print('cdef extern from "Zydis/Zydis.h":')
    CythonPxdEnumVisitor().visit(ast)
else:
    assert False
